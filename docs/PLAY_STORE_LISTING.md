# Local First — Google Play Store Listing

> Use this document to fill in your Play Console listing fields.  
> Copy-paste each section into the corresponding Play Console field.

**Repository:** [https://github.com/moyeenhaider3/local_first](https://github.com/moyeenhaider3/local_first)  
**GitHub Pages base (policies):** `https://moyeenhaider3.github.io/local_first/`  
**No App Links / `.well-known` required** — Local First does not use HTTPS share links or verified deep links for content sharing initially.

---

## App Identity

| Field | Value |
| ----- | ----- |
| **Package name** | `io.github.moyeenhaider3.localfirst` _(Confirm exact applicationId in build.gradle)_ |
| **App name** | Local First |
| **Developer / support email** | _Replace with your public support address_ |
| **Category** | Lifestyle _(or Business / Tools — choose best fit in Play Console)_ |
| **Default language** | English (United States) or English (India) |

---

## Store Listing Details

### App title (max 30 characters)

```
Local First: Rent & Hire
```

_(Shorten if needed to fit 30 characters.)_

### Short description (max 80 characters)

```
P2P neighborhood rent & hire trust platform. Verified physical handovers & services.
```

### Full description (max 4000 characters)

```
Local First — P2P Neighborhood Rent & Hire Trust Platform

Local First is your trusted companion for neighborhood peer-to-peer transactions. Whether you're renting out physical items or hiring local service workers, Local First acts as a Trust, Agreement, and Verification Layer for your community.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WHAT MAKES IT DIFFERENT

Trust and Verification Layer
We secure your agreements. You handle payments and chat externally (like via UPI and WhatsApp), while Local First securely manages your digital contracts, identity (KYC), and physical handovers using unique one-time Milestone Verification Codes.

Mutually Verified Transaction History
Every step of your transaction—from consent, pickup, payment, to return—is recorded and verified by both parties. You build a trustworthy history and gather indisputable evidence without the platform interfering with your money.

Secure Milestone Codes
Use simple 4-digit codes to securely verify pickups, payments, and returns. All codes are hashed and matched securely on the server to prevent any unauthorized tampering.

Local Worker Discovery
Find trusted local service providers and track job completion securely, bridging the gap for everyday neighborhood tasks.

Peer Reviews & Trust Score
Make informed decisions by checking the Trust Score of users before interacting. Completed agreements directly build your reputation in the community.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

IDEAL FOR

• Neighbors wanting to safely rent out tools, equipment, or vehicles.
• Individuals looking to hire verified local workers for tasks and services.
• Anyone who needs a reliable, timestamped, and mutually-agreed digital contract for local exchanges.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

IMPORTANT

Local First is an agreement and verification tracking tool. It does not process payments directly or provide escrow services. All monetary transactions are handled externally by the users.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Download Local First today and bring trust to your neighborhood exchanges!
```

---

## Tags / keywords (Play Console — use where applicable)

```
neighborhood rent
peer to peer
local hire
trust platform
rental agreement
service verification
```

---

## Graphics requirements

### App icon

- **Size:** 512 × 512 px (PNG, 32-bit; Play requirement for store listing asset)
- **In project:** `android/app/src/main/res/mipmap-*` / `flutter_launcher_icons`
- **Tool:** [Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/icons-launcher.html) or [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)

### Feature graphic

- **Size:** 1024 × 500 px (JPG or PNG)
- **Suggestion:** App name + tagline + screenshot of Home or Active Agreements

### Screenshots (minimum 2; recommended 4–8)

Suggested captures:

1. Home — Marketplace Map & List  
2. Rental Item Details  
3. Booking & Digital Contract Consent  
4. Active Agreement Console / Verification Codes  
5. Worker Profile & Services  
6. Profile, KYC Status & Trust Score  

---

## Content rating questionnaire (guidance)

Answer honestly in Play Console. Typical answers for Local First:

| Topic | Likely answer |
| ----- | ------------- |
| Violence | No |
| Sexual content | No |
| User-generated content / social feeds | No |
| Location shared with others | Disclose YES (app uses location to find nearby items and workers) |
| Personal info | Disclose YES (stores name, phone number, KYC documents) |

**Expected rating:** Everyone or Teen — depends on your exact Data safety answers and local regulations regarding KYC.

---

## Privacy policy

**URL for Play Console:**

```
https://moyeenhaider3.github.io/local_first/privacy.html
```

Host the HTML in your **`moyeenhaider3/local_first`** GitHub repo (e.g. `docs/privacy.html` on **GitHub Pages**).  
Describe: Firebase Auth (phone numbers), Firestore storage for transaction history, location data usage (geoflutterfire), KYC identity verification data retention, and explain that you do **not** process payments or in-app chat.

---

## Terms of service (optional but recommended)

**URL:**

```
https://moyeenhaider3.github.io/local_first/terms.html
```

Include disclaimer: the app is an agreement verification tool, not a payment gateway or escrow service; limit liability for disputes; contact email.

---

## Data safety (Play Console)

Declare at minimum:

- Data collected: Phone number, Location (approximate/precise), Personal Info (Name, KYC ID if uploaded).
- Data shared: None to third-parties (except standard Firebase analytics/crashlytics if enabled).
- Encryption: Data encrypted in transit.
- Deletion: User can request account deletion (if feature is implemented).

---

## Release checklist

### Before first upload

- [ ] Create release keystore **`localfirst.jks`** (see `PRE_PUBLISH_TODO.md` and `android/key.properties.example`)
- [ ] Add **`android/key.properties`** (never commit)
- [ ] Confirm **`applicationId`** is correct in `android/app/build.gradle` or `build.gradle.kts`
- [ ] Replace launcher icons if still placeholder
- [ ] Feature graphic + screenshots
- [ ] Publish **privacy** (and **terms**) HTML under `moyeenhaider3.github.io/local_first/`
- [ ] Build AAB: `flutter build appbundle --release`

### Play Console

1. Create the app in [Google Play Console](https://play.google.com/console)
2. Store listing: title, short/full description, graphics
3. App content: privacy policy URL, ads declaration (if no ads: declare **no ads**)
4. Content rating questionnaire
5. Target audience & news apps declarations as applicable
6. Upload signed **AAB** from `build/app/outputs/bundle/release/app-release.aab`
7. Internal testing → production when ready

---

## Build commands

```bash
cd local_first
flutter clean && flutter pub get
flutter analyze
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`
