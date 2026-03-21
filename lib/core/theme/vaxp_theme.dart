import 'dart:ui';
import 'package:flutter/material.dart';
import '../colors/vaxp_colors.dart';
import '../text/vaxp_text_theme.dart';

class VaxpTheme {
  /// 🎨 الثيم الرسمي (دارك + زجاجي)
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: VaxpColors.secondary,
      secondary: VaxpColors.secondary,
      surface: VaxpColors.glassSurface,
    ),
    scaffoldBackgroundColor: VaxpColors.darkGlassBackground,
    primaryColor: VaxpColors.secondary,
    textTheme: VaxpTextTheme.darkText,
    
    // ⚡️ AppBar شفاف بزجاجية
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // 📦 Card
    cardTheme: CardThemeData(
      color: VaxpColors.glassSurface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.all(8),
    ),

    // 🔘 ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: VaxpColors.secondary.withValues(alpha: 0.8),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    // ⚪ OutlinedButton
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: VaxpColors.secondary.withValues(alpha: 0.5)),
        foregroundColor: VaxpColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ),

    // 🧭 NavigationBar
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      elevation: 0,
      height: 72,
      indicatorColor: VaxpColors.secondary.withValues(alpha: 0.25),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.all(
        const IconThemeData(),
      ),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // ⚙️ Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: VaxpColors.secondary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),

    // 💬 TextFields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: VaxpColors.glassSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: VaxpColors.secondary, width: 1.3),
      ),
      hintStyle: const TextStyle(color: Colors.white54),
      labelStyle: const TextStyle(),
    ),

    // 🧩 Drawer
    drawerTheme: DrawerThemeData(
      backgroundColor: VaxpColors.glassSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
    ),

    // 💬 Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: VaxpColors.glassSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(fontSize: 15),
    ),

    // ✅ Checkbox / Switch / Slider
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.all(VaxpColors.secondary),
      checkColor: WidgetStateProperty.all(Colors.white),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(
        VaxpColors.secondary.withValues(alpha: 0.9),
      ),
      trackColor: WidgetStateProperty.all(
        VaxpColors.secondary.withValues(alpha: 0.4),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: VaxpColors.secondary,
      thumbColor: VaxpColors.secondary,
      inactiveTrackColor: VaxpColors.secondary.withValues(alpha: 0.2),
    ),

    // 🧭 BottomSheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: VaxpColors.glassSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );
}

/// 🧊 أداة جاهزة لتطبيق الزجاج (Blur) على أي Widget
class VaxpGlass extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? radius;

  const VaxpGlass({
    super.key,
    required this.child,
    this.blur = 18,
    this.opacity = 0.25,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity * 0.8),
            borderRadius: radius ?? BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: child,
        ),
      ),
    );
  }
}
