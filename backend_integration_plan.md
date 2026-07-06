# Daimond Backend Integration Plan (Supabase)

This document outlines the senior-level architectural plan for migrating Daimond from hardcoded dummy data to a production-ready Supabase backend. The design prioritizes **scalability (targeting 1M+ users)**, **performance (offline-caching, CDNs)**, **security (Row Level Security)**, and **Administrative Control (Flutter Web)**.

---

## Phase 1: Database Schema & Role Architecture

To support a secure Admin Panel without compromising the consumer app, we will implement a Role-Based Access Control (RBAC) system.

### 1. Role Management Setup
We will create a secure `user_roles` table (or utilize Supabase Custom Claims) to strictly define who has admin privileges.

**Table: `user_roles`**
* `user_id` (uuid, primary key, references `auth.users`)
* `role` (text) - e.g., 'admin', 'customer'
* `created_at` (timestamp)

### 2. Core Tables Configuration
**Table: `categories`**
* `id` (uuid, primary key)
* `name` (text, non-null)
* `icon_url` (text, nullable)
* `sort_order` (int) - Crucial for admins to reorder categories visually.
* `is_active` (boolean, default true) - Allows admins to "hide" categories without deleting them.
* `created_at` (timestamp, default now())

**Table: `cards`**
* `id` (uuid, primary key)
* `category_id` (uuid, foreign key -> `categories.id`)
* `title` (text, non-null)
* `cover_image_url` (text, non-null)
* `default_front_message` (text, nullable) - For the front of the card
* `default_inside_message` (text, nullable) - For the inside/back of the card
* `price` (numeric, default 5.99)
* `is_featured` (boolean, default false) - Controlled by Admin to highlight cards on Home.
* `color_value` (int, nullable)
* `is_active` (boolean, default true) - Allows admins to "hide" cards.
* `created_at` (timestamp, default now())

### 3. Row Level Security (RLS) & Performance Indexes
* **Read Access (Consumers & Admins)**: Policy allowing `SELECT` where `is_active = true` (consumers) and all rows for Admins.
* **Write Access (Admins Only)**: Policy allowing `INSERT`, `UPDATE`, `DELETE` exclusively if the user's `user_id` exists in `user_roles` with `role = 'admin'`.
* **Indexes**: `cards(category_id)`, `cards(is_featured)`.

---

## Phase 2: Uncompromised Asset Strategy & Text Bounds
You made it clear that image quality is non-negotiable. The files provided are beautiful 4-5MB high-resolution templates. We will preserve them flawlessly.

### 1. Lossless Storage Strategy
1. **Storage Bucket**: Create a `card_assets` bucket in Supabase.
2. **Zero-Compression Uploads**: We will **NOT** compress these files to WebP or lower quality JPEGs. The raw, 100% quality `.jpg` files will be pushed to the Supabase CDN exactly as you provided them.
3. **Aggressive Local Caching**: To handle 5MB files for millions of users without blowing up bandwidth costs, the mobile app will use `cached_network_image`. A user downloads the 5MB file *exactly once*. It is then permanently stored in their phone's local cache. They get uncompromised premium quality, and you don't pay for recurrent downloads.

### 2. Strict Geometric Text Boundaries
Based on the `Inside Card Text Area Marking.jpg` provided:
* The UI forms (`AppTextField`) will implement strict `maxLength` properties (e.g., 150 characters for the front, 300 for the inside) based strictly on the pixel area allowed by the design.
* The Flutter `Stack` rendering the text over the image will use strict bounding boxes (`SizedBox` or `Positioned`) matching the marking templates to guarantee the user's text never overflows the premium artwork.

---

## Phase 3: Flutter Clean Architecture Implementation
We will build distinct consumer and admin layers to ensure code separation.

### 1. Consumer Layer (`lib/features/cards/`)
* **Repositories**: Read-only interfaces (`getFeaturedCards()`, `getCardsByCategory()`).
* **Data Sources**: Supabase queries mapped to `CardModel`.
* **State Management**: Caching Riverpod `FutureProvider`s for infinite scrolling.
* **UI States & Skeleton Loaders**: During `AsyncLoading` (when data is not yet available), we will utilize the **`shimmer`** package to render a modern, animated skeleton UI over the card grids and category lists, preventing jarring layout shifts and providing a premium user experience while Supabase fetches the data.

### 2. Admin Layer (`lib/features/admin/`)
* **Routing**: Web-only routes (e.g., `/admin/dashboard`, `/admin/cards/new`) guarded by GoRouter redirect logic checking the user's role.
* **Repositories**: Write-capable interfaces (`addCategory()`, `updateCard()`, `uploadCardAsset()`).
* **Data Sources**: Supabase mutations utilizing the authenticated admin session.
* **State Management**: Reactive `AsyncNotifier`s to instantly reflect CMS changes in the web dashboard without page reloads.

---

## Phase 4: Offline-First Synchronization Strategy (Drift)
To ensure the best user experience (instant load times, offline support), we will use Drift as the "Single Source of Truth" for the mobile app, rather than relying purely on Riverpod network caching.

### 1. Local Schema (`lib/core/database/`)
* Create `RemoteCategoriesTable` and `RemoteCardsTable` in Drift, mirroring the Supabase schema.
* Primary keys in Drift will be `TextColumn` to store the Supabase UUIDs.

### 2. Synchronization Flow
* **Background Sync**: On app startup or pull-to-refresh, the `CardsRepository` will fetch data from Supabase.
* **Smart Updates**: We will use `insertOnConflictUpdate` in Drift. This automatically merges any new or updated cards from the backend into the local database.
* **Handling Deletions**: Because we use soft-deletes (`is_active = false`) on Supabase, the background sync will pull these "deactivated" cards, update the local Drift row to `is_active = false`, and the UI will instantly filter them out.

### 3. Reactive UI
* The UI Riverpod Providers will **not** listen directly to Supabase. Instead, they will use Drift's `.watch()` streams. 
* *Result*: 0ms load times on app restart. When the background sync finishes updating Drift, the UI automatically and seamlessly updates with the new data.

### 4. Optimistic UI Updates (Favorites & Likes)
To make interactions like "favoriting" a card feel incredibly fast and satisfying, we will implement the **Optimistic UI Pattern**:
* **Instant Feedback**: When the user taps the like button, we immediately update the local Drift `FavoritesTable` and trigger the heart animation. The UI responds in 0 milliseconds.
* **Background Sync**: The `FavoritesRepository` quietly fires the network request to Supabase in the background to log the `user_id` and `card_id`.
* **Graceful Rollback**: If the Supabase request fails (e.g., connection lost), the repository catches the exception, silently reverts the local Drift change (un-liking the card), and pops an `AppSnackbar` notifying the user.
* **Cross-Device Sync**: On app startup, a background sync pulls the user's canonical list of favorites from Supabase and reconciles it with Drift, ensuring they never lose data.

---

## Phase 5: Execution Roadmap

1. **Step 1: Backend Provisioning & RBAC**
   - Execute SQL to create `categories`, `cards`, and `user_roles`.
   - Setup highly secure RLS policies ensuring only Admins can mutate data.
   - Create Storage bucket with Admin-only write policies.
2. **Step 2: Admin Flutter Web Scaffolding**
   - Create the `/admin` feature module in Flutter.
   - Build forms for Category and Card creation/editing.
   - Implement Supabase Storage upload flow for the Web.
3. **Step 3: Consumer Flutter Scaffold**
   - Generate read-only Entities, Models, and Repository interfaces for the mobile app.
4. **Step 4: UI Binding**
   - Update mobile `HomeScreen` and `CardsScreen` to consume Riverpod `AsyncValue` streams.
5. **Step 5: Testing & Audit**
   - Verify RLS policies block regular users from updating cards.
   - Ensure `RepaintBoundary` and pagination perform flawlessly on mobile.

---
**Ready to begin Phase 5, Step 1?**
