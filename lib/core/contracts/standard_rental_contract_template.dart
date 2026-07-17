class StandardRentalContractTemplate {
  static const String contractVersion = "standard_v1.0";

  static String generateLegalText({
    required String ownerName,
    required String renterName,
    required String itemName,
    required double dailyRate,
    required double securityDeposit,
    required int durationDays,
    required DateTime startDate,
  }) {
    final DateTime endDate = startDate.add(Duration(days: durationDays));

    return '''
LOCAL FIRST: STANDARD P2P RENTAL CONTRACT
Version: $contractVersion

1. PARTIES
This legally binding agreement is entered into by and between:
Owner (Lessor): $ownerName
Renter (Lessee): $renterName

2. RENTAL ITEM & TERMS
The Owner hereby leases to the Renter the following item:
Item Description: $itemName
Daily Rental Rate: INR ${dailyRate.toStringAsFixed(2)} per day
Required Security Deposit: INR ${securityDeposit.toStringAsFixed(2)}
Rental Duration: $durationDays Days
Commencement Date: ${startDate.toLocal().toString().split(' ')[0]}
Expected Return Date: ${endDate.toLocal().toString().split(' ')[0]}

3. INSPECTION & HANDOVER STATUS
By entering the "Pickup Verification Code" in the application, the Renter formally acknowledges that they have physically inspected the item and received it in good, acceptable, and safe working condition. The Renter waives any future claims of pre-existing cosmetic or functional damage.

4. LIABILITY FOR LOSS & DAMAGE
The Renter assumes full financial and civil liability for the item during the rental period. If the item is returned damaged, broken, or in non-working condition:
a) The Owner is authorized to withhold repair or replacement costs from the Security Deposit.
b) If repair costs exceed the Security Deposit, the Renter is contractually obligated to pay the difference.
c) In the event of non-compliance, the platform is authorized to release the Renter’s verified identity details (Full Name, Address, and ID Snapshot) and this signed contract to the Owner to support legal recovery in a court of law.

5. DIGITAL SIGNATURES & CONSENT
Both parties agree that checking the boxes and submitting their typed legal names in the application serves as a valid digital signature, contractually binding both parties under applicable contract laws.
''';
  }
}
