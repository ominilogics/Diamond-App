# Workspace Rules & Technical Memory - Daimond App

This document stores essential technical memory, layout offsets, animation physics parameters, and responsive design systems for the Daimond Flutter project.

---

## 1. 3D Envelope & Card Emergence Physics (`preview_card_screen.dart`)

- **Total Controller Duration**: `3600ms` (3.6 seconds).
- **Phase 1a (0ms – 400ms / `0.0` to `0.111` interval)**:
  - `closed_top.svg` 3D rotates `0°` -> `90°` around top hinge (`top: 211.29.h`).
  - Card rests flat inside envelope pocket (`height: 165.0.h`, `top: 222.29.h`).
- **Phase 1b (400ms – 800ms / `0.111` to `0.222` interval)**:
  - `animate_top.svg` comes into view at 400ms (90° midpoint) and rotates open `90°` -> `180°`.
  - Simultaneously, card height grows upward (`165.0.h` -> `275.0.h`, `top: 222.29.h` -> `112.29.h`) in 1:1 speed sync with `animate_top` (`Curves.easeInOutSine`).
  - **Bottom Anchor**: Card bottom position (`top + height = 387.29.h`) remains **100% stuck to the bottom of the envelope pocket**.
- **Phase 2 Hold Pause (800ms – 1000ms / `0.222` to `0.278` interval)**:
  - **Exact 200ms (0.2s) pause** at peak height extension (`275.0.h`).
- **Phase 3 Multi-Spin & Gliding Launch (1000ms – 3384ms / `0.278` to `0.94` interval)**:
  - Card launches out of envelope, scaling up to `1.62` (`Curves.easeOutCubic`).
  - 5x PUBG multi-spin (`10 * pi` = `1800°`, `Curves.easeOutQuart` over 1000ms-3240ms), landing face-forward on Front side.
  - **Fast Envelope Dissolve**: Envelope background assets (`_envelopeOpacity`) fade out from `1.0` to `0.0` in **300ms** (`1000ms` to `1300ms`, `Curves.easeOut`) as soon as spinning begins.

---

## 2. Contextual Tap-to-Flip Nudge

- **Trigger Delay**: **5 seconds** idle wait after emergence completes (`AnimationStatus.completed`).
- **Occurrence**: Triggers **once per card view session** ONLY IF the user remains idle on the front side without flipping.
- **Visual Badge & Teaser**: Fades in `[ 🔄 TAP TO FLIP ]` badge (`bottom: 12.h`, 10% black opacity `Color(0x1A000000)`, `12.r` rounded corners) + `15°` (`0.26 rad`) Y-axis teaser peek tilt.
- **Cancellation**: If the user taps/flips the card before 5 seconds, `_hintTimer.cancel()` is called immediately so the hint **never appears**.

---

## 3. Senior Responsive Typography (Non-Scrollable)

- **No Scroll Views**: `SingleChildScrollView` is explicitly removed from all card faces across Card Details, Customize Card, and Preview Details screens.
- **Pattern**: Use `FittedBox(fit: BoxFit.scaleDown)` wrapped around `SizedBox(width: ...)` containing `Text` inside bounded `Positioned` containers.
- **Line Wrapping & Scaling**: Text wraps into natural multi-line paragraphs at native font size (`12.sp` / `10.sp`), and scales down smoothly ONLY if vertical container bounds shrink on small screens.
- **Width Bounds**:
  - Front Cover: `SizedBox(width: 197.w)` (Card Details & Customize), `SizedBox(width: 163.w)` (Preview).
  - Back Inside: `SizedBox(width: 215.w)` (Card Details & Customize), `SizedBox(width: 163.w)` (Preview).

---

## 4. Flap & Layer Asset Offsets

- `animate_top.svg`: `top: 123.86.h`, `left: 45.w`, `width: 300.w`, `height: 95.43.h`.
- `closed_top.svg`: `top: 211.29.h`, `left: 44.w`, `width: 302.w`, `height: 133.h`.
- `animate_middle.svg`: `top: 216.29.h`, `left: 47.w`, `width: 296.w`, `height: 171.h`.
- `envelopeFront.png`: `top: 220.92.h`, `width: 320.w`, `height: 200.37.h`.
- **Card Image Fit**: Always use `fit: BoxFit.fill` for card artwork so left and right edges are never cropped or chopped off.
