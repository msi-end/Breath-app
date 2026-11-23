import 'package:flutter/material.dart';

/// BreatheCare nature palette.
class AppColors {
  AppColors._();

  static const sage = Color(0xFF8FAE8B);
  static const sageDark = Color(0xFF6E8F6B);
  static const mint = Color(0xFFD5EFE1);
  static const mintDeep = Color(0xFFA9DCC2);
  static const sky = Color(0xFFA8D2EA);
  static const skyDeep = Color(0xFF6FAFD3);
  static const cream = Color(0xFFFBF6EC);
  static const creamDeep = Color(0xFFF1E8D6);
  static const forest = Color(0xFF24442F);
  static const forestSoft = Color(0xFF3B6248);
  static const sun = Color(0xFFF4D9A6);
  static const blush = Color(0xFFF2C9B8);
  static const lavender = Color(0xFFCFC8EA);

  // Dark theme surfaces
  static const night = Color(0xFF0B120E);
  static const nightSurface = Color(0xFF121C16);
  static const nightCard = Color(0xFF17231C);
  static const nightLine = Color(0xFF26382D);
}

/// Theme-aware accessors used throughout the UI.
extension NatureColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get cardColor => isDark ? AppColors.nightCard : Colors.white;
  Color get softText => isDark ? AppColors.cream.withValues(alpha: 0.7) : AppColors.forest.withValues(alpha: 0.65);
  Color get strongText => isDark ? AppColors.cream : AppColors.forest;
  Color get pageBackground => isDark ? AppColors.night : AppColors.cream;
}
