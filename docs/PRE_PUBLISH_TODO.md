# Local First — Pre-Publish Checklist

**Repo:** [https://github.com/moyeenhaider3/local_first](https://github.com/moyeenhaider3/local_first)  
**GitHub Pages site:** `https://moyeenhaider3.github.io/local_first/` (landing + shared styles in `docs/`)

| Page | URL |
|------|-----|
| Home | `https://moyeenhaider3.github.io/local_first/` |
| Privacy | `https://moyeenhaider3.github.io/local_first/privacy.html` |
| Terms | `https://moyeenhaider3.github.io/local_first/terms.html` |

This app **does not** use verified App Links or Digital Asset Links for shared HTTPS URLs. **No `.well-known/assetlinks.json` (or iOS AASA) setup is required** for launch unless you later add shareable web links.

---

## 1. Android signing & package ID

- [x] `applicationId` / `namespace` set correctly in `android/app/build.gradle` or `build.gradle.kts`
- [x] Release signing wired to read `android/key.properties` when present (falls back to debug if missing for local dev)
- [x] **Generate keystore** (one-time; keep backup offline):

  ```bash
  cd android
  keytool -genkey -v -keystore localfirst.jks -alias localfirst -keyalg RSA -keysize 2048 -validity 10000
  ```

- [x] Copy `android/key.properties.example` → `android/key.properties` and fill passwords and paths (Generated with placeholders)
- [x] **Never** commit `localfirst.jks` or `key.properties` (already in `.gitignore`)

---

## 2. GitHub Pages — marketing site + privacy & terms (no `.well-known`)

Static site files live under **`docs/`**: `index.html` (landing), `site.css`, `privacy.html`, `terms.html`. Header + bottom bar on every page link **Home**, **Privacy**, **Terms**, and **GitHub**. (Files have been generated in the `docs` folder).

- [ ] Push to **`moyeenhaider3/local_first`**
- [ ] Repo **Settings → Pages**: Source **Deploy from a branch**, branch **`main`**, folder **`/docs`**, Save
- [ ] After build (~1 min), confirm:

  - `https://moyeenhaider3.github.io/local_first/`
  - `https://moyeenhaider3.github.io/local_first/privacy.html`
  - `https://moyeenhaider3.github.io/local_first/terms.html`

- [ ] If the app shows legal links in Settings, point them to the same URLs (add constants in Dart when you wire UI)

---

## 3. Store listing prep (Play Store)

- [ ] Fill fields from `docs/PLAY_STORE_LISTING.md`
- [ ] 512×512 icon, feature graphic 1024×500, 2+ phone screenshots
- [ ] Data safety form completed accurately (mostly on-device data, KYC data encrypted/secured)
- [ ] Support email that you monitor

---

## 4. Quality & device checks

- [ ] **Real Android devices** (multiple OEMs): check map views, location permissions, camera access for ID upload.
- [ ] `flutter analyze` — clean or only acceptable infos
- [ ] Release build: `flutter build appbundle --release`

---

## 5. Optional / later

- [ ] Crash reporting (e.g. Firebase Crashlytics) for production
- [ ] iOS build & App Store checklist (separate from this doc)
- [ ] ProGuard / R8 shrinking — only if you add rules and test thoroughly

---

## Quick reference — files

| File | Purpose |
| ---- | ------- |
| `android/localfirst.jks` | Release keystore (local only) |
| `android/key.properties` | Passwords + alias (local only) |
| `android/key.properties.example` | Template for teammates |
| `android/app/build.gradle` | `applicationId`, signing |
| `docs/PLAY_STORE_LISTING.md` | Copy for Play Console |
