import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { sendNotification } from "../notifications/sendNotification";

/**
 * Cloud Function to release escrow payment payout to owner.
 * Server-authoritatively verifies authorization, updates payment & escrow records,
 * and notifies owner via FCM.
 */
export const releasePaymentPayout = functions.https.onCall(async (data, context) => {
  // 1. Verify user authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to release payment payout."
    );
  }

  const { agreementId } = data;

  // 2. Validate parameters
  if (!agreementId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing required parameter: agreementId."
    );
  }

  const db = admin.firestore();

  // 3. Fetch agreement document
  const agreementRef = db.collection("agreements").doc(agreementId);
  const agreementDoc = await agreementRef.get();

  if (!agreementDoc.exists) {
    throw new functions.https.HttpsError(
      "not-found",
      `Agreement with ID ${agreementId} was not found.`
    );
  }

  const agreementData = agreementDoc.data();
  if (!agreementData) {
    throw new functions.https.HttpsError("not-found", "Agreement data is empty.");
  }

  // 4. Verify caller authorization: caller must be participant in agreement
  const callerId = context.auth.uid;
  const initiatorId = agreementData.initiatorId;
  const counterpartyId = agreementData.counterpartyId;

  if (callerId !== initiatorId && callerId !== counterpartyId) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Caller is not a participant in this agreement."
    );
  }

  const ownerId = counterpartyId;

  // 5. Query associated payment record
  const paymentsSnapshot = await db
    .collection("payments")
    .where("agreementId", "==", agreementId)
    .limit(1)
    .get();

  if (paymentsSnapshot.empty) {
    throw new functions.https.HttpsError(
      "not-found",
      `No payment record found for agreement ID ${agreementId}.`
    );
  }

  const paymentDoc = paymentsSnapshot.docs[0];
  const paymentData = paymentDoc.data();

  if (paymentData.status === "payoutReleased") {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Payout for this agreement has already been released."
    );
  }

  // 6. Fetch escrow document
  const escrowRef = db.collection("escrows").doc(agreementId);
  const escrowDoc = await escrowRef.get();

  const now = admin.firestore.FieldValue.serverTimestamp();
  const batch = db.batch();

  // Update Payment record
  batch.update(paymentDoc.ref, {
    status: "payoutReleased",
    releasedAt: now,
  });

  // Update Escrow record
  if (escrowDoc.exists) {
    batch.update(escrowRef, {
      status: "releasedToOwner",
      resolvedAt: now,
    });
  }

  await batch.commit();

  // 7. Send FCM notification to item/service owner
  const ownerPayout = paymentData.ownerPayout ?? (paymentData.totalAmount * 0.95);
  await sendNotification(
    ownerId,
    "Payout Released!",
    `Payout of ₹${ownerPayout} has been released to your account!`
  );

  return {
    success: true,
    agreementId,
    ownerPayout,
  };
});
