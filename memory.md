# Project Memory

## 1. App Foundation & Utilities
* **UI Components**:
  * `GradientScaffold` (`lib/core/widgets/gradient_scaffold.dart`): Reusable scaffold wrapper handling the global linear background.
  * `AppTextField` (`lib/core/widgets/app_text_field.dart`): Reusable text field configured strictly to design metrics (354x44, #FFFFFF background, 0.5px border).
  * `AppBar1` and `AppBar2` (`lib/core/widgets/`): Highly reusable header components. They implement `8px` tap-target padding around icons (back arrow, notification bell) and are paired with strict `12px` (top) and `24px` (bottom) grid offsets across all screens to compensate for that invisible tap area natively.
* **Theme Elements**:
  * `AppColors` (`lib/core/theme/app_colors.dart`): Global colors, gradients, and specific card mappings (`card1` to `card5`).
  * `AppTextStyles` (`lib/core/theme/app_text_styles.dart`): Centralized typography generating all font variations cleanly without the use of `.copyWith()`.
* **Standardized 8-Point Grid Layout**:
  * Every major view (Home, Settings, Notifications, Cards) implements a unified fluid container architecture utilizing `double.infinity` constrained by mathematically perfect `24px` horizontal margins.
* **Localization & Strings**:
  * App strictly utilizes `AppLocalizations` (`app_en.arb`). Zero hardcoded text allowed in UI files—even dummy profile data ("Samama Hussain") has been successfully bridged to i18n rules to enforce architecture.
* **Core Initialization**:
  * `main.dart` is pre-configured with `flutter_screenutil` (Size: 393x852) to ensure universal responsiveness and locks the app natively to Portrait orientation.
  * Uses `MaterialApp.router` to strictly enforce GoRouter routing configuration instead of standard Navigator.
* **Utilities**:
  * `AppValidators` (`lib/core/utils/app_validators.dart`): Centralized static methods for all form validation logic, keeping UI code clean.
  * `AppHelpers` (`lib/core/utils/app_helpers.dart`): Centralized helper functions, currently providing global keyboard dismissal via `dismissKeyboard()`.
* **Routing**:
  * `AppRoute` (`lib/core/routing/app_routes.dart`): Strongly typed Enum defining all application paths.
  * `AppRouter` (`lib/core/routing/app_router.dart`): Centralized GoRouter setup utilizing `state.extra` to pass dynamic arguments (like dynamic page titles).

## 2. Features Implemented
* **Authentication**:
  * `SignUpScreen` (`/signup`), `LoginScreen` (`/login`), `ForgotPasswordScreen` (`/forgot-password`): Fully responsive forms with validation. All are `HookConsumerWidget` instances.
  * **Note**: Password visibility toggling is abstracted cleanly inside the stateless `AppLabelledTextField`.
* **Main Screen & Navigation**:
  * `MainScreen`: Hosts bottom navigation and switches between pages. State managed via Riverpod `bottomNavIndexProvider`.
  * `CustomBottomNavBar`: Fully custom bottom navigation with animations and SVG icons.
* **Home Screen**:
  * Displays user greeting, Search Bar, Categories Section, Featured Cards, and Islamic Cards section.
  * Deep-linked "View All" buttons that trigger GoRouter context pushes.
* **Notifications Screen**:
  * Reusable `NotificationCard` widget dynamically styled with responsive 8-point padding gaps, rounded corners, and absolute SVG scaling.
* **Settings Screen**:
  * Extracted and implemented user Profile header and Preferences container block dynamically scaling to screen size.
* **Favorites Screen**:
  * Integrated directly into bottom nav. Features a flexible `GridView` recycling the core `FeaturedCard` components alongside dummy data.
* **Cards Screen (View All)**:
  * Hybrid-use screen. Acts as a passive tab in `MainScreen` (using `AppBar1`) and as an active push-route for "View All" clicks (using `AppBar2` with back navigation).
  * Built as a `HookConsumerWidget` mapping `useState` to a horizontally scrolling row of filter chips featuring real-time active state coloration toggling.
