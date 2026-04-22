import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KineticVaultTheme {
  // --- Design Tokens (Tailwind-like) ---
  
  // Spacing (8px grid)
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXl = 24.0;
  static const double spacing2xl = 32.0;
  static const double spacing3xl = 48.0;
  static const double spacing4xl = 64.0;

  // Border Radius
  static const double radiusXs = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXl = 24.0;
  static const double radius2xl = 32.0;
  static const double radiusFull = 9999.0;

  // Animations
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Curve curveDefault = Curves.easeInOutCubic;

  // Brand Colors from Tailwind Config
  static const Color background = Color(0xFF0C0E12);
  static const Color surface = Color(0xFF0C0E12);
  static const Color surfaceContainer = Color(0xFF171A1F);
  static const Color surfaceContainerLow = Color(0xFF111318);
  static const Color surfaceContainerHigh = Color(0xFF1D2025);
  static const Color surfaceContainerHighest = Color(0xFF23262C);
  
  static const Color primary = Color(0xFF81ECFF);
  static const Color primaryFixed = Color(0xFF00E3FD);
  static const Color secondary = Color(0xFFBC87FE);
  static const Color tertiary = Color(0xFFAAFFDC);
  static const Color error = Color(0xFFFF716C);
  static const Color errorDim = Color(0xFFD7383B);
  static const Color errorContainer = Color(0xFF9F0519);
  
  static const Color onSurface = Color(0xFFF6F6FC);
  static const Color onSurfaceVariant = Color(0xFFAAABB0);
  static const Color onPrimaryFixed = Color(0xFF003840);
  static const Color outline = Color(0xFF74757A);
  static const Color outlineVariant = Color(0xFF46484D);

  static String formatCurrency(double amount) {
    // Basic formatting for IDR
    final String sign = amount < 0 ? '-' : '';
    final String absoluteValue = amount.abs().toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = absoluteValue.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(absoluteValue[i]);
      count++;
    }
    return 'Rp $sign${buffer.toString().split('').reversed.join('')}';
  }

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryFixed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        error: error,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        surfaceContainer: surfaceContainer,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainerHighest: surfaceContainerHighest,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          bodyLarge: TextStyle(color: onSurface),
          bodyMedium: TextStyle(color: onSurface),
          labelLarge: TextStyle(fontWeight: FontWeight.w700),
        ),
      ).copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: onSurface),
        headlineLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: onSurface),
        headlineMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: onSurface),
        titleLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: onSurface),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
