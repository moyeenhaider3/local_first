import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const recordAgreementConsent = functions.https.onCall(async (data, context) => {
  // 1. Auth check
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }

  const { agreementId, consentVersion, contentHash } = data;

  if (!agreementId || !consentVersion || !contentHash) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing required arguments: agreementId, consentVersion, contentHash."
    );
  }

  const db = admin.firestore();
  const userId = context.auth.uid;

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

  // 3. Auth: only participants
  if (userId !== agreementData.initiatorId && userId !== agreementData.counterpartyId) {
    throw new functions.https.HttpsError("permission-denied", "Only agreement participants can consent.");
  }

  // 4. Verify agreement status
  if (agreementData.status !== "draft" && agreementData.status !== "negotiating" && agreementData.status !== "pendingConsent") {
    throw new functions.https.HttpsError("failed-precondition", `Cannot record consent in status: ${agreementData.status}`);
  }

  // 5. Verify the content hash matches current agreement
  if (agreementData.contentHash !== contentHash) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Content hash mismatch. The agreement has been modified since your last review."
    );
  }

  // 6. Verify consent version matches
  if (agreementData.version !== consentVersion) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Consent version mismatch. A newer version exists."
    );
  }

  // 7. Write consent record
  const consentRecordRef = db.collection("consent_records").doc();

  const consentEvidence = {
    agreementId: agreementId,
    userId: userId,
    consentVersion: consentVersion,
    contentHash: contentHash,
    consentedAt: admin.firestore.FieldValue.serverTimestamp(),
    ipAddress: context.rawRequest?.ip || "unknown",
    userAgent: context.rawRequest?.headers?.["user-agent"] || "unknown",
  };

  // 8. Determine which party is consenting
  const isInitiator = userId === agreementData.initiatorId;
  const consentField = isInitiator ? "initiatorConsentStatus" : "counterpartyConsentStatus";
  const otherConsentField = isInitiator ? "counterpartyConsentStatus" : "initiatorConsentStatus";

  await db.runTransaction(async (transaction) => {
    // Re-read agreement in transaction
    const freshAgreementDoc = await transaction.get(agreementRef);
    const freshData = freshAgreementDoc.data();

    if (!freshData) {
      throw new functions.https.HttpsError("not-found", "Agreement data not found in transaction.");
    }

    // Write consent record
    transaction.set(consentRecordRef, consentEvidence);

    // Update agreement consent status
    const updatePayload: Record<string, unknown> = {
      [consentField]: "consented",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    // Check if both parties have now consented
    const otherStatus = freshData[otherConsentField];
    if (otherStatus === "consented") {
      // Both consented → activate the agreement
      updatePayload.status = "confirmed";
    } else {
      updatePayload.status = "pendingConsent";
    }

    transaction.update(agreementRef, updatePayload);

    // If both consented, also update listing status to 'reserved'
    if (otherStatus === "consented") {
      const listingRef = db.collection("listings").doc(freshData.listingId);
      transaction.update(listingRef, {
        status: "reserved",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  });

  return { consentRecordId: consentRecordRef.id };
});
