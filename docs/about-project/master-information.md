\# Master Engineering & Product Design Specification    
\#\# Neighborhood Rent & Hire Trust Platform    
\*\*Target stack:\*\* Flutter \+ Firebase    
\*\*Document type:\*\* Product Requirements Document \+ Software Design Specification    
\*\*Primary users:\*\* UI/UX designers, Flutter developers, Firebase engineers, QA engineers, AI coding agents    
\*\*Version:\*\* 1.0

\---

\# 1\. Product Vision

Build a neighborhood marketplace where users can:

1\. Rent physical items from nearby owners.  
2\. Hire nearby workers or service providers.  
3\. Communicate through WhatsApp or phone.  
4\. Pay through external payment applications such as UPI.  
5\. Return to the app after every external interaction.  
6\. Confirm whether the external step was completed.  
7\. Ask the other party to verify that step.  
8\. Maintain a structured, mutually verified transaction history.  
9\. Create evidence of consent, item handover, payment, service completion, item return, and disputes.

The platform does not initially provide:

\- In-app chat.  
\- Payment processing.  
\- Escrow.  
\- Automated booking settlement.  
\- Legal recovery services.

The platform provides:

\- Discovery.  
\- Identity and profile verification.  
\- Requests and acceptance.  
\- Agreement generation.  
\- Digital consent records.  
\- External interaction handoffs.  
\- Mutual milestone verification.  
\- One-time verification codes.  
\- Notifications and reminders.  
\- Reviews and trust scores.  
\- Transaction, rental, hiring, and subscription history.  
\- Dispute evidence packages.

\---

\# 2\. Core Product Principle

\> Use third-party applications for execution and use our platform for structured tracking, mutual verification, history, and trust.

The reusable platform pattern is:

\`\`\`text  
Discover  
→ Request  
→ Accept  
→ Negotiate externally  
→ Return to app  
→ Finalize terms  
→ Consent to agreement  
→ Complete external milestone  
→ Ask if completed  
→ First party confirms  
→ Second party verifies  
→ Store timeline event  
→ Update agreement status  
→ Show in user history  
\`\`\`

This model must work for:

\- Rentals.  
\- Hiring.  
\- Recurring subscriptions.  
\- External payments.  
\- Item pickup.  
\- Item return.  
\- Service completion.  
\- Deposits.  
\- Damage resolution.  
\- Future resale or community services.

\---

\# 3\. Important Legal and Product Boundary

The application records evidence of consent and activity. It must not promise that:

\- Every agreement is automatically legally enforceable.  
\- Entering a code guarantees legal liability in every jurisdiction.  
\- KYC guarantees that a user is trustworthy.  
\- The platform will recover payment or damages.  
\- The platform is a court, arbitrator, escrow provider, or collection agency.

Legal counsel must review:

\- Standard rental agreement.  
\- Digital signature and consent implementation.  
\- Privacy policy.  
\- KYC provider terms.  
\- Identity-data disclosure rules.  
\- Damage-liability clauses.  
\- Evidence export format.  
\- Data retention.  
\- Applicable Indian electronic signature and contract laws.

The UI should use wording such as:

\> “This action creates a recorded acknowledgment associated with your account, agreement, device, and timestamp.”

Avoid unsupported wording such as:

\> “Entering this code legally proves liability in every situation.”

\---

\# 4\. Product Modules

\#\# 4.1 MVP Modules

1\. Authentication.  
2\. User profile and multiple roles.  
3\. KYC and verification status.  
4\. Rent listings.  
5\. Worker/service listings.  
6\. Location and nearby discovery.  
7\. Request management.  
8\. External WhatsApp handoff.  
9\. Generic agreement engine.  
10\. Digital consent.  
11\. Generic verification-task engine.  
12\. External payment verification.  
13\. Rental pickup inspection approval.  
14\. Rental return verification.  
15\. Service-completion verification.  
16\. Subscription and recurring agreement support.  
17\. Agreement timeline.  
18\. Notifications and reminders.  
19\. Reviews and trust score.  
20\. Reports, blocks, and disputes.  
21\. Admin portal.  
22\. User transaction history.

\#\# 4.2 Post-MVP Modules

\- Payment gateway.  
\- Escrow.  
\- In-app chat.  
\- Video inspection.  
\- AI-assisted damage comparison.  
\- Insurance.  
\- Advanced legal assistance.  
\- Automated recurring billing.  
\- Dynamic pricing.  
\- AI recommendations.

\---

\# 5\. User and Role Model

One account can have multiple roles. Do not create separate account types.

\`\`\`json  
{  
  "roles": {  
    "renter": true,  
    "owner": true,  
    "customer": true,  
    "worker": true  
  }  
}  
\`\`\`

Roles are enabled as the user performs relevant actions.

Examples:

\- A renter becomes an owner after publishing an item.  
\- A customer becomes a worker after publishing a service profile.  
\- The same user may rent an item and provide electrical services.

\---

\#\# 5.1 User Lifecycle Flow

\`\`\`mermaid  
flowchart TD  
    A\[Guest\] \--\> B\[Phone Authentication\]  
    B \--\> C{OTP Valid?}  
    C \-- No \--\> B  
    C \-- Yes \--\> D\[Registered User\]  
    D \--\> E\[Complete Basic Profile\]  
    E \--\> F\[Phone Verified User\]  
    F \--\> G{Action Requires KYC?}  
    G \-- No \--\> H\[Browse and Save\]  
    G \-- Yes \--\> I\[Submit KYC to Provider\]  
    I \--\> J{KYC Result}  
    J \-- Approved \--\> K\[Verified User\]  
    J \-- Pending \--\> L\[KYC Pending\]  
    J \-- Rejected \--\> M\[KYC Rejected\]  
    K \--\> N\[Enable Owner, Renter, Worker, or Customer Roles\]  
\`\`\`

\#\# 5.2 UML Sequence — Authentication and KYC

\`\`\`mermaid  
sequenceDiagram  
    actor User  
    participant App as Flutter App  
    participant Auth as Firebase Auth  
    participant API as Cloud Functions  
    participant KYC as Third-Party KYC  
    participant DB as Firestore  
    participant FCM as Firebase Messaging

    User-\>\>App: Enter phone number  
    App-\>\>Auth: Request OTP  
    Auth--\>\>User: Send OTP  
    User-\>\>App: Enter OTP  
    App-\>\>Auth: Verify OTP  
    Auth--\>\>App: Firebase user token  
    App-\>\>API: Create or load user profile  
    API-\>\>DB: Upsert user and profile  
    User-\>\>App: Submit KYC information  
    App-\>\>KYC: Start KYC workflow  
    KYC--\>\>API: Verification webhook  
    API-\>\>DB: Update KYC status  
    API-\>\>FCM: Send verification result  
    FCM--\>\>App: KYC notification  
\`\`\`

\---

\# 6\. Generic Backend Model

The backend must not implement completely separate transaction engines for Rent and Hire.

The core model is:

\`\`\`text  
Listing → Request → Agreement → Verification Tasks → Timeline → History  
\`\`\`

The UI and agreement templates differ by transaction type, but the backend lifecycle remains reusable.

\---

\# 7\. Master Data Relationship Diagram

\`\`\`mermaid  
erDiagram  
    USERS {  
        string userId PK  
        string phone  
        string displayName  
        string email  
        string photoUrl  
        string accountStatus  
        timestamp createdAt  
        timestamp updatedAt  
    }

    USER\_ROLES {  
        string userRoleId PK  
        string userId FK  
        string role  
        boolean enabled  
        timestamp enabledAt  
    }

    KYC\_RECORDS {  
        string kycId PK  
        string userId FK  
        string provider  
        string providerReference  
        string status  
        timestamp verifiedAt  
    }

    LISTINGS {  
        string listingId PK  
        string ownerId FK  
        string listingType  
        string categoryId FK  
        string title  
        string status  
        float latitude  
        float longitude  
        string geohash  
        timestamp createdAt  
    }

    RENT\_LISTING\_DETAILS {  
        string listingId PK  
        float pricePerDay  
        float pricePerWeek  
        float depositAmount  
        string itemCondition  
        string availabilityStatus  
    }

    WORKER\_LISTING\_DETAILS {  
        string listingId PK  
        string workerId FK  
        string skillId FK  
        float startingRate  
        string rateUnit  
        string availabilityStatus  
        float serviceRadiusKm  
    }

    REQUESTS {  
        string requestId PK  
        string listingId FK  
        string requesterId FK  
        string receiverId FK  
        string requestType  
        string status  
        timestamp startAt  
        timestamp endAt  
        timestamp expiresAt  
    }

    AGREEMENTS {  
        string agreementId PK  
        string requestId FK  
        string listingId FK  
        string initiatorId FK  
        string counterpartyId FK  
        string agreementType  
        string status  
        string templateVersion  
        float totalAmount  
        float depositAmount  
        timestamp startAt  
        timestamp endAt  
    }

    AGREEMENT\_PARTICIPANTS {  
        string participantId PK  
        string agreementId FK  
        string userId FK  
        string partyRole  
        string consentStatus  
        timestamp consentedAt  
    }

    CONSENT\_RECORDS {  
        string consentId PK  
        string agreementId FK  
        string userId FK  
        string agreementHash  
        string templateVersion  
        string deviceIdHash  
        string ipHash  
        timestamp acceptedAt  
    }

    VERIFICATION\_TASKS {  
        string taskId PK  
        string agreementId FK  
        string taskType  
        string status  
        string initiatedBy FK  
        string verifierId FK  
        float declaredAmount  
        timestamp dueAt  
        timestamp completedAt  
    }

    VERIFICATION\_RESPONSES {  
        string responseId PK  
        string taskId FK  
        string userId FK  
        string response  
        string remark  
        timestamp respondedAt  
    }

    OTP\_MILESTONES {  
        string milestoneCodeId PK  
        string taskId FK  
        string agreementId FK  
        string codeHash  
        string codeType  
        string issuedToUserId FK  
        timestamp expiresAt  
        timestamp consumedAt  
    }

    EXTERNAL\_ACTIONS {  
        string externalActionId PK  
        string agreementId FK  
        string taskId FK  
        string actionType  
        string provider  
        string initiatedBy FK  
        timestamp openedAt  
        timestamp returnedAt  
    }

    TIMELINE\_EVENTS {  
        string eventId PK  
        string agreementId FK  
        string eventType  
        string actorId FK  
        string entityType  
        string entityId  
        timestamp createdAt  
    }

    SUBSCRIPTIONS {  
        string subscriptionId PK  
        string agreementId FK  
        string subscriberId FK  
        string providerId FK  
        string status  
        string billingFrequency  
        timestamp nextDueAt  
        timestamp endedAt  
    }

    REVIEWS {  
        string reviewId PK  
        string agreementId FK  
        string reviewerId FK  
        string revieweeId FK  
        string reviewType  
        float rating  
        timestamp createdAt  
    }

    DISPUTES {  
        string disputeId PK  
        string agreementId FK  
        string openedBy FK  
        string disputeType  
        string status  
        timestamp openedAt  
    }

    ATTACHMENTS {  
        string attachmentId PK  
        string ownerId FK  
        string parentType  
        string parentId  
        string storagePath  
        string mediaType  
        timestamp createdAt  
    }

    NOTIFICATIONS {  
        string notificationId PK  
        string userId FK  
        string agreementId FK  
        string type  
        string status  
        timestamp scheduledAt  
        timestamp sentAt  
    }

    USERS ||--o{ USER\_ROLES : has  
    USERS ||--o{ KYC\_RECORDS : submits  
    USERS ||--o{ LISTINGS : publishes  
    LISTINGS ||--|| RENT\_LISTING\_DETAILS : has  
    LISTINGS ||--|| WORKER\_LISTING\_DETAILS : has  
    LISTINGS ||--o{ REQUESTS : receives  
    USERS ||--o{ REQUESTS : creates  
    REQUESTS ||--o| AGREEMENTS : becomes  
    AGREEMENTS ||--|{ AGREEMENT\_PARTICIPANTS : includes  
    USERS ||--o{ AGREEMENT\_PARTICIPANTS : participates  
    AGREEMENTS ||--o{ CONSENT\_RECORDS : records  
    AGREEMENTS ||--o{ VERIFICATION\_TASKS : contains  
    VERIFICATION\_TASKS ||--o{ VERIFICATION\_RESPONSES : receives  
    VERIFICATION\_TASKS ||--o| OTP\_MILESTONES : may\_use  
    AGREEMENTS ||--o{ EXTERNAL\_ACTIONS : tracks  
    AGREEMENTS ||--o{ TIMELINE\_EVENTS : records  
    AGREEMENTS ||--o| SUBSCRIPTIONS : may\_create  
    AGREEMENTS ||--o{ REVIEWS : produces  
    AGREEMENTS ||--o{ DISPUTES : may\_have  
    AGREEMENTS ||--o{ ATTACHMENTS : contains  
    USERS ||--o{ NOTIFICATIONS : receives  
\`\`\`

\---

\# 8\. Rent Module

\#\# 8.1 Goal

Allow a verified owner to list an item and a verified renter to request, negotiate, consent to, receive, use, and return the item through a documented workflow.

\#\# 8.2 Business Rules

1\. Owners and renters must complete minimum identity verification before activating an agreement.  
2\. One physical item cannot have overlapping active rental agreements.  
3\. Negotiation may happen on WhatsApp.  
4\. Final terms must be entered into the app before agreement consent.  
5\. Both parties must consent to the same immutable agreement version.  
6\. Any terms changed after consent require a new version and renewed consent.  
7\. The renter must inspect the item before entering the pickup code.  
8\. Pickup-code entry records the renter’s acknowledgment of the declared handover condition.  
9\. Payment happens outside the platform.  
10\. The owner confirms actual receipt of payment before issuing the payment verification code.  
11\. The item return requires owner inspection.  
12\. Damage disputes preserve evidence and prevent ordinary completion.  
13\. An item remains reserved or rented until the agreement is completed, cancelled, or administratively resolved.

\---

\#\# 8.3 Complete Rent Flow

\`\`\`mermaid  
flowchart TD  
    A\[Renter discovers item\] \--\> B\[View item details\]  
    B \--\> C{Renter eligible?}  
    C \-- No \--\> D\[Login, profile or KYC\]  
    D \--\> C  
    C \-- Yes \--\> E\[Submit rental request\]  
    E \--\> F\[Owner receives notification\]  
    F \--\> G{Owner decision}  
    G \-- Reject \--\> H\[Request Rejected\]  
    G \-- No response \--\> I\[Request Expired\]  
    G \-- Accept \--\> J\[Request Accepted\]

    J \--\> K\[Open WhatsApp with contextual message\]  
    K \--\> L\[Parties negotiate externally\]  
    L \--\> M\[Return to app reminder\]  
    M \--\> N{Deal agreed?}  
    N \-- No \--\> O\[Cancel request\]  
    N \-- Yes \--\> P\[Enter final terms\]

    P \--\> Q\[Generate versioned rental agreement\]  
    Q \--\> R\[Owner reviews and consents\]  
    R \--\> S\[Renter reviews warnings and consents\]  
    S \--\> T{Both consented to same version?}  
    T \-- No \--\> U\[Wait for consent or revise terms\]  
    U \--\> Q  
    T \-- Yes \--\> V\[Agreement Confirmed and Item Reserved\]

    V \--\> W\[External payment initiated\]  
    W \--\> X\[App asks renter: Payment sent?\]  
    X \--\> Y{Renter confirms?}  
    Y \-- No \--\> W  
    Y \-- Yes \--\> Z\[Owner asked to verify receipt\]  
    Z \--\> AA{Owner received payment?}  
    AA \-- No \--\> AB\[Payment Pending or Disputed\]  
    AA \-- Yes \--\> AC\[Issue payment verification code\]  
    AC \--\> AD\[Renter enters code\]  
    AD \--\> AE\[Payment Verified\]

    AE \--\> AF\[Meet for item handover\]  
    AF \--\> AG\[Renter inspects item and photos\]  
    AG \--\> AH{Condition accepted?}  
    AH \-- No \--\> AI\[Record issue, revise or cancel\]  
    AH \-- Yes \--\> AJ\[Owner issues pickup code\]  
    AJ \--\> AK\[Renter enters pickup code\]  
    AK \--\> AL\[Pickup Inspection Acknowledged\]  
    AL \--\> AM\[Agreement Active\]

    AM \--\> AN\[Rental period and reminders\]  
    AN \--\> AO\[Return due\]  
    AO \--\> AP\[Renter returns item\]  
    AP \--\> AQ\[Owner inspects returned item\]  
    AQ \--\> AR{Condition acceptable?}  
    AR \-- Yes \--\> AS\[Owner confirms return\]  
    AS \--\> AT\[Renter verifies closure\]  
    AT \--\> AU\[Agreement Completed\]  
    AU \--\> AV\[Reviews and verified history\]

    AR \-- No \--\> AW\[Open damage dispute\]  
    AW \--\> AX\[Upload photos, estimate and remarks\]  
    AX \--\> AY\[Generate evidence package\]  
    AY \--\> AZ\[Resolution, settlement or external legal action\]  
\`\`\`

\---

\#\# 8.4 UML Sequence — Rental Journey

\`\`\`mermaid  
sequenceDiagram  
    actor Renter  
    participant App as Flutter App  
    participant DB as Firestore  
    participant CF as Cloud Functions  
    actor Owner  
    participant WA as WhatsApp  
    participant Pay as External Payment App  
    participant FCM as Notifications

    Renter-\>\>App: Send rental request  
    App-\>\>CF: createRequest()  
    CF-\>\>DB: Create pending request  
    CF-\>\>FCM: Notify owner  
    Owner-\>\>App: Accept request  
    App-\>\>CF: acceptRequest()  
    CF-\>\>DB: Update request to accepted  
    CF-\>\>FCM: Notify renter

    Renter-\>\>App: Open WhatsApp  
    App-\>\>DB: Record external action opened  
    App-\>\>WA: Launch contextual message  
    Renter-\>\>Owner: Negotiate terms externally

    Renter-\>\>App: Confirm deal agreed  
    Owner-\>\>App: Confirm final terms  
    App-\>\>CF: generateAgreement()  
    CF-\>\>DB: Save immutable agreement version

    Owner-\>\>App: Consent to agreement  
    App-\>\>CF: recordConsent()  
    Renter-\>\>App: Consent to agreement  
    App-\>\>CF: recordConsent()  
    CF-\>\>DB: Activate confirmed agreement

    Renter-\>\>Pay: Make external payment  
    Renter-\>\>App: Declare payment sent  
    App-\>\>CF: createPaymentVerificationTask()  
    CF-\>\>FCM: Ask owner to verify  
    Owner-\>\>App: Confirm payment received  
    App-\>\>CF: issuePaymentCode()  
    CF--\>\>Owner: Display one-time code  
    Owner--\>\>Renter: Share code  
    Renter-\>\>App: Enter payment code  
    App-\>\>CF: consumeCode()  
    CF-\>\>DB: Mark payment verified

    Renter-\>\>Owner: Meet and inspect item  
    Owner-\>\>App: Issue pickup code  
    Owner--\>\>Renter: Share pickup code  
    Renter-\>\>App: Enter pickup code  
    App-\>\>CF: verifyPickupCode()  
    CF-\>\>DB: Mark pickup acknowledged  
    CF-\>\>DB: Set agreement active  
    CF-\>\>FCM: Notify both parties

    Renter-\>\>Owner: Return item  
    Owner-\>\>App: Accept return or report damage  
    App-\>\>CF: processReturn()  
    CF-\>\>DB: Complete agreement or create dispute  
\`\`\`

\---

\#\# 8.5 Rental Agreement State Machine

\`\`\`mermaid  
stateDiagram-v2  
    \[\*\] \--\> Draft  
    Draft \--\> AwaitingConsent  
    AwaitingConsent \--\> Confirmed: Both consent  
    AwaitingConsent \--\> Draft: Terms revised  
    AwaitingConsent \--\> Cancelled

    Confirmed \--\> PaymentPending  
    PaymentPending \--\> PaymentDeclared  
    PaymentDeclared \--\> PaymentVerified  
    PaymentDeclared \--\> PaymentDisputed  
    PaymentDisputed \--\> PaymentPending  
    PaymentDisputed \--\> Cancelled

    PaymentVerified \--\> PickupPending  
    PickupPending \--\> PickupIssueReported  
    PickupIssueReported \--\> PickupPending: Issue resolved  
    PickupIssueReported \--\> Cancelled  
    PickupPending \--\> Active: Pickup code consumed

    Active \--\> ExtensionPending  
    ExtensionPending \--\> Active: Extension rejected  
    ExtensionPending \--\> Extended: Extension accepted  
    Extended \--\> Active

    Active \--\> ReturnPending  
    ReturnPending \--\> Completed: Return accepted  
    ReturnPending \--\> DamageDisputed: Damage reported  
    DamageDisputed \--\> Completed: Resolved  
    DamageDisputed \--\> Archived: External resolution

    Draft \--\> Cancelled  
    Confirmed \--\> Cancelled  
    Completed \--\> Archived  
    Cancelled \--\> Archived  
\`\`\`

\---

\# 9\. Payment Verification

\#\# 9.1 Purpose

The platform does not process payment. It creates a mutually verified record that:

1\. The payer declared payment was sent.  
2\. The recipient declared payment was received.  
3\. A milestone-specific verification code was issued.  
4\. The payer entered the code.  
5\. The amount, method, date, references, and remarks were recorded.

This does not independently verify the bank transaction unless a payment provider API is integrated later.

\#\# 9.2 Payment Flow

\`\`\`mermaid  
flowchart TD  
    A\[Payment task created\] \--\> B\[Open UPI or selected payment app\]  
    B \--\> C\[User returns to platform\]  
    C \--\> D{Did you send payment?}  
    D \-- No \--\> E\[Keep task pending\]  
    D \-- Yes \--\> F\[Enter amount, reference and optional screenshot\]  
    F \--\> G\[Notify payment recipient\]  
    G \--\> H{Did you receive payment?}  
    H \-- No \--\> I\[Add rejection remark\]  
    I \--\> J\[Task marked disputed\]  
    H \-- Yes \--\> K\[Confirm amount received\]  
    K \--\> L\[Generate recipient-authorized one-time code\]  
    L \--\> M\[Recipient shares code with payer\]  
    M \--\> N\[Payer enters code\]  
    N \--\> O{Code valid?}  
    O \-- No \--\> P\[Retry or request new code\]  
    O \-- Yes \--\> Q\[Payment milestone verified\]  
    Q \--\> R\[Create timeline and history entry\]  
\`\`\`

\#\# 9.3 UML Sequence — Payment

\`\`\`mermaid  
sequenceDiagram  
    actor Payer  
    participant App as Flutter App  
    participant Payment as UPI or Bank App  
    participant CF as Cloud Functions  
    participant DB as Firestore  
    actor Recipient  
    participant FCM as Notifications

    Payer-\>\>App: Start external payment  
    App-\>\>DB: Record external payment action  
    App-\>\>Payment: Open payment application  
    Payment--\>\>Payer: Payment result shown externally  
    Payer-\>\>App: Declare payment sent  
    App-\>\>CF: submitPaymentDeclaration()  
    CF-\>\>DB: Store amount and reference  
    CF-\>\>FCM: Notify recipient

    Recipient-\>\>App: Confirm actual receipt  
    App-\>\>CF: confirmPaymentReceipt()  
    CF-\>\>DB: Record recipient confirmation  
    CF-\>\>CF: Generate hashed, expiring code  
    CF--\>\>Recipient: Display code

    Recipient--\>\>Payer: Share code  
    Payer-\>\>App: Enter code  
    App-\>\>CF: consumePaymentCode()  
    CF-\>\>DB: Mark verification task verified  
    CF-\>\>DB: Append immutable timeline event  
    CF-\>\>FCM: Notify both parties  
\`\`\`

\#\# 9.4 Code Rules

\- Six digits for usability, with attempt limits.  
\- Store only a cryptographic hash.  
\- Maximum five failed attempts.  
\- Expire after a configurable period, such as 30 minutes.  
\- One-time use.  
\- Bound to one agreement, task, recipient, payer, and amount.  
\- Generated only after the recipient confirms receipt.  
\- Regeneration invalidates the previous code.  
\- Never display a valid code in push-notification text.  
\- Code consumption must occur through a server-side transaction.

\---

\# 10\. Pickup and Inspection Approval

\#\# 10.1 Product Meaning

Before pickup-code entry, the renter must see:

\- Item details.  
\- Current-condition declaration.  
\- Handover photographs.  
\- Known defects.  
\- Accessories included.  
\- Safety warnings.  
\- Damage responsibility clause.  
\- A clear acknowledgment checkbox.

Recommended wording:

\> “I inspected the item and its listed accessories. I accept the recorded handover condition, including the disclosed defects. Entering the pickup code records my acknowledgment that I received the item in this condition.”

\#\# 10.2 Pickup Flow

\`\`\`mermaid  
flowchart TD  
    A\[Pickup appointment begins\] \--\> B\[Owner uploads or confirms handover photos\]  
    B \--\> C\[Renter reviews item and accessories\]  
    C \--\> D{Renter finds an issue?}  
    D \-- Yes \--\> E\[Add photo and remark\]  
    E \--\> F{Owner agrees to update condition record?}  
    F \-- Yes \--\> B  
    F \-- No \--\> G\[Cancel or open pre-handover dispute\]  
    D \-- No \--\> H\[Renter accepts inspection statement\]  
    H \--\> I\[Owner requests pickup code\]  
    I \--\> J\[System generates one-time pickup code\]  
    J \--\> K\[Owner shares code\]  
    K \--\> L\[Renter enters code\]  
    L \--\> M{Code valid?}  
    M \-- No \--\> N\[Retry or regenerate\]  
    M \-- Yes \--\> O\[Record inspection acknowledgment\]  
    O \--\> P\[Set item status to Rented\]  
    P \--\> Q\[Set agreement status to Active\]  
\`\`\`

\#\# 10.3 UML Sequence — Pickup Inspection

\`\`\`mermaid  
sequenceDiagram  
    actor Owner  
    actor Renter  
    participant App as Flutter App  
    participant Storage as Firebase Storage  
    participant CF as Cloud Functions  
    participant DB as Firestore

    Owner-\>\>App: Confirm handover condition  
    Owner-\>\>App: Upload handover photos  
    App-\>\>Storage: Store photos  
    App-\>\>DB: Save attachment metadata

    Renter-\>\>App: Review item, defects and accessories  
    Renter-\>\>App: Accept inspection acknowledgment  
    Owner-\>\>App: Request pickup code  
    App-\>\>CF: issuePickupCode()  
    CF-\>\>DB: Save hashed code and expiry  
    CF--\>\>Owner: Display pickup code

    Owner--\>\>Renter: Share pickup code  
    Renter-\>\>App: Enter pickup code  
    App-\>\>CF: consumePickupCode()  
    CF-\>\>DB: Save acknowledgment event  
    CF-\>\>DB: Set agreement active  
    CF-\>\>DB: Set listing rented  
\`\`\`

\---

\# 11\. Item Return and Damage

\#\# 11.1 Return Outcomes

The owner may:

1\. Accept the return.  
2\. Accept with remarks.  
3\. Report missing accessories.  
4\. Report damage.  
5\. Request a repair or replacement amount.  
6\. Open a dispute.

Normal wear and tear must be distinguished from chargeable damage in the agreement.

\#\# 11.2 Return Flow

\`\`\`mermaid  
flowchart TD  
    A\[Return due reminder\] \--\> B\[Renter returns item\]  
    B \--\> C\[Owner inspects item\]  
    C \--\> D\[Compare pickup and return records\]  
    D \--\> E{Return acceptable?}

    E \-- Yes \--\> F\[Owner confirms satisfactory return\]  
    F \--\> G\[Optional return code or mutual confirmation\]  
    G \--\> H\[Renter verifies closure\]  
    H \--\> I\[Agreement completed\]  
    I \--\> J\[Listing becomes available\]  
    J \--\> K\[Reviews enabled\]

    E \-- No \--\> L\[Owner reports damage or missing item\]  
    L \--\> M\[Upload current photos and remarks\]  
    M \--\> N\[Enter estimated repair or replacement cost\]  
    N \--\> O\[Notify renter\]  
    O \--\> P{Renter response}  
    P \-- Accept \--\> Q\[Create external settlement task\]  
    P \-- Reject \--\> R\[Open dispute\]  
    Q \--\> S\[Verify settlement using payment workflow\]  
    S \--\> T\[Close dispute and agreement\]  
    R \--\> U\[Preserve evidence and admin review\]  
    U \--\> V\[Generate downloadable evidence package\]  
\`\`\`

\#\# 11.3 UML Sequence — Damage Dispute

\`\`\`mermaid  
sequenceDiagram  
    actor Owner  
    participant App as Flutter App  
    participant Storage as Firebase Storage  
    participant CF as Cloud Functions  
    participant DB as Firestore  
    actor Renter  
    participant Admin as Admin Portal

    Owner-\>\>App: Report damage  
    Owner-\>\>App: Upload photos and repair estimate  
    App-\>\>Storage: Store evidence  
    App-\>\>CF: createDamageDispute()  
    CF-\>\>DB: Create dispute  
    CF-\>\>DB: Lock relevant timeline records  
    CF--\>\>Renter: Send dispute notification

    Renter-\>\>App: Accept or reject claim  
    alt Renter accepts  
        App-\>\>CF: createSettlementTask()  
        CF-\>\>DB: Create external payment verification task  
    else Renter rejects  
        App-\>\>CF: escalateDispute()  
        CF-\>\>DB: Set admin review pending  
        Admin-\>\>DB: Review allowed evidence  
        Admin--\>\>Owner: Record administrative outcome  
        Admin--\>\>Renter: Record administrative outcome  
    end  
\`\`\`

\---

\# 12\. Hire Module

\#\# 12.1 Goal

Allow workers to publish service profiles and customers to discover, request, negotiate, hire, and verify service completion.

\#\# 12.2 Worker Profile Types

Support both:

\- Individual worker.  
\- Small team or service business.

\`\`\`json  
{  
  "providerType": "individual | team | business",  
  "teamSize": 1,  
  "businessName": null  
}  
\`\`\`

\#\# 12.3 Business Rules

\- Phone verification is mandatory.  
\- KYC should be mandatory before accepting a job.  
\- Rates should be displayed as “starting from” unless fixed.  
\- Worker availability must be maintained.  
\- WhatsApp messages should include skill, job description, location, and preferred date.  
\- Final scope and price must be entered in the app.  
\- Both parties consent to the service agreement.  
\- Completion is mutually verified.  
\- Reviews measure work quality, punctuality, professionalism, and communication.

\#\# 12.4 Hire Flow

\`\`\`mermaid  
flowchart TD  
    A\[Customer searches by skill and location\] \--\> B\[View worker profile\]  
    B \--\> C\[Check availability, portfolio and trust\]  
    C \--\> D\[Submit job request\]  
    D \--\> E\[Worker receives request\]  
    E \--\> F{Worker decision}  
    F \-- Reject \--\> G\[Request rejected\]  
    F \-- Expire \--\> H\[Request expired\]  
    F \-- Accept \--\> I\[Open WhatsApp\]  
    I \--\> J\[Discuss scope externally\]  
    J \--\> K\[Return to app\]  
    K \--\> L{Job agreed?}  
    L \-- No \--\> M\[Cancel request\]  
    L \-- Yes \--\> N\[Enter final scope, date and price\]  
    N \--\> O\[Generate service agreement\]  
    O \--\> P\[Customer consents\]  
    P \--\> Q\[Worker consents\]  
    Q \--\> R\[Agreement confirmed\]  
    R \--\> S\[Optional advance payment verification\]  
    S \--\> T\[Service in progress\]  
    T \--\> U\[Worker marks work complete\]  
    U \--\> V\[Customer inspects work\]  
    V \--\> W{Customer accepts?}  
    W \-- Yes \--\> X\[Final payment verification\]  
    X \--\> Y\[Agreement completed\]  
    Y \--\> Z\[Reviews and service history\]  
    W \-- No \--\> AA\[Rework request or dispute\]  
\`\`\`

\#\# 12.5 UML Sequence — Hire

\`\`\`mermaid  
sequenceDiagram  
    actor Customer  
    participant App as Flutter App  
    participant CF as Cloud Functions  
    participant DB as Firestore  
    actor Worker  
    participant WA as WhatsApp  
    participant FCM as Notifications

    Customer-\>\>App: Send service request  
    App-\>\>CF: createHireRequest()  
    CF-\>\>DB: Save pending request  
    CF-\>\>FCM: Notify worker  
    Worker-\>\>App: Accept  
    App-\>\>CF: acceptRequest()  
    CF-\>\>DB: Update request

    Customer-\>\>App: Open WhatsApp  
    App-\>\>WA: Launch job-context message  
    Customer-\>\>Worker: Discuss work and price  
    Customer-\>\>App: Submit agreed scope  
    Worker-\>\>App: Confirm agreed scope

    App-\>\>CF: generateServiceAgreement()  
    CF-\>\>DB: Save agreement version  
    Customer-\>\>App: Consent  
    Worker-\>\>App: Consent  
    CF-\>\>DB: Confirm agreement

    Worker-\>\>App: Mark service complete  
    CF-\>\>FCM: Ask customer to inspect  
    Customer-\>\>App: Accept or dispute completion  
    CF-\>\>DB: Complete agreement or create dispute  
\`\`\`

\---

\# 13\. Subscription and Recurring Agreement Support

\#\# 13.1 Meaning of “Subscribed”

A subscription is not created merely because a user clicks a button.

A subscription must follow a request-and-acceptance process:

\`\`\`text  
Subscriber raises request  
→ Provider accepts  
→ Terms are finalized  
→ Both parties consent  
→ Subscription becomes active  
→ Recurring milestones are created  
→ Each external payment or delivery is mutually verified  
→ Subscription appears in both users’ histories  
\`\`\`

Examples:

\- Monthly equipment rental.  
\- Recurring cleaning service.  
\- Monthly maintenance.  
\- Weekly worker engagement.  
\- Long-term tool rental.

\#\# 13.2 Subscription Flow

\`\`\`mermaid  
flowchart TD  
    A\[User requests recurring service or rental\] \--\> B\[Provider reviews request\]  
    B \--\> C{Provider accepts?}  
    C \-- No \--\> D\[Rejected\]  
    C \-- Yes \--\> E\[Define frequency, amount and duration\]  
    E \--\> F\[Generate recurring agreement\]  
    F \--\> G\[Both parties consent\]  
    G \--\> H\[Subscription Active\]  
    H \--\> I\[Scheduler creates next milestone\]  
    I \--\> J\[External payment or service occurs\]  
    J \--\> K\[Requester confirms completion\]  
    K \--\> L\[Other party verifies with remark\]  
    L \--\> M{Both agree?}  
    M \-- Yes \--\> N\[Milestone Verified\]  
    M \-- No \--\> O\[Milestone Disputed\]  
    N \--\> P\[Update subscription history\]  
    P \--\> Q{More cycles?}  
    Q \-- Yes \--\> I  
    Q \-- No \--\> R\[Subscription Completed\]  
    H \--\> S\[Pause or cancellation request\]  
    S \--\> T\[Apply notice and agreement rules\]  
    T \--\> U\[Paused or Cancelled\]  
\`\`\`

\#\# 13.3 UML Sequence — Subscription Milestone

\`\`\`mermaid  
sequenceDiagram  
    actor Subscriber  
    participant App as Flutter App  
    participant Scheduler as Scheduled Cloud Function  
    participant DB as Firestore  
    participant FCM as Notifications  
    actor Provider

    Scheduler-\>\>DB: Find subscriptions with nextDueAt  
    Scheduler-\>\>DB: Create recurring verification task  
    Scheduler-\>\>FCM: Send due reminder to both parties

    Subscriber-\>\>App: Declare payment or service cycle completed  
    App-\>\>DB: Save first-party response  
    FCM--\>\>Provider: Verification requested  
    Provider-\>\>App: Approve, reject, and add remark

    alt Both agree  
        App-\>\>DB: Mark milestone verified  
        App-\>\>DB: Update nextDueAt  
        App-\>\>DB: Append subscription history  
    else Disagreement  
        App-\>\>DB: Mark milestone disputed  
    end  
\`\`\`

\---

\# 14\. Generic Verification Engine

Every external step becomes a \`VerificationTask\`.

\#\# 14.1 Supported Task Types

\- \`PAYMENT\`  
\- \`DEPOSIT\_PAYMENT\`  
\- \`PICKUP\_INSPECTION\`  
\- \`ITEM\_RECEIVED\`  
\- \`MONTHLY\_PAYMENT\`  
\- \`SERVICE\_STARTED\`  
\- \`SERVICE\_COMPLETED\`  
\- \`ITEM\_RETURNED\`  
\- \`DEPOSIT\_RETURNED\`  
\- \`DAMAGE\_SETTLEMENT\`  
\- \`SUBSCRIPTION\_CYCLE\`

\#\# 14.2 Verification State Machine

\`\`\`mermaid  
stateDiagram-v2  
    \[\*\] \--\> Pending  
    Pending \--\> InitiatorConfirmed  
    InitiatorConfirmed \--\> Verified: Verifier approves  
    InitiatorConfirmed \--\> Rejected: Verifier rejects  
    Rejected \--\> InitiatorConfirmed: Initiator resubmits  
    Rejected \--\> Disputed  
    Pending \--\> Expired  
    InitiatorConfirmed \--\> Expired  
    Verified \--\> \[\*\]  
    Disputed \--\> Resolved  
    Resolved \--\> Verified  
    Resolved \--\> Cancelled  
\`\`\`

\#\# 14.3 Required Responses

Initiating party:

\- Completed: Yes/No.  
\- Amount, where applicable.  
\- Date and time.  
\- Reference number, where applicable.  
\- Remarks.  
\- Optional attachment.

Verifying party:

\- Approve or reject.  
\- Confirmed amount.  
\- Remarks.  
\- Optional attachment.

\---

\# 15\. External Interaction Pattern

After every WhatsApp, phone, or payment handoff, the app must preserve a pending return action.

\#\# 15.1 External Interaction Flow

\`\`\`mermaid  
flowchart TD  
    A\[User taps external action\] \--\> B\[Create ExternalAction record\]  
    B \--\> C\[Launch WhatsApp, phone or payment app\]  
    C \--\> D\[User leaves application\]  
    D \--\> E{User returns through deep link?}  
    E \-- Yes \--\> F\[Show completion question\]  
    E \-- No \--\> G\[Scheduled reminder\]  
    G \--\> H\[Push notification\]  
    H \--\> F  
    F \--\> I{Was the step completed?}  
    I \-- No \--\> J\[Keep pending or reschedule\]  
    I \-- Yes \--\> K\[Collect completion details\]  
    K \--\> L\[Create verification request\]  
    L \--\> M\[Other party verifies with remark\]  
\`\`\`

\#\# 15.2 WhatsApp Template Examples

\#\#\# Rent

\`\`\`text  
Hi {ownerName}, I am interested in renting {itemName} from  
{startDate} to {endDate}. My request reference is {requestId}.  
\`\`\`

\#\#\# Hire

\`\`\`text  
Hi {workerName}, I need a {skillName} for {jobSummary} on  
{preferredDate}. My request reference is {requestId}.  
\`\`\`

Do not place sensitive KYC information or private contract details in WhatsApp messages.

\---

\# 16\. Listing Lifecycles

\#\# 16.1 Generic Listing States

\`\`\`mermaid  
stateDiagram-v2  
    \[\*\] \--\> Draft  
    Draft \--\> ModerationPending  
    ModerationPending \--\> Published  
    ModerationPending \--\> Rejected  
    Rejected \--\> Draft  
    Published \--\> Hidden  
    Hidden \--\> Published  
    Published \--\> Suspended  
    Published \--\> Archived  
    Suspended \--\> Published: Admin restores  
    Archived \--\> \[\*\]  
\`\`\`

\#\# 16.2 Rental Item Availability

\`\`\`text  
AVAILABLE  
RESERVED  
RENTED  
MAINTENANCE  
HIDDEN  
\`\`\`

\#\# 16.3 Worker Availability

\`\`\`text  
AVAILABLE\_NOW  
AVAILABLE\_TODAY  
AVAILABLE\_THIS\_WEEK  
BY\_APPOINTMENT  
BUSY  
ON\_LEAVE  
INACTIVE  
\`\`\`

Availability must be separate from listing-publication status.

\---

\# 17\. Request Lifecycle

\`\`\`mermaid  
stateDiagram-v2  
    \[\*\] \--\> Sent  
    Sent \--\> Viewed  
    Sent \--\> CancelledByRequester  
    Sent \--\> Expired  
    Viewed \--\> Accepted  
    Viewed \--\> Rejected  
    Viewed \--\> CancelledByRequester  
    Viewed \--\> Expired  
    Accepted \--\> Negotiating  
    Negotiating \--\> AgreementCreated  
    Negotiating \--\> Cancelled  
    AgreementCreated \--\> \[\*\]  
\`\`\`

Server-side validation must prevent:

\- Accepting an expired request.  
\- Accepting a request for an unavailable item.  
\- Creating multiple agreements from one request.  
\- Users requesting their own listing.

\---

\# 18\. Agreement Versioning and Consent

\#\# 18.1 Agreement Immutability

Once either party consents:

\- The agreement snapshot cannot be edited.  
\- A change creates a new version.  
\- Previous consent is invalid for the new version.  
\- Both parties must consent again.

Store:

\`\`\`json  
{  
  "agreementId": "agr\_123",  
  "version": 3,  
  "templateVersion": "rent-in-v1.2",  
  "contentHash": "SHA-256...",  
  "ownerConsentStatus": "accepted",  
  "renterConsentStatus": "accepted"  
}  
\`\`\`

\#\# 18.2 Consent Evidence

Record:

\- User ID.  
\- Agreement ID and version.  
\- Content hash.  
\- Timestamp from the server.  
\- Device identifier hash.  
\- IP address hash, only if legally justified.  
\- Application version.  
\- Checkbox acknowledgments.  
\- Consent language version.  
\- Authentication context.

Never allow the client to directly write consent timestamps or agreement hashes.

\---

\# 19\. Flutter Application Architecture

Use feature-first Clean Architecture.

\`\`\`text  
lib/  
├── app/  
│   ├── app.dart  
│   ├── router/  
│   ├── theme/  
│   ├── localization/  
│   └── dependency\_injection/  
├── core/  
│   ├── auth/  
│   ├── errors/  
│   ├── network/  
│   ├── firebase/  
│   ├── analytics/  
│   ├── notifications/  
│   ├── security/  
│   ├── widgets/  
│   └── utils/  
├── features/  
│   ├── authentication/  
│   ├── profile/  
│   ├── kyc/  
│   ├── discovery/  
│   ├── listings/  
│   ├── requests/  
│   ├── agreements/  
│   ├── consent/  
│   ├── verification/  
│   ├── payments/  
│   ├── rental/  
│   ├── hire/  
│   ├── subscriptions/  
│   ├── timeline/  
│   ├── reviews/  
│   ├── disputes/  
│   └── notifications/  
└── main.dart  
\`\`\`

Each feature:

\`\`\`text  
feature/  
├── presentation/  
│   ├── pages/  
│   ├── widgets/  
│   ├── cubit/  
│   └── models/  
├── domain/  
│   ├── entities/  
│   ├── repositories/  
│   └── usecases/  
└── data/  
    ├── models/  
    ├── datasources/  
    ├── repositories/  
    └── mappers/  
\`\`\`

Recommended state management:

\- Riverpod or Bloc/Cubit.  
\- Choose one and use it consistently.  
\- Bloc/Cubit is suitable when agreement state machines require explicit transitions.

\---

\# 20\. Flutter Screens

\#\# 20.1 Shared

\- Splash.  
\- Authentication.  
\- OTP verification.  
\- Profile setup.  
\- KYC.  
\- Home.  
\- Map discovery.  
\- Search filters.  
\- Notifications.  
\- Activity history.  
\- Agreement details.  
\- Timeline.  
\- Verification task.  
\- External-action return confirmation.  
\- Reviews.  
\- Reports and disputes.  
\- Settings and privacy.

\#\# 20.2 Rent

\- Rent discovery.  
\- Item details.  
\- Create/edit item.  
\- Availability calendar.  
\- Rental request form.  
\- Finalize rental terms.  
\- Rental agreement review.  
\- Digital consent.  
\- Payment declaration.  
\- Payment receipt verification.  
\- Pickup inspection checklist.  
\- Pickup code entry.  
\- Active rental dashboard.  
\- Return inspection.  
\- Damage report.  
\- Evidence package.

\#\# 20.3 Hire

\- Worker discovery.  
\- Worker profile.  
\- Create worker profile.  
\- Portfolio.  
\- Worker availability.  
\- Job request.  
\- Finalize job scope.  
\- Service agreement.  
\- Service progress.  
\- Completion inspection.  
\- Rework or dispute.

\#\# 20.4 Subscription

\- Subscription request.  
\- Frequency and terms.  
\- Active subscription dashboard.  
\- Recurring milestone history.  
\- Pause request.  
\- Cancellation request.

\---

\# 21\. UI/UX Design Requirements

\#\# 21.1 Navigation

Primary bottom navigation:

1\. Home.  
2\. Rent.  
3\. Hire.  
4\. Activity.  
5\. Profile.

Activity contains:

\- Requests.  
\- Active agreements.  
\- Verification pending.  
\- Rentals.  
\- Hires.  
\- Subscriptions.  
\- Completed history.  
\- Disputes.

\#\# 21.2 Status Design

Every state must have:

\- Human-readable label.  
\- Color.  
\- Icon.  
\- Next recommended action.  
\- Responsible party.  
\- Due date.  
\- Explanation.

Examples:

\- Yellow: Waiting for action.  
\- Green: Mutually verified.  
\- Red: Rejected or disputed.  
\- Blue: Active.  
\- Gray: Completed or archived.

Do not depend on color alone; include text and icons.

\#\# 21.3 Agreement Dashboard

Show:

\- Current agreement status.  
\- Item or service.  
\- Other party.  
\- Start/end dates.  
\- Agreed amount.  
\- Deposit.  
\- Next required action.  
\- Pending verification.  
\- Timeline.  
\- Documents and evidence.  
\- External contact action.  
\- Report problem action.

\#\# 21.4 Consent UX

Consent must not use dark patterns.

Requirements:

\- Display a summary first.  
\- Allow opening the full agreement.  
\- Highlight damage and payment responsibilities.  
\- Require explicit checkboxes.  
\- Disable consent until mandatory clauses are acknowledged.  
\- Show the agreement version.  
\- Provide download access.  
\- Warn that changed terms require renewed consent.

\---

\# 22\. Firebase Architecture

\#\# 22.1 Services

\- Firebase Authentication: phone authentication.  
\- Cloud Firestore: transactional data.  
\- Firebase Storage: photos and documents.  
\- Cloud Functions: trusted business logic.  
\- Firebase Cloud Messaging: notifications.  
\- Cloud Scheduler: reminders and expiry jobs.  
\- App Check: API abuse reduction.  
\- Crashlytics: crash monitoring.  
\- Analytics: funnel analytics.  
\- Remote Config: configurable limits and feature flags.

\#\# 22.2 Collections

\`\`\`text  
users  
user\_roles  
kyc\_records  
listings  
listing\_search  
requests  
agreements  
agreement\_versions  
agreement\_participants  
consent\_records  
verification\_tasks  
verification\_responses  
milestone\_codes  
external\_actions  
timeline\_events  
subscriptions  
reviews  
trust\_scores  
notifications  
reports  
disputes  
attachments  
admin\_actions  
audit\_logs  
\`\`\`

High-volume records such as timeline events may use subcollections:

\`\`\`text  
agreements/{agreementId}/timeline/{eventId}  
agreements/{agreementId}/verificationTasks/{taskId}  
agreements/{agreementId}/versions/{versionId}  
\`\`\`

Use collection-group queries only when required and indexed.

\---

\# 23\. Required Cloud Functions

1\. \`onUserCreated\`  
2\. \`handleKycWebhook\`  
3\. \`publishListing\`  
4\. \`moderateListing\`  
5\. \`createRequest\`  
6\. \`acceptRequest\`  
7\. \`expireRequests\`  
8\. \`generateAgreementVersion\`  
9\. \`recordAgreementConsent\`  
10\. \`activateAgreementAfterConsent\`  
11\. \`createVerificationTask\`  
12\. \`submitVerificationResponse\`  
13\. \`issueMilestoneCode\`  
14\. \`consumeMilestoneCode\`  
15\. \`recordExternalAction\`  
16\. \`sendExternalActionReminder\`  
17\. \`activateRentalAfterPickup\`  
18\. \`processRentalReturn\`  
19\. \`createDamageDispute\`  
20\. \`generateEvidencePackage\`  
21\. \`createRecurringSubscriptionTasks\`  
22\. \`sendDueReminders\`  
23\. \`calculateTrustScore\`  
24\. \`enableReviewsAfterCompletion\`  
25\. \`updateSearchIndex\`  
26\. \`enforceListingAvailability\`  
27\. \`writeAuditEvent\`

All critical transitions must be implemented server-side, not trusted to the Flutter client.

\---

\# 24\. Security Rules Matrix

| Collection | Read | Create | Update | Delete |  
|---|---|---|---|---|  
| Users | Owner and limited public fields | Authenticated owner/server | Owner for allowed fields | Admin only |  
| KYC records | Owner and authorized admin | Server/provider | Server only | Restricted admin |  
| Listings | Public if published | Verified owner | Owner, with status restrictions | Archive only |  
| Requests | Participants | Requester through function | Participants through function | No hard delete |  
| Agreements | Participants/admin | Cloud Function only | Cloud Function only | Never |  
| Consent records | Participants/admin | Cloud Function only | Never | Never |  
| Verification tasks | Participants | Cloud Function only | Cloud Function only | Never |  
| Codes | No direct code-hash read | Cloud Function only | Cloud Function only | Expiry process |  
| Timeline | Participants/admin | Cloud Function only | Never | Never |  
| Reviews | Public with privacy controls | Eligible participant | Limited correction window | Moderation only |  
| Disputes | Participants/admin | Participant through function | Controlled workflow | Never |  
| Attachments | Authorized parent readers | Authorized participant | Metadata only | Retention policy |

Additional requirements:

\- Use Firebase App Check.  
\- Validate all state transitions.  
\- Prevent client-supplied server timestamps.  
\- Prevent users from reading another user’s private identity information.  
\- Use signed, expiring download URLs for protected evidence.  
\- Maintain immutable audit logs.  
\- Mask sensitive identifiers in UI and logs.

\---

\# 25\. Notifications

Required notifications:

\- New request.  
\- Request accepted or rejected.  
\- Request expiring.  
\- Return from WhatsApp reminder.  
\- Deal-finalization reminder.  
\- Agreement consent pending.  
\- Payment confirmation pending.  
\- Verification code expiring.  
\- Pickup due.  
\- Rental due tomorrow.  
\- Return overdue.  
\- Service scheduled.  
\- Service completion pending.  
\- Subscription payment due.  
\- Subscription verification pending.  
\- Extension request.  
\- Review pending.  
\- Damage dispute opened.  
\- Administrative update.

Reminder escalation example:

\`\`\`text  
Immediately → In-app pending task  
After 2 hours → Push reminder  
After 24 hours → Second reminder  
Before expiry → Final reminder  
After expiry → Mark expired and notify both parties  
\`\`\`

\---

\# 26\. Trust Score

Trust score inputs may include:

\- Phone verified.  
\- KYC verified.  
\- Profile completeness.  
\- Completed rentals.  
\- Completed jobs.  
\- Mutually verified milestones.  
\- Average ratings.  
\- Response time.  
\- Request cancellation rate.  
\- Agreement cancellation rate.  
\- Overdue returns.  
\- Disputes.  
\- Confirmed violations.  
\- Account age.

Do not expose the exact fraud-detection formula publicly.

A dispute alone should not automatically reduce trust. Only verified outcomes or repeated risk patterns should have significant impact.

\---

\# 27\. Analytics

Track:

\- Listing views.  
\- Map impressions.  
\- Search-to-detail conversion.  
\- Request creation.  
\- Request acceptance.  
\- WhatsApp opens.  
\- External payment opens.  
\- Return-to-app rate.  
\- Agreement creation.  
\- Consent completion.  
\- Payment-verification completion.  
\- Pickup-code completion.  
\- Agreement activation.  
\- Agreement completion.  
\- Dispute rate.  
\- Subscription renewal.  
\- Review completion.  
\- User retention.

Never send sensitive agreement, KYC, payment-reference, or dispute content to analytics systems.

\---

\# 28\. Critical Edge Cases

1\. Owner changes terms after renter consent.  
2\. One party never returns from WhatsApp.  
3\. Payer claims payment but recipient cannot find it.  
4\. Recipient confirms payment accidentally.  
5\. Verification code expires.  
6\. Too many incorrect code attempts.  
7\. User screenshots or shares a code with the wrong person.  
8\. Item condition differs from listing.  
9\. Renter refuses pickup after inspection.  
10\. Owner deletes listing during an agreement.  
11\. Item receives overlapping requests.  
12\. Owner accepts two requests simultaneously.  
13\. Rental return is overdue.  
14\. Owner fails to inspect the return.  
15\. Renter disputes damage.  
16\. Worker becomes unavailable after accepting.  
17\. Customer changes service scope.  
18\. Subscription cycle is skipped.  
19\. User blocks the other participant during an active agreement.  
20\. User account is suspended during an agreement.  
21\. KYC is revoked or expires.  
22\. Push notifications are disabled.  
23\. External payment application is unavailable.  
24\. Firestore write retries create duplicate events.  
25\. Device clock is incorrect.

Use idempotency keys for all critical Cloud Functions.

\---

\# 29\. Testing Strategy

\#\# 29.1 Unit Tests

\- State-transition validators.  
\- Agreement version hashing.  
\- Price and duration calculation.  
\- Code expiry and attempt logic.  
\- Trust-score calculation.  
\- Subscription recurrence calculation.

\#\# 29.2 Widget Tests

\- Consent checkboxes.  
\- Verification forms.  
\- Agreement dashboard.  
\- Request state presentation.  
\- Error and retry states.

\#\# 29.3 Integration Tests

\- Request to agreement.  
\- Dual consent.  
\- External-action return.  
\- Payment-code workflow.  
\- Pickup-code workflow.  
\- Return completion.  
\- Damage dispute.  
\- Subscription milestone.

\#\# 29.4 Firebase Emulator Tests

\- Security rules.  
\- Concurrent request acceptance.  
\- Duplicate code consumption.  
\- Unauthorized agreement access.  
\- Immutable consent and timeline records.  
\- Scheduled request expiration.

\---

\# 30\. Implementation Phases

\#\# Phase 1 — Foundation

\- Flutter project architecture.  
\- Firebase environments.  
\- Authentication.  
\- User profiles.  
\- Roles.  
\- Basic KYC integration.  
\- Navigation and design system.

\#\# Phase 2 — Discovery

\- Generic listings.  
\- Rent listings.  
\- Worker listings.  
\- Location search.  
\- Map and filters.  
\- Listing moderation.

\#\# Phase 3 — Core Trust Engine

\- Requests.  
\- Acceptance.  
\- WhatsApp handoff.  
\- External-action tracking.  
\- Generic agreements.  
\- Agreement versioning.  
\- Digital consent.

\#\# Phase 4 — Verification

\- Generic verification tasks.  
\- Payment declaration and confirmation.  
\- Milestone codes.  
\- Notifications and reminders.  
\- Agreement timeline.

\#\# Phase 5 — Rental Completion

\- Pickup inspection.  
\- Active rental dashboard.  
\- Return inspection.  
\- Damage dispute.  
\- Evidence package.

\#\# Phase 6 — Hire Completion

\- Worker availability.  
\- Service agreements.  
\- Service completion.  
\- Hire-specific reviews.

\#\# Phase 7 — Subscription and Administration

\- Recurring milestones.  
\- Subscription history.  
\- Admin portal.  
\- Trust score.  
\- Analytics.  
\- Moderation and abuse controls.

\---

\# 31\. Master Prompt for UI/UX Designer

\`\`\`text  
Design a mobile-first Flutter application for a neighborhood marketplace with  
two primary tabs: RENT and HIRE.

The platform does not process payments or provide in-app chat. It delegates  
communication to WhatsApp and payments to external UPI or banking applications.  
After every external interaction, users return to the app and answer whether  
the step was completed. The other party must verify the result with an approval,  
rejection, and optional remark.

The platform’s main purpose is discovery, identity, agreements, milestone  
verification, history, and trust.

Design the following end-to-end experiences:

1\. Phone login, profile setup, multiple user roles, and KYC.  
2\. Rent item discovery through map and grid views.  
3\. Worker discovery by skill, location, rate, and availability.  
4\. Request creation, acceptance, rejection, cancellation, and expiry.  
5\. Contextual WhatsApp handoff.  
6\. Return-to-app completion confirmation.  
7\. Final-term entry and agreement generation.  
8\. Versioned agreement review and explicit consent by both parties.  
9\. External payment declaration and recipient verification.  
10\. Milestone-specific one-time codes for payment, pickup, and optional return.  
11\. Rental pickup inspection with photos, defects, accessories, warnings, and  
    acknowledgment.  
12\. Active agreement dashboard with timeline, next action, due date, documents,  
    and pending verifications.  
13\. Rental return inspection and damage dispute.  
14\. Worker service completion and customer verification.  
15\. Recurring subscriptions created through request, acceptance, consent, and  
    recurring mutually verified milestones.  
16\. User rental, hire, subscription, and transaction histories.  
17\. Reviews, trust indicators, notifications, reports, and disputes.

UX requirements:

\- Always show who must act next.  
\- Always show the current agreement state.  
\- Use plain language rather than technical state names.  
\- Show legal and damage warnings clearly without using manipulative design.  
\- Do not imply that KYC guarantees trustworthiness.  
\- Do not claim that every digital acknowledgment is automatically legally  
  enforceable.  
\- Require explicit agreement checkboxes.  
\- Make external-action return prompts easy to complete.  
\- Support users with low technical literacy.  
\- Design for Indian users, mobile numbers, rupee formatting, UPI handoff,  
  unreliable networks, and Android-first usage.  
\- Use accessible colors, icons, labels, and minimum touch targets.  
\- Produce a component library, screen inventory, user flows, empty states,  
  loading states, error states, offline states, and responsive specifications.  
\`\`\`

\---

\# 32\. Master Prompt for AI Coding Agent

\`\`\`text  
Implement a production-oriented Flutter and Firebase application based on this  
Software Design Specification.

Architecture requirements:

\- Flutter with feature-first Clean Architecture.  
\- Use one consistent state-management solution: Bloc/Cubit or Riverpod.  
\- Firebase Authentication for phone login.  
\- Cloud Firestore for operational data.  
\- Firebase Storage for protected media.  
\- Cloud Functions for all trusted state transitions.  
\- Firebase Cloud Messaging and Cloud Scheduler for reminders.  
\- Firebase App Check, Crashlytics, Analytics, and Remote Config.  
\- Strongly typed Dart models with explicit enums.  
\- Repository interfaces in the domain layer.  
\- Data-source implementations in the data layer.  
\- Immutable presentation states.  
\- Server timestamps for all authoritative events.  
\- Idempotency keys for critical operations.  
\- No client-side direct updates to agreement, consent, code, verification,  
  dispute, or timeline status.  
\- Firestore security rules and emulator tests are mandatory.

Implement the backend as a generic platform:

Listing → Request → Agreement → VerificationTask → Timeline → History

Do not build separate duplicated transaction engines for Rent and Hire.  
Use agreementType, listingType, taskType, and templateVersion to specialize the  
shared engine.

Critical requirements:

1\. One account may have multiple roles.  
2\. Agreements are immutable after consent.  
3\. Term changes create a new agreement version and require renewed consent.  
4\. Consent records include the agreement content hash and server timestamp.  
5\. External WhatsApp and payment actions create ExternalAction records.  
6\. If users do not return, scheduled notifications must request completion.  
7\. Every external milestone supports first-party confirmation and second-party  
   verification with remarks.  
8\. Payment codes are created only after the payment recipient confirms receipt.  
9\. Pickup codes are one-time, expiring, hashed, attempt-limited, and bound to a  
   specific agreement and task.  
10\. Consuming the pickup code records inspection acknowledgment and activates  
    the rental.  
11\. Return damage creates a dispute and preserves evidence.  
12\. Recurring subscriptions generate scheduled verification tasks and remain  
    visible in both parties’ subscription histories.  
13\. Timeline events are append-only.  
14\. Sensitive KYC data must not be copied into ordinary user documents.  
15\. Protected evidence must use authorized, expiring access.  
16\. All lifecycle transitions require server-side validation.

For every feature, generate:

\- Domain entities.  
\- Dart enums.  
\- DTOs and Firestore converters.  
\- Repository interface.  
\- Repository implementation.  
\- Cloud Function endpoints.  
\- Cubit/Provider and immutable states.  
\- Pages and reusable widgets.  
\- Router configuration.  
\- Firestore indexes.  
\- Firestore security rules.  
\- Unit tests.  
\- Widget tests.  
\- Firebase Emulator integration tests.  
\- Error states, retry behavior, and analytics events.

Implement sequentially:

1\. Foundation and authentication.  
2\. Profiles, roles, and KYC status.  
3\. Listings and nearby discovery.  
4\. Requests.  
5\. External-action handoff.  
6\. Agreements and versioning.  
7\. Consent.  
8\. Verification tasks.  
9\. Payment verification codes.  
10\. Rental pickup inspection codes.  
11\. Active agreement dashboard and timeline.  
12\. Rental return and disputes.  
13\. Hire completion.  
14\. Subscriptions.  
15\. Reviews, trust score, notifications, and administration.

Do not generate placeholder business logic for critical workflows.  
When a business rule is ambiguous, record it as an explicit assumption before  
coding. Never describe digital consent, verification codes, or KYC as a  
guaranteed legal outcome.  
\`\`\`

\---

\# 33\. Final Consolidated Product Definition

The application is a neighborhood trust platform for renting items and hiring local workers.

It connects two users, lets them make a request, records acceptance, sends them to third-party applications for discussion and payment, and brings them back to confirm the outcome.

Every important external step becomes a structured verification task:

\`\`\`text  
One party reports completion  
→ The other party approves or rejects  
→ Both may add remarks and evidence  
→ The platform records the result in an immutable timeline  
\`\`\`

For rentals, both parties consent to a versioned rental agreement before handover. The renter inspects the item before entering a pickup code. The code records acknowledgment of the documented handover condition. External payments are verified through payer declaration, recipient confirmation, and a recipient-authorized one-time code. Item return is inspected and either completed or converted into a damage dispute.

For hiring, the same generic request, agreement, verification, timeline, and history engines are reused with service-specific screens and reviews.

For subscriptions, a user raises a recurring request, the provider accepts it, both parties consent, and each recurring cycle is verified and shown in subscription history.

The platform remains lightweight by delegating chat and payment execution to established third-party services while retaining the structured records, reminders, mutual verification, agreements, history, and trust mechanisms required for a complete user experience.