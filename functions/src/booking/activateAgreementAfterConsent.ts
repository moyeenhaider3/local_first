import * as admin from "firebase-admin";

/**
 * Internal helper to activate an agreement after both renter and owner have consented.
 * Transitions agreement status to 'confirmed', updates the listing status to 'reserved',
 * and sends push notifications to both parties.
 */
export async function activateAgreementAfterConsent(agreementId: string, db: admin.firestore.Firestore) {
  const agreementRef = db.collection("agreements").doc(agreementId);
  const agreementDoc = await agreementRef.get();
  
  if (!agreementDoc.exists) {
    console.error(`Agreement not found for activation: ${agreementId}`);
    return;
  }

  const agreementData = agreementDoc.data();
  if (!agreementData) {
    console.error(`Agreement data is empty for activation: ${agreementId}`);
    return;
  }

  // Double check that both have consented before performing activation
  if (agreementData.initiatorConsentStatus !== "accepted" || agreementData.counterpartyConsentStatus !== "accepted") {
    console.log(`Agreement ${agreementId} is not fully consented yet. Initiator: ${agreementData.initiatorConsentStatus}, Counterparty: ${agreementData.counterpartyConsentStatus}`);
    return;
  }

  // 1. Transaction to update agreement status to confirmed and listing status to reserved
  const listingRef = db.collection("listings").doc(agreementData.listingId);

  await db.runTransaction(async (transaction) => {
    transaction.update(agreementRef, {
      status: "confirmed",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    transaction.update(listingRef, {
      status: "reserved",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  // 2. Send FCM notifications to both participants
  try {
    const initiatorDoc = await db.collection("users").doc(agreementData.initiatorId).get();
    const initiatorToken = initiatorDoc.data()?.fcmToken;

    const counterpartyDoc = await db.collection("users").doc(agreementData.counterpartyId).get();
    const counterpartyToken = counterpartyDoc.data()?.fcmToken;

    const notificationPayload = {
      notification: {
        title: "Agreement Confirmed!",
        body: `Agreement for ${agreementData.listingTitle} is confirmed. Coordinate pickup via WhatsApp.`,
      },
    };

    if (initiatorToken) {
      await admin.messaging().send({
        ...notificationPayload,
        token: initiatorToken,
      });
    }

    if (counterpartyToken) {
      await admin.messaging().send({
        ...notificationPayload,
        token: counterpartyToken,
      });
    }
  } catch (error) {
    console.error("Failed to send confirmation FCM notifications:", error);
  }
}
