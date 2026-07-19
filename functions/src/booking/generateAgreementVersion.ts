import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { createHash } from "crypto";

export const generateAgreementVersion = functions.https.onCall(async (data, context) => {
  // 1. Auth check
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }

  const { agreementId, terms } = data;

  if (!agreementId || !terms) {
    throw new functions.https.HttpsError("invalid-argument", "Missing required arguments: agreementId, terms.");
  }

  const db = admin.firestore();

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
  const userId = context.auth.uid;
  if (userId !== agreementData.initiatorId && userId !== agreementData.counterpartyId) {
    throw new functions.https.HttpsError("permission-denied", "Only agreement participants can generate versions.");
  }

  // 4. Status must be 'draft' or 'negotiating'
  if (agreementData.status !== "draft" && agreementData.status !== "negotiating") {
    throw new functions.https.HttpsError("failed-precondition", `Cannot generate version in status: ${agreementData.status}`);
  }

  // 5. Calculate SHA256 content hash
  const termsString = JSON.stringify(terms);
  const contentHash = createHash("sha256").update(termsString).digest("hex");

  // 6. Increment version number
  const newVersion = (agreementData.version || 0) + 1;

  // 7. Write version snapshot and update agreement
  const versionRef = agreementRef.collection("versions").doc(`v${newVersion}`);

  await db.runTransaction(async (transaction) => {
    transaction.set(versionRef, {
      version: newVersion,
      terms: terms,
      contentHash: contentHash,
      generatedBy: userId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    transaction.update(agreementRef, {
      version: newVersion,
      contentHash: contentHash,
      status: "negotiating",
      initiatorConsentStatus: "pending",
      counterpartyConsentStatus: "pending",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return { version: newVersion, contentHash };
});
