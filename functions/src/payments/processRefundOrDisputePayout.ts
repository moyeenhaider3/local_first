import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { sendNotification } from "../notifications/sendNotification";

/**
 * Cloud Function to process refund or dispute payout for an agreement escrow.
 * Server-authoritatively updates payment/escrow records and notifies renter & owner via FCM.
 */
export const processRefundOrDisputePayout = functions.https.onCall(async (data, context) => {
  // 1. Verify user authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to process refund or dispute payouts."
    );
  }

  const { agreementId, refundAmount, reason, action = "refund" } = data;

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

  // 4. Verify caller authorization: participant or system
  const callerId = context.auth.uid;
  const initiatorId = agreementData.initiatorId;
  const counterpartyId = agreementData.counterpartyId;

  if (callerId !== initiatorId && callerId !== counterpartyId) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Caller is not a participant in this agreement."
    );
  }

  const renterId = initiatorId;
  const ownerId = counterpartyId;

  // 5. Query matching payment record
  const paymentsSnapshot = await db
    .collection("payments")
    .where("agreementId", "==", agreementId)
    .limit(1)
    .get();

  const now = admin.firestore.FieldValue.serverTimestamp();
  const batch = db.batch();

  const escrowRef = db.collection("escrows").doc(agreementId);
  const escrowDoc = await escrowRef.get();

  if (action === "dispute") {
    // Action is freezing payout due to an active dispute
    if (!paymentsSnapshot.empty) {
      batch.update(paymentsSnapshot.docs[0].ref, {
        status: "disputed",
      });
    }

    if (escrowDoc.exists) {
      batch.update(escrowRef, {
        status: "disputeFrozen",
      });
    }

    await batch.commit();

    // Send FCM notifications to both renter and owner
    await sendNotification(
      renterId,
      "Payment Frozen",
      "Escrow payment has been frozen pending dispute resolution."
    );
    await sendNotification(
      ownerId,
      "Payment Frozen",
      "Escrow payment has been frozen pending dispute resolution."
    );

    return { success: true, status: "disputed" };
  } else {
    // Action is processing a full or partial refund
    const effectiveRefundAmount = typeof refundAmount === "number" ? refundAmount : (paymentsSnapshot.empty ? 0 : paymentsSnapshot.docs[0].data().totalAmount);

    if (!paymentsSnapshot.empty) {
      batch.update(paymentsSnapshot.docs[0].ref, {
        status: "refunded",
        releasedAt: now,
      });
    }

    if (escrowDoc.exists) {
      batch.update(escrowRef, {
        status: "refundedToRenter",
        resolvedAt: now,
      });
    }

    await batch.commit();

    // Send FCM push notifications regarding resolution
    await sendNotification(
      renterId,
      "Refund Processed",
      `Refund of ₹${effectiveRefundAmount} has been processed for your booking.`
    );
    await sendNotification(
      ownerId,
      "Refund Notice",
      `Payment update: Refund of ₹${effectiveRefundAmount} was processed due to: ${reason || "dispute resolution"}.`
    );

    return { success: true, status: "refunded", refundAmount: effectiveRefundAmount };
  }
});
