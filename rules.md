# Project Rules

## Architectural Guidelines & Principles

* **Architecture**: Feature-based Clean Architecture throughout the app.
* **State Management**: Riverpod.
* **Navigation**: Go Router.
* **Code Quality**: Code must be highly testable, maintainable, and expandable. Adding new features in the future should be straightforward.
* **Design Principles**: Strictly follow SOLID and KISS principles.
* **Separation of Concerns**: Clearly separate UI from business logic.
* **Scalability & Performance**: The application targets over a million users. Code must be optimized for smoothness and capable of handling high scale and performance requirements.

## Implementation Standards

### 1. Directory Structure
* Each feature must have three main layers: `presentation` (UI & Riverpod controllers), `domain` (entities, use cases, repository interfaces), and `data` (models, repository implementations, data sources).

### 2. Error Handling & State Representation
* Never expose raw Exceptions to the UI. The data/domain layer must catch exceptions and return standardized `Failure` objects (e.g., using `Either` type from packages like `fpdart` or `dartz`).
* UI states should explicitly handle `loading`, `error`, and `success` states (leveraging Riverpod's `AsyncValue`).

### 3. Flutter Performance Rules
* Aggressively use `const` constructors everywhere to reduce widget rebuilds.
* Keep the `build` methods absolutely clean. No business logic, heavy computations, or data parsing should happen inside `build()`.
* Use `RepaintBoundary` for animations or frequently updating widgets to prevent redrawing the entire screen.

### 4. Testing Requirements
* Every new business logic class (Use Cases, Riverpod Notifiers) must have accompanying Unit Tests.
* Mocks should be generated using `mockito` or `mocktail`.

### 5. Linting & Code Formatting
* Enforce strict linting rules using a package like `very_good_analysis` or `flutter_lints`. All code must pass linter checks without warnings.
* All files must be formatted using `dart format` before committing.

### 6. Dependency Injection Strategy
* Use Riverpod exclusively for Dependency Injection. Global singletons should be avoided; instead, use Riverpod `Provider`s to pass down dependencies like repositories and data sources.

### 7. Security & Storage
* Never store sensitive data (like auth tokens or user PII) in plain `SharedPreferences`. Always use `flutter_secure_storage`.

### 8. Internationalization (i18n)
* Hardcoding strings in the UI is strictly prohibited. All user-facing text must use Flutter's localizations (`AppLocalizations`) to ensure the app is ready for global expansion.

### 9. UI & Device Configuration
* **Responsiveness**: Use the `flutter_screenutil` package to ensure UI components scale perfectly across all screen sizes.
* **Platform Support**: The app targets Android and iOS.
* **Orientation**: The application must be locked to **Portrait mode** only (disable landscape mode entirely).

### 10. Theme & Styling
* **Global Background**: Every screen's Scaffold must use the following linear gradient background: `linear-gradient(180deg, #E7FFEC 0%, #FFFFFF 50%, #FDEBFA 100%)`.
  * *Implementation Note*: Since Flutter's `Scaffold.backgroundColor` only takes solid colors, implement a custom base wrapper widget (e.g., `BaseScaffold`) that wraps the content in a `Container` or `DecoratedBox` with a `BoxDecoration` using a `LinearGradient`.
* **Primary Button**: The primary button uses a gradient background: `linear-gradient(270deg, #FF5E60 0%, #FF8B8D 100%)`.
* **Typography**: All text styles are tightly managed in `AppTextStyles` (`lib/core/theme/app_text_styles.dart`).
  * Methods must be strictly named after exact design tokens (e.g., `colitez400Italic32`, `roboto400Regular16`).
  * Methods take optional overrides for every property but perfectly default to their strict design rules.
  * Flutter's `TextLeadingDistribution.even` is used on `TextStyle` to approximate CSS `leading-trim: NONE`.
  * Do **NOT** use or add dummy/placeholder text styles. Only add styles that are explicitly provided by the user.

### 11. Layout & Spacing Standards
* **8-Point Grid System**: All vertical spacing must strictly follow an 8-point grid rhythm (e.g., 8, 16, 24, 32, 40) to ensure a mathematically consistent vertical rhythm.
* **Fluid Horizontal Margins**: Every primary screen must employ a standardized `24px` horizontal padding (`EdgeInsets.symmetric(horizontal: 24.w)`). Hardcoded absolute widths (like `356.w`) for full-width containers are strictly prohibited. Instead, use `double.infinity` inside the `24px` padded parent to ensure perfectly fluid scaling across different device widths.
* **AppBar Offset Compensation**: 
  * To ensure accessible touch targets, interactive icons in headers (like back arrows or notification bells) have an invisible `8px` tap-target padding. 
  * To mathematically maintain the visual grid against this invisible padding, the spacing immediately **above** any `AppBar` must be strictly `12.h` (visual 20 - padding 8).
  * The spacing immediately **below** any `AppBar` must be strictly `24.h` (visual 32 - padding 8).

### 12. Core Reusable Widgets Library
To ensure DRY principles and absolute visual consistency, developers must leverage the following established UI components before building custom implementations:
* **Scaffolding & Layout**:
  * `GradientScaffold`: Base wrapper applying the global vertical linear gradient background.
* **Headers / AppBars**:
  * `AppBar1`: Primary screen header. Used for top-level tabs (Home, Settings, Favorites). Features the notification bell with an expanded tap target.
  * `AppBar2`: Secondary screen header. Used for pushed navigation routes. Features the back arrow with an expanded tap target.
* **Forms & Inputs**:
  * `AppTextField`: Standard text input field.
  * `AppLabelledTextField`: Labelled text input featuring built-in internal state management for toggling password visibility.
  * `PrimaryButton`: Global gradient action button.
* **Cards & Content Blocks**:
  * `FeaturedCard`: Standard vertical display card featuring the dynamic colored graphic and bottom text. Utilized extensively in grid layouts (Home, Cards, and Favorites).
  * `CategoryCard`: Standard horizontal display card featuring a colored block, title, subtitle, and an actionable "View All" interaction.
  * `NotificationCard`: Fully responsive horizontal row card containing a colored avatar, structured text lines, and right-aligned timestamps.

### 13. Code Constraints & Reusability
* **File Size Limits**: No file should exceed 500 lines of code. This is a strict rule to enforce maintainability and separation of concerns. If absolutely necessary, 700 lines is the absolute red line.
* **Reusable Widgets**: Always create and use reusable widgets whenever necessary. Extract UI components to keep files small, clean, and DRY (Don't Repeat Yourself).
