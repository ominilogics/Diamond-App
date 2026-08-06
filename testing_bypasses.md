# Testing Bypasses Log

This document serves as a record of all the temporary code modifications made to test the Diamond Card deep-linking, Share Sheet, and SMS/WhatsApp flow locally, completely bypassing the Twilio backend and RevenueCat payment gates. 

**IMPORTANT: All of these changes must be reverted before releasing the app to production.**

---

## 1. Payment Gate Bypasses — 🔴 ACTIVE

To allow the "Send" button to proceed without requiring an actual premium subscription or a one-off "single card" purchase, the payment logic is short-circuited.

### Files Modified:
- `lib/features/cards/presentation/providers/card_detail_controller.dart`
- `lib/features/cards/presentation/providers/edit_card_controller.dart`

**What was changed:**
In the `handlePurchaseAndOrder` method of both controllers, the entire subscription/purchase block (checking `hasActiveSubscription` or looking for the `rivon_single_card` package) is commented out and replaced with a direct call to `_placeOrderAndSend()`.

**How to revert:**
Search for the comment `// TEMPORARY: Bypass payment gate for testing the share/send flow` in both files. Delete the BYPASS START/END block and uncomment the PRODUCTION START/END block below it.

---

## 2. Form Validation Bypass — 🔴 ACTIVE

The 10-digit phone number check and the confirmation checkbox requirement in `RecipientDeliveryForm` are both commented out so you can tap Send with any input.

### File Modified:
- `lib/features/cards/presentation/widgets/recipient_delivery_form.dart`

**What was changed:**
In `handleSend()`, both validation `if` blocks are commented out inside PRODUCTION markers. The phone text and E.164 number are still constructed from whatever the user has typed.

**How to revert:**
In `recipient_delivery_form.dart`, search for `// TEMPORARY: Bypass form validation for testing` and uncomment the two PRODUCTION blocks.

---

## 3. SMS Share-Sheet Bypass (Twilio) — 🔴 ACTIVE

The Twilio `send-sms` Edge Function is bypassed. Instead, the app opens the **Android native share sheet** (`Intent.ACTION_SEND`) via a `MethodChannel` wired into `MainActivity.kt`. No new packages required.

### Files Modified:
- `lib/features/cards/data/repositories/sms_repository_impl.dart`
- `android/app/src/main/kotlin/com/greetingcards/invitationmaker/rivon/MainActivity.kt`

**What was changed:**
`sendCard()` still builds the full Base64 deep link URL identically to production. Instead of calling the Edge Function, it calls `_shareChannel.invokeMethod('shareText', {'text': messageBody})` which triggers `Intent.ACTION_SEND` in Kotlin — the OS shows the full native share sheet (WhatsApp, SMS, Gmail, Telegram, etc.) pre-filled with the message and deep link.

**Message shown in the share sheet:**
```
✉️ {senderName} sent you a digital card via {SMS|WhatsApp}!
Tap the link below to open it 🎴

https://{supabase-url}/functions/v1/open-card?data={base64-payload}
```

**How to revert:**
1. In `sms_repository_impl.dart`, delete the BYPASS block and uncomment the PRODUCTION block. Remove the `_shareChannel` constant.
2. Revert `MainActivity.kt` to the single-line `class MainActivity: FlutterActivity()`.

---

## 3b. Controller Field Validation Bypass — 🔴 ACTIVE

The `from`/`to`/`message` early-return checks in both controllers were **silently blocking** the entire flow (navigating away with no feedback). These are now commented out.

### Files Modified:
- `lib/features/cards/presentation/providers/card_detail_controller.dart`
- `lib/features/cards/presentation/providers/edit_card_controller.dart`

**How to revert:**
Search for `// TEMPORARY: Bypass early field validation for testing` in both files and uncomment the PRODUCTION blocks.

### Files Modified:
- `lib/features/cards/data/repositories/sms_repository_impl.dart`
- `pubspec.yaml` (added `share_plus: ^10.1.4`)

**What was changed:**
The `sendCard()` method still builds the full Base64 deep link URL (`{SUPABASE_URL}/functions/v1/open-card?data=<encoded>`) exactly as production would. However, instead of invoking the `send-sms` Edge Function, it calls `SharePlus.instance.share()` to open the native OS Share Sheet, pre-populated with:
```
✉️ {senderName} sent you a digital card via {SMS|WhatsApp}! Tap the link below to open it 🎴

https://{supabase-url}/functions/v1/open-card?data={base64-payload}
```
The production Edge Function block is fully preserved in commented-out code marked with `// ── PRODUCTION START` / `// ── PRODUCTION END` markers.

**How to revert:**
1. In `sms_repository_impl.dart`, delete the BYPASS START/END block and uncomment the PRODUCTION block below it. Remove the `share_plus` import.
2. Remove the `share_plus` dependency from `pubspec.yaml`.
3. Run `flutter pub get`.

---

## 4. Deep Link Infrastructure (Permanent, production-ready)
The deep link pipeline is now fully wired end-to-end:

- **`app_links` package** added to `pubspec.yaml` and initialised in `main.dart` to intercept `rivon://` URIs from the OS.
- **Cold start**: initial URI captured before `GoRouter` static field is evaluated → `AppRouter.initialDeepLink` is set → router boots directly to `/open?data=...`.
- **Warm start**: `uriLinkStream` listener calls `AppRouter.router.go(path)` for any URI arriving while the app is running.
- **The Shared URL format:** `https://jlfgigvfmxuvlixohzli.supabase.co/functions/v1/open-card?data=<base64-payload>`
- **The Edge Function (`supabase/functions/open-card/index.ts`):** Renders a styled HTML landing page. On Android, it uses `intent://`. On iOS, it uses `rivon://`, falling back to the App Store after 2.5 seconds if the app isn't installed.
- **App Configuration:** `AndroidManifest.xml` intercepts `rivon://open`. `Info.plist` registers `rivon` scheme with `CFBundleURLName = com.greetingcards.invitationmaker.rivon`.

> **Action required before going live:** Deploy the Edge Function with `supabase functions deploy open-card` and ensure Twilio secrets are set in the Supabase dashboard.
