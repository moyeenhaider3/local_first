import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const createRequest = functions.https.onCall(async (data, context) => {
  // 1. Auth check
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }

  const {
    listingId,
    requesterId,
    requestType,
    proposedStartDate,
    proposedEndDate,
    proposedDurationDays,
    estimatedTotal,
    estimatedDeposit,
    message,
  } = data;

  if (!listingId || !requesterId || !requestType || !proposedStartDate || estimatedTotal === undefined) {
    throw new functions.https.HttpsError("invalid-argument", "Missing required arguments.");
  }

  if (context.auth.uid !== requesterId) {
    throw new functions.https.HttpsError("permission-denied", "Requester ID does not match auth context.");
  }

  const db = admin.firestore();

  // 2. Fetch listing
  const listingRef = db.collection("listings").doc(listingId);
  const listingDoc = await listingRef.get();

  if (!listingDoc.exists) {
    throw new functions.https.HttpsError("not-found", `Listing not found: ${listingId}`);
  }

  const listingData = listingDoc.data();
  if (!listingData) {
    throw new functions.https.HttpsError("not-found", "Listing data is empty.");
  }

  // 3. Validation: status must be 'available'
  if (listingData.status !== "available") {
    throw new functions.https.HttpsError("failed-precondition", "Listing is not available.");
  }

  // 4. Validation: no self-request
  if (listingData.ownerId === requesterId) {
    throw new functions.https.HttpsError("invalid-argument", "Users cannot request their own listing.");
  }

  // 5. Validation: check duplicate pending request
  const existingRequests = await db.collection("requests")
    .where("listingId", "==", listingId)
    .where("requesterId", "==", requesterId)
    .where("status", "in", ["sent", "viewed", "accepted", "negotiating", "agreementCreated"])
    .get();

  if (!existingRequests.empty) {
    throw new functions.https.HttpsError("already-exists", "A pending request already exists for this listing.");
  }

  // 6. Create request document
  const startDate = new Date(proposedStartDate);
  const endDate = proposedEndDate ? new Date(proposedEndDate) : null;
  const expiresAt = new Date(Date.now() + 48 * 60 * 60 * 1000); // 48 hours

  const newRequestRef = db.collection("requests").doc();
  const requestPayload = {
    listingId,
    listingTitle: listingData.title || "",
    requesterId,
    receiverId: listingData.ownerId,
    requestType,
    status: "sent",
    proposedStartDate: admin.firestore.Timestamp.fromDate(startDate),
    proposedEndDate: endDate ? admin.firestore.Timestamp.fromDate(endDate) : null,
    proposedDurationDays: proposedDurationDays || null,
    estimatedTotal,
    estimatedDeposit: estimatedDeposit !== undefined ? estimatedDeposit : null,
    message: message || "",
    expiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await newRequestRef.set(requestPayload);

  // 7. Send FCM to receiver (owner) — placeholder, no-op if no token
  try {
    const receiverId = listingData.ownerId;
    const userDoc = await db.collection("users").doc(receiverId).get();
    const userData = userDoc.data();
    if (userData && userData.fcmToken) {
      const messagePayload = {
        notification: {
          title: "New Booking Request",
          body: `New request for ${listingData.title || "your listing"}`,
        },
        token: userData.fcmToken,
      };
      await admin.messaging().send(messagePayload);
    }
  } catch (error) {
    console.error("Failed to send FCM:", error);
  }

  return { requestId: newRequestRef.id };
});
