import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    String url = dotenv.get('API_BASE_URL', fallback: 'https://backend-v1-beta.vercel.app');
    
    // Auto-fix for Android Emulator
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android && url.contains('localhost')) {
      return url.replaceFirst('localhost', '10.0.2.2');
    }
    return url;
  }
  
  static String get ocrBaseUrl => dotenv.get('OCR_BASE_URL', fallback: baseUrl);
}
