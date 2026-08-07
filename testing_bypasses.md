# Testing Bypasses & Implementation Log

This document serves as a record of the temporary code modifications made to test the Diamond Card deep-linking, Share Sheet, and SMS/WhatsApp flow locally. We have completely bypassed the Twilio backend and RevenueCat payment gates for rapid local testing.

**IMPORTANT: All of these changes must be reverted before releasing the app to production.**

---

## 1. SMS Share-Sheet Bypass (Twilio & Edge Functions) — 🔴 ACTIVE

To avoid relying on a paid Twilio account and live backend functions during testing, the app bypasses the Supabase `send-sms` Edge Function. Instead, the app directly triggers the **Android Native Share Sheet** (`Intent.ACTION_SEND`) via a `MethodChannel` wired into `MainActivity.kt`.

### Files Modified:
- `lib/features/cards/data/repositories/sms_repository_impl.dart`
- `android/app/src/main/kotlin/com/greetingcards/invitationmaker/rivon/MainActivity.kt`

### What was changed:
In `SmsRepositoryImpl.sendCard()`, the app successfully gathers all card data and constructs the Base64 JSON payload. It then builds the final Firebase Hosting deep link URL (`https://rivon-62e8a.web.app/open-card?data=...`).

However, instead of sending this URL to the Supabase Edge Function to dispatch via Twilio SMS, the repository calls `_shareChannel.invokeMethod('shareText', {'text': messageBody})`. 
This triggers `Intent.ACTION_SEND` natively in Kotlin, popping up the OS share sheet (WhatsApp, SMS, Gmail, Telegram) pre-filled with the message and the deep link so you can share it to yourself instantly.

**Message generated:**
```
✉️ {senderName} sent you a digital card via {SMS|WhatsApp}!
Tap the link below to open it 🎴

https://rivon-62e8a.web.app/open-card?data={base64-payload}
```

### How to revert to Production:
1. In `sms_repository_impl.dart`, locate the `// ── BYPASS START ──` block and delete it.
2. Remove the `const _shareChannel = MethodChannel(...)` at the top of the file.
3. Uncomment the `// ── PRODUCTION ──` block that invokes the `send-sms` Edge Function via `_client.functions.invoke`.
4. Revert `MainActivity.kt` back to the default single-line `class MainActivity: FlutterActivity()`.

---

## 2. Payment Gate Bypasses — 🔴 ACTIVE

To allow the "Send" button to proceed immediately without requiring a RevenueCat premium subscription or a one-off "single card" purchase, the payment logic is short-circuited.

### Files Modified:
- `lib/features/cards/presentation/providers/card_detail_controller.dart`
- `lib/features/cards/presentation/providers/edit_card_controller.dart`

### What was changed:
In the `handlePurchaseAndOrder()` method of both controllers, the entire subscription and purchase verification block (checking `hasActiveSubscription` or looking for the `rivon_single_card` entitlement) is commented out. It is replaced with a direct call to `_placeOrderAndSend()`.

### How to revert to Production:
1. Search for the comment `// TEMPORARY: Bypass payment gate for testing` in both controllers. 
2. Delete the short-circuited block and uncomment the production block beneath it.

---

## 3. Form Validation Bypass — 🔴 ACTIVE

The 10-digit phone number check, confirmation checkbox requirements, and early-returns are bypassed so you can tap Send with any test input.

### Files Modified:
- `lib/features/cards/presentation/widgets/recipient_delivery_form.dart`
- `lib/features/cards/presentation/providers/card_detail_controller.dart`
- `lib/features/cards/presentation/providers/edit_card_controller.dart`

### What was changed:
In `recipient_delivery_form.dart`, the `if` blocks for form validation within `handleSend()` are commented out.
In both controllers, early-return validation checks for `from`, `to`, and `message` fields were silently blocking the flow and have been commented out.

### How to revert to Production:
1. In `recipient_delivery_form.dart`, search for `// TEMPORARY: Bypass form validation` and uncomment the production validation checks.
2. In both controllers, uncomment the validation check blocks at the beginning of `_placeOrderAndSend()`.
