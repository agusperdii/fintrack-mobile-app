// api_config.dart
// Menyediakan konfigurasi URL dasar untuk API backend dan OCR, termasuk
// penyesuaian otomatis saat berjalan di Android Emulator.

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    String url = dotenv.get('API_BASE_URL', fallback: 'https://api-savaio.fly.dev');

    // Perbaikan otomatis untuk Android Emulator: localhost tidak bisa diakses
    // langsung dari emulator, harus diarahkan ke alamat host 10.0.2.2.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android && url.contains('localhost')) {
      return url.replaceFirst('localhost', '10.0.2.2');
    }
    return url;
  }
  
  static String get ocrBaseUrl => dotenv.get('OCR_BASE_URL', fallback: baseUrl);
}
