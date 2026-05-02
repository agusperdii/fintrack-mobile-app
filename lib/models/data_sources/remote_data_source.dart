import 'dart:convert';
import 'package:http/http.dart' as http;
import '../entities/app_data.dart';
import '../../controllers/auth_controller.dart';
import '../../core/utils/parser_utils.dart';
import '../../core/config/api_config.dart';

import '../entities/nudge_data.dart';

abstract class RemoteDataSource {
  Future<AppData> getDashboardData();
  Future<List<AnalysisData>> getAnalysisData();
  Future<Map<String, String>> getUserProfile();
  Future<Map<String, dynamic>> getSpendingTarget();
  Future<List<Map<String, dynamic>>> getAllBudgets();
  Future<Map<String, dynamic>> getWeeklyPulse();
  Future<List<NudgeData>> getNudges();
  Future<bool> markNudgeRead(String id);
  Future<bool> saveSpendingTarget({required double amount, required String period, String category = 'All', String? month});
  Future<bool> addTransaction({
    required String title,
    String? description,
    required double amount,
    required String category,
    required String type,
    DateTime? date,
  });
  Future<List<Transaction>> getTransactions({String? month});
  Future<bool> deleteTransaction(String id);
  Future<bool> updateProfile({required String fullName, String? username});
  Future<bool> updatePassword({required String currentPassword, required String newPassword});
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
    if (response.statusCode == 401 || response.statusCode == 403 || response.statusCode == 404) {
      // Token invalid, expired, or user deleted (404), logout user
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

  Future<http.Response> _put(String url, Map<String, dynamic> body) async {
    final response = await http.put(Uri.parse(url), headers: _headers, body: jsonEncode(body)).timeout(_timeout);
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
      final username = data['username'] as String?;
      return {
        'name': data['full_name'] ?? email.split('@')[0],
        'handle': username != null ? '@$username' : '@${email.split('@')[0]}',
        'username': username ?? '',
        'email': email,
        'avatar': 'https://www.gravatar.com/avatar/${data['id']}?d=identicon&s=200',
      };
    }
    throw Exception('Failed to load user profile');
  }

  @override
  Future<Map<String, dynamic>> getSpendingTarget() async {
    final budgets = await getAllBudgets();
    if (budgets.isNotEmpty) {
      // Return the 'All' or 'Total' budget if exists, otherwise first one
      final totalBudget = budgets.firstWhere((b) => b['category'] == 'All' || b['category'] == 'Total', orElse: () => budgets[0]);
      return totalBudget;
    }
    return {'amount': 0.0, 'period': 'Bulanan', 'category': 'All'};
  }

  @override
  Future<List<Map<String, dynamic>>> getAllBudgets() async {
    final response = await _get('$baseUrl/budgets/');
    if (response.statusCode == 200) {
      final List budgets = jsonDecode(response.body);
      return budgets.map((b) => {
        'id': b['id'],
        'amount': ParserUtils.toDouble(b['amount']),
        'period': b['month'] ?? 'Bulanan',
        'category': b['category'] ?? 'All'
      }).toList();
    }
    throw Exception('Failed to load budgets');
  }

  @override
  Future<bool> saveSpendingTarget({required double amount, required String period, String category = 'All', String? month}) async {
    String monthStr = month ?? "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}";
    final response = await _post('$baseUrl/budgets/', {'category': category, 'amount': amount, 'month': monthStr});
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> addTransaction({
    required String title,
    String? description,
    required double amount,
    required String category,
    required String type,
    DateTime? date,
  }) async {
    final response = await _post(
      '$baseUrl/transactions/',
      {
        'title': title,
        'description': description,
        'amount': amount,
        'category': category,
        'type': type.toLowerCase(),
        if (date != null) 'date': date.toIso8601String(),
      },
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
  Future<bool> updateProfile({required String fullName, String? username}) async {
    final response = await _patch('$baseUrl/auth/me', {
      'full_name': fullName,
      'username': username,
    });
    return response.statusCode == 200;
  }

  @override
  Future<bool> updatePassword({required String currentPassword, required String newPassword}) async {
    final response = await _post('$baseUrl/auth/me/change-password', {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
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

  @override
  Future<List<NudgeData>> getNudges() async {
    final response = await _get('$baseUrl/nudges/');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((n) => NudgeData.fromJson(n)).toList();
    }
    throw Exception('Failed to load nudges');
  }

  @override
  Future<bool> markNudgeRead(String id) async {
    final response = await _put('$baseUrl/nudges/$id/read', {});
    return response.statusCode == 200;
  }

  @override
  Future<Map<String, dynamic>> getWeeklyPulse() async {
    final response = await _get('$baseUrl/analytics/weekly-pulse');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load weekly pulse data');
  }
}
