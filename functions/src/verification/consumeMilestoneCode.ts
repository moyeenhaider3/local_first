import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as crypto from "crypto";
import { sendNotification } from "../notifications/sendNotification";

export const consumeMilestoneCode = functions.https.onCall(async (data, context) => {
  // 1. Auth check
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }

  const { taskId, code } = data;
  if (!taskId || !code) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing required arguments: taskId and code."
    );
  }

  const db = admin.firestore();
  const callerId = context.auth.uid;

  let result: {
    verified: boolean;
    attemptsRemaining: number;
    message: string;
  } | null = null;

  let initiatedById = "";
  let verifierId = "";
  let taskType = "";

  // Execute all reads and writes in a single Firestore transaction
  await db.runTransaction(async (transaction) => {
    // A. Read verification task
    const taskRef = db.collection("verification_tasks").doc(taskId);
    const taskDoc = await transaction.get(taskRef);

    if (!taskDoc.exists) {
      throw new functions.https.HttpsError("not-found", `Verification task not found: ${taskId}`);
    }

    const taskData = taskDoc.data();
    if (!taskData) {
      throw new functions.https.HttpsError("not-found", "Verification task data is empty.");
    }

    initiatedById = taskData.initiatedById;
    verifierId = taskData.verifierId;
    taskType = taskData.taskType || "";

    // B. Validation: Caller must be the verifier
    if (callerId !== verifierId) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only the designated verifier can submit/consume the code."
      );
    }

    // C. Validation: Check status
    if (
      taskData.status === "verified" ||
      taskData.status === "expired" ||
      taskData.status === "cancelled"
    ) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        `Task is already in status: ${taskData.status}`
      );
    }

    const now = admin.firestore.Timestamp.now();
    const expiresAt = taskData.expiresAt as admin.firestore.Timestamp;

    // D. Validation: Expiry check
    if (expiresAt && expiresAt.toMillis() < now.toMillis()) {
      transaction.update(taskRef, {
        status: "expired",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      result = {
        verified: false,
        attemptsRemaining: 0,
        message: "Code has expired.",
      };
      return;
    }

    const maxAttempts = taskData.maxAttempts || 5;
    const attemptsUsed = taskData.attemptsUsed || 0;

    // E. Validation: Attempts check
    if (attemptsUsed >= maxAttempts) {
      transaction.update(taskRef, {
        status: "expired",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      result = {
        verified: false,
        attemptsRemaining: 0,
        message: "Maximum incorrect attempts reached.",
      };
      return;
    }

    // F. Verify code hash
    const inputHash = crypto.createHash("sha256").update(code).digest("hex");
    const isMatch = inputHash === taskData.codeHash;

    if (isMatch) {
      // 1. Mark task verified
      transaction.update(taskRef, {
        status: "verified",
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 2. Delete plaintext milestone_codes
      const milestoneCodeRef = db.collection("milestone_codes").doc(taskId);
      transaction.delete(milestoneCodeRef);

      // 3. Status cascade for parent agreement & listings
      const agreementRef = db.collection("agreements").doc(taskData.agreementId);
      const agreementDoc = await transaction.get(agreementRef);

      if (agreementDoc.exists) {
        const agreementData = agreementDoc.data();
        if (agreementData) {
          const agreementUpdate: Record<string, any> = {
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          };
          let listingRef: admin.firestore.DocumentReference | null = null;
          let listingUpdate: Record<string, any> | null = null;

          if (agreementData.listingId) {
            listingRef = db.collection("listings").doc(agreementData.listingId);
          }

          if (taskType === "pickupInspection") {
            agreementUpdate.status = "active";
            if (listingRef) {
              listingUpdate = { status: "rented" };
            }
          } else if (taskType === "paymentSettlement") {
            agreementUpdate.status = "paymentVerified";
          } else if (taskType === "itemReturn") {
            agreementUpdate.status = "completed";
            if (listingRef) {
              listingUpdate = { status: "available" };
            }
          } else if (taskType === "serviceCompletion") {
            agreementUpdate.status = "completed";
          }

          transaction.update(agreementRef, agreementUpdate);
          if (listingRef && listingUpdate) {
            transaction.update(listingRef, listingUpdate);
          }
        }
      }

      // 4. Create timeline event
      const timelineEventRef = db.collection("timeline_events").doc();
      transaction.set(timelineEventRef, {
        agreementId: taskData.agreementId,
        taskId: taskId,
        eventType: "code_verified",
        description: `${taskType} verification complete.`,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      result = {
        verified: true,
        attemptsRemaining: maxAttempts - attemptsUsed - 1,
        message: "Code verified successfully.",
      };
    } else {
      // Increment attempts
      const newAttemptsUsed = attemptsUsed + 1;
      const remains = Math.max(0, maxAttempts - newAttemptsUsed);
      const newStatus = remains <= 0 ? "expired" : taskData.status;

      transaction.update(taskRef, {
        attemptsUsed: newAttemptsUsed,
        status: newStatus,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      result = {
        verified: false,
        attemptsRemaining: remains,
        message: remains <= 0 ? "Maximum attempts reached. Task expired." : "Incorrect code.",
      };
    }
  });

  if (result && (result as any).verified) {
    // Send FCM notifications to both parties
    const taskTypeFriendly =
      taskType === "pickupInspection"
        ? "Pickup inspection"
        : taskType === "paymentSettlement"
        ? "Payment settlement"
        : taskType === "itemReturn"
        ? "Item return"
        : taskType === "serviceCompletion"
        ? "Service completion"
        : taskType;

    const title = `${taskTypeFriendly} Verified`;
    const messageBody = `Verification successfully completed for agreement tasks.`;

    await Promise.all([
      sendNotification(initiatedById, title, messageBody),
      sendNotification(verifierId, title, messageBody),
    ]);
  }

  return result || { verified: false, attemptsRemaining: 0, message: "Transaction failed." };
});
