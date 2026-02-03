import 'package:flutter/material.dart';

/// Vaxp color palette - simplified without venom_config
class VaxpColors {
  static const Color primary = Color.fromARGB(141, 32, 32, 32);
  static const Color secondary = Color.fromARGB(111, 122, 177, 255);

  /// 🔲 خلفية النظام (الخلفية العامة)
  static const Color darkGlassBackground = Color.fromARGB(188, 0, 0, 0);

  /// 🧊 لون الزجاج (سطح نصف شفاف)
  static const Color glassSurface = Color.fromARGB(188, 0, 0, 0);

  /// Aliases for compatibility
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2D2D2D);
  static const Color primaryColor = Color(0xFF1E88E5);

  /// 📝 لون النصوص الافتراضي
  static Color defaultText = Colors.white;
  static final ValueNotifier<Color> textNotifier = ValueNotifier<Color>(
    Colors.white,
  );

  // Category colors for logs
  static const Color applicationColor = Color(0xFF5C6BC0);
  static const Color systemColor = Color(0xFF42A5F5);
  static const Color securityColor = Color(0xFFEF5350);
  static const Color hardwareColor = Color(0xFF66BB6A);
  
  // Status colors
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF43A047);
  static const Color infoColor = Color(0xFF1E88E5);

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
        return infoColor;
    }
  }
}
