import * as admin from "firebase-admin";

// Initialize the Firebase Admin SDK
admin.initializeApp();

// Export public callable Cloud Functions
export { createRequest } from "./booking/createRequest";
export { acceptRequest } from "./booking/acceptRequest";
export { generateAgreementVersion } from "./booking/generateAgreementVersion";
export { recordAgreementConsent } from "./booking/recordAgreementConsent";
