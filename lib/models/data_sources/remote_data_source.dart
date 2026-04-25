import 'dart:convert';
import 'package:http/http.dart' as http;
import '../entities/app_data.dart';
import '../../controllers/auth_controller.dart';

abstract class RemoteDataSource {
  Future<AppData> getDashboardData();
  Future<List<AnalysisData>> getAnalysisData();
  Future<Map<String, String>> getUserProfile();
  Future<Map<String, dynamic>> getSpendingTarget();
  Future<bool> saveSpendingTarget({
    required double amount,
    required String period,
  });
  Future<bool> addTransaction({
    required String title,
    required double amount,
    required String category,
    required String type,
  });
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final AuthController authController;
  // Use 10.0.2.2 for Android Emulator, 127.0.0.1 for iOS Simulator
  final String baseUrl = 'http://127.0.0.1:8000/api/v1';

  RemoteDataSourceImpl({required this.authController});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (authController.token != null)
          'Authorization': 'Bearer ${authController.token}',
      };

  @override
  Future<AppData> getDashboardData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return AppData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load dashboard data');
    }
  }

  @override
  Future<List<AnalysisData>> getAnalysisData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/analytics/summary'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final summary = data['category_breakdown'] as Map<String, dynamic>;
      final colors = ['FF4242', '4285F4', '34A853', 'FBBC05', '9C27B0', '00BCD4'];
      int i = 0;
      return summary.entries.map((e) {
        final color = colors[i % colors.length];
        i++;
        return AnalysisData(
          label: e.key,
          amount: (e.value as num).toDouble(),
          colorHex: color,
        );
      }).toList();
    } else {
      throw Exception('Failed to load analysis data');
    }
  }

  @override
  Future<Map<String, String>> getUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'name': data['full_name'] ?? 'User',
        'handle': '@${data['email'].split('@')[0]}',
        'email': data['email'],
        'avatar': 'https://www.gravatar.com/avatar/${data['id']}?d=identicon',
      };
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  @override
  Future<Map<String, dynamic>> getSpendingTarget() async {
    final response = await http.get(
      Uri.parse('$baseUrl/budgets/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List budgets = jsonDecode(response.body);
      if (budgets.isNotEmpty) {
        return {
          'amount': (budgets[0]['amount'] as num).toDouble(),
          'period': budgets[0]['month'] ?? 'Bulanan',
        };
      }
      return {'amount': 0.0, 'period': 'Bulanan'};
    } else {
      throw Exception('Failed to load spending target');
    }
  }

  @override
  Future<bool> saveSpendingTarget({
    required double amount,
    required String period,
  }) async {
    final now = DateTime.now();
    final monthStr = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    final response = await http.post(
      Uri.parse('$baseUrl/budgets/'),
      headers: _headers,
      body: jsonEncode({
        'category': 'All',
        'amount': amount,
        'month': monthStr,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> addTransaction({
    required String title,
    required double amount,
    required String category,
    required String type,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions/'),
      headers: _headers,
      body: jsonEncode({
        'description': title,
        'amount': amount,
        'category': category,
        'type': type.toLowerCase(),
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
