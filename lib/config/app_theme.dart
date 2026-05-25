import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      cardColor: AppColors.cardBgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.cardBgLight,
        onSurface: AppColors.textPriLight,
        onSurfaceVariant: AppColors.textSecLight,
        error: AppColors.error,
        brightness: Brightness.light,
      ),
      fontFamily: 'Inter',
      textTheme: _buildTextTheme(
        AppColors.textPriLight,
        AppColors.textSecLight,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      cardColor: AppColors.cardBgDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.cardBgDark,
        onSurface: AppColors.textPriDark,
        onSurfaceVariant: AppColors.textSecDark,
        error: AppColors.error,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Inter',
      textTheme: _buildTextTheme(AppColors.textPriDark, AppColors.textSecDark),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: secondaryColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: primaryColor,
      ),
    );
  }
}
