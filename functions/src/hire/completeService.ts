import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as crypto from "crypto";
import { sendNotification } from "../notifications/sendNotification";

/**
 * Callable Cloud Function to complete a hire service request via 4-digit completion code.
 * Validates verification code, updates service request and agreement statuses to 'completed',
 * recalculates worker trust score rating, enables review eligibility, and sends FCM notifications.
 */
export const completeService = functions.https.onCall(async (data, context) => {
  // 1. Verify user authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to complete a service."
    );
  }

  const { requestId, taskId, code } = data;
  if ((!requestId && !taskId) || !code) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing required arguments: requestId/taskId and completion code."
    );
  }

  const db = admin.firestore();
  const callerId = context.auth.uid;

  let targetRequestId = requestId || "";
  let targetWorkerId = "";
  let targetCustomerId = "";
  let agreementId = "";

  await db.runTransaction(async (transaction) => {
    // A. Read service request or verification task
    let serviceReqDoc: admin.firestore.DocumentSnapshot | null = null;
    let serviceReqRef: admin.firestore.DocumentReference | null = null;

    if (targetRequestId) {
      serviceReqRef = db.collection("service_requests").doc(targetRequestId);
      serviceReqDoc = await transaction.get(serviceReqRef);
    } else if (taskId) {
      const taskDoc = await transaction.get(db.collection("verification_tasks").doc(taskId));
      if (taskDoc.exists) {
        const taskData = taskDoc.data();
        if (taskData?.requestId) {
          targetRequestId = taskData.requestId;
          serviceReqRef = db.collection("service_requests").doc(targetRequestId);
          serviceReqDoc = await transaction.get(serviceReqRef);
        }
        if (taskData?.agreementId) {
          agreementId = taskData.agreementId;
        }
      }
    }

    if (!serviceReqDoc || !serviceReqDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        `Service request not found: ${targetRequestId || taskId}`
      );
    }

    const reqData = serviceReqDoc.data();
    if (!reqData) {
      throw new functions.https.HttpsError("not-found", "Service request data is empty.");
    }

    targetWorkerId = reqData.workerId;
    targetCustomerId = reqData.customerId;

    // B. Authorization check: Caller must be worker or customer
    if (callerId !== targetWorkerId && callerId !== targetCustomerId) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only participants of this service request can submit completion."
      );
    }

    // C. Validate verification code hash if task exists
    if (taskId) {
      const taskRef = db.collection("verification_tasks").doc(taskId);
      const taskDoc = await transaction.get(taskRef);
      if (taskDoc.exists) {
        const taskData = taskDoc.data();
        if (taskData?.codeHash) {
          const inputHash = crypto.createHash("sha256").update(code).digest("hex");
          if (inputHash !== taskData.codeHash) {
            const attemptsUsed = (taskData.attemptsUsed || 0) + 1;
            const maxAttempts = taskData.maxAttempts || 5;
            transaction.update(taskRef, {
              attemptsUsed,
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            throw new functions.https.HttpsError(
              "invalid-argument",
              `Incorrect code. ${Math.max(0, maxAttempts - attemptsUsed)} attempts remaining.`
            );
          }

          transaction.update(taskRef, {
            status: "verified",
            completedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      }
    }

    // D. Update service request status
    if (serviceReqRef) {
      transaction.update(serviceReqRef, {
        status: "completed",
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // E. Update parent agreement if present
    if (agreementId) {
      const agreementRef = db.collection("agreements").doc(agreementId);
      transaction.update(agreementRef, {
        status: "completed",
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // F. Update worker profile trust score stats
    const workerProfileRef = db.collection("service_profiles").doc(targetWorkerId);
    const workerProfileDoc = await transaction.get(workerProfileRef);
    if (workerProfileDoc.exists) {
      const workerData = workerProfileDoc.data();
      const currentCompleted = workerData?.completedJobsCount || 0;
      const currentTrust = workerData?.trustScore || 4.5;
      // Slight positive bump for successful verified service completion
      const newTrust = Math.min(5.0, currentTrust + 0.05);

      transaction.update(workerProfileRef, {
        completedJobsCount: currentCompleted + 1,
        trustScore: Number(newTrust.toFixed(2)),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // G. Create review eligibility record for both parties
    const reviewEligibilityRef = db.collection("review_eligibility").doc(targetRequestId);
    transaction.set(reviewEligibilityRef, {
      requestId: targetRequestId,
      workerId: targetWorkerId,
      customerId: targetCustomerId,
      isCustomerEligible: true,
      isWorkerEligible: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // H. Add timeline event
    const timelineRef = db.collection("timeline_events").doc();
    transaction.set(timelineRef, {
      requestId: targetRequestId,
      agreementId: agreementId || null,
      eventType: "service_completed",
      description: "Service completed and verified successfully via 4-digit code.",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  // Dispatch FCM notifications
  await Promise.all([
    sendNotification(
      targetCustomerId,
      "Service Completed",
      "Your service job has been completed and verified successfully. Please leave a review!"
    ),
    sendNotification(
      targetWorkerId,
      "Service Verified",
      "Service completion code verified. Payout released and job marked completed."
    ),
  ]);

  return {
    success: true,
    status: "completed",
    message: "Service completed and verified successfully.",
  };
});
