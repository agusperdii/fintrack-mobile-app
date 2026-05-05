import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:savaio/models/remote_data_source.dart';
import 'package:savaio/models/finance_repository.dart';
import 'package:savaio/controllers/finance_controller.dart';
import 'package:savaio/controllers/auth_controller.dart';
import 'package:savaio/controllers/ocr_controller.dart';
import 'package:savaio/models/ocr_data_source.dart';
import 'package:savaio/models/ocr_repository.dart';

// --- API CONFIGURATION ---
class ApiConfig {
  static String get _host => dotenv.get('OCR_HOST', fallback: 'localhost');
  static String get supabaseUrl => dotenv.get('SUPABASE_URL', fallback: '');
  static String get supabaseAnonKey => dotenv.get('SUPABASE_ANON_KEY', fallback: '');
  static String get ocrBaseUrl => 'http://$_host:8002';
}

// --- THEME ---
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
  static const double radiusFull = 9999.0;

  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Curve curveDefault = Curves.easeInOutCubic;

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
  static const Color success = Color(0xFFAAFFDC);
  static const Color error = Color(0xFFFF716C);
  static const Color errorDim = Color(0xFFD7383B);
  static const Color errorContainer = Color(0xFF9F0519);
  
  static const Color onSurface = Color(0xFFF6F6FC);
  static const Color onSurfaceVariant = Color(0xFFAAABB0);
  static const Color onPrimaryFixed = Color(0xFF003840);
  static const Color outline = Color(0xFF74757A);
  static const Color outlineVariant = Color(0xFF46484D);

  static String formatCurrency(double amount) {
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
    return 'Rp$sign${buffer.toString().split('').reversed.join('')}';
  }

  static String formatCurrencyShorthand(double amount, {bool isExpense = false}) {
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
      return 'Rp${valueStr}juta';
    } else if (absAmount >= 1000) {
      int rounded = isExpense ? (absAmount / 1000).ceil() : (absAmount / 1000).floor();
      return 'Rp${rounded}ribu';
    } else {
      return formatCurrency(absAmount);
    }
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
        displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w800, color: onSurface),
        headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w800, color: onSurface),
        headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, color: onSurface),
        titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, color: onSurface),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}

// --- UTILS ---
class ParserUtils {
  static double toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int paramInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static List<T> toList<T>(dynamic value, T Function(dynamic) mapper) {
    if (value == null || value is! List) return [];
    return value.map((item) => mapper(item)).toList();
  }
}

// --- SERVICE LOCATOR ---
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  RemoteDataSource? _remoteDataSource;
  FinanceRepository? _financeRepository;
  FinanceController? _financeController;
  AuthController? _authController;
  OcrController? _ocrController;
  OcrRepository? _ocrRepository;
  OcrDataSource? _ocrDataSource;

  RemoteDataSource get remoteDataSource => _remoteDataSource!;
  FinanceRepository get financeRepository => _financeRepository!;
  FinanceController get financeController => _financeController!;
  AuthController get authController => _authController!;
  OcrController get ocrController => _ocrController!;
  OcrRepository get ocrRepository => _ocrRepository!;
  OcrDataSource get ocrDataSource => _ocrDataSource!;

  set financeController(FinanceController value) => _financeController = value;

  void setup() {
    _authController = AuthController();
    _remoteDataSource = RemoteDataSourceImpl();
    _financeRepository = FinanceRepository(remoteDataSource: remoteDataSource);
    _financeController = FinanceController(financeRepository);
    _ocrDataSource = OcrDataSource();
    _ocrRepository = OcrRepository(_ocrDataSource!);
    _ocrController = OcrController(_ocrRepository!);
  }

  void reset() {
    _authController = null;
    _remoteDataSource = null;
    _financeRepository = null;
    _financeController = null;
    _ocrDataSource = null;
    _ocrRepository = null;
    _ocrController = null;
  }
}

final sl = ServiceLocator();
