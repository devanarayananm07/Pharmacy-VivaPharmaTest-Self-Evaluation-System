import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ObsidianTheme {
  static const Color primary = Color(0xFFa78bfa);
  static const Color background = Color(0xFF09090b);
  static const Color surfaceContainer = Color(0xFF121215);
  static const Color surfaceContainerHighest = Color(0xFF1e1e22);
  static const Color surfaceContainerLow = Color(0xFF0e0e11);
  static const Color surfaceContainerLowest = Color(0xFF09090b);
  static const Color outline = Color(0xFF3f3f46);
  static const Color outlineVariant = Color(0xFF27272a);
  static const Color tertiary = Color(0xFF34d399);
  static const Color error = Color(0xFFef4444);
  
  static const Color onSurface = Color(0xFFfafafa);
  static const Color onSurfaceVariant = Color(0xFFa1a1aa);

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.geistTextTheme();
    
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: tertiary,
        surface: background,
        surfaceContainer: surfaceContainer,
        surfaceContainerHighest: surfaceContainerHighest,
        error: error,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outlineVariant: outlineVariant,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(color: onSurface, letterSpacing: -0.02),
        displayMedium: baseTextTheme.displayMedium?.copyWith(color: onSurface, letterSpacing: -0.02),
        displaySmall: baseTextTheme.displaySmall?.copyWith(color: onSurface, letterSpacing: -0.02),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: onSurface, letterSpacing: -0.02),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: onSurface, letterSpacing: -0.02),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: onSurface, letterSpacing: -0.02),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: onSurface),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: onSurface),
        titleSmall: baseTextTheme.titleSmall?.copyWith(color: onSurfaceVariant),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: onSurface),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: onSurfaceVariant),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: outlineVariant, width: 1),
        ),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: const TextStyle(color: onSurfaceVariant),
        hintStyle: const TextStyle(color: onSurfaceVariant),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFF0a0012),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.geistTextTheme();
    
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      primaryColor: const Color(0xFF7C3AED),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF7C3AED),
        secondary: Color(0xFF059669),
        surface: Color(0xFFFFFFFF),
        surfaceContainer: Color(0xFFF4F4F5),
        surfaceContainerHighest: Color(0xFFE4E4E7),
        error: Color(0xFFDC2626),
        onSurface: Color(0xFF09090B),
        onSurfaceVariant: Color(0xFF71717A),
        outlineVariant: Color(0xFFE4E4E7),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(color: const Color(0xFF09090B), letterSpacing: -0.02),
        displayMedium: baseTextTheme.displayMedium?.copyWith(color: const Color(0xFF09090B), letterSpacing: -0.02),
        displaySmall: baseTextTheme.displaySmall?.copyWith(color: const Color(0xFF09090B), letterSpacing: -0.02),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: const Color(0xFF09090B), letterSpacing: -0.02),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: const Color(0xFF09090B), letterSpacing: -0.02),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: const Color(0xFF09090B), letterSpacing: -0.02),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: const Color(0xFF09090B)),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: const Color(0xFF09090B)),
        titleSmall: baseTextTheme.titleSmall?.copyWith(color: const Color(0xFF71717A)),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: const Color(0xFF09090B)),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: const Color(0xFF71717A)),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: const Color(0xFF71717A)),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE4E4E7), width: 1),
        ),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF71717A)),
        hintStyle: const TextStyle(color: Color(0xFF71717A)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C3AED),
          foregroundColor: const Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF7C3AED),
          side: const BorderSide(color: Color(0xFF7C3AED)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF7C3AED),
        ),
      ),
    );
  }
}

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _init();
    return ThemeMode.dark;
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('theme_is_dark') ?? true;
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    } catch (_) {}
  }

  Future<void> toggleTheme(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('theme_is_dark', isDark);
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    } catch (_) {}
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});
