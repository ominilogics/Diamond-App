import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Gradient Background Colors
  static const Color gradientStart = Color(0xFFE7FFEC);
  static const Color gradientMiddle = Color(0xFFFFFFFF);
  static const Color gradientEnd = Color(0xFFFDEBFA);

  // Global Background Gradient
  static const LinearGradient globalBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      gradientStart,
      gradientMiddle,
      gradientEnd,
    ],
    stops: [0.0, 0.5, 1.0], // 0%, 50%, 100%
  );
  // Primary Button Colors
  static const Color primaryButtonGradientStart = Color(0xFFFF5E60);
  static const Color primaryButtonGradientEnd = Color(0xFFFF8B8D);

  // Primary Button Gradient (270deg = right to left)
  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
    colors: [
      primaryButtonGradientStart,
      primaryButtonGradientEnd,
    ],
  );

  // Card Colors
  static const Color card1 = Color(0xFFFFA7A7);
  static const Color card2 = Color(0xFFADA7FF);
  static const Color card3 = Color(0xFFA7CDFF);
  static const Color card4 = Color(0xFFA7FFB5); // Light Green
  static const Color card5 = Color(0xFFFFDCA7);
}
