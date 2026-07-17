import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as crypto from "crypto";

export const generateAgreementVersion = onCall(async (request) => {
  // 1. Auth check
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  const data = request.data;
  const {
    agreementId,
    totalAmount,
    depositAmount,
    dailyRate,
    startDate,
    endDate,
    durationDays,
  } = data;

  if (!agreementId || totalAmount === undefined || depositAmount === undefined || dailyRate === undefined || !startDate || durationDays === undefined) {
    throw new HttpsError("invalid-argument", "Missing required arguments.");
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

  // 3. Validation: Caller must be a participant
  if (request.auth.uid !== agreementData.initiatorId && request.auth.uid !== agreementData.counterpartyId) {
    throw new HttpsError("permission-denied", "User is not a participant in this agreement.");
  }

  // 4. Parse Dates to canonical ISO strings for hashing, and Firestore Timestamps for storage
  const startObj = new Date(startDate);
  const endObj = endDate ? new Date(endDate) : null;
  
  const startStr = startObj.toISOString();
  const endStr = endObj ? endObj.toISOString() : "";

  // 5. Generate contentHash (canonical terms JSON order: alphabetical key sort)
  const terms = {
    agreementId,
    dailyRate: Number(dailyRate),
    depositAmount: Number(depositAmount),
    durationDays: Number(durationDays),
    endDate: endStr,
    startDate: startStr,
    totalAmount: Number(totalAmount),
  };
  const canonicalTermsJson = JSON.stringify(terms);
  const contentHash = crypto.createHash("sha256").update(canonicalTermsJson).digest("hex");

  const currentVersion = agreementData.version || 0;
  const nextVersion = currentVersion + 1;

  // 6. DB Transaction to write version snapshot and update parent agreement doc
  const versionRef = agreementRef.collection("versions").doc(nextVersion.toString());

  await db.runTransaction(async (transaction) => {
    transaction.set(versionRef, {
      agreementId,
      version: nextVersion,
      totalAmount,
      depositAmount,
      dailyRate,
      startDate: admin.firestore.Timestamp.fromDate(startObj),
      endDate: endObj ? admin.firestore.Timestamp.fromDate(endObj) : null,
      durationDays,
      contentHash,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    transaction.update(agreementRef, {
      version: nextVersion,
      totalAmount,
      depositAmount,
      dailyRate,
      startDate: admin.firestore.Timestamp.fromDate(startObj),
      endDate: endObj ? admin.firestore.Timestamp.fromDate(endObj) : null,
      durationDays,
      contentHash,
      status: "awaitingConsent",
      initiatorConsentStatus: "pending",
      counterpartyConsentStatus: "pending",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return { version: nextVersion, contentHash };
});
