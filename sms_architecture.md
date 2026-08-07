# SMS Sending & Deep Linking Architecture

This document serves as the comprehensive architectural blueprint for the "Send Card via SMS" feature, integrating Firebase Hosting Android App Links to deliver a seamless 3D unboxing experience.

---

## 0. High-Level Workflow (How it Works)

1. **The Sender's Experience:** A user customizes a card, clicks share, and selects SMS/WhatsApp. The Flutter app gathers the card details, compresses them into a Base64 string, and generates a Firebase Hosting link.
2. **The Delivery:** The sender shares the link: `https://rivon-62e8a.web.app/open-card?data=[base64-payload]`.
3. **The Recipient's Experience:**
   - The recipient taps the `https://` link in their text messages.
   - **If the app is installed:** The Android OS verifies the domain against the app's `assetlinks.json` file. It completely bypasses the web browser, snaps the app open, decodes the card data, and triggers the 3D envelope animation in `PreviewCardScreen`.
   - **If the app is NOT installed:** The native App Link fails over to the web browser. The user sees a beautifully rendered static HTML fallback page hosted on Firebase (`public/open-card/index.html`) instructing them to download the app from the Play Store.

---

## 1. The Deep Linking Strategy (Android App Links via Firebase Hosting)

To ensure that the recipient experiences the exact card with the correct animation without requiring a backend database to store temporary card states, we encode the card data directly into the URL string.

### Why Firebase Hosting App Links?
Previously, the architecture used a Supabase Edge Function to serve a JavaScript redirect to a custom scheme (`rivon://`). However, modern browsers (Chrome 70+, Safari, WebView) enforce strict security policies blocking JavaScript from automatically launching external apps without a physical user click.

To bypass browser security blocks, we migrated to **Android App Links (HTTPS)** natively supported by the OS.
Since Supabase's free `.supabase.co` domains do not allow hosting the required `.well-known/assetlinks.json` verification file at the root, we utilize a free Firebase Hosting project (`rivon-62e8a.web.app`) to act as the deep-link bridge.

---

## 2. Firebase Hosting (The Deep Link Bridge)

Firebase Hosting serves two critical static files for deep linking:

### A. `public/.well-known/assetlinks.json`
- Contains the SHA-256 fingerprint and the package name (`com.greetingcards.invitationmaker.rivon`).
- Android silently queries this file when a user clicks the link. If it matches the installed app, the OS natively intercepts the URL.

### B. `public/open-card/index.html` (The Fallback)
- If the app is not installed, the OS falls back to opening the URL in Chrome.
- Firebase Routing (`firebase.json` rewrites) intercepts the `/open-card` path and serves this static HTML page.
- The page detects the user's platform (Android/iOS) and displays a button linking directly to the respective App Store.

---

## 3. Flutter Implementation Layers

Following the project's Clean Architecture (`rules.md`):

### A. Data Layer (`SmsRepository`)
- Generates the `url` by converting card properties to a Base64 JSON string.
- URL encapsulates the data: `https://rivon-62e8a.web.app/open-card?data=$encoded`

### B. Routing Layer (`app_router.dart`)
We use GoRouter to catch the path intercepted by the OS:
```dart
GoRoute(
  path: '/open-card', // Catches the Firebase Hosting path
  builder: (context, state) {
    final base64Data = state.uri.queryParameters['data'];
    if (base64Data != null) {
      // Decode base64 to JSON and extract properties
      return PreviewCardScreen(...);
    }
    return const Scaffold(...); // Error screen if malformed
  }
)
```

### C. OS-Level Deep Link Configuration
- **Android (`AndroidManifest.xml`):** Added an `<intent-filter>` with `android:autoVerify="true"` to accept the HTTPS scheme for the `rivon-62e8a.web.app` host on the `/open-card` path.
