import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as crypto from "crypto";
import { sendNotification } from "../notifications/sendNotification";

export const issueMilestoneCode = functions.https.onCall(async (data, context) => {
  // 1. Auth check
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }

  const { taskId } = data;
  if (!taskId) {
    throw new functions.https.HttpsError("invalid-argument", "Missing required arguments: taskId.");
  }

  const db = admin.firestore();

  // 2. Fetch verification task
  const taskRef = db.collection("verification_tasks").doc(taskId);
  const taskDoc = await taskRef.get();

  if (!taskDoc.exists) {
    throw new functions.https.HttpsError("not-found", `Verification task not found: ${taskId}`);
  }

  const taskData = taskDoc.data();
  if (!taskData) {
    throw new functions.https.HttpsError("not-found", "Verification task data is empty.");
  }

  // 3. Validation: Caller is the initiatedById (code-holder) or verifierId
  const callerId = context.auth.uid;
  if (callerId !== taskData.initiatedById && callerId !== taskData.verifierId) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only agreement participants associated with this task can request code issuance."
    );
  }

  // 4. Validation: Caller must be the code-holder (initiatedById) to request the code
  if (callerId !== taskData.initiatedById) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only the designated code-holder can request code issuance."
    );
  }

  // 5. Validation: Task status must be 'pending' or 'initiatorConfirmed'
  if (taskData.status !== "pending" && taskData.status !== "initiatorConfirmed") {
    throw new functions.https.HttpsError(
      "failed-precondition",
      `Cannot issue code for a task in status: ${taskData.status}`
    );
  }

  // 6. Fetch and validate parent agreement
  const agreementRef = db.collection("agreements").doc(taskData.agreementId);
  const agreementDoc = await agreementRef.get();

  if (!agreementDoc.exists) {
    throw new functions.https.HttpsError(
      "not-found",
      `Associated agreement not found: ${taskData.agreementId}`
    );
  }

  const agreementData = agreementDoc.data();
  if (!agreementData) {
    throw new functions.https.HttpsError("not-found", "Agreement data is empty.");
  }

  // Check agreement is not cancelled or archived
  if (agreementData.status === "cancelled" || agreementData.status === "archived") {
    throw new functions.https.HttpsError(
      "failed-precondition",
      `Cannot issue code for a cancelled or archived agreement.`
    );
  }

  // 7. Generate 4-digit code: Math.floor(1000 + Math.random() * 9000).toString()
  const plaintext = Math.floor(1000 + Math.random() * 9000).toString();

  // Hash using SHA-256
  const hash = crypto.createHash("sha256").update(plaintext).digest("hex");

  const now = admin.firestore.Timestamp.now();
  const expiresAt = admin.firestore.Timestamp.fromMillis(now.toMillis() + 30 * 60 * 1000); // 30 minutes expiry

  // 8. Save hash in verification_tasks and plaintext in milestone_codes
  const batch = db.batch();

  batch.update(taskRef, {
    codeHash: hash,
    attemptsUsed: 0,
    maxAttempts: 5,
    expiresAt: expiresAt,
    status: "initiatorConfirmed",
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  const milestoneCodeRef = db.collection("milestone_codes").doc(taskId);
  batch.set(milestoneCodeRef, {
    code: plaintext,
    taskId: taskId,
    agreementId: taskData.agreementId,
    issuedToUserId: taskData.initiatedById,
    expiresAt: expiresAt,
  });

  await batch.commit();

  // 9. Send FCM notification to code holder (initiatedById)
  // We do NOT include the plaintext code in the notification text for security.
  await sendNotification(
    taskData.initiatedById,
    "Verification Code Ready",
    "Your verification code is ready. Open the app to view it."
  );

  return { success: true };
});
