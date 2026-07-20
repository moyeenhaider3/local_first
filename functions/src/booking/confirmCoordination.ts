import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { sendNotification } from "../notifications/sendNotification";

export const confirmCoordination = functions.https.onCall(async (data, context) => {
  // 1. Auth check
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }

  const { agreementId } = data;

  if (!agreementId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing required arguments: agreementId."
    );
  }

  const db = admin.firestore();
  const userId = context.auth.uid;

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

  // 3. Auth: only participants
  if (userId !== agreementData.initiatorId && userId !== agreementData.counterpartyId) {
    throw new functions.https.HttpsError("permission-denied", "Only agreement participants can confirm coordination.");
  }

  // 4. Verify agreement status
  if (agreementData.status !== "confirmed") {
    throw new functions.https.HttpsError("failed-precondition", `Cannot confirm coordination in status: ${agreementData.status}`);
  }

  const isInitiator = userId === agreementData.initiatorId;
  const coordinationField = isInitiator ? "initiatorCoordinationConfirmed" : "counterpartyCoordinationConfirmed";
  const otherCoordinationField = isInitiator ? "counterpartyCoordinationConfirmed" : "initiatorCoordinationConfirmed";

  let statusChanged = false;

  await db.runTransaction(async (transaction) => {
    const freshAgreementDoc = await transaction.get(agreementRef);
    const freshData = freshAgreementDoc.data();

    if (!freshData) {
      throw new functions.https.HttpsError("not-found", "Agreement data not found in transaction.");
    }

    const updatePayload: Record<string, unknown> = {
      [coordinationField]: true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const otherStatus = freshData[otherCoordinationField];
    
    // If both have confirmed (or if we are just requiring one for now. Based on user feedback: "it will be better for both parties, so for both parties their corresponding next step appear.")
    if (otherStatus === true) {
      updatePayload.status = "paymentPending";
      statusChanged = true;
      
      // We must create the 3 verification tasks!
      const paymentRef = db.collection("verification_tasks").doc();
      const pickupRef = db.collection("verification_tasks").doc();
      const returnRef = db.collection("verification_tasks").doc();
      
      const now = admin.firestore.FieldValue.serverTimestamp();
      
      transaction.set(paymentRef, {
        agreementId: agreementId,
        taskType: "paymentSettlement",
        status: "pending",
        initiatedById: freshData.initiatorId,
        verifierId: freshData.counterpartyId,
        codeHash: "",
        attemptsUsed: 0,
        maxAttempts: 5,
        expiresAt: now, // Placeholder, updated when code is issued
        createdAt: now,
        updatedAt: now,
      });

      transaction.set(pickupRef, {
        agreementId: agreementId,
        taskType: "pickupInspection",
        status: "pending",
        initiatedById: freshData.counterpartyId,
        verifierId: freshData.initiatorId,
        codeHash: "",
        attemptsUsed: 0,
        maxAttempts: 5,
        expiresAt: now,
        createdAt: now,
        updatedAt: now,
      });

      transaction.set(returnRef, {
        agreementId: agreementId,
        taskType: "itemReturn",
        status: "pending",
        initiatedById: freshData.initiatorId,
        verifierId: freshData.counterpartyId,
        codeHash: "",
        attemptsUsed: 0,
        maxAttempts: 5,
        expiresAt: now,
        createdAt: now,
        updatedAt: now,
      });
    }

    transaction.update(agreementRef, updatePayload);
  });
  
  if (statusChanged) {
     const otherId = isInitiator ? agreementData.counterpartyId : agreementData.initiatorId;
     await sendNotification(
        otherId,
        "Coordination Complete",
        `Both parties have confirmed coordination. The agreement has moved to the payment phase.`
     );
  } else {
     const otherId = isInitiator ? agreementData.counterpartyId : agreementData.initiatorId;
     await sendNotification(
        otherId,
        "Coordination Confirmed",
        `The other party has confirmed coordination. Please confirm on your end to proceed to payment.`
     );
  }

  return { success: true, statusChanged };
});
