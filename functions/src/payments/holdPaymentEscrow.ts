import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { sendNotification } from "../notifications/sendNotification";

/**
 * Cloud Function to hold payment in escrow server-authoritatively.
 * Validates agreement, calculates 5% platform fee & 95% owner payout,
 * writes payment & escrow records, and sends FCM notification to the owner.
 */
export const holdPaymentEscrow = functions.https.onCall(async (data, context) => {
  // 1. Verify user authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to hold payment in escrow."
    );
  }

  const { agreementId, amount, paymentMethod, remarks, proofUrl } = data;

  // 2. Validate mandatory parameters
  if (!agreementId || typeof amount !== "number" || amount <= 0) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing or invalid parameters: agreementId and a positive amount are required."
    );
  }

  const db = admin.firestore();

  // 3. Fetch associated agreement document
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

  // 4. Check caller authorization: caller must be initiator (renter) or counterparty (owner)
  const callerId = context.auth.uid;
  const initiatorId = agreementData.initiatorId;
  const counterpartyId = agreementData.counterpartyId;

  if (callerId !== initiatorId && callerId !== counterpartyId) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Caller is not a participant in this agreement."
    );
  }

  // Renter is initiatorId, Owner is counterpartyId
  const renterId = initiatorId;
  const ownerId = counterpartyId;

  // 5. Calculate split payment amounts (5% platform fee, 95% owner payout)
  // Round to 2 decimal places using standard financial computation
  const platformFeeRate = 0.05;
  const platformFee = Math.round(amount * platformFeeRate * 100) / 100;
  const ownerPayout = Math.round((amount - platformFee) * 100) / 100;

  // 6. Write payment document to 'payments' collection and escrow document to 'escrows'
  const paymentRef = db.collection("payments").doc();
  const escrowRef = db.collection("escrows").doc(agreementId);

  const batch = db.batch();

  const now = admin.firestore.FieldValue.serverTimestamp();

  // Payment document structure matching Flutter PaymentModel
  batch.set(paymentRef, {
    agreementId,
    renterId,
    ownerId,
    totalAmount: amount,
    amountPaid: amount,
    remarks: remarks || null,
    proofUrl: proofUrl || null,
    platformFee,
    ownerPayout,
    currency: "INR",
    status: "escrowHeld",
    paymentMethod: paymentMethod || "Escrow",
    transactionId: `txn_${Date.now()}_${Math.floor(Math.random() * 1000)}`,
    createdAt: now,
    releasedAt: null,
  });

  // Escrow document structure matching Flutter EscrowModel
  batch.set(escrowRef, {
    agreementId,
    renterId,
    ownerId,
    totalHeld: amount,
    status: "held",
    heldAt: now,
    resolvedAt: null,
  });

  // Update agreement status to paymentDeclared so counterparty can verify it
  batch.update(agreementRef, {
    status: "paymentDeclared",
    updatedAt: now,
  });

  await batch.commit();

  // 7. Send FCM notification to item/service owner
  await sendNotification(
    ownerId,
    "Payment Escrow Held",
    `Payment of ₹${amount} is now locked in Local First escrow.`
  );

  return {
    success: true,
    paymentId: paymentRef.id,
    escrowId: escrowRef.id,
    platformFee,
    ownerPayout,
  };
});
