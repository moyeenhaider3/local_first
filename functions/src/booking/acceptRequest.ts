import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const acceptRequest = functions.https.onCall(async (data, context) => {
  // 1. Auth check
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }

  const { requestId } = data;

  if (!requestId) {
    throw new functions.https.HttpsError("invalid-argument", "Missing required arguments: requestId.");
  }

  const db = admin.firestore();

  // 2. Fetch request
  const requestRef = db.collection("requests").doc(requestId);
  const requestDoc = await requestRef.get();

  if (!requestDoc.exists) {
    throw new functions.https.HttpsError("not-found", `Request not found: ${requestId}`);
  }

  const requestData = requestDoc.data();
  if (!requestData) {
    throw new functions.https.HttpsError("not-found", "Request data is empty.");
  }

  // 3. Validation: Caller must be receiver of the request
  if (context.auth.uid !== requestData.receiverId) {
    throw new functions.https.HttpsError("permission-denied", "Only the receiver of the request can accept it.");
  }

  // 4. Validation: Status must be 'sent' or 'viewed'
  if (requestData.status !== "sent" && requestData.status !== "viewed") {
    throw new functions.https.HttpsError("failed-precondition", `Request cannot be accepted in status: ${requestData.status}`);
  }

  // 5. Validation: Request not expired
  const now = admin.firestore.Timestamp.now();
  const expiresAt = requestData.expiresAt as admin.firestore.Timestamp;
  if (expiresAt && expiresAt.toMillis() < now.toMillis()) {
    throw new functions.https.HttpsError("failed-precondition", "Cannot accept an expired request.");
  }

  // 6. Fetch and validate listing
  const listingRef = db.collection("listings").doc(requestData.listingId);
  const listingDoc = await listingRef.get();

  if (!listingDoc.exists) {
    throw new functions.https.HttpsError("not-found", `Listing not found: ${requestData.listingId}`);
  }

  const listingData = listingDoc.data();
  if (!listingData) {
    throw new functions.https.HttpsError("not-found", "Listing data is empty.");
  }

  if (listingData.status !== "available") {
    throw new functions.https.HttpsError("failed-precondition", "Listing is no longer available.");
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
      initiatorId: requestData.requesterId,
      counterpartyId: requestData.receiverId,
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

  // 9. Auto-decline conflicting pending requests for the same listing
  try {
    const pendingRequestsSnapshot = await db
      .collection("requests")
      .where("listingId", "==", requestData.listingId)
      .where("status", "in", ["sent", "viewed"])
      .get();

    const batch = db.batch();
    const autoDeclinedRequesters: { requesterId: string; requestId: string }[] = [];

    for (const doc of pendingRequestsSnapshot.docs) {
      if (doc.id !== requestId) {
        batch.update(doc.ref, {
          status: "rejected",
          rejectionReason: "Listing booked for requested dates",
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        const reqData = doc.data();
        if (reqData.requesterId) {
          autoDeclinedRequesters.push({
            requesterId: reqData.requesterId,
            requestId: doc.id,
          });
        }
      }
    }

    if (autoDeclinedRequesters.length > 0) {
      await batch.commit();

      // Send FCM notification to auto-declined requesters
      for (const item of autoDeclinedRequesters) {
        try {
          const userDoc = await db.collection("users").doc(item.requesterId).get();
          const userData = userDoc.data();
          if (userData && userData.fcmToken) {
            await admin.messaging().send({
              notification: {
                title: "Request Declined",
                body: `Your request for ${requestData.listingTitle} was declined as the item was booked for requested dates.`,
              },
              token: userData.fcmToken,
            });
          }
        } catch (fcmError) {
          console.error(`Failed to send FCM to auto-declined user ${item.requesterId}:`, fcmError);
        }
      }
    }
  } catch (autoDeclineError) {
    console.error("Error auto-declining conflicting requests:", autoDeclineError);
  }

  // 10. Send FCM to requester (renter) of accepted request
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
