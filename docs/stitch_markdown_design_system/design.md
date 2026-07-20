Below is the complete, production-ready specifications document formatted as a `design.md` file. It can be handed directly to your UI/UX design team to build the design system, high-fidelity mockups, and interactive prototypes.
***
# File: `design.md`
# UI/UX Specification Document: P2P Neighborhood Sharing & Services Platform
This document serves as the absolute visual blueprint and single source of truth for the UI/UX design team. The platform acts as a secure, decentralized **Trust, Agreement, and Verification Layer**. The actual monetary transactions and communication are delegated to external platforms (WhatsApp and UPI), while the app manages identity, digital contracts, and physical handshakes via **Milestone-Specific Verification Codes**.
---
## 1. Global Visual Identity & Design System
All layouts must strictly align with the following design tokens, typographic hierarchies, and layout rules.
### 1.1 Color Token System
| Token Name | HEX Value | Visual Weight / Application |
| :--- | :--- | :--- |
| `ColorPrimary` | `#0D9488` | Teal (Teal 600) — Represents trust, safety, and core brand actions. |
| `ColorSecondary` | `#0F172A` | Slate (Slate 900) — Primary headers, navigation hubs, and body text. |
| `ColorBgDark` | `#F8FAFC` | Cool Slate (Slate 50) — Base canvas background for all screens. |
| `ColorSurface` | `#FFFFFF` | Pure White — Base background for cards, forms, bottom sheets, and dialogs. |
| `ColorTextMain` | `#1E293B` | Dark Slate (Slate 800) — Primary readable body text. |
| `ColorTextMuted` | `#64748B` | Slate Gray (Slate 500) — Secondary annotations, captions, and helper texts. |
| `ColorSuccess` | `#16A34A` | Green (Green 600) — Completed steps, active states, and verified indicators. |
| `ColorWarning` | `#D97706` | Amber (Amber 600) — Pending verifications, signatures, and warning borders. |
| `ColorDanger` | `#DC2626` | Red (Red 600) — Disputed agreements, damages, and cancellation indicators. |
### 1.2 Layout & Grid Specifications
* **Base Grid**: Strict **8dp spacing system**. All spacing, margins, gaps, and padding values must be multiples of 8 (e.g., 8, 16, 24, 32, 48).
* **Base Margins**: Left and right margins must be exactly **16dp** on mobile phone layouts.
* **Safe Areas**: Safe margins of **16dp** must be enforced below top status bars and above bottom system controls.
* **Touch Targets**: All interactive elements (buttons, selectors, input checkboxes) must have a minimum size of **48dp x 48dp** to ensure accessible touch controls.
### 1.3 Typography Rules
| Token Name | Font Size / Weight | Line Height | Usage Context |
| :--- | :--- | :--- | :--- |
| `H1` | 32sp / Bold (700) | 40sp | Onboarding headers, primary screen titles |
| `H2` | 24sp / Bold (700) | 32sp | Section headers, card titles, form names |
| `TitleMedium` | 18sp / SemiBold (600) | 24sp | Dialog headers, checklist titles |
| `BodyLarge` | 16sp / Regular (400) | 24sp | Standard body copy, user messages |
| `BodySmall` | 14sp / Regular (400) | 20sp | Captions, card labels, details |
| `LabelBold` | 14sp / Bold (700) | 16sp | Interactive buttons, navigation tabs |
| `Caption` | 12sp / Medium (500) | 16sp | Timestamps, warnings, secondary annotations |
---
## 2. Screen & Bottom Sheet Inventory
Use this master list to track the development status of your screens and bottom sheets:
### Module 1: Onboarding & Trust Profiling
* [ ] **AUTH-01 (Screen)**: Welcome, Value Propositions & Phone Registration
* [ ] **AUTH-02 (Screen)**: OTP Security Input Verification
* [ ] **AUTH-03 (Screen)**: Profile Creation & Platform Intent
* [ ] **AUTH-04 (Screen)**: KYC Identity Verification Hub (ID Upload & Live Checks)
### Module 2: Neighborhood Discovery Engine
* [ ] **DISC-01 (Screen)**: Unified Directory (Map/Grid Dual-View Main Hub)
* [ ] **DISC-01B (Bottom Sheet)**: Range, Category, and Trust Score Filters
* [ ] **DISC-02 (Bottom Sheet)**: Quick-Preview Card Map Marker Overlay
* [ ] **DISC-03 (Screen)**: Rental Item Details
### Module 3: Booking & Legal Contracting
* [ ] **BKG-01 (Bottom Sheet)**: Term Picker, Estimates & Damage Liability Warning
* [ ] **BKG-02 (Screen)**: Standard Legal Rental Agreement & Consent Gate
* [ ] **BKG-03 (Screen)**: Inbound Request Overview (Owner Evaluation Screen)
* [ ] **BKG-04 (Bottom Sheet)**: External Contact Handoff (WhatsApp Redirect Tool)
### Module 4: Three-Token Milestone Verification Engine
* [ ] **VFY-01 (Bottom Sheet)**: Pickup Verification Code Console (Inspection Sign-Off)
* [ ] **VFY-02 (Bottom Sheet)**: Payment Code Verification Tool (UPI Receipt Confirmation)
* [ ] **VFY-03 (Bottom Sheet)**: Return Code Check-In Form (Item Return Sign-Off)
* [ ] **VFY-04 (Bottom Sheet)**: Damage Dispute Reporter & Legal Document Release Portal
### Module 5: Active Agreements & Operational Logs
* [ ] **AGR-01 (Screen)**: Active Agreement Timeline & Status Console
* [ ] **AGR-02 (Screen)**: Historical Transactions Activity Log
### Module 6: Local Service Worker Directory
* [ ] **HIRE-01 (Screen)**: Local Worker Service Profile Page
* [ ] **HIRE-02 (Bottom Sheet)**: Service Request Form & Job Scope Setup
* [ ] **HIRE-03 (Screen)**: Service Worker Dashboard & Jobs Management
* [ ] **HIRE-04 (Bottom Sheet)**: Service Completion Code Console
### Module 7: Profile, Settings & Support
* [ ] **PROF-01 (Screen)**: Personal Account Settings & Profile Hub
* [ ] **PROF-02 (Screen)**: Trust Metrics & Peer Review Feed
---
## 3. Screen Specifications & Layout Blueprints
This section provides structural layouts, spacing, state transitions, and database bindings for every screen and bottom sheet.
### Module 1: Onboarding & Trust Profiling
#### AUTH-01: Welcome, Value Propositions & Phone Registration (Screen)
* **Goal**: Capture user phone numbers and present the app's key value propositions.
* **Layout Positioning**:
  * *Top Section*: App logo followed by a horizontal sliding carousel showcasing key value propositions ("Rent nearby", "Hire local workers", "Verify identity and trust").
  * *Middle Section*: Text input field with a country code prefix selector (`+91` pre-filled) and a 10-digit mobile number input.
  * *Lower Middle*: Consent checkbox with text: *"I accept the terms of service, rental liabilities, and safety guidelines."*
  * *Bottom Section*: Sticky primary action button: **[ GET OTP ]** (centered, full-width).
* **Spacing Rules**: Top safe area 24dp. Input field height 48dp. Consent checkbox vertical padding 16dp.
* **UI/UX Interactions**: The **[ GET OTP ]** button remains disabled in a muted state until a valid 10-digit phone number is entered and the consent checkbox is checked. Tapping input activates a teal outline.
* **Firestore Bindings**: Creates a new record in the `users` collection with `verificationStatus = 'unverified'`.
#### AUTH-02: OTP Security Input Verification (Screen)
* **Goal**: Validate the user's mobile number using Firebase SMS Authentication.
* **Layout Positioning**:
  * *Top Section*: Back navigation arrow (`ColorSecondary`). Screen title: *"Verification Code"* (H2 bold). Subtitle: *"We sent a verification code to +91 XXXX..."* (BodySmall).
  * *Middle Section*: Row of 6 individual OTP input boxes. Below the row: Resend timer countdown text: *"Didn't receive the code? Resend SMS in 45s"* (Caption style).
  * *Bottom Section*: Sticky primary action button: **[ VERIFY CODE ]** (centered, full-width).
* **Spacing Rules**: Individual OTP boxes are $44\text{dp} \times 52\text{dp}$, separated by 8dp gaps.
* **UI/UX Interactions**: Tapping an input field displays the numeric keyboard. Entering a digit moves focus to the next box automatically. If the verification fails, the borders of the input boxes turn red and display the error text: *"Invalid code. Please try again."*
* **Firestore Bindings**: Updates `users.verificationStatus` to `pending`.
#### AUTH-03: Profile Creation & Platform Intent (Screen)
* **Goal**: Set up the user's public profile and specify their default account roles.
* **Layout Positioning**:
  * *Top Section*: Screen title: *"Create Profile"* (H1 bold). Circular avatar selector (diameter 100dp) with a camera overlay icon.
  * *Middle Section*: Text input field: *"Full Display Name"* (standard height 48dp).
  * *Lower Middle*: Role selection section: *"How do you plan to use this platform?"* containing 4 selectable, multi-line checkboxes:
    * `[ ] I want to rent items from neighbors`
    * `[ ] I want to rent out my items to others`
    * `[ ] I want to hire local service workers`
    * `[ ] I want to list my skills as a service worker`
  * *Bottom Section*: Sticky primary action button: **[ CREATE ACCOUNT ]** (centered, full-width).
* **Spacing Rules**: Avatar selector vertical margin 24dp. Input fields separated by 16dp. Checked options are highlighted with a teal border.
* **UI/UX Interactions**: Tapping the avatar selector opens a native camera or gallery picker. Users can select multiple roles. Tapping role cards changes their border highlights to `ColorPrimary` (Teal).
* **Firestore Bindings**: Creates a document in the `profiles` collection with fields for `displayName`, `photoUrl`, and `skills`.
#### AUTH-04: KYC Identity Verification Hub (Screen)
* **Goal**: Capture and submit government-issued ID documents for identity verification.
* **Layout Positioning**:
  * *Top Section*: Title: *"Identity Verification"* (H2 bold). Status pill: *"Status: Unverified"* (Gray background).
  * *Middle Section*: Selection dropdown for government-issued ID type (Aadhaar, Passport, or Driving License).
  * *Lower Middle*: Large dashed camera card slot: *"Tap to photograph front of ID"* (containing camera icon).
  * *Bottom Section*: Sticky primary action button: **[ SUBMIT KYC DETAILS ]** (centered, full-width).
* **Spacing Rules**: Dashed upload slot dimensions $328\text{dp} \times 160\text{dp}$. Spacing between dropdown menu and card is 24dp.
* **UI/UX Interactions**: Uploading a document changes the dashed card's display to show a preview of the photo with a small "X" delete button in the top-right corner.
* **Firestore Bindings**: Saves the uploaded document image reference path to `users.kycDetails.kycDocumentUrl` and updates the verification status to `pending`.
---
### Module 2: Neighborhood Discovery Engine
#### DISC-01: Unified Directory Map/Grid (Screen)
* **Goal**: Main dashboard to browse and search available items and local service workers.
```
+-------------------------------------------------------------------+
| [Icon: Pin] location: Sector 4 layout (1.5km)        [Icon: Bell] |
+-------------------------------------------------------------------+
|  [     RENT ITEMS (Active)    ]    [     HIRE SERVICES     ]      |
+-------------------------------------------------------------------+
|  [Icon: Search] Search items, tools, and services...             |
+-------------------------------------------------------------------+
|  [Filter: Tools]   [Filter: Camping]   [Filter: Ladders]  [More]  |
+-------------------------------------------------------------------+
|                                                                   |
|  +-----------------------------------+ +-----------------------+  |
|  | +-------------------------------+ | | +-------------------+ |  |
|  | |                               | | | |                   | |  |
|  | |         [Product Img]         | | | |   [Product Img]   | |  |
|  | |                               | | | |                   | |  |
|  | +-------------------------------+ | | +-------------------+ |  |
|  |  Premium Hammer Drill           | |  5-Person Camping Tent|  |
|  |  ₹300/day                       | |  ₹150/day             |  |
|  |  [Star] 4.9 (14) * 500m         | |  [Star] 4.8 (3) * 1km |  |
|  +-----------------------------------+ +-----------------------+  |
|                                                                   |
+-------------------------------------------------------------------+
|   [Icon: Explore]  [Icon: Orders]  [Icon: Listing]  [Icon: User]  |
+-------------------------------------------------------------------+
```
* **Layout Positioning**:
  * *Header Bar*: Display of current location name with a map toggle shortcut.
  * *Primary Directory Switcher*: Double horizontal tabs to switch views between **RENT ITEMS** and **HIRE SERVICES**.
  * *Search Row*: Custom search input bar (height 48dp) featuring vertical search filters.
  * *Dynamic Scroll Area*: Two-column grid layout displaying local listing cards.
  * *Bottom Bar*: Tab bar for app navigation (Explore, Orders, Listings, Profile).
* **Spacing Rules**: All list cards use a grid layout with a horizontal margin of 16dp and vertical gaps of 12dp.
* **UI/UX Interactions**: Tapping the directory switcher changes listing displays between Rent items and Hire worker directories. Tapping a listing card opens `DISC-03` or `DISC-04`.
* **Firestore Bindings**: Retrieves and filters active documents in the `listings` and `profiles` collections based on coordinates, active statuses, and selected categories.
#### DISC-01B: Range, Category, and Trust Score Filters (Bottom Sheet)
* **Goal**: Granular filters to refine search results by distance, categories, and trust scores.
* **Layout Positioning**:
  * *Top Section*: Center drag indicator capsule ($36\text{dp} \times 4\text{dp}$). Section Title: *"Filters & Preferences"* with a right-aligned *"Reset All"* button.
  * *Middle Section*: Distance range slider with markers at 500m, 1km, 5km, and 10km.
  * *Lower Middle*: Multi-select horizontal scroll chips for item categories (e.g., Power Tools, Camping, Ladders).
  * *Bottom Section*: Checkbox selectors for required trust scores: *"Show All"*, *"Verified KYC Only"*, and *"Trust Score 90+"*.
  * *Footer Area*: Sticky primary action button: **[ APPLY FILTERS ]** (full-width).
* **Spacing Rules**: Left/right margin 16dp, bottom spacing 24dp. Sliders use 40dp vertical blocks.
* **UI/UX Interactions**: Dragging the distance slider updates the range labels dynamically. Selected filter chips are highlighted with a teal background and white text.
* **Firestore Bindings**: Updates local filter states to refine geohash query ranges and parameters in Firestore.
#### DISC-02: Quick-Preview Card Map Marker Overlay (Bottom Sheet)
* **Goal**: Displays a quick-preview card at the bottom of the map view when a user taps a map pin.
* **Layout Positioning**:
  * *Card Container*: Horizontal card layout overlaying the bottom portion of the map view.
  * *Left Aspect Slot*: Product thumbnail image ($80\text{dp} \times 80\text{dp}$) with an aspect ratio of `1:1`.
  * *Right Text Slot*: Title (H2 size), daily price tag, owner name, distance, and trust score metrics.
  * *Bottom Section*: Primary action button: **[ VIEW FULL DETAILS ]** (centered, full-width).
* **Spacing Rules**: Margins 16dp on all sides. Card vertical padding 12dp.
* **UI/UX Interactions**: Swiping left or right on the card cycles through adjacent map markers on the screen.
* **Firestore Bindings**: Binds to selected document parameters from the `listings` collection.
#### DISC-03: P2P Rental Item Details (Screen)
* **Goal**: Displays complete specifications for a rental item, including approximate pick-up radius, pricing, and owner details.
* **Layout Positioning**:
  * *Header Bar*: Back arrow (`ColorSecondary`) and share icons overlays.
  * *Dynamic Photo Box*: Full-width image carousel showing multiple angles of the item.
  * *Primary Info Block*: Bold title (H1 size), price per day tag, and category label.
  * *Owner Identity Card*: Shows the owner's name, profile photo, verified badge, and current Trust Score (99/100).
  * *Location Estimate*: Approximate pick-up zone displayed on a static map card.
  * *Bottom Section*: Sticky primary action button: **[ INITIATE RENTAL REQUEST ]** (centered, full-width).
* **Spacing Rules**: Safe margins 16dp. Carousel aspect ratio `16:9`. Static map card height 140dp with rounded corners.
* **UI/UX Interactions**: Horizontal swipes cycle through product images. Tapping **[ INITIATE RENTAL REQUEST ]** checks if the user is verified. If verified, it opens bottom sheet `BKG-01`. If unverified, it redirects to the KYC Portal (`AUTH-04`).
* **Firestore Bindings**: Retrieves listing details from `listings`, and details for the linked owner from `users` and `profiles`.
---
### Module 3: Booking & Legal Contracting
#### BKG-01: Term Picker, Estimates & Damage Liability Warning (Bottom Sheet)
* **Goal**: Booking setup screen where the renter selects dates and acknowledges their damage liabilities.
* **Layout Positioning**:
  * *Header Bar*: Drag indicator bar. Section title: *"Setup Booking Dates"* with daily price labels.
  * *Date Picker Row*: Inline display boxes for **[ Start Date ]** and **[ End Date ]** selection.
  * *Liability Warning Block*: High-contrast warning card: *"IMPORTANT: You are contractually liable for any damage to this item. Entering handover codes confirms you received it in working condition."*
  * *Summary Balance Card*: Displays estimated billing metrics: Duration in days, base rental charge, security deposit, and total payment due.
  * *Bottom Section*: Sticky primary action button: **[ GO TO AGREEMENT SIGNING ]** (centered, full-width).
* **Spacing Rules**: Spacing 16dp. Date picker boxes are $140\text{dp} \times 48\text{dp}$. Summary card padding 16dp.
* **UI/UX Interactions**: Tapping a date picker box opens system date selection calendars. Price estimates and totals recalculate dynamically as dates are selected.
* **Firestore Bindings**: Local cache is prepared to write draft parameters into the `requests` collection.
#### BKG-02: Standard Legal Rental Agreement & Consent Gate (Screen)
* **Goal**: Displays the standard rental contract and captures digital signatures and consent from both parties.
* **Layout Positioning**:
  * *Header Bar*: Back arrow. Title: *"Rental Agreement Consent"* (H2 bold).
  * *Contract Document Viewer*: Scrollable document container containing standard rental terms (Parties, Item details, duration, security deposit, damage liabilities, legal clauses, and recovery conditions).
  * *Consent Checkboxes*: Row list of explicit checklist conditions:
    * `[ ] I have read and agree to the rental terms.`
    * `[ ] I understand I am legally responsible for any damage caused during this rental.`
    * `[ ] I authorize the platform to release my verified identity details to the owner if damages are disputed.`
  * *Signature Input*: Text field for typing full legal name to sign the contract.
  * *Bottom Section*: Sticky primary action button: **[ SIGN & SUBMIT CONSOLIDATED TERMS ]** (centered, full-width).
* **Spacing Rules**: Text field height 48dp. Document viewer box height 220dp with thin grey borders.
* **UI/UX Interactions**: The scrollable document viewer must be scrolled to the bottom before check-boxes are enabled. The signature button remains disabled until all checkboxes are checked and the typed signature field matches the user's KYC verified name.
* **Firestore Bindings**: Creates an `agreements` document with `status = 'signed'` and logs the digital signature metadata (timestamps, IP, device identifiers).
#### BKG-03: Inbound Request Overview (Screen)
* **Goal**: Allows owners to review incoming booking requests and evaluate the requester's profiles.
* **Layout Positioning**:
  * *Header Bar*: Back arrow. Title: *"Evaluate Booking Request"* (H2 bold).
  * *Renter Profile Card*: Renter details (display name, profile photo, verified KYC badge, and Trust Score rating).
  * *Requested Terms Card*: Proposed rental period, daily rate, and deposit amounts.
  * *Earning Summary Card*: Net earnings estimator (base rent minus platform fee) and required security deposit.
  * *Bottom Section*: Double-stacked action buttons:
    * Top: **[ ACCEPT BOOKING REQUEST ]** (solid teal, height 52dp).
    * Bottom: **[ REJECT REQUEST ]** (transparent red border, height 52dp).
* **Spacing Rules**: Spacing between card groups is 16dp. Margin limits are 16dp on all sides.
* **UI/UX Interactions**: Tapping accept prompts an in-app confirmation dialog. Rejecting the request opens a text input window where the owner can explain the reason for rejection.
* **Firestore Bindings**: Updates request status to `accepted` or `rejected` in the database.
#### BKG-04: External Contact Handoff (Bottom Sheet)
* **Goal**: Prepares and displays a pre-filled messaging template, then redirects the renter to WhatsApp to coordinate logistics.
* **Layout Positioning**:
  * *Header Bar*: Drag indicator. Title: *"Redirecting to WhatsApp"*.
  * *Summary Text*: *"Coordinate handover logistics and payments directly with [Name] over WhatsApp."*
  * *Message Template Card*: Text box displaying the pre-written message: *"Hi Ramesh, this is Amit. My rental request for your Bosch Drill has been approved. Let's arrange pickup!"*
  * *Bottom Section*: Sticky primary action button: **[ OPEN WHATSAPP CHAT ]** (centered, full-width).
* **Spacing Rules**: Sheet left/right margins 16dp. Message template card uses a light-gray border and inner padding of 16dp.
* **UI/UX Interactions**: Tapping **[ OPEN WHATSAPP CHAT ]** copies the pre-written template text to the system clipboard and opens WhatsApp with the owner's phone number.
* **Firestore Bindings**: Local cache retrieves phone numbers and listing details from the database.
---
### Module 4: Three-Token Milestone Verification Engine
#### VFY-01: Pickup Verification Code Console (Bottom Sheet)
* **Goal**: Renter enters the owner's Pickup Code to verify they have inspected the item and accepted its condition.
* **Layout Positioning**:
  * *Header Bar*: Drag indicator. Title: *"1. Item Handover Verification"* (H2 bold).
  * *Action Warning Card*: Highlighted banner: *"INSPECT FIRST: Inspect the item's condition. Enter the owner's Pickup Code only after you have verified the item is in working condition."*
  * *Verification Input Slot*: 4-digit verification code input fields.
  * *Bottom Section*: Sticky primary action button: **[ VERIFY HANDOVER & CONDITION ]** (centered, full-width).
* **Spacing Rules**: Warning card background is styled in warning amber (`ColorWarning`). Code input box height is 48dp.
* **UI/UX Interactions**: Renter enters the 4-digit code provided physically by the owner. On submission, the code is sent to the backend to compare against its stored hash.
* **Firestore Bindings**: If verified, updates `verification_tasks.progress.isPickupVerified = true` in Firestore.
#### VFY-02: Payment Code Verification Tool (Bottom Sheet)
* **Goal**: Renter enters the owner's Payment Code to verify they have completed the UPI transfer and the owner has received it.
* **Layout Positioning**:
  * *Header Bar*: Drag indicator. Title: *"2. Payment Settlement Code"*.
  * *Summary Text*: *"Renter: Amit Shah has sent the UPI payment. Owner: Ramesh S. please verify receipt on your bank app, then share the Payment Code."*
  * *Verification Input Slot*: 4-digit verification code input fields.
  * *Bottom Section*: Sticky primary action button: **[ VERIFY PAYMENT SETTLEMENT ]** (centered, full-width).
* **Spacing Rules**: Numeric input cells are $48\text{dp} \times 48\text{dp}$. Spacing between rows is 24dp.
* **UI/UX Interactions**: Renter enters the 4-digit Payment Code provided by the owner. If verified, the app displays a success animation and activates the agreement.
* **Firestore Bindings**: If verified, updates `verification_tasks.progress.isPaymentVerified = true` and `agreements.status = 'active'`.
#### VFY-03: Item Return Check-In Form (Bottom Sheet)
* **Goal**: Owner enters the renter's Return Code to verify they have received the item back in satisfactory condition.
* **Layout Positioning**:
  * *Header Bar*: Drag indicator. Title: *"Confirm Item Return"*.
  * *Condition Checkboxes*: Row choices to log return condition:
    * `[ ] Item returned clean`
    * `[ ] Item undamaged & tested working`
    * `[ ] Clear to refund security deposit`
  * *Verification Input Slot*: 4-digit verification code input fields.
  * *Bottom Section*: Sticky primary action button: **[ SUBMIT RETURN VERIFICATION ]** (centered, full-width).
* **Spacing Rules**: Vertical stack with 16dp spacing between checkbox rows.
* **UI/UX Interactions**: Owner enters the 4-digit Return Code provided by the renter. If verified, the agreement is marked completed. If there is damage, the owner taps *"Report Damage or Issue"* instead of entering the code.
* **Firestore Bindings**: If verified, updates `verification_tasks.progress.isReturnVerified = true` and `agreements.status = 'completed'`.
#### VFY-04: Damage Dispute Reporter & Legal Document Release Portal (Bottom Sheet)
* **Goal**: Allows owners to report damages, log issues, and download the signed contract and renter's KYC details to pursue recovery.
* **Layout Positioning**:
  * *Header Bar*: Drag indicator. Title: *"Report Return Damage / Issues"* (H2 bold).
  * *Dispute Selection Group*: Vertical radio selectors:
    * `( ) Item returned damaged / not working`
    * `( ) Renter did not return the item`
    * `( ) Unpaid rental balances or outstanding dues`
  * *Details Input Field*: Multi-line description field: *"Describe damage details..."*
  * *Photo Upload Slots*: Dashed photo upload boxes to upload evidence of damage.
  * *Bottom Section*: Double-stacked action buttons:
    * Top: **[ SUBMIT DISPUTE & REPORT ISSUE ]** (solid crimson, height 52dp).
    * Bottom: **[ DOWNLOAD CONTRACT & RENTER ID ]** (outlined black, height 52dp).
* **Spacing Rules**: Spacing 16dp. Input text area height 100dp. Photo cards are $72\text{dp} \times 72\text{dp}$.
* **UI/UX Interactions**: Submitting a dispute changes the agreement status to `disputed` and freezes the transaction. If the status is `disputed`, the owner can tap **[ DOWNLOAD CONTRACT & RENTER ID ]** to download a PDF report containing the signed contract, transaction timeline, and the renter's verified KYC details.
* **Firestore Bindings**: Updates `agreements.status = 'disputed'`, saves dispute reasons to the database, and unlocks read access to the renter's KYC document reference path for the owner.
---
### Module 5: Active Agreements & Operational Logs
#### AGR-01: Active Agreement Timeline & Status Console (Screen)
* **Goal**: Central transaction hub displaying the chronological progress timeline and active verification tasks for an agreement.
```
+-------------------------------------------------------------------+
| [Icon: Close]  Rental Agreement Details                [ID: #9902] |
+-------------------------------------------------------------------+
|  PARTIES & ITEM SUMMARY                                           |
|  Renter: Amit Shah <---> Owner: Ramesh Singh                      |
|  Item: Bosch Hammer Drill | Daily Rate: ₹300                      |
+-------------------------------------------------------------------+
|  AGREEMENT MILESTONES PROGRESS TIMELINE                           |
|                                                                   |
|  [Check: Green] 1. Request Approved & Terms Signed       [Oct 24] |
|                                                                   |
|  [Alert: Orange] 2. Item Handover & Pickup Verification [PENDING] |
|  +-------------------------------------------------------------+  |
|  |  Renter: Amit Shah says deposit is sent. Waiting for Ramesh |  |
|  |  to confirm receipt and item handover.                      |  |
|  |  [Button: Enter Pickup Code (Renter)]                       |  |
|  +-------------------------------------------------------------+  |
|                                                                   |
|  [Lock: Grey]   3. Rental Active Period                           |
|  [Lock: Grey]   4. Return Verified & Security Deposit Refund      |
+-------------------------------------------------------------------+
|  +-------------------------------------------------------------+  |
|  |              [ BUTTON: CHAT WITH OWNER ON WHATSAPP ]        |  |
|  +-------------------------------------------------------------+  |
+-------------------------------------------------------------------+
```
* **Layout Positioning**:
  * *Top Status Bar*: Header displays agreement ID with a right-aligned state badge (Draft, Signed, Active, Completed, Disputed).
  * *Summary Card*: Details the item name, daily rate, and security deposit terms.
  * *Vertical Timeline Tracker*: Displays completed steps (Green node with checkmark) and the current active step (Amber node showing dynamic action buttons).
  * *Bottom Section*: Sticky primary action button: **[ CHAT ON WHATSAPP ]** (centered, full-width).
* **Spacing Rules**: Margins 16dp. Timeline nodes are connected by a vertical 2dp line.
* **UI/UX Interactions**: The active timeline node displays a button pointing to the next required verification step (e.g., opens `VFY-01` or `VFY-02`).
* **Firestore Bindings**: Retrieves timeline logs, current statuses, and task completions from `agreements` and `verification_tasks`.
#### AGR-02: Historical Transactions Activity Log (Screen)
* **Goal**: List view of the user's completed, active, and pending agreements.
* **Layout Positioning**:
  * *Top Section*: Screen title: *"Your Transactions"* (H1 bold). Swappable tabs: **[ ACTIVE TRANSACTIONS ]** and **[ COMPLETED HISTORY ]**.
  * *Activity List View*: Vertical list of transaction cards.
  * *Transaction Card Layout*:
    * Left side: Item thumbnail image ($64\text{dp} \times 64\text{dp}$) and item title.
    * Middle: Transaction date range and total amount.
    * Right side: High-contrast status pill (e.g., Active, Signed, Completed, Disputed).
* **Spacing Rules**: Vertical spacing between card rows is 12dp. Outer margins are 16dp.
* **UI/UX Interactions**: Tapping any transaction card opens its active progress console (`AGR-01`).
* **Firestore Bindings**: Retrieves and paginates lists from `agreements` matching the logged-in user's UID as either renter or owner.
---
### Module 6: Local Service Worker Directory
#### HIRE-01: Local Worker Service Profile Page (Screen)
* **Goal**: Displays a service provider's details, certifications, experience, trade skill tags, and client reviews.
* **Layout Positioning**:
  * *Header Bar*: Back arrow (`ColorSecondary`) and share overlays.
  * *Worker Header Card*: Shows the worker's profile photo, name, primary trade skill (e.g., Electrician), verified KYC badge, starting rate, and dynamic availability badge ("Available Today", "Booked", or "On Leave").
  * *Skill Category Tags*: Flow-wrap row displaying certified skills.
  * *Experience & Bio Section*: Standard text block detailing years of experience and services offered.
  * *Client Reviews Feed*: Scrollable list of past reviews with star ratings (1-5 stars) and user comments.
  * *Bottom Section*: Sticky primary action button: **[ REQUEST SERVICE BOOKING ]** (centered, full-width).
* **Spacing Rules**: Safe margins 16dp. Avatar diameter 72dp. Skill chips height 32dp.
* **UI/UX Interactions**: Tapping **[ REQUEST SERVICE BOOKING ]** checks if the user is verified, then opens bottom sheet `HIRE-02`.
* **Firestore Bindings**: Retrieves profile details from `profiles` and reviews from `reviews`.
#### HIRE-02: Service Request Form & Job Scope Setup (Bottom Sheet)
* **Goal**: Booking setup screen where the customer describes the job scope and schedules the service date.
* **Layout Positioning**:
  * *Header Bar*: Drag indicator. Title: *"Request Service Booking"*.
  * *Details Input Area*: Multi-line text area to describe the job details (e.g., leak repair, custom wiring).
  * *Date Picker Box*: Input box to select the scheduled service date.
  * *Estimated Rate Block*: Displays starting rate parameters and a disclaimer: *"Final rates are negotiated with the worker directly on WhatsApp."*
  * *Bottom Section*: Sticky primary action button: **[ SUBMIT BOOKING REQUEST ]** (centered, full-width).
* **Spacing Rules**: Spacing 16dp. Text area input height 120dp. Date selection container height 48dp.
* **UI/UX Interactions**: The submit button remains disabled until the job description has at least 15 characters and a valid date is selected.
* **Firestore Bindings**: Prepares the draft booking parameters to write to the `requests` collection.
#### HIRE-03: Service Worker Dashboard & Jobs Management (Screen)
* **Goal**: Allows service workers to track, update, and manage their assigned jobs.
* **Layout Positioning**:
  * *Header Bar*: Screen title: *"Worker Dashboard"* (H1 bold). Status toggle bar: *"Status: Available Today"* (displays active green status).
  * *Job List View*: Vertical list of assigned job cards.
  * *Job Card Layout*:
    * Left: Customer's name and photo.
    * Middle: Job description, scheduled date, and rate.
    * Right: Action buttons (e.g., "Accept", "Chat on WhatsApp", or "Request Completion Code").
* **Spacing Rules**: Card vertical spacing is 12dp. Outer margins are 16dp.
* **UI/UX Interactions**: Workers can use the toggle at the top of the screen to change their availability status between Available Today, Booked, and On Leave. Tapping "Request Completion Code" opens bottom sheet `HIRE-04`.
* **Firestore Bindings**: Retrieves and updates listings and profiles matching the worker's UID.
#### HIRE-04: Service Completion Code Console (Bottom Sheet)
* **Goal**: Worker enters the customer's Return/Completion Code to verify the job has been completed and payment has been received.
* **Layout Positioning**:
  * *Header Bar*: Drag indicator. Title: *"Verify Job Completion"*.
  * *Summary Text*: *"Ramu (Plumber): Once the job is completed and you have verified receipt of the payment on your bank app, please enter the customer's Return Code below."*
  * *Verification Input Slot*: 4-digit verification code input fields.
  * *Bottom Section*: Sticky primary action button: **[ VERIFY COMPLETION & CLOSE ]** (centered, full-width).
* **Spacing Rules**: Sheet margins 16dp, bottom 24dp. Input cells are $48\text{dp} \times 48\text{dp}$.
* **UI/UX Interactions**: The worker enters the 4-digit Completion Code provided by the customer. If verified, the job status updates to completed and both parties can submit reviews.
* **Firestore Bindings**: Updates `verification_tasks.progress.isCompletionVerified = true` and `agreements.status = 'completed'`.
---
### Module 7: Profile, Settings & Support
#### PROF-01: Personal Account Settings & Profile Hub (Screen)
* **Goal**: Standard navigation dashboard displaying settings, identity verification steps, support options, and log out.
* **Layout Positioning**:
  * *Header Bar*: Screen title: *"Profile Settings"* (H1 bold).
  * *Profile Summary Card*: Shows the user's name, profile photo, verified KYC badge, and Trust Score rating.
  * *Navigation Menu List*: Vertical rows with chevron indicators:
    * `[Icon: Settings] Manage My Shared Listings` (Opens `LST-01`)
    * `[Icon: Shield]   KYC Identity Verification` (Opens `AUTH-04`)
    * `[Icon: Star]     My Ratings & Client Reviews` (Opens `PROF-02`)
    * `[Icon: Support]  Help Desk & Platform Support` (Opens `ADM-01`)
  * *Bottom Section*: Pinned text link action button: **[ LOGOUT ACCOUNT ]** (centered, Crimson color).
* **Spacing Rules**: Rows are 56dp high with bottom divider lines. Spacing between card sections is 20dp.
* **UI/UX Interactions**: Tapping a menu row opens its corresponding sub-section. Tapping Logout displays a confirmation dialog.
* **Firestore Bindings**: Reads profile details from `profiles` and verification status from `users`.
#### PROF-02: Trust Metrics & Peer Review Feed (Screen)
* **Goal**: Displays the user's detailed Trust Score rating, platform metrics, and peer reviews.
* **Layout Positioning**:
  * *Top Section*: Back arrow. Title: *"My Trust Rating"* (H2 bold).
  * *Trust Highlights Card*: Displays the overall trust percentage (98/100) and metrics metrics grid:
    * `Completed Transactions: 28` | `Completed Service Jobs: 14` | `Client Rating: 4.9/5`
  * *Scrollable Reviews List*: Vertical list of reviews containing star ratings (1-5 stars), reviewer names, dates, and comments.
* **Spacing Rules**: Highlights card height 100dp. Spacing between review rows is 16dp.
* **UI/UX Interactions**: Users can filter the reviews feed to show only 5-star, 4-star, or disputed reviews.
* **Firestore Bindings**: Reads review list from `reviews` where `targetId` matches the user's UID.