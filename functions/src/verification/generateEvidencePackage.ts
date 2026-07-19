import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Extracts storage path from a gs:// or https:// firebasestorage.googleapis.com URL.
 */
function getStoragePathFromUrl(url: string): string | null {
  if (!url) return null;
  if (url.startsWith("gs://")) {
    const parts = url.split("/");
    return parts.slice(3).join("/");
  }
  if (url.includes("firebasestorage.googleapis.com")) {
    try {
      const matches = url.match(/\/o\/([^?#]+)/);
      if (matches && matches[1]) {
        return decodeURIComponent(matches[1]);
      }
    } catch (e) {
      console.error("Failed to parse URL:", url, e);
    }
  }
  return null;
}

/**
 * Generates a 1-hour signed URL for a given Firebase Storage file path or URL.
 */
async function generateSignedUrl(urlOrPath: string): Promise<string> {
  const path = getStoragePathFromUrl(urlOrPath) || urlOrPath;
  if (
    (path.startsWith("http://") || path.startsWith("https://")) &&
    !urlOrPath.includes("firebasestorage.googleapis.com")
  ) {
    return urlOrPath;
  }
  try {
    const bucket = admin.storage().bucket();
    const file = bucket.file(path);
    const [signedUrl] = await file.getSignedUrl({
      action: "read",
      expires: Date.now() + 60 * 60 * 1000, // 1 hour
    });
    return signedUrl;
  } catch (e) {
    console.error("Failed to generate signed URL for path:", path, e);
    return urlOrPath; // Fallback to original URL
  }
}

/**
 * Recursively searches an object/array and signs all Firebase Storage URLs.
 */
async function signAllUrlsInObject(obj: any): Promise<any> {
  if (obj === null || obj === undefined) return obj;
  if (typeof obj === "string") {
    if (obj.startsWith("gs://") || obj.includes("firebasestorage.googleapis.com")) {
      return await generateSignedUrl(obj);
    }
    return obj;
  }
  if (Array.isArray(obj)) {
    return await Promise.all(obj.map((item) => signAllUrlsInObject(item)));
  }
  if (typeof obj === "object") {
    // If it is a Firestore Timestamp or other special object, do not traverse
    if (obj.constructor && obj.constructor.name === "Timestamp") {
      return obj;
    }
    const res: Record<string, any> = {};
    for (const key of Object.keys(obj)) {
      res[key] = await signAllUrlsInObject(obj[key]);
    }
    return res;
  }
  return obj;
}

export const generateEvidencePackage = functions.https.onCall(async (data, context) => {
  // 1. Auth check
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }

  const { agreementId } = data;
  if (!agreementId) {
    throw new functions.https.HttpsError("invalid-argument", "Missing required argument: agreementId.");
  }

  const db = admin.firestore();
  const callerId = context.auth.uid;

  // 2. Fetch agreement
  const agreementRef = db.collection("agreements").doc(agreementId);
  const agreementDoc = await agreementRef.get();

  if (!agreementDoc.exists) {
    throw new functions.https.HttpsError("not-found", `Agreement not found: ${agreementId}`);
  }

  const agreementData = agreementDoc.data();
  if (!agreementData) {
    throw new functions.https.HttpsError("not-found", "Agreement data is empty.");
  }

  // 3. Validation: Caller must be agreement participant
  const initiatorId = agreementData.initiatorId;
  const counterpartyId = agreementData.counterpartyId;

  if (callerId !== initiatorId && callerId !== counterpartyId) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only participants of this agreement can generate the evidence package."
    );
  }

  // 4. Validation: Status check
  if (agreementData.status !== "damageDisputed") {
    throw new functions.https.HttpsError(
      "failed-precondition",
      `Evidence package can only be generated when the agreement is in status 'damageDisputed'. Current status: ${agreementData.status}`
    );
  }

  // 5. Gather evidence data parallelly
  const versionsPromise = agreementRef.collection("versions").get();
  const consentRecordsPromise = db
    .collection("consent_records")
    .where("agreementId", "==", agreementId)
    .get();
  const timelineEventsPromise = db
    .collection("timeline_events")
    .where("agreementId", "==", agreementId)
    .get();
  const disputesPromise = db
    .collection("disputes")
    .where("agreementId", "==", agreementId)
    .get();

  // The renter is the initiatorId
  const renterKycPromise = db.collection("kyc_records").doc(initiatorId).get();

  const [
    versionsSnap,
    consentRecordsSnap,
    timelineEventsSnap,
    disputesSnap,
    renterKycDoc,
  ] = await Promise.all([
    versionsPromise,
    consentRecordsPromise,
    timelineEventsPromise,
    disputesPromise,
    renterKycPromise,
  ]);

  // Map snap results to array of data objects
  const versions = versionsSnap.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  const consentRecords = consentRecordsSnap.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  const timelineEvents = timelineEventsSnap.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  const disputes = disputesSnap.docs.map((doc) => ({ id: doc.id, ...doc.data() }));

  const renterKycData = renterKycDoc.exists ? renterKycDoc.data() : null;

  // 6. Recursively find and sign all storage URLs inside all collected objects
  const signedAgreement = await signAllUrlsInObject(agreementData);
  const signedVersions = await signAllUrlsInObject(versions);
  const signedConsentRecords = await signAllUrlsInObject(consentRecords);
  const signedTimelineEvents = await signAllUrlsInObject(timelineEvents);
  const signedDisputes = await signAllUrlsInObject(disputes);
  const signedRenterKyc = renterKycData ? await signAllUrlsInObject(renterKycData) : null;

  // Return the complete structured package along with legal recourse guidance certificate
  return {
    agreement: signedAgreement,
    versions: signedVersions,
    consentRecords: signedConsentRecords,
    timelineEvents: signedTimelineEvents,
    disputes: signedDisputes,
    renterKyc: signedRenterKyc,
    legalNoticeGuidance: {
      platform: "Local First",
      certificateTitle: "Local First Digital Evidence Package & Statutory Legal Recourse Certificate",
      statutoryProvisions: {
        digitalEvidenceAdmissibility: "Bharatiya Sakshya Adhiniyam (BSA), 2023 - Section 63 & Information Technology Act, 2000 - Section 10A",
        civilRecoveryOfProperty: "Specific Relief Act, 1963 - Section 7 (Recovery of specific movable property) & CPC Order 37",
        criminalBreachOfTrust: "Bharatiya Nyaya Sanhita (BNS), 2023 - Section 316 & Section 318 (Criminal Breach of Trust & Misappropriation)",
      },
      recommendedAvenues: [
        "1. Pre-Litigation Legal Notice: Send a formal advocate notice demanding item return or monetary settlement within 7-15 days.",
        "2. Civil Suit for Recovery: File a recovery suit under Section 7 of the Specific Relief Act, 1963 in Civil Court for item recovery or financial damages.",
        "3. Police FIR / Complaint: File an FIR under BNS Sections 316/318 (Criminal Breach of Trust) at the local police station attaching this evidence package.",
      ],
    },
  };
});

