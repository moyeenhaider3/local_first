import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Callable Cloud Function to compute and persist user trust score server-side.
 * Evaluates user KYC status, completed rentals, completed service jobs, average ratings,
 * and open damage disputes in Local First to return a verified trust score between 0 and 100.
 */
export const calculateTrustScore = functions.https.onCall(async (data, context) => {
  // 1. Authentication check
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to recalculate trust score."
    );
  }

  const db = admin.firestore();
  const userId = data.userId || context.auth.uid;

  // 2. Fetch user profile document
  const userDoc = await db.collection("users").doc(userId).get();
  const userData = userDoc.data() || {};

  // A. Check KYC verification status (+20 pts)
  const isKycVerified = userData.kycStatus === "verified" || userData.isKycVerified === true;
  const kycBonus = isKycVerified ? 20 : 0;

  // B. Query completed rental agreements (+5 pts per completed rental, max +20)
  const completedAgreementsSnap = await db
    .collection("agreements")
    .where("status", "==", "completed")
    .get();

  const userCompletedRentals = completedAgreementsSnap.docs.filter((doc) => {
    const data = doc.data();
    return data.ownerId === userId || data.renterId === userId;
  }).length;

  const rentalBonus = Math.min(20, userCompletedRentals * 5);

  // C. Query completed service requests (+5 pts per completed service, max +20)
  const completedServicesSnap = await db
    .collection("service_requests")
    .where("status", "==", "completed")
    .get();

  const userCompletedServices = completedServicesSnap.docs.filter((doc) => {
    const data = doc.data();
    return data.workerId === userId || data.customerId === userId;
  }).length;

  const serviceBonus = Math.min(20, userCompletedServices * 5);

  // D. Query review ratings for target user (+4 pts per rating star, max +20)
  const reviewsSnap = await db
    .collection("reviews")
    .where("targetId", "==", userId)
    .get();

  let avgRating = 4.5; // Default baseline for new users
  if (!reviewsSnap.empty) {
    const totalRating = reviewsSnap.docs.reduce((sum, doc) => sum + (doc.data().rating || 5.0), 0);
    avgRating = totalRating / reviewsSnap.size;
  }
  const ratingBonus = Math.min(20, Math.round(avgRating * 4));

  // E. Query active damage disputes (-15 pts per open dispute)
  const openDisputesSnap = await db
    .collection("damage_disputes")
    .where("status", "==", "open")
    .get();

  const userOpenDisputes = openDisputesSnap.docs.filter((doc) => {
    const data = doc.data();
    return data.reportedBy === userId || data.againstUserId === userId;
  }).length;

  const disputeDeduction = userOpenDisputes * 15;

  // F. Calculate total trust score (Base 20 + bonuses - deductions), clamped between 0 and 100
  const baseScore = 20;
  const rawScore = baseScore + kycBonus + rentalBonus + serviceBonus + ratingBonus - disputeDeduction;
  const finalScore = Math.max(0, Math.min(100, Math.round(rawScore)));

  // 3. Update user document and service profile document (if exists)
  const batch = db.batch();
  batch.set(db.collection("users").doc(userId), { trustScore: finalScore }, { merge: true });

  const serviceProfileRef = db.collection("service_profiles").doc(userId);
  const serviceProfileDoc = await serviceProfileRef.get();
  if (serviceProfileDoc.exists) {
    batch.set(serviceProfileRef, { trustScore: finalScore }, { merge: true });
  }

  await batch.commit();

  return {
    success: true,
    userId: userId,
    trustScore: finalScore,
    breakdown: {
      kycBonus,
      rentalBonus,
      serviceBonus,
      ratingBonus,
      disputeDeduction,
      avgRating,
    },
  };
});
