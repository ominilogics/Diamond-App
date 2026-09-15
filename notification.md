# Daimond Notifications Implementation

This document outlines the complete, end-to-end implementation of the notification system in the Daimond application. The architecture relies on a hybrid approach using Firebase Cloud Messaging (FCM) for delivery and Drift SQLite for offline-first state management and UI reactivity.

## 1. Core Services & FCM Integration
The entry point for push notifications is the `LocalNotificationServiceImpl` (implementing `NotificationService`). 

### Initialization & Permissions
- It initializes `flutter_local_notifications` for foreground displays and `FirebaseMessaging` for push delivery.
- Permissions are requested dynamically (Android 13+ Notification, iOS Alerts/Badges/Sounds, Android 14+ Exact Alarms).
- **iOS Foreground Heads-Up & Local Details**: On iOS, `FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true)` is enabled in `init()`, and `DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true)` is attached to local notifications to ensure heads-up banner display parity with Android.
- **iOS APNs Readiness Loop**: On iOS, token synchronization explicitly awaits Apple's asynchronous APNs token generation (`getAPNSToken()`) before invoking `getToken()`, preventing null token errors on initial app launch.
- **Native iOS Background Modes & Registration**: `ios/Runner/Info.plist` includes `UIBackgroundModes` with `fetch` and `remote-notification`. `ios/Runner/AppDelegate.swift` explicitly calls `application.registerForRemoteNotifications()`, while `Runner.entitlements` specifies `aps-environment`.
- **OS Permission Synchronization**: The UI in `NotificationSettingsScreen` and `NotificationSettingsNotifier` dynamically cross-references `SharedPreferences` with native OS permission status (`Permission.notification.status`). If system-level notifications are denied by the user, the in-app toggle automatically syncs to OFF. Toggling ON prompts for permission or presents a direct option to `openAppSettings()`. Resuming the app from device settings automatically re-checks and refreshes the switch state.


### Payload Routing (System-Level)
Notifications carry deep-link payloads. When a push notification arrives (in foreground, background, or killed state), the service extracts the payload.
- **Background/Killed State**: Tapped payloads are immediately broadcast via `onPayloadHandled` stream. To ensure Riverpod's `StreamProvider` always detects state changes (even if the identical notification is tapped twice), the payload is prefixed with a millisecond timestamp (`${timestamp}_$payload`).
- **Smart Navigation**: When navigating from the in-app Notifications Screen, the app differentiates between "Root Tabs" (e.g., `/main?tab=1`) and "Deep Pages" (e.g., `/cards`). It uses `context.go()` for root tabs to perform a clean backward transition (preventing duplicate MainScreen stacks) and `context.push()` for deep pages to preserve back-navigation into the Notifications Inbox.
- **Bottom Navigation Sync**: Tapping a bottom nav tab also actively invokes `context.go('/main?tab=$index')` to keep GoRouter's internal URL perfectly synchronized with Riverpod state, ensuring subsequent payload navigation correctly triggers Riverpod `useEffect` rebuilds.

### Token Synchronization
FCM tokens are continuously synchronized with the Supabase `user_fcm_tokens` table, strictly respecting user opt-in preferences stored in `SharedPreferences`.

## 2. Backend Notification Engine (Supabase Edge Functions)
Event reminders and broadcasts are processed centrally by Supabase Edge Functions powered by Deno and the Firebase Admin SDK, engineered to safely scale to 1,000,000+ users.

### A. The `event-reminders` Function
A scheduled cron-job function designed to autonomously process upcoming events at high scale.
- **Batch Query Strategy (`BATCH_LIMIT = 200`)**: Scans the `events` table for records where `notification_time <= now()` and `is_notified = false`, ordered chronologically and capped at 200 per run. This guarantees lightning-fast execution (~1.8s) and immunity to edge function timeouts (150s limit) during peak global holidays.
- **Eliminated N+1 Queries**: Instead of querying tokens sequentially in a loop, all FCM tokens for the entire batch of users are fetched in **1 single SQL query** (`.in('user_id', uniqueUserIds)`) and indexed into an in-memory `Map<string, string[]>`.
- **Apple APNs Standards (`apns-priority: 10`, `apns-push-type: alert`, `sound: default`)**: Configured explicit APNs headers and payload options to ensure immediate alert delivery on iPhones (even in Low Power Mode), native chime sounds, and background database pre-fetching via `contentAvailable: true`.
- **Dead Token Self-Healing**: Failed tokens (`messaging/invalid-registration-token` or `messaging/registration-token-not-registered`) are collected and batch-deleted from `user_fcm_tokens` in a single query.
- **Batch State Transition**:
  - Marks all processed events as `is_notified = true` in **1 single batch UPDATE query**, regardless of whether the user had active push tokens, completely eliminating infinite cron polling loops.
  - Inserts all in-app notification rows into the Supabase `notifications` table in **1 single batch INSERT query** (`payload: '/main?tab=1'`), guaranteeing that users who turned off push notifications still receive their reminders in their in-app notification bell.

### B. The `dynamic-processor` Function
An HTTP endpoint for ad-hoc and broadcast notification dispatch, respecting granular user preferences and inserting dynamically routed payloads.
- **500-Token Multicast Batching (`CHUNK_SIZE = 500`)**: Firebase Admin SDK `messaging.sendEachForMulticast` has a strict hard limit of 500 tokens per call. The function automatically partitions subscriber tokens into 500-token chunks, ensuring broadcasts to 500+ or millions of users never crash.
- **Full Apple APNs Parity**: Configured `'apns-priority': '10'`, `'apns-push-type': 'alert'`, and `sound: 'default'` alongside Android's high priority.
- **Batched Database Inserts**: In-app notification records are written to the database in safe batches of 500 to prevent payload size errors.
- **Single Source of Truth**: The `dynamic-processor` handles both sending the push (via FCM Multicast) AND executing the Supabase database insertion (with payload). Client-side screens like the Admin Dashboard only trigger this Edge Function and deliberately avoid duplicate raw database insertions.

### C. Automated Data Cleanup (Retention Policy)
To prevent database bloat, a native Postgres `pg_cron` worker automatically runs every day at 3:00 AM, deleting any notifications older than 30 days from the Supabase cloud.

## 3. Data Sync & Offline-First Repository
The `NotificationsRepositoryImpl` ensures the in-app Inbox is instantly responsive and available offline.

### Remote vs Local & Pagination
- **Remote**: `RemoteNotificationsDataSourceImpl` fetches records from Supabase.
- **Local**: Drift's `notificationsTable` acts as the single source of truth for the UI. The stream is queried using a dynamic `limit()` to support infinite scrolling and memory efficiency.
- **Local Cleanup**: During `syncNotifications()`, the repository silently purges any local Drift notifications older than 30 days to save the user's phone storage.

### Optimistic Actions (Mark As Read & Delete)
When a user interacts with a notification (via tap or the `...` Action Menu), the UI does not wait for network requests:
1. **Local Mutation**: The local Drift row is immediately updated (`isRead = true`) or deleted (`_db.delete()`).
2. **Background Sync**: A fire-and-forget request is sent to Supabase to mirror the deletion or read state in the cloud.

## 4. State Management & Facebook-Style UX (Riverpod)
The `notifications_provider.dart` maps the Drift database to a highly optimized, Facebook-style UI.

### The "Seen" State vs "Read" State
The global red Bell Badge is decoupled from the individual tile read state:
- **`lastOpenedNotificationsProvider`**: Stores a `DateTime` in `SharedPreferences` marking the exact moment the user last opened the Notifications tab.
- **`unreadNotificationsCountProvider`**: Actively computes the badge count by filtering out any notifications received *before* the `lastOpened` timestamp. This makes the global red badge instantly disappear when the user checks their inbox.

### "Unread" vs Date-Based Read Grouping
- **`groupedNotificationsProvider`**: Categorizes notifications into:
  - **"Unread"**: All unread notifications (`!isRead`) grouped at the top.
  - **"Today"**: Read notifications received today.
  - **"Yesterday"**: Read notifications received yesterday.
  - **Date Sections** (e.g. `Jul 21`): Read notifications received on older dates.


## 5. Global Real-Time Reactivity (`main.dart`)
1. **Foreground Syncs**: When a foreground FCM message is received, `LocalNotificationServiceImpl` pushes an event to `onNotificationReceived`. `MyApp` instantly triggers `syncNotifications()`, seamlessly updating the UI and launcher badge.
2. **Background/Killed Syncs**: When a system-tray notification is tapped, `LocalNotificationServiceImpl` emits the unique timestamped string to `onPayloadHandled`. 
3. **Auto Mark-As-Read**: Inside `MyApp`'s listener, the timestamp is stripped. The app actively runs `syncNotifications()` to ensure the Drift database downloads the new record, and then invokes `markLatestAsReadByPayload(payload)`. This completely guarantees that any background notification immediately marks itself as read and drops the red badge count upon tap.
