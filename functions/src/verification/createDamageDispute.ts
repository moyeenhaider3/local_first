import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { sendNotification } from "../notifications/sendNotification";

export const createDamageDispute = functions.https.onCall(async (data, context) => {
  // 1. Auth check
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }

  const { agreementId, disputeType, description, photoUrls } = data;
  if (!agreementId || !disputeType || !description || !Array.isArray(photoUrls)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing or invalid required arguments: agreementId, disputeType, description, photoUrls."
    );
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
      "Only participants of this agreement can raise disputes."
    );
  }

  // 4. Validation: Status check
  const allowedStatuses = ["active", "returnPending", "itemReturned"];
  if (!allowedStatuses.includes(agreementData.status)) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      `Cannot open a dispute for an agreement in status: ${agreementData.status}`
    );
  }

  // 5. Determine counterparty
  const otherPartyId = callerId === initiatorId ? counterpartyId : initiatorId;

  const disputeRef = db.collection("disputes").doc();
  const timelineEventRef = db.collection("timeline_events").doc();

  // 6. DB Updates using Batch
  const batch = db.batch();

  batch.update(agreementRef, {
    status: "damageDisputed",
    kycUnlockedForUserId: callerId,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  batch.set(disputeRef, {
    agreementId,
    openedBy: callerId,
    disputeType,
    description,
    photoUrls,
    status: "open",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  batch.set(timelineEventRef, {
    agreementId,
    eventType: "dispute_created",
    description: "Damage dispute opened",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  await batch.commit();

  // 7. Send FCM notification to counterparty
  await sendNotification(
    otherPartyId,
    "Dispute Filed",
    `A damage dispute has been filed for agreement #${agreementId}`
  );

  return { disputeId: disputeRef.id };
});
