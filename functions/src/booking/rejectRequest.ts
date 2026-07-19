import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Callable Cloud Function to decline/reject a rental or service request.
 * Updates request status to 'rejected', records optional rejection reason,
 * and sends an FCM notification to the requester.
 */
export const rejectRequest = functions.https.onCall(async (data, context) => {
  // 1. Auth check
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to reject a request."
    );
  }

  const { requestId, reason } = data;

  if (!requestId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing required argument: requestId."
    );
  }

  const db = admin.firestore();

  // 2. Fetch request document
  const requestRef = db.collection("requests").doc(requestId);
  const requestDoc = await requestRef.get();

  if (!requestDoc.exists) {
    throw new functions.https.HttpsError(
      "not-found",
      `Request not found: ${requestId}`
    );
  }

  const requestData = requestDoc.data();
  if (!requestData) {
    throw new functions.https.HttpsError("not-found", "Request data is empty.");
  }

  // 3. Validation: Caller must be the receiver of the request
  if (context.auth.uid !== requestData.receiverId) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only the receiver of the request can decline it."
    );
  }

  // 4. Validation: Request status must be 'sent' or 'viewed'
  if (requestData.status !== "sent" && requestData.status !== "viewed") {
    throw new functions.https.HttpsError(
      "failed-precondition",
      `Request cannot be rejected in status: ${requestData.status}`
    );
  }

  const rejectionReason = reason && typeof reason === "string" && reason.trim().length > 0
    ? reason.trim()
    : null;

  // 5. Update request in Firestore
  await requestRef.update({
    status: "rejected",
    rejectionReason: rejectionReason,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // 6. Send FCM notification to the requester
  try {
    const renterDoc = await db.collection("users").doc(requestData.requesterId).get();
    const renterData = renterDoc.data();
    if (renterData && renterData.fcmToken) {
      const messagePayload = {
        notification: {
          title: "Request Declined",
          body: rejectionReason
            ? `Your request for ${requestData.listingTitle} was declined: ${rejectionReason}`
            : `Your request for ${requestData.listingTitle} was declined.`,
        },
        token: renterData.fcmToken,
      };
      await admin.messaging().send(messagePayload);
    }
  } catch (error) {
    console.error("Failed to send FCM notification for request rejection:", error);
  }

  return { success: true, requestId };
});
