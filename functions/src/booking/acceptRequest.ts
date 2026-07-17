import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

export const acceptRequest = onCall(async (request) => {
  // 1. Auth check
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  const data = request.data;
  const { requestId } = data;

  if (!requestId) {
    throw new HttpsError("invalid-argument", "Missing required arguments: requestId.");
  }

  const db = admin.firestore();

  // 2. Fetch request
  const requestRef = db.collection("requests").doc(requestId);
  const requestDoc = await requestRef.get();

  if (!requestDoc.exists) {
    throw new HttpsError("not-found", `Request not found: ${requestId}`);
  }

  const requestData = requestDoc.data();
  if (!requestData) {
    throw new HttpsError("not-found", "Request data is empty.");
  }

  // 3. Validation: Caller must be receiver of the request
  if (request.auth.uid !== requestData.receiverId) {
    throw new HttpsError("permission-denied", "Only the receiver of the request can accept it.");
  }

  // 4. Validation: Status must be 'sent' or 'viewed'
  if (requestData.status !== "sent" && requestData.status !== "viewed") {
    throw new HttpsError("failed-precondition", `Request cannot be accepted in status: ${requestData.status}`);
  }

  // 5. Validation: Request not expired
  const now = admin.firestore.Timestamp.now();
  const expiresAt = requestData.expiresAt as admin.firestore.Timestamp;
  if (expiresAt && expiresAt.toMillis() < now.toMillis()) {
    throw new HttpsError("failed-precondition", "Cannot accept an expired request.");
  }

  // 6. Fetch and validate listing
  const listingRef = db.collection("listings").doc(requestData.listingId);
  const listingDoc = await listingRef.get();

  if (!listingDoc.exists) {
    throw new HttpsError("not-found", `Listing not found: ${requestData.listingId}`);
  }

  const listingData = listingDoc.data();
  if (!listingData) {
    throw new HttpsError("not-found", "Listing data is empty.");
  }

  if (listingData.status !== "available") {
    throw new HttpsError("failed-precondition", "Listing is no longer available.");
  }

  // 7. Calculate rate
  let dailyRate = 0;
  if (listingData.pricePerDay !== undefined && listingData.pricePerDay !== null) {
    dailyRate = Number(listingData.pricePerDay);
  } else if (listingData.startingRate !== undefined && listingData.startingRate !== null) {
    dailyRate = Number(listingData.startingRate);
  } else {
    const duration = requestData.proposedDurationDays || 1;
    dailyRate = requestData.estimatedTotal / duration;
  }

  const agreementRef = db.collection("agreements").doc();

  // 8. DB Transaction to update request and create agreement
  await db.runTransaction(async (transaction) => {
    transaction.update(requestRef, {
      status: "accepted",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const agreementPayload = {
      requestId: requestId,
      listingId: requestData.listingId,
      listingTitle: requestData.listingTitle,
      listingThumbnailUrl: listingData.thumbnailUrl || null,
      initiatorId: requestData.requesterId, // Renter/Requester is initiator
      counterpartyId: requestData.receiverId, // Owner/Receiver is counterparty
      agreementType: requestData.requestType,
      status: "draft",
      templateVersion: "rent-in-v1.0",
      totalAmount: requestData.estimatedTotal,
      depositAmount: requestData.estimatedDeposit || 0,
      dailyRate: dailyRate,
      startDate: requestData.proposedStartDate,
      endDate: requestData.proposedEndDate || null,
      durationDays: requestData.proposedDurationDays || 0,
      contentHash: "",
      version: 0,
      initiatorConsentStatus: "pending",
      counterpartyConsentStatus: "pending",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    transaction.set(agreementRef, agreementPayload);
  });

  // 9. Send FCM to requester (renter)
  try {
    const renterDoc = await db.collection("users").doc(requestData.requesterId).get();
    const renterData = renterDoc.data();
    if (renterData && renterData.fcmToken) {
      const messagePayload = {
        notification: {
          title: "Request Accepted!",
          body: `Your request for ${requestData.listingTitle} was accepted!`,
        },
        token: renterData.fcmToken,
      };
      await admin.messaging().send(messagePayload);
    }
  } catch (error) {
    console.error("Failed to send FCM:", error);
  }

  return { agreementId: agreementRef.id };
});
