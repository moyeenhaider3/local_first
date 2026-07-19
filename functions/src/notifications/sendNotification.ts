import * as admin from "firebase-admin";

/**
 * Sends an FCM push notification to a user's registered devices.
 * Automatically cleans up expired or invalid tokens from the database.
 *
 * @param userId The ID of the recipient user.
 * @param title The title of the notification.
 * @param body The body text of the notification.
 * @param data Optional custom key-value pairs to include in the payload.
 */
export async function sendNotification(
  userId: string,
  title: string,
  body: string,
  data?: Record<string, string>
): Promise<void> {
  const db = admin.firestore();
  const tokensSnapshot = await db
    .collection("users")
    .doc(userId)
    .collection("tokens")
    .get();

  if (tokensSnapshot.empty) {
    console.log(`No FCM tokens found for user: ${userId}`);
    return;
  }

  const tokensWithDocId: { docId: string; token: string }[] = [];
  tokensSnapshot.forEach((doc) => {
    const tokenData = doc.data();
    if (tokenData && typeof tokenData.token === "string") {
      tokensWithDocId.push({ docId: doc.id, token: tokenData.token });
    }
  });

  if (tokensWithDocId.length === 0) {
    return;
  }

  const tokens = tokensWithDocId.map((t) => t.token);

  // firebase-admin v11 uses sendEachForMulticast
  const message: admin.messaging.MulticastMessage = {
    notification: {
      title,
      body,
    },
    data,
    tokens,
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    
    // Process results to identify invalid/expired tokens for cleanup
    const tokensToDelete: string[] = [];
    response.responses.forEach((res, index) => {
      if (!res.success && res.error) {
        const code = res.error.code;
        // Check if error indicates the token is invalid or no longer registered
        if (
          code === "messaging/invalid-registration-token" ||
          code === "messaging/registration-token-not-registered"
        ) {
          tokensToDelete.push(tokensWithDocId[index].docId);
        }
      }
    });

    if (tokensToDelete.length > 0) {
      console.log(`Cleaning up ${tokensToDelete.length} invalid tokens for user: ${userId}`);
      const batch = db.batch();
      tokensToDelete.forEach((docId) => {
        batch.delete(db.collection("users").doc(userId).collection("tokens").doc(docId));
      });
      await batch.commit();
    }
  } catch (error) {
    console.error(`Error sending multicast notification to user ${userId}:`, error);
  }
}
