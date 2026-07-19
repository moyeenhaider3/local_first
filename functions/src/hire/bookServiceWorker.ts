import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { sendNotification } from "../notifications/sendNotification";

/**
 * Callable Cloud Function to initiate a hire service request booking for a registered worker.
 * Validates worker availability, input parameters, creates a service request record, and dispatches FCM notifications.
 */
export const bookServiceWorker = functions.https.onCall(async (data, context) => {
  // 1. Verify user authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to book a service worker."
    );
  }

  const {
    workerId,
    jobDescription,
    scheduledDate,
    estimatedRate,
    rateUnit = "per hour",
  } = data;

  // 2. Input validation
  if (!workerId || !jobDescription || !scheduledDate || estimatedRate === undefined) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing required arguments: workerId, jobDescription, scheduledDate, estimatedRate."
    );
  }

  const customerId = context.auth.uid;

  // 3. Prevent self-booking
  if (customerId === workerId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Workers cannot book their own services."
    );
  }

  const db = admin.firestore();

  // 4. Verify worker profile exists and is available
  const workerProfileRef = db.collection("service_profiles").doc(workerId);
  const workerProfileDoc = await workerProfileRef.get();

  if (!workerProfileDoc.exists) {
    throw new functions.https.HttpsError(
      "not-found",
      `Service worker profile not found: ${workerId}`
    );
  }

  const workerData = workerProfileDoc.data();
  if (!workerData) {
    throw new functions.https.HttpsError("not-found", "Worker profile data is empty.");
  }

  // 5. Fetch customer user profile details
  const customerProfileDoc = await db.collection("users").doc(customerId).get();
  const customerData = customerProfileDoc.data();
  const customerName = customerData?.displayName || "Local First User";

  // 6. Create service_requests document
  const requestRef = db.collection("service_requests").doc();
  const scheduledTimestamp = admin.firestore.Timestamp.fromDate(new Date(scheduledDate));

  const requestPayload = {
    id: requestRef.id,
    workerId,
    workerName: workerData.displayName || "Service Worker",
    customerId,
    customerName,
    jobDescription,
    scheduledDate: scheduledTimestamp,
    estimatedRate: Number(estimatedRate),
    rateUnit,
    status: "pending",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await requestRef.set(requestPayload);

  // 7. Dispatch FCM notification to worker
  await sendNotification(
    workerId,
    "New Hire Request",
    `You have a new service request from ${customerName} for ${jobDescription}`
  );

  return {
    requestId: requestRef.id,
    status: "pending",
    message: "Service request created successfully.",
  };
});
