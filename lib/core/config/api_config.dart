/// Configuration file for API endpoints.
///
/// How to use:
/// 1. Find your computer's local IP address (e.g., 192.168.1.10).
/// 2. Replace 'localhost' with your local IP address if you are testing on a real device.
/// 3. If using an Android Emulator, use '10.0.2.2' instead of 'localhost'.
class ApiConfig {
  // --- CONFIGURATION ---

  // Replace 'localhost' with your computer's IP address (e.g., '192.168.1.10')
  static const String _host = '172.20.10.3';

  // --- ENDPOINTS ---

  /// Base URL for the Fintech Backend API
  static const String baseUrl = 'http://$_host:8000/api/v1';

  /// Base URL for the Receipt OCR Service
  static const String ocrBaseUrl = 'http://$_host:8002';
}
