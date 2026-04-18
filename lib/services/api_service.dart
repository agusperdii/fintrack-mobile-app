import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_data.dart';

class ApiService {
  // Simulate network delay
  static const Duration _delay = Duration(milliseconds: 800);

  /// Fetch main dashboard data (balance, recent transactions)
  static Future<AppData> getDashboardData() async {
    await Future.delayed(_delay);
    // This is where you will later call your real API
    // e.g., final response = await http.get('https://api.com/dashboard');
    return AppData.getDummyData();
  }

  /// Fetch analysis data
  static Future<List<AnalysisData>> getAnalysisData() async {
    await Future.delayed(_delay);
    return AppData.getDummyData().analysis;
  }

  /// Add a new transaction
  static Future<bool> addTransaction({
    required String title,
    required double amount,
    required String category,
    required String type,
  }) async {
    await Future.delayed(_delay);
    // Logic for real API call here
    debugPrint('Transaction Added: $title, $amount, $category, $type');
    return true;
  }

  /// Send message to AI Chat
  static Future<String> getAiChatResponse(String message) async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulated AI Response logic
    if (message.toLowerCase().contains('budget')) {
      return 'Untuk budget, saya sarankan alokasi 50% kebutuhan, 30% keinginan, dan 20% tabungan.';
    } else if (message.toLowerCase().contains('makan')) {
      return 'Pengeluaran makan kamu minggu ini cukup tinggi (Rp 500rb). Coba masak sendiri di rumah!';
    } else {
      return 'Saya adalah asisten keuanganmu. Kamu bisa tanya tentang budget, laporan, atau tips menabung.';
    }
  }

  /// Fetch user profile data
  static Future<Map<String, String>> getUserProfile() async {
    await Future.delayed(_delay);
    return {
      'name': 'Budi Setiawan',
      'email': 'budi.setiawan@example.com',
      'avatar': 'https://i.pravatar.cc/300',
    };
  }
}
