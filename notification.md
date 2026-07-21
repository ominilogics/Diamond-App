# Daimond Notifications Implementation

This document outlines the complete, end-to-end implementation of the notification system in the Daimond application. The architecture relies on a hybrid approach using Firebase Cloud Messaging (FCM) for delivery and Drift SQLite for offline-first state management and UI reactivity.

## 1. Core Services & FCM Integration
The entry point for push notifications is the `LocalNotificationServiceImpl` (implementing `NotificationService`). 

### Initialization & Permissions
- It initializes `flutter_local_notifications` for foreground displays and `FirebaseMessaging` for push delivery.
- Permissions are requested dynamically (Android 13+ Notification, iOS Alerts/Badges, Android 14+ Exact Alarms).

### Payload Routing (System-Level)
Notifications carry deep-link payloads. When a push notification arrives (in foreground, background, or killed state), the service extracts the payload.
- **Background/Killed State**: Tapped payloads are immediately broadcast via `onPayloadHandled` stream. To ensure Riverpod's `StreamProvider` always detects state changes (even if the identical notification is tapped twice), the payload is prefixed with a millisecond timestamp (`${timestamp}_$payload`).
- **Smart Navigation**: When navigating from the in-app Notifications Screen, the app differentiates between "Root Tabs" (e.g., `/main?tab=1`) and "Deep Pages" (e.g., `/cards`). It uses `context.go()` for root tabs to perform a clean backward transition (preventing duplicate MainScreen stacks) and `context.push()` for deep pages to preserve back-navigation into the Notifications Inbox.
- **Bottom Navigation Sync**: Tapping a bottom nav tab also actively invokes `context.go('/main?tab=$index')` to keep GoRouter's internal URL perfectly synchronized with Riverpod state, ensuring subsequent payload navigation correctly triggers Riverpod `useEffect` rebuilds.

### Token Synchronization
FCM tokens are continuously synchronized with the Supabase `user_fcm_tokens` table, strictly respecting user opt-in preferences stored in `SharedPreferences`.

## 2. Backend Notification Engine (Supabase Edge Functions)
Event reminders and broadcasts are processed centrally by Supabase Edge Functions powered by Deno and the Firebase Admin SDK.

### A. The `event-reminders` Function
A scheduled cron-job function designed to autonomously process upcoming events.
- **Query Strategy**: Scans the `events` table for records where `notification_time <= now()` and `is_notified = false`.
- **Delivery**: Uses `messaging.sendEachForMulticast` with Android priority `"high"` and APNs `contentAvailable: true`.
- **Database Insertion**: Critically, after sending the FCM push, it inserts a new row into the Supabase `notifications` table containing the `title`, `description`, `is_read=false`, and an explicit `payload` (e.g., `/events`). This ensures the Flutter app can sync the exact navigation route.

### B. The `dynamic-processor` Function
An HTTP endpoint for ad-hoc and broadcast notification dispatch, respecting granular user preferences and inserting dynamically routed payloads.
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

### "New" vs "Earlier" Grouping
- **`groupedNotificationsProvider`**: Categorizes the raw Drift stream into two distinct buckets: **"New"** (unread or received within the last 24 hours) and **"Earlier"** (read and older than 24 hours). This focuses user attention exactly where it belongs.

## 5. Global Real-Time Reactivity (`main.dart`)
1. **Foreground Syncs**: When a foreground FCM message is received, `LocalNotificationServiceImpl` pushes an event to `onNotificationReceived`. `MyApp` instantly triggers `syncNotifications()`, seamlessly updating the UI and launcher badge.
2. **Background/Killed Syncs**: When a system-tray notification is tapped, `LocalNotificationServiceImpl` emits the unique timestamped string to `onPayloadHandled`. 
3. **Auto Mark-As-Read**: Inside `MyApp`'s listener, the timestamp is stripped. The app actively runs `syncNotifications()` to ensure the Drift database downloads the new record, and then invokes `markLatestAsReadByPayload(payload)`. This completely guarantees that any background notification immediately marks itself as read and drops the red badge count upon tap.
