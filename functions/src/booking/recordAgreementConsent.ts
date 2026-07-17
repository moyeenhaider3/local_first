import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as crypto from "crypto";
import { activateAgreementAfterConsent } from "./activateAgreementAfterConsent";

export const recordAgreementConsent = onCall(async (request) => {
  // 1. Auth check
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  const data = request.data;
  const { agreementId } = data;
  const signature = data.signature || {};

  const fullName = data.fullName || signature.fullName;
  const deviceInfo = data.deviceInfo || signature.deviceInfo || "";
  const appVersion = data.appVersion || signature.appVersion || "";

  if (!agreementId || !fullName) {
    throw new HttpsError("invalid-argument", "Missing required arguments: agreementId and fullName.");
  }

  const db = admin.firestore();

  // 2. Fetch agreement
  const agreementRef = db.collection("agreements").doc(agreementId);
  const agreementDoc = await agreementRef.get();

  if (!agreementDoc.exists) {
    throw new HttpsError("not-found", `Agreement not found: ${agreementId}`);
  }

  const agreementData = agreementDoc.data();
  if (!agreementData) {
    throw new HttpsError("not-found", "Agreement data is empty.");
  }

  const currentUserId = request.auth.uid;

  // 3. Validation: Caller must be a participant
  const isInitiator = currentUserId === agreementData.initiatorId;
  const isCounterparty = currentUserId === agreementData.counterpartyId;

  if (!isInitiator && !isCounterparty) {
    throw new HttpsError("permission-denied", "User is not a participant in this agreement.");
  }

  // 4. Auto-generate Version 1 if in draft or version is 0
  let currentVersion = agreementData.version || 0;
  let currentHash = agreementData.contentHash || "";

  if (agreementData.status === "draft" || currentVersion === 0 || !currentHash) {
    currentVersion = 1;
    
    // Convert timestamps to ISO string strings for canonical representation
    const startStr = agreementData.startDate 
      ? new Date(agreementData.startDate.toDate()).toISOString() 
      : "";
    const endStr = agreementData.endDate 
      ? new Date(agreementData.endDate.toDate()).toISOString() 
      : "";

    const terms = {
      agreementId,
      dailyRate: Number(agreementData.dailyRate || 0),
      depositAmount: Number(agreementData.depositAmount || 0),
      durationDays: Number(agreementData.durationDays || 0),
      endDate: endStr,
      startDate: startStr,
      totalAmount: Number(agreementData.totalAmount || 0),
    };
    
    const canonicalTermsJson = JSON.stringify(terms);
    currentHash = crypto.createHash("sha256").update(canonicalTermsJson).digest("hex");

    const versionRef = agreementRef.collection("versions").doc("1");

    await db.runTransaction(async (transaction) => {
      transaction.set(versionRef, {
        agreementId,
        version: 1,
        totalAmount: agreementData.totalAmount,
        depositAmount: agreementData.depositAmount,
        dailyRate: agreementData.dailyRate,
        startDate: agreementData.startDate,
        endDate: agreementData.endDate,
        durationDays: agreementData.durationDays,
        contentHash: currentHash,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      transaction.update(agreementRef, {
        version: 1,
        contentHash: currentHash,
        status: "awaitingConsent",
        initiatorConsentStatus: "pending",
        counterpartyConsentStatus: "pending",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });
  }

  // 5. If specific version or contentHash is requested to validate, check them
  if (data.version !== undefined && data.version !== currentVersion) {
    throw new HttpsError("failed-precondition", `Agreement version mismatch. Current version: ${currentVersion}`);
  }
  if (data.contentHash !== undefined && data.contentHash !== currentHash) {
    throw new HttpsError("failed-precondition", "Agreement terms content hash mismatch.");
  }

  // 6. Generate device info hash
  const deviceIdHash = deviceInfo 
    ? crypto.createHash("sha256").update(deviceInfo).digest("hex") 
    : "";

  const consentRecordRef = db.collection("consent_records").doc();
  const consentRecordPayload = {
    userId: currentUserId,
    agreementId,
    version: currentVersion,
    contentHash: currentHash,
    fullName,
    deviceIdHash,
    appVersion,
    serverTimestamp: admin.firestore.FieldValue.serverTimestamp(),
    authenticationContext: {
      uid: currentUserId,
      phone: request.auth.token.phone_number || signature.phone || "",
    },
    checkboxAcknowledgments: true,
    consentLanguageVersion: "v1.0",
  };

  const consentField = isInitiator ? "initiatorConsentStatus" : "counterpartyConsentStatus";

  // 7. DB Transaction: Record consent + update agreement status
  await db.runTransaction(async (transaction) => {
    transaction.set(consentRecordRef, consentRecordPayload);
    transaction.update(agreementRef, {
      [consentField]: "accepted",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  // 8. Re-fetch agreement to see if both parties have consented
  const updatedDoc = await agreementRef.get();
  const updatedData = updatedDoc.data();

  if (updatedData && updatedData.initiatorConsentStatus === "accepted" && updatedData.counterpartyConsentStatus === "accepted") {
    await activateAgreementAfterConsent(agreementId, db);
  }

  return { success: true, consentRecordId: consentRecordRef.id };
});
