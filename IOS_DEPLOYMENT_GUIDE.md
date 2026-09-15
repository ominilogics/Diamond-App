# iOS App Store & TestFlight Deployment Guide (GitHub Actions)

This document provides a step-by-step, zero-to-hero guide for any developer or DevOps engineer to configure, build, sign, and automatically upload the iOS app (**Rivon**) to **App Store Connect / TestFlight** using **GitHub Actions**, without requiring a local macOS machine.

---

## 📋 Table of Contents
1. [Architecture & Workflow Overview](#1-architecture--workflow-overview)
2. [Prerequisites](#2-prerequisites)
3. [Step 1: Apple Developer Portal (Certificates & Profiles)](#3-step-1-apple-developer-portal-certificates--profiles)
4. [Step 2: App Store Connect API Key](#4-step-2-app-store-connect-api-key)
5. [Step 3: GitHub Secrets Configuration](#5-step-3-github-secrets-configuration)
6. [Step 4: Project Configuration Files](#6-step-4-project-configuration-files)
7. [Step 5: Triggering Builds](#7-step-5-triggering-builds)
8. [Step 6: TestFlight & App Store Release](#8-step-6-testflight--app-store-release)
9. [Common Gotchas & Troubleshooting](#9-common-gotchas--troubleshooting)

---

## 1. Architecture & Workflow Overview

```text
Developer (Windows / Mac / Linux)
       │
       ▼  git push origin main
GitHub Repository (ominilogics/Diamond-App)
       │
       ▼  Triggers .github/workflows/deploy_ios.yml
GitHub Actions macOS Runner (macos-latest / Xcode 26)
       │
       ├─► 1. Decode & import Apple Distribution Certificate (.p12) to temporary keychain
       ├─► 2. Install Provisioning Profile (.mobileprovision)
       ├─► 3. Setup Flutter & CocoaPods dependencies
       ├─► 4. Run `flutter build ipa --release` (signs with Apple Distribution)
       ├─► 5. Upload .ipa artifact to GitHub Actions artifacts
       └─► 6. Upload .ipa directly to App Store Connect via `xcrun altool` (API Key)
       │
       ▼
App Store Connect / TestFlight (Ready for testing & submission)
```

---

## 2. Prerequisites

Before starting, ensure you have:
1. An active **Apple Developer Program Account** ($99/year) with **Account Holder** or **Admin** role.
2. An App record created in [App Store Connect](https://appstoreconnect.apple.com/apps):
   - **Name:** `Rivon: Cards & Invitations` (or desired name)
   - **Bundle ID:** `com.greetingcards.invitationmaker.rivon`
   - **Primary Language:** English
   - **SKU:** `rivon-ios-app`
3. Admin access to the GitHub repository: `ominilogics/Diamond-App`.

---

## 3. Step 1: Apple Developer Portal (Certificates & Profiles)

Go to [developer.apple.com/account](https://developer.apple.com/account).

### A. Register the App ID
1. Navigate to **Certificates, Identifiers & Profiles** &rarr; **Identifiers**.
2. Click **+** to add a new **App ID** (App).
3. **Description:** `Rivon Cards`
4. **Bundle ID:** Explicit &rarr; `com.greetingcards.invitationmaker.rivon`.
5. Under **Capabilities**, enable:
   - ✅ **Push Notifications**
   - ✅ **Sign In with Apple** (Primary App ID)
6. Click **Continue** &rarr; **Register**.

### B. Create the Distribution Certificate (`.p12`)
1. In **Certificates**, click **+**.
2. Select **Apple Distribution** and click **Continue**.
3. Upload a Certificate Signing Request (CSR) generated via Mac Keychain Access (or generated via OpenSSL on Windows/Linux).
4. Download the resulting certificate (`distribution.cer`).
5. Export the certificate and its private key as a **PKCS#12 (`.p12`)** file:
   - Password: Choose a secure password (e.g. `Rivon2026!`).
   - File name: `distribution.p12`.

### C. Create the App Store Provisioning Profile
1. In **Profiles**, click **+**.
2. Select **App Store** under *Distribution* and click **Continue**.
3. Select your App ID: `com.greetingcards.invitationmaker.rivon`.
4. Select the **Apple Distribution Certificate** created in step B.
5. Profile Name: `Rivon AppStore Profile`.
6. Click **Generate** and download the `.mobileprovision` file.
7. Note the UUID inside the profile (e.g., `f2da7508-9c02-4004-bf4c-4b8f33a5a35e`).

---

## 4. Step 2: App Store Connect API Key

An App Store Connect API Key allows GitHub Actions to authenticate non-interactively without SMS 2FA codes.

1. Go to [App Store Connect &rarr; Users and Access &rarr; Integrations (Keys)](https://appstoreconnect.apple.com/access/integrations/api).
2. Click **+** (Generate API Key).
   - **Name:** `GitHub Actions Deploy`
   - **Access:** `App Manager` (or `Admin`)
3. Note the **Issuer ID** at the top of the page (UUID format: `69a6de70-xxxx-xxxx-xxxx-xxxxxxxxxxxx`).
4. Note the **Key ID** of your new key (e.g. `27354MJPMV`).
5. Click **Download API Key** (downloads `AuthKey_XXXXXXXXXX.p8`).
   > ⚠️ **Important:** Apple only allows downloading the `.p8` file **once**. Store it safely.

---

## 5. Step 3: GitHub Secrets Configuration

Convert your `.p12` certificate and `.mobileprovision` file to Base64 strings.

### Base64 Encoding Commands

**On Windows (PowerShell):**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("path\to\distribution.p12")) | Set-Clipboard
# The base64 string is now in your clipboard! Paste into GitHub Secrets.

[Convert]::ToBase64String([IO.File]::ReadAllBytes("path\to\Rivon_AppStore_Profile.mobileprovision")) | Set-Clipboard
# Paste into GitHub Secrets.
```

**On macOS / Linux (Terminal):**
```bash
base64 -i distribution.p12 | pbcopy
base64 -i Rivon_AppStore_Profile.mobileprovision | pbcopy
```

### Required GitHub Secrets
Go to your repo: **Settings &rarr; Secrets and variables &rarr; Actions &rarr; New repository secret** and add:

| Secret Name | Description | Example / Value |
| :--- | :--- | :--- |
| `BUILD_CERTIFICATE_BASE64` | Base64 string of `distribution.p12` | *(Long base64 string)* |
| `P12_PASSWORD` | Password used when exporting `.p12` | `Rivon2026!` |
| `BUILD_PROVISION_PROFILE_BASE64` | Base64 string of `.mobileprovision` | *(Long base64 string)* |
| `APP_STORE_CONNECT_KEY_ID` | Key ID from App Store Connect | `27354MJPMV` |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID from App Store Connect | `8d5786a8-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `APP_STORE_CONNECT_PRIVATE_KEY` | Entire content of `AuthKey_XXXXX.p8` | `-----BEGIN PRIVATE KEY----- ... -----END PRIVATE KEY-----` |
| `ENV_FILE` | Your production `.env` contents | `SUPABASE_URL=... SUPABASE_ANON_KEY=...` |
| `KEYCHAIN_PASSWORD` | *(Optional)* Temporary build keychain password | `temporary-build-password-123` |

---

## 6. Step 4: Project Configuration Files

Ensure the following project configuration files remain consistent with your Apple Developer account:

### A. `ios/Flutter/Release.xcconfig`
```xcconfig
#include "Generated.xcconfig"

CODE_SIGN_STYLE = Manual
DEVELOPMENT_TEAM = C48YJWY386
PROVISIONING_PROFILE_SPECIFIER = Rivon AppStore Profile
CODE_SIGN_IDENTITY = Apple Distribution
CODE_SIGN_IDENTITY[sdk=iphoneos*] = Apple Distribution
```

### B. `ios/ExportOptions.plist`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>destination</key>
	<string>export</string>
	<key>method</key>
	<string>app-store</string>
	<key>signingStyle</key>
	<string>manual</string>
	<key>teamID</key>
	<string>C48YJWY386</string>
	<key>provisioningProfiles</key>
	<dict>
		<key>com.greetingcards.invitationmaker.rivon</key>
		<string>Rivon AppStore Profile</string>
	</dict>
	<key>uploadSymbols</key>
	<true/>
	<key>manageAppVersionAndBuildNumber</key>
	<false/>
</dict>
</plist>
```

### C. `ios/Runner/Info.plist` (Mandatory Privacy Purpose Strings)
Apple **rejects** builds if user-facing purpose strings are missing:
```xml
<!-- Contacts Access (for picking card recipients) -->
<key>NSContactsUsageDescription</key>
<string>We need access to your contacts so you can pick a recipient for sending digital cards.</string>

<!-- Photo Library Access (for attaching photos to cards) -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Rivon needs access to your photo library so you can select and add photos to your custom cards and invitations.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Rivon needs permission to save created cards and invitations directly to your photo library.</string>

<!-- Camera Access (for taking photos for cards) -->
<key>NSCameraUsageDescription</key>
<string>Rivon needs access to your camera so you can take photos to include on your greeting cards and invitations.</string>

<!-- Automatic Export Compliance (Skips manual compliance prompt on TestFlight) -->
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

### D. `pubspec.yaml` (Build Version Incrementing)
Every time you deploy a new build to App Store Connect, you **must increment the build number** (`+X`):
```yaml
version: 1.0.0+1  # First build
version: 1.0.0+2  # Second build
version: 1.0.0+3  # Third build
```
*(Apple rejects uploads with duplicate version + build number combinations).*

---

## 7. Step 5: Triggering Builds

There are three ways to trigger an iOS build and upload:

### Method 1: Git Push to `main` (Automatic)
Any commit pushed to `main` automatically starts the GitHub Actions workflow.
```bash
git add .
git commit -m "feat: new feature and bump version to 1.0.0+3"
git push origin main
```

### Method 2: Manual Trigger via GitHub UI (`workflow_dispatch`)
1. Go to GitHub: **Actions &rarr; Build & Release iOS (IPA)**.
2. Click the **Run workflow** dropdown on the right.
3. Select branch `main` and click **Run workflow**.

### Method 3: Git Tag Release
Pushing a release tag (e.g. `v1.0.1`):
```bash
git tag v1.0.1
git push origin v1.0.1
```

---

## 8. Step 6: TestFlight & App Store Release

1. Once the GitHub Actions workflow finishes with **`SUCCESS`**:
2. Open [App Store Connect &rarr; Apps &rarr; Rivon](https://appstoreconnect.apple.com/apps).
3. Click on the **TestFlight** tab &rarr; **iOS** in the left sidebar.
4. The uploaded build will show **"Processing"** with a spinner (takes 5–15 minutes).
5. Once processing finishes:
   - Because `ITSAppUsesNonExemptEncryption` is set to `<false/>`, the build status transitions immediately to **Ready to Submit / Test**.
   - Internal testers will automatically receive a notification to install the build via the TestFlight app.
6. **Submitting for App Store Review:**
   - In App Store Connect, go to the **App Store** tab.
   - Under **Build**, click **Add Build** and select your latest TestFlight build.
   - Click **Save** and **Submit for Review**.

---

## 9. Common Gotchas & Troubleshooting

### Q1: `ITMS-90683: Missing purpose string in Info.plist`
- **Cause:** Apple detected code referencing photos, camera, or contacts without a descriptive permission message in `Info.plist`.
- **Solution:** Ensure `NSPhotoLibraryUsageDescription`, `NSPhotoLibraryAddUsageDescription`, `NSCameraUsageDescription`, and `NSContactsUsageDescription` exist in `ios/Runner/Info.plist`.

### Q2: `Validation failed (409) SDK version issue: ... must be built with iOS 26 SDK`
- **Cause:** Apple mandates that apps submitted in 2026 be compiled with Xcode 26 / iOS 26 SDK.
- **Solution:** Ensure `.github/workflows/deploy_ios.yml` uses `runs-on: macos-latest` (which provides Xcode 26+).

### Q3: `Redundant Binary Upload (ITMS-90189)`
- **Cause:** You uploaded a binary with the exact same version and build number as a previously uploaded build.
- **Solution:** Bump the build number in `pubspec.yaml` (e.g. `1.0.0+2` &rarr; `1.0.0+3`), commit, and push.

### Q4: `altool` hangs or takes over 1 hour during upload
- **Cause:** Apple's default `altool` transfer method (Aspera UDP) is blocked by GitHub Actions runner firewalls.
- **Solution:** Always pass `--transport DAV --show-progress` to `xcrun altool --upload-app`. This forces direct HTTPS WebDAV transfer, completing the upload in under 2 minutes.

### Q5: `Failed to load AuthKey file (Code -43)`
- **Cause:** The `.p8` API key secret contains Windows CRLF line endings or was improperly formatted.
- **Solution:** The pipeline uses `.github/scripts/install_asc_key.py`, which normalizes line endings to Unix LF and verifies the key using `openssl pkey` before invoking `altool`.
