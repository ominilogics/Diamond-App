# SMS Sending & Deep Linking Architecture

This document serves as the comprehensive architectural blueprint for the "Send Card via SMS" feature, integrating Twilio, Supabase Edge Functions, and Custom Scheme Deep Linking to deliver a seamless 3D unboxing experience.

---

## 0. High-Level Workflow (How it Works)

1. **The Sender's Experience:** A user customizes a card, enters a phone number in the Delivery Form, and taps "Send". The Flutter app gathers the card details, compresses them into a Base64 string, and securely calls the `send-sms` Edge Function.
2. **The Delivery:** The `send-sms` function asks Twilio to send a text to the recipient containing a link to our second Edge Function: `https://[supabase-url]/functions/v1/open-card?data=[base64-payload]`.
3. **The Recipient's Experience:**
   - The recipient taps the `https://` link in their text messages.
   - Their phone's web browser briefly opens the `open-card` Edge Function.
   - The function returns a script that immediately attempts to redirect the phone to our custom scheme: `rivon://open?data=[base64-payload]`.
   - **If the app is installed:** The OS intercepts `rivon://open`, snaps the app open, decodes the card data, and triggers the 3D envelope animation in `PreviewCardScreen`.
   - **If the app is NOT installed:** The custom scheme fails. A 2.5-second fallback timer in the Edge Function script automatically redirects the recipient's browser to the App Store/Play Store so they can download the app.

---

## 1. The Deep Linking Strategy

To ensure that the recipient experiences the exact card with the correct animation, we encode the card data directly into the URL string.

### Why a Custom Scheme (`rivon://`) + Redirector?
Standard "Universal Links" require domain ownership and hosting verification files (`assetlinks.json` / `apple-app-site-association`). To avoid this overhead and keep the solution free/serverless, we use a hybrid approach:
1. SMS contains a standard HTTPS link (so it is clickable in iMessage/Android Messages) pointing to a Supabase Edge Function (`open-card`).
2. The Edge Function acts as a "Redirector", immediately throwing the user to a custom URL scheme (`rivon://open`) which the OS allows any installed app to claim without domain verification.

---

## 2. Supabase Edge Functions (The Backend)

To protect Twilio secrets and handle routing without a dedicated website, we use two Edge Functions:

### A. `send-sms` (Delivery)
- **Trigger:** Called securely via the Supabase SDK in Flutter.
- **Payload:** `toPhoneNumber`, `senderName`, `deepLinkUrl` (pointing to `open-card`).
- **Action:** Authenticates the request (or bypasses for now), composes the SMS string, and calls the Twilio REST API to deliver the text.

### B. `open-card` (The Redirector)
- **Trigger:** Tapped by the recipient in their messaging app.
- **Action:** Returns a raw HTML/JS page that executes `window.location.href = "rivon://open?data=..."`. It also includes a `setTimeout` fallback to redirect to the App Store if the app is not installed.

---

## 3. Flutter Implementation Layers

Following the project's Clean Architecture (`rules.md`):

### A. Data Layer (`SmsRepository`)
- Invokes the `send-sms` Edge Function via `supabase.functions.invoke`.
- Generates the `deepLinkUrl` by converting card properties to a Base64 JSON string.

### B. Presentation Layer
- `CardDetailController` and `EditCardController` listen to the `RecipientDeliveryForm`.
- They manage the Riverpod `AsyncValue` state to show loading spinners and success/error snackbars when invoking the repository.

### C. Routing Layer (`app_router.dart`)
We use GoRouter to catch the custom scheme:
```dart
GoRoute(
  path: '/open', // Catches rivon://open
  builder: (context, state) {
    final base64Data = state.uri.queryParameters['data'];
    if (base64Data != null) {
      // Decode base64 to JSON and extract properties
      return PreviewCardScreen(...);
    }
    return const MainScreen(); // Fallback
  }
)
```

### D. OS-Level Deep Link Configuration
- **Android (`AndroidManifest.xml`):** Added an `<intent-filter>` to accept the custom scheme `<data android:scheme="rivon" android:host="open" />`.
- **iOS (`Info.plist`):** Registered the URL type for `rivon`.
