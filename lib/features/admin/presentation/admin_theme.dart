import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:daimond/core/theme/app_colors.dart';
export 'package:daimond/core/theme/app_colors.dart';

/// Centralized Design System Tokens for Rivon Admin Dashboard
/// Primary-Centric Chromatic Color Architecture revolving around AppColors (#FF5E60)
/// Combined with Enterprise High-Density Sizing Standards.

// ─── 1. Primary Brand Spectrum (1:1 Mobile App) ───
const kPrimary = AppColors.primaryButtonGradientStart; // 0xFFFF5E60 (App Primary Brand Coral)
const kPrimaryEnd = AppColors.primaryButtonGradientEnd; // 0xFFFF8B8D (App Gradient End)
const kPrimaryGradient = AppColors.primaryButtonGradient;
const kPrimaryLight = Color(0xFFFFF0F2); // 6% soft rose wash
const kPrimaryBorder = Color(0xFFFED7DA); // Delicate coral border
const kPrimaryDark = Color(0xFFE03E40); // WCAG AA accessible coral for text links

// ─── 2. Consumer App Pastel Accents & Saturated Companions ───
const kCoral = AppColors.card1; // 0xFFFFA7A7 (Soft Salmon)
const kPurple = AppColors.card2; // 0xFFADA7FF (Lavender Periwinkle / VIP)
const kPurpleText = Color(0xFF6366F1); // Saturated contrast companion
const kPurpleLight = Color(0xFFF5F3FF);
const kSkyBlue = AppColors.card3; // 0xFFA7CDFF (Soft Sky Blue)
const kSkyBlueText = Color(0xFF2563EB); // Saturated contrast companion
const kSkyBlueLight = Color(0xFFEFF6FF);
const kMint = AppColors.card4; // 0xFFA7FFB5 (Mint Green)
const kApricot = AppColors.card5; // 0xFFFFDCA7 (Warm Apricot)
const kApricotText = Color(0xFFD97706); // Saturated contrast companion

// ─── 3. Functional Semantics (Harmonized with Warm Palette) ───
const kSuccess = Color(0xFF10B981); // Emerald Green
const kSuccessLight = AppColors.gradientStart; // 0xFFE7FFEC (App light mint)
const kWarning = Color(0xFFF59E0B); // Warm Amber
const kWarningLight = Color(0xFFFFFBEB);
const kDanger = Color(0xFFE11D48); // Ruby Crimson (Decoupled from brand coral for unambiguous danger)
const kDangerLight = Color(0xFFFFF1F2);

// ─── 4. Chromatic Neutrals (Tinted with Warm Rose / Coral Undertone) ───
const kDashBg = Color(0xFFFAF7F7); // Warm porcelain canvas (not cold bluish)
const kDashCardBg = Color(0xFFFFFFFF); // Pure white card surface
const kDashBorder = Color(0xFFEFEAE9); // Rose-stone subtle border
const kDashDivider = Color(0xFFF7F3F3); // Soft warm table divider

// ─── 5. Chromatic Dark Sidebar (Deep Obsidian Warm Slate) ───
const kSidebarBg = Color(0xFF181214); // Deep luxury obsidian slate with warm rose undertone
const kSidebarHoverBg = Color(0xFF251D20); // Warm dark hover
const kSidebarActiveBg = AppColors.primaryButtonGradientStart; // 0xFFFF5E60
const kSidebarText = Color(0xFFA29396); // Muted rose-slate
const kSidebarTextActive = Colors.white;
const kSidebarSection = Color(0xFF746568); // Uppercase group headers

// ─── 6. Chromatic Typography Hierarchy ───
const kTitleColor = Color(0xFF1A1113); // Deep obsidian warm dark
const kBodyColor = Color(0xFF3E3134); // High-contrast warm charcoal
const kLabelColor = Color(0xFF6E5C60); // Warm rose-slate (App secondary text evolution)
const kMutedColor = Color(0xFF9E8D91); // Table headers and meta timestamps

// ─── 7. Professional High-Density Dimensions & Radii ───
const kSidebarWidth = 256.0; // Professional enterprise sidebar width (upgraded from 224px)
const kCardRadius = 12.0; // Compact modern corners (from 16-20px)
const kCardPadding = 16.0; // High-density internal padding (from 20-24px)
const kPagePadding = 20.0; // Compact margins (from 32px)
const kTopBarHeight = 54.0; // Streamlined top bar (from 64px)

// ─── 8. Shadows ───
final kCardShadow = BoxShadow(
  color: const Color(0xFF1A1113).withValues(alpha: 0.035),
  blurRadius: 8,
  offset: const Offset(0, 1.5),
);

// ─── Reusable Card Decoration ───
final kCardDecoration = BoxDecoration(
  color: kDashCardBg,
  borderRadius: BorderRadius.circular(kCardRadius),
  border: Border.all(color: kDashBorder),
  boxShadow: [kCardShadow],
);

// ─── Global Admin Theme with Inter Typography ───
ThemeData buildAdminTheme(BuildContext context) {
  final base = Theme.of(context);
  final interTextTheme = GoogleFonts.interTextTheme(base.textTheme);

  return base.copyWith(
    scaffoldBackgroundColor: kDashBg,
    textTheme: interTextTheme.apply(
      bodyColor: kBodyColor,
      displayColor: kTitleColor,
    ),
    colorScheme: base.colorScheme.copyWith(
      primary: kPrimary,
      surface: kDashCardBg,
      error: kDanger,
    ),
    cardTheme: CardThemeData(
      color: kDashCardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
        side: const BorderSide(color: kDashBorder),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kTitleColor,
        side: const BorderSide(color: kDashBorder),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kPrimary,
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kDashBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      hintStyle: GoogleFonts.inter(
        color: kMutedColor,
        fontSize: 12.5,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kDashBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kDashBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kPrimary, width: 1.5),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: kDashCardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: kDashBorder),
      ),
      titleTextStyle: GoogleFonts.inter(
        color: kTitleColor,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: GoogleFonts.inter(
        color: kBodyColor,
        fontSize: 13,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: kDashDivider,
      thickness: 1,
      space: 1,
    ),
  );
}

// ─── Universal High-Density Admin Dialog Container ───
Widget buildAdminDialog({
  required BuildContext context,
  required String title,
  required IconData icon,
  Color iconColor = kPrimary,
  required Widget content,
  List<Widget>? actions,
  double width = 440,
}) {
  return Dialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    child: Container(
      width: width,
      decoration: BoxDecoration(
        color: kDashCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kDashBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1113).withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: kDashBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: Border(bottom: BorderSide(color: kDashBorder)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kTitleColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: kLabelColor),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Body Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: content,
            ),
          ),
          // Footer Actions
          if (actions != null && actions.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: const BoxDecoration(
                color: kDashBg,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                border: Border(top: BorderSide(color: kDashBorder)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions,
              ),
            ),
        ],
      ),
    ),
  );
}
