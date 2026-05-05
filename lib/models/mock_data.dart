import 'package:savaio/models/app_data.dart';
import 'package:savaio/models/nudge_data.dart';
import 'package:savaio/models/notification_data.dart';
import 'package:savaio/models/checkin_data.dart';

class MockData {
  static final Map<String, String> userProfile = {
    'id': 'user-123',
    'name': 'Budi Santoso',
    'handle': '@budisan',
    'email': 'budi.santoso@email.com',
    'avatar': 'https://i.pravatar.cc/150?u=user-123',
  };

  static final List<Transaction> transactions = [
    Transaction(
      id: 'tx-1',
      title: 'Gaji Bulanan',
      amount: 7500000.0,
      category: 'Salary',
      type: TransactionType.income,
      date: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    ),
    Transaction(
      id: 'tx-2',
      title: 'Makan Siang Padang',
      amount: 35000.0,
      category: 'Food',
      type: TransactionType.expense,
      date: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    ),
    Transaction(
      id: 'tx-3',
      title: 'Kopi Susu Gula Aren',
      amount: 22000.0,
      category: 'Coffee',
      type: TransactionType.expense,
      date: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    ),
    Transaction(
      id: 'tx-4',
      title: 'Uang Saku',
      amount: 500000.0,
      category: 'Uang Saku',
      type: TransactionType.income,
      date: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
    ),
    Transaction(
      id: 'tx-5',
      title: 'Belanja Mingguan',
      amount: 450000.0,
      category: 'Food',
      type: TransactionType.expense,
      date: DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
    ),
  ];

  static final Map<String, dynamic> weeklyPulse = {
    'growth': 15.2,
    'values': [450000.0, 320000.0, 580000.0, 210000.0, 670000.0, 150000.0, 300000.0],
  };

  static final Map<String, dynamic> analysisSnapshot = {
    'total_expense': 4200000.0,
    'target_amount': 5000000.0,
    'average_daily_expense': 140000.0,
    'category_breakdown': [
      {'label': 'Food', 'amount': 1500000.0, 'budget_limit': 1800000.0, 'color': 'FF4242'},
      {'label': 'Coffee', 'amount': 450000.0, 'budget_limit': 500000.0, 'color': '4285F4'},
      {'label': 'Transport', 'amount': 300000.0, 'budget_limit': 400000.0, 'color': '34A853'},
      {'label': 'Fun', 'amount': 800000.0, 'budget_limit': 1000000.0, 'color': 'FBBC05'},
      {'label': 'Kost/Sewa', 'amount': 1150000.0, 'budget_limit': 1150000.0, 'color': '9C27B0'},
    ],
    'daily_trend': [120000.0, 150000.0, 90000.0, 200000.0, 110000.0, 300000.0, 180000.0],
  };

  static final Map<String, dynamic> spendingTarget = {
    'amount': 3000000.0,
    'period': 'Monthly',
    'category': 'All',
  };

  static final List<Map<String, dynamic>> categories = [
    {'id': '1', 'name': 'Food', 'icon': '🍔', 'is_system': true},
    {'id': '2', 'name': 'Salary', 'icon': '💰', 'is_system': true},
    {'id': '3', 'name': 'Coffee', 'icon': '☕', 'is_system': true},
    {'id': '4', 'name': 'Transport', 'icon': '🚌', 'is_system': true},
    {'id': '5', 'name': 'Investment', 'icon': '📈', 'is_system': true},
    {'id': '6', 'name': 'Education', 'icon': '📚', 'is_system': true},
    {'id': '7', 'name': 'Gift', 'icon': '🎁', 'is_system': true},
    {'id': '8', 'name': 'Fun', 'icon': '🎮', 'is_system': true},
    {'id': '9', 'name': 'Uang Saku', 'icon': '💸', 'is_system': true},
    {'id': '10', 'name': 'Kost/Sewa', 'icon': '🏠', 'is_system': true},
  ];

  static final List<NudgeData> nudges = [
    NudgeData(
      id: 'nudge-1',
      type: NudgeType.positive,
      message: 'Kamu hemat 15% minggu ini dibanding minggu lalu! Mantap!',
      isRead: false,
      createdAt: DateTime.now(),
    ),
  ];

  static final List<NotificationData> notifications = [
    NotificationData(
      id: 'notif-1',
      title: 'Check-in Berhasil',
      message: 'Selamat! Kamu sudah check-in hari ini.',
      type: NotificationType.success,
      isRead: false,
      createdAt: DateTime.now(),
    ),
  ];

  static final CheckInStatus checkInStatus = CheckInStatus(
    streakCount: 7,
    lastCheckinDate: DateTime.now().subtract(const Duration(days: 1)),
    isCheckedInToday: false,
  );
}
