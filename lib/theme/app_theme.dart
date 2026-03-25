import 'package:flutter/material.dart';

/// 毒鸡汤 App — 简洁大气的深色主题与色板
abstract final class AppColors {
  static const Color scaffold = Color(0xFF0E1013);
  static const Color surface = Color(0xFF161A1F);
  static const Color surfaceElevated = Color(0xFF1E2329);
  static const Color border = Color(0xFF2A3038);
  static const Color textPrimary = Color(0xFFF2F4F7);
  static const Color textSecondary = Color(0xFF8F96A0);
  static const Color poison = Color(0xFFB85C5C);
  static const Color manga = Color(0xFFD97848);
  static const Color net = Color(0xFF5A9AD4);
  static const Color profile = Color(0xFF7C5CD6);
  static const Color subtleGlow = Color(0x14FFFFFF);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.scaffold,
    colorScheme: ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.textPrimary,
      onPrimary: AppColors.scaffold,
      secondary: AppColors.textSecondary,
      onSurface: AppColors.textPrimary,
      outline: AppColors.border,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface.withValues(alpha: 0.94),
      indicatorColor: AppColors.subtleGlow,
      elevation: 0,
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          );
        }
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        );
      }),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceElevated,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        height: 1.55,
        letterSpacing: 0.15,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        height: 1.45,
        color: AppColors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: AppColors.textSecondary,
      ),
    ),
  );
}
