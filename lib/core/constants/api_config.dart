import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl => dotenv.get('API_BASE_URL', fallback: 'https://fastapi-fintrack-backend-production.up.railway.app/api/v1');
  static String get ocrBaseUrl => dotenv.get('OCR_BASE_URL', fallback: 'http://localhost:8002');
}
