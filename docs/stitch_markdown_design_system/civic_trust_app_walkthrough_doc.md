# Civic Trust: Full App Walkthrough & User Journeys

This document outlines the two primary user journeys within the Civic Trust platform: **P2P Item Rental** and **Local Service Hiring**. 

---

## Journey 1: The Secure Renter Flow (P2P Item Rental)

**Goal**: A neighbor (Amit) needs to rent a specialized tool (Hammer Drill) from another neighbor (Ramesh).

1.  **Discovery (DISC-01)**: Amit opens the app, sees "Sector 4" as his location, and browses the "Rent Items" directory. He finds a "Premium Hammer Drill" nearby.
2.  **Evaluation (DISC-03)**: Amit reviews the item details, photos, and Ramesh's Trust Score (99/100). He initiates a rental request.
3.  **Booking Setup (BKG-01)**: Amit selects his dates. The app shows him the total cost, including the security deposit, and a liability warning.
4.  **Legal Signing (BKG-02)**: Amit reads the digital contract and types his legal name to sign. This creates a binding agreement.
5.  **Owner Approval (BKG-03)**: Ramesh receives a notification, reviews Amit's verified profile and Trust Score, and accepts the request.
6.  **Handoff Coordination (BKG-04)**: The app provides a WhatsApp template. Amit taps to open a chat with Ramesh to coordinate the physical meetup.
7.  **Pickup Verification (VFY-01)**: They meet. Amit inspects the drill. Once satisfied, he enters the 4-digit Pickup Code Ramesh shows him on his phone.
8.  **Payment Settlement (VFY-02)**: Amit sends the UPI payment. Ramesh confirms receipt on his bank app and shares the Payment Code. Amit enters it to activate the rental.
9.  **Active Monitoring (AGR-01)**: Amit sees the "Active" status in his timeline. He uses the drill for 2 days.
10. **Return & Close (VFY-03)**: Amit returns the drill. Ramesh checks its condition, enters Amit's Return Code, and the agreement is marked "Completed."

---

## Journey 2: The Local Professional Flow (Hire Services)

**Goal**: A neighbor needs a plumber for a repair.

1.  **Service Search (DISC-01)**: User switches the main directory to "Hire Services."
2.  **Worker Profile (HIRE-01)**: User views "David Miller's" profile, seeing his "Master Electrician" badge, 4.9 rating, and "Available Today" status.
3.  **Service Request (HIRE-02)**: User describes the job (e.g., "Leaking pipe under kitchen sink") and selects a preferred date.
4.  **Worker Management (HIRE-03)**: David sees the request on his Worker Dashboard, reviews the scope, and accepts.
5.  **Completion (HIRE-04)**: After finishing the job and receiving payment, David enters the customer's Completion Code to finalize the transaction and log the service history.

---

## System Pillars: Trust & Identity

*   **Onboarding (AUTH-01 to 04)**: Every user must verify their phone (OTP) and identity (KYC) before participating in high-value transactions.
*   **Trust Score (PROF-02)**: Reputation is the platform's currency. Every completed transaction, review, and verified metric contributes to a user's public Trust Score.
*   **Safety Net (VFY-04)**: If an item is returned damaged, owners can freeze the transaction and download the signed contract and renter's ID to pursue legal recovery.