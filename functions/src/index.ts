import * as admin from "firebase-admin";

// Initialize the Firebase Admin SDK
admin.initializeApp();

// Export public callable Cloud Functions
export { createRequest } from "./booking/createRequest";
export { acceptRequest } from "./booking/acceptRequest";
export { rejectRequest } from "./booking/rejectRequest";
export { generateAgreementVersion } from "./booking/generateAgreementVersion";
export { recordAgreementConsent } from "./booking/recordAgreementConsent";
export { confirmCoordination } from "./booking/confirmCoordination";
export { issueMilestoneCode } from "./verification/issueMilestoneCode";
export { consumeMilestoneCode } from "./verification/consumeMilestoneCode";
export { createDamageDispute } from "./verification/createDamageDispute";
export { generateEvidencePackage } from "./verification/generateEvidencePackage";
export { holdPaymentEscrow } from "./payments/holdPaymentEscrow";
export { releasePaymentPayout } from "./payments/releasePaymentPayout";
export { processRefundOrDisputePayout } from "./payments/processRefundOrDisputePayout";
export { bookServiceWorker } from "./hire/bookServiceWorker";
export { completeService } from "./hire/completeService";
export { calculateTrustScore } from "./trust/calculateTrustScore";





