import 'package:flutter/material.dart';

/// Application theme configuration
class AppTheme {
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color secondaryColor = Color(0xFF26C6DA);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF43A047);
  
  // Category colors
  static const Color applicationColor = Color(0xFF5C6BC0);
  static const Color systemColor = Color(0xFF42A5F5);
  static const Color securityColor = Color(0xFFEF5350);
  static const Color hardwareColor = Color(0xFF66BB6A);

  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2D2D2D);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: surfaceDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardTheme: const CardThemeData(
        color: cardDark,
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardDark,
        selectedColor: primaryColor.withValues(alpha: 0.3),
        labelStyle: const TextStyle(fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  /// Get color for log category
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'application':
        return applicationColor;
      case 'system':
        return systemColor;
      case 'security':
        return securityColor;
      case 'hardware':
        return hardwareColor;
      default:
        return primaryColor;
    }
  }
}
