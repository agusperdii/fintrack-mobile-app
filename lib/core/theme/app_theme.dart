// app_theme.dart
// Mendefinisikan token desain aplikasi (spacing, radius, durasi animasi,
// palet warna mode terang/gelap) serta membangun ThemeData Material untuk
// digunakan di seluruh aplikasi.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SavaioTheme {
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXl = 24.0;
  static const double spacing2xl = 32.0;
  static const double spacing3xl = 48.0;
  static const double spacing4xl = 64.0;

  static const double radiusXs = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXl = 24.0;
  static const double radius2xl = 32.0;
  static const double radiusFull = 16.0;

  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Curve curveDefault = Curves.easeInOutCubic;

static const Color background = Color(0xFF0D0D0D);
static const Color surface = Color(0xFF0D0D0D);

static const Color surfaceContainer = Color(0xFF161616);
static const Color surfaceContainerLow = Color(0xFF121212);
static const Color surfaceContainerHigh = Color(0xFF1E1E1E);
static const Color surfaceContainerHighest = Color(0xFF262626);

static const Color primary = Color(0xFFD4AF37);
static const Color primaryFixed = Color(0xFFFFD700);

static const Color secondary = Color(0xFFE6C766);
static const Color tertiary = Color(0xFFF4E3A1);

static const Color success = Color(0xFF6EE7B7);
static const Color warning = Color(0xFFFFC800);

static const Color error = Color(0xFFFF6B6B);
static const Color errorDim = Color(0xFFE04B4B);
static const Color errorContainer = Color(0xFF8F1D2C);

static const Color onSurface = Color(0xFFF8F8F8);
static const Color onSurfaceVariant = Color(0xFFB5B5B5);

static const Color onPrimaryFixed = Color(0xFF1A1A1A);

static const Color outline = Color(0xFF8A8A8A);
static const Color outlineVariant = Color(0xFF3A3A3A);

static const Color lightBackground = Color(0xFFFAFAFA);
static const Color lightSurface = Color(0xFFFFFFFF);

static const Color lightSurfaceContainer = Color(0xFFF4F4F4);
static const Color lightSurfaceContainerLow = Color(0xFFFFFFFF);
static const Color lightSurfaceContainerHigh = Color(0xFFECECEC);
static const Color lightSurfaceContainerHighest = Color(0xFFE0E0E0);

static const Color lightPrimary = Color(0xFFB8860B);
static const Color lightPrimaryFixed = Color(0xFFD4AF37);

static const Color lightSecondary = Color(0xFF8A6A00);
static const Color lightTertiary = Color(0xFF6F5600);

static const Color lightSuccess = Color(0xFF047857);
static const Color lightWarning = Color(0xFFD97706);

static const Color lightError = Color(0xFFBA1A1A);
static const Color lightErrorDim = Color(0xFF93000A);
static const Color lightErrorContainer = Color(0xFFFFDAD6);

static const Color lightOnSurface = Color(0xFF1A1A1A);
static const Color lightOnSurfaceVariant = Color(0xFF5F5F5F);

static const Color lightOnPrimaryFixed = Color(0xFFFFFFFF);

static const Color lightOutline = Color(0xFF8A8A8A);
static const Color lightOutlineVariant = Color(0xFFD0D0D0);

  static Color backgroundOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? background : lightBackground;

  static Color surfaceOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surface : lightSurface;

  static Color surfaceContainerOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? surfaceContainer
          : lightSurfaceContainer;

  static Color surfaceContainerLowOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? surfaceContainerLow
          : lightSurfaceContainerLow;

  static Color surfaceContainerHighOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? surfaceContainerHigh
          : lightSurfaceContainerHigh;

  static Color surfaceContainerHighestOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? surfaceContainerHighest
          : lightSurfaceContainerHighest;

  static Color onSurfaceOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? onSurface : lightOnSurface;

  static Color onSurfaceVariantOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? onSurfaceVariant
          : lightOnSurfaceVariant;

  static Color outlineOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? outline : lightOutline;

  static Color outlineVariantOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? outlineVariant
          : lightOutlineVariant;

  static Color onPrimaryFixedOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? onPrimaryFixed
          : lightOnPrimaryFixed;

  static Color primaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? primary : lightPrimary;

  static Color primaryFixedOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? primaryFixed
          : lightPrimaryFixed;

  static Color secondaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? secondary : lightSecondary;

  static Color tertiaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? tertiary : lightTertiary;

  static Color successOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? success : lightSuccess;

  static Color errorOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? error : lightError;

  static Color warningOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? warning : lightWarning;

  static LinearGradient primaryGradientOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? primaryGradient
          : const LinearGradient(
              colors: [lightPrimary, lightPrimaryFixed],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            );

  static LinearGradient secondaryGradientOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? secondaryGradient
          : const LinearGradient(
              colors: [lightSecondary, Color(0xFFE5C26A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            );

  static LinearGradient errorGradientOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? errorGradient
          : const LinearGradient(
              colors: [lightError, lightErrorDim],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            );

  static String formatCurrency(double amount, {String currency = 'IDR'}) {
    final String symbol =
        currency == 'USD' ? r'$' : (currency == 'IDR' ? 'Rp' : '$currency ');
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

    return '$symbol$sign${buffer.toString().split('').reversed.join('')}';
  }

  static String formatCurrencyShorthand(
    double amount, {
    bool isExpense = false,
    String currency = 'IDR',
  }) {
    final String symbol =
        currency == 'USD' ? r'$' : (currency == 'IDR' ? 'Rp' : '$currency ');
    final double absAmount = amount.abs();

    if (absAmount >= 1000000) {
      double millions = absAmount / 1000000;
      double rounded;

      if (isExpense) {
        rounded = (millions * 10).ceilToDouble() / 10.0;
      } else {
        rounded = (millions * 10).floorToDouble() / 10.0;
      }

      String valueStr = rounded == rounded.toInt()
          ? rounded.toStringAsFixed(0)
          : rounded.toStringAsFixed(1).replaceAll('.', ',');

      return '$symbol${valueStr}juta';
    } else if (absAmount >= 1000) {
      int rounded =
          isExpense ? (absAmount / 1000).ceil() : (absAmount / 1000).floor();

      return '$symbol${rounded}ribu';
    } else {
      return formatCurrency(absAmount, currency: currency);
    }
  }

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryFixed, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFFD8B35A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, errorDim],
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
        displayLarge:
            GoogleFonts.inter(fontWeight: FontWeight.w800, color: onSurface),
        headlineLarge:
            GoogleFonts.inter(fontWeight: FontWeight.w800, color: onSurface),
        headlineMedium:
            GoogleFonts.inter(fontWeight: FontWeight.w700, color: onSurface),
        titleLarge:
            GoogleFonts.inter(fontWeight: FontWeight.w700, color: onSurface),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        tertiary: lightTertiary,
        error: lightError,
        surface: lightSurface,
        onSurface: lightOnSurface,
        onSurfaceVariant: lightOnSurfaceVariant,
        surfaceContainer: lightSurfaceContainer,
        surfaceContainerLow: lightSurfaceContainerLow,
        surfaceContainerHigh: lightSurfaceContainerHigh,
        surfaceContainerHighest: lightSurfaceContainerHighest,
        outline: lightOutline,
        outlineVariant: lightOutlineVariant,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          bodyLarge: TextStyle(color: lightOnSurface),
          bodyMedium: TextStyle(color: lightOnSurface),
          labelLarge: TextStyle(fontWeight: FontWeight.w700),
        ),
      ).copyWith(
        displayLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w800,
          color: lightOnSurface,
        ),
        headlineLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w800,
          color: lightOnSurface,
        ),
        headlineMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: lightOnSurface,
        ),
        titleLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: lightOnSurface,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}