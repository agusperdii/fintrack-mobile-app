import 'dart:convert';
import 'package:http/http.dart' as http;
import '../entities/app_data.dart';
import '../../controllers/auth_controller.dart';
import '../../core/utils/parser_utils.dart';
import '../../core/config/api_config.dart';

abstract class RemoteDataSource {
  Future<AppData> getDashboardData();
  Future<List<AnalysisData>> getAnalysisData();
  Future<Map<String, String>> getUserProfile();
  Future<Map<String, dynamic>> getSpendingTarget();
  Future<bool> saveSpendingTarget({required double amount, required String period});
  Future<bool> addTransaction({required String title, required double amount, required String category, required String type});
  Future<List<Transaction>> getTransactions({String? month});
  Future<bool> deleteTransaction(String id);
  Future<bool> updateProfile({required String fullName});
  Future<List<Map<String, dynamic>>> getMonthlySummary();
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final AuthController authController;
  final String baseUrl = ApiConfig.baseUrl;

  /// Global timeout for all HTTP requests.
  /// If the server does not respond within this time, a TimeoutException is thrown.
  static const _timeout = Duration(seconds: 10);

  RemoteDataSourceImpl({required this.authController});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (authController.token != null)
          'Authorization': 'Bearer ${authController.token}',
      };

  Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode == 401 || response.statusCode == 403) {
      // Token invalid or expired, logout user
      authController.logout();
    }
    return response;
  }

  // --- Private HTTP helpers with timeout ---

  Future<http.Response> _get(String url) async {
    final response = await http.get(Uri.parse(url), headers: _headers).timeout(_timeout);
    return _handleResponse(response);
  }

  Future<http.Response> _getUri(Uri uri) async {
    final response = await http.get(uri, headers: _headers).timeout(_timeout);
    return _handleResponse(response);
  }

  Future<http.Response> _post(String url, Map<String, dynamic> body) async {
    final response = await http.post(Uri.parse(url), headers: _headers, body: jsonEncode(body)).timeout(_timeout);
    return _handleResponse(response);
  }

  Future<http.Response> _patch(String url, Map<String, dynamic> body) async {
    final response = await http.patch(Uri.parse(url), headers: _headers, body: jsonEncode(body)).timeout(_timeout);
    return _handleResponse(response);
  }

  Future<http.Response> _delete(String url) async {
    final response = await http.delete(Uri.parse(url), headers: _headers).timeout(_timeout);
    return _handleResponse(response);
  }

  // --- Implementations ---

  @override
  Future<AppData> getDashboardData() async {
    final response = await _get('$baseUrl/dashboard/');
    if (response.statusCode == 200) {
      return AppData.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load dashboard data: ${response.statusCode}');
  }

  @override
  Future<List<AnalysisData>> getAnalysisData() async {
    final response = await _get('$baseUrl/analytics/summary');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final summary = data['category_breakdown'] as Map<String, dynamic>;
      final colors = ['FF4242', '4285F4', '34A853', 'FBBC05', '9C27B0', '00BCD4'];
      int i = 0;
      return summary.entries.map((e) {
        final color = colors[i % colors.length];
        i++;
        return AnalysisData(label: e.key, amount: ParserUtils.toDouble(e.value), colorHex: color);
      }).toList();
    }
    throw Exception('Failed to load analysis data');
  }

  @override
  Future<Map<String, String>> getUserProfile() async {
    final response = await _get('$baseUrl/auth/me');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final email = data['email'] as String;
      return {
        'name': data['full_name'] ?? email.split('@')[0],
        'handle': '@${email.split('@')[0]}',
        'email': email,
        'avatar': 'https://www.gravatar.com/avatar/${data['id']}?d=identicon&s=200',
      };
    }
    throw Exception('Failed to load user profile');
  }

  @override
  Future<Map<String, dynamic>> getSpendingTarget() async {
    final response = await _get('$baseUrl/budgets/');
    if (response.statusCode == 200) {
      final List budgets = jsonDecode(response.body);
      if (budgets.isNotEmpty) {
        return {'amount': ParserUtils.toDouble(budgets[0]['amount']), 'period': budgets[0]['month'] ?? 'Bulanan'};
      }
      return {'amount': 0.0, 'period': 'Bulanan'};
    }
    throw Exception('Failed to load spending target');
  }

  @override
  Future<bool> saveSpendingTarget({required double amount, required String period}) async {
    final now = DateTime.now();
    final monthStr = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    final response = await _post('$baseUrl/budgets/', {'category': 'All', 'amount': amount, 'month': monthStr});
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> addTransaction({required String title, required double amount, required String category, required String type}) async {
    final response = await _post(
      '$baseUrl/transactions/',
      {'description': title, 'amount': amount, 'category': category, 'type': type.toLowerCase()},
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<List<Transaction>> getTransactions({String? month}) async {
    final uri = Uri.parse('$baseUrl/transactions/').replace(
      queryParameters: {
        'limit': '200',
        'month': month,
      },
    );
    final response = await _getUri(uri);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((t) => Transaction.fromJson(t)).toList();
    }
    throw Exception('Failed to load transactions');
  }

  @override
  Future<bool> deleteTransaction(String id) async {
    final response = await _delete('$baseUrl/transactions/$id');
    return response.statusCode == 200;
  }

  @override
  Future<bool> updateProfile({required String fullName}) async {
    final response = await _patch('$baseUrl/auth/me', {'full_name': fullName});
    return response.statusCode == 200;
  }

  @override
  Future<List<Map<String, dynamic>>> getMonthlySummary() async {
    final response = await _get('$baseUrl/dashboard/monthly-summary');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['months']);
    }
    throw Exception('Failed to load monthly summary');
  }
}
