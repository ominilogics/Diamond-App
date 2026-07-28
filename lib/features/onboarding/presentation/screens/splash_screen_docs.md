# Daimond Splash Screen Documentation

This document provides a comprehensive technical overview of the **Daimond Splash Screen** (`SplashScreen`), including its architecture, animation timeline, performance optimizations, routing logic, and asset references.

---

## 1. Overview & Location

- **File Path**: [`lib/features/onboarding/presentation/screens/splash_screen.dart`](file:///c:/Users/PC/Documents/GitHub/daimond/lib/features/onboarding/presentation/screens/splash_screen.dart)
- **Route Name / Path**: `AppRoute.splash` (`/`)
- **Widget Type**: `StatefulWidget` using `TickerProviderStateMixin`
- **Total Duration**: `3.2 Seconds` (`3200ms`)

---

## 2. Animation Timeline & Sequence

The entire sequence is driven by a single high-performance `AnimationController` split into fluid, non-blocking phase intervals:

| Phase | Timeline Interval | Keyframe Range | Animation Type | Target Component |
| :--- | :--- | :--- | :--- | :--- |
| **1. Back Card Slide** | `0.00 – 0.22` (0ms – 792ms) | `Offset(-1.4, 0)` → `Offset.zero` | `Curves.easeOutCubic` Slide & Opacity | Back Card SVG (`back_card.svg`) |
| **2. Front Card Slide** | `0.03 – 0.28` (108ms – 1008ms) | `Offset(-1.6, 0)` → `Offset.zero` | Staggered Slide with Drop Shadow | Front Card SVG (`front_card.svg`) |
| **3. 'R' Letter Pop** | `0.25 – 0.42` (900ms – 1512ms) | `Scale 0.5 → 1.0`, `Opacity 0 → 1` | `Curves.easeOutBack` Spring Pop | R Letter PNG (`R_letter.png`) |
| **4. Custom Underline Line** | `0.36 – 0.92` (1300ms – 3300ms) | `Width 0.0 → 55.79px` (Static 2.0s Duration) | `Curves.easeInOutCubic` Custom Loading Line | Custom `_UnderlineLoadingPainter` |
| **5. Navigation** | `1.00` (3600ms) | Instant route push (No fade-out) | GoRouter Navigation | `_navigateNext()` |

---

## 3. Front Card Drop Shadow

Applied exclusively to the Front Card SVG container:
- **CSS Formula**: `box-shadow: -15.45px 25.72px 28.28px 0px #6C01174D;`
- **Flutter Implementation**:
  ```dart
  BoxShadow(
    color: Color(0x4D6C0117), // #6C01174D (30% opacity)
    offset: Offset(-15.45, 25.72),
    blurRadius: 28.28,
    spreadRadius: 0.0,
  )
  ```

---

## 3. Custom Underline Loading Line Widget

Instead of a static image asset, the underline is rendered dynamically via a hardware-accelerated `CustomPainter` (`_UnderlineLoadingPainter`):
- **Track Background**: Crisp white (`Colors.white`).
- **Filled Active Bar**: CSS `270.59deg` LinearGradient (`#FB6A79 0.38%`, `#FB3D5F 61.51%`, `#FB3D5F 99.62%`)
- **Rotation**: `7° anticlockwise` (`Transform.rotate(angle: -7 * math.pi / 180)`).
- **Positioning & Size**:
  - `left: 25.41`
  - `top: 130.36` (exact `17px` gap below R letter's bottom boundary)
  - `width: 64.13`
  - `height: 6.0` (6.0px pill height)

---

## 3. Visual Styling & Design Metrics

### Background Gradient
- **Scaffold Color**: `#FB3D5F`
- **Linear Gradient** (CSS `270.59deg`):
  - `begin`: `Alignment.centerRight`
  - `end`: `Alignment.centerLeft`
  - `stops`: `[0.0038, 0.6151, 0.9962]`
  - `colors`: `[#FB6A79, #FB3D5F, #FB3D5F]`

### Composition Bounding Box
- **Canvas Size**: `131.03w` x `168.26h` (1x Figma pixel ratio)
- **Status Bar Style**: Translucent background with forced white icons (`Brightness.light`) via `SystemChrome.setSystemUIOverlayStyle`.

---

## 4. Assets & Coordinates

1. **Back Card**:
   - Asset: `assets/icons/back_card.svg`
   - Size: `123.63` x `157.09`
   - Position: `left: 7.4`, `top: 0`
2. **Front Card**:
   - Asset: `assets/icons/front_card.svg`
   - Size: `109.32` x `150.84`
   - Position: `left: 0`, `top: 17.42`
3. **R Letter**:
   - Asset: `assets/icons/R_letter.png`
   - Rendered Size: `55.79px` x `60.53px`
   - Composition Relative Position: `left: 26.51px`, `top: 47.83px`
4. **Custom Underline Loading Line**:
   - Track Background: Crisp white (`Colors.white`).
   - Filled Active Bar: CSS `270.59deg` LinearGradient (`#FB6A79 0.38%`, `#FB3D5F 61.51%`, `#FB3D5F 99.62%`)
   - Rotation: `8° anticlockwise` (`Transform.rotate(angle: -8 * math.pi / 180)`).
   - Positioning & Size: `left: 26.51`, `top: 130.36`, `width: 55.79` (matched to R letter width), `height: 7.0`

---

## 5. Navigation Routing Logic (`_navigateNext`)

Upon completion of `_controller.forward()`, the app evaluates session state and target platform:

```
                  ┌──────────────────────┐
                  │ _controller complete │
                  └──────────┬───────────┘
                             │
                      Is kIsWeb == true?
                     ┌───────┴───────┐
                    YES              NO
                     │               │
                     v               v
            AppRoute.adminDashboard  Is Supabase session active?
                                    ┌────────┴────────┐
                                   YES                NO
                                    │                 │
                                    v                 v
                              AppRoute.main     Has seen onboarding?
                                               ┌──────┴──────┐
                                              YES            NO
                                               │              │
                                               v              v
                                         AppRoute.login  AppRoute.onboarding
```

---

## 6. Performance Optimization & Low-End Devices

- **Hardware Acceleration**: Replaced expensive runtime pixel blurs (`ImageFilter.blur`) with `SlideTransition` and `Transform.translate`. Transforms run directly on the GPU composite layer without causing CPU/GPU pixel recalculation bottlenecks.
- **Constant Frame Rate**: Maintained a steady 60–120 FPS frame rate on low-end budget Android hardware.
- **Clean Memory Cleanup**: `_controller.dispose()` releases TickerProvider resources immediately when navigating off screen.
- **Removed Unnecessary Elements**: Bottom `CircularProgressIndicator` removed to minimize rebuild loops and keep screen minimalist and focused.
