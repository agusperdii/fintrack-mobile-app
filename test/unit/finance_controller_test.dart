import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:savaio/controllers/finance_controller.dart';
import 'package:savaio/models/finance_repository.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/models/nudge_data.dart';
import 'package:savaio/models/notification_data.dart';
import 'package:savaio/models/checkin_data.dart';

class MockFinanceRepository extends Mock implements FinanceRepository {}

/// Helper to set up all required stubs for fetchAllData()
void _setupFullMocks(MockFinanceRepository repo, {
  AppData? dashboardData,
  Map<String, dynamic>? spendingTarget,
  Map<String, dynamic>? weeklyPulse,
}) {
  final mockData = dashboardData ?? AppData(
    initialBalance: 0,
    totalIncome: 1000,
    totalExpense: 400,
    recentTransactions: [],
    analysis: [],
  );
  
  when(() => repo.getDashboardData(forceRefresh: any(named: 'forceRefresh')))
      .thenAnswer((_) async => mockData);
  when(() => repo.getSpendingTarget(forceRefresh: any(named: 'forceRefresh')))
      .thenAnswer((_) async => spendingTarget ?? {'amount': 1000.0});
  when(() => repo.getUserProfile(forceRefresh: any(named: 'forceRefresh')))
      .thenAnswer((_) async => {'name': 'Test User'});
  when(() => repo.getAllBudgets()).thenAnswer((_) async => []);
  when(() => repo.getWeeklyPulse(forceRefresh: any(named: 'forceRefresh')))
      .thenAnswer((_) async => weeklyPulse ?? {'values': [0, 0, 0, 0, 0, 0, 0]});
  when(() => repo.getNudges(forceRefresh: any(named: 'forceRefresh')))
      .thenAnswer((_) async => []);
  when(() => repo.getCategories(forceRefresh: any(named: 'forceRefresh')))
      .thenAnswer((_) async => []);
  when(() => repo.getNotifications(forceRefresh: any(named: 'forceRefresh')))
      .thenAnswer((_) async => []);
  when(() => repo.getCheckInStatus(forceRefresh: any(named: 'forceRefresh')))
      .thenAnswer((_) async => CheckInStatus(isCheckedInToday: false, streakCount: 0));
  when(() => repo.getMonthlySummary(forceRefresh: any(named: 'forceRefresh')))
      .thenAnswer((_) async => []);
}

void main() {
  late FinanceController controller;
  late MockFinanceRepository mockRepository;

  setUp(() {
    mockRepository = MockFinanceRepository();
    controller = FinanceController(mockRepository);
  });

  group('FinanceController Analysis Logic Tests', () {
    test('analysisBudgetPercentage returns 0.0 before data is loaded', () {
      // Before fetchAllData(), dashboardData and spendingTarget are null
      expect(controller.analysisBudgetPercentage, 0.0);
    });

    test('analysisBudgetPercentage calculates correctly after fetchAllData', () async {
      _setupFullMocks(
        mockRepository,
        dashboardData: AppData(
          initialBalance: 0,
          totalIncome: 1000,
          totalExpense: 400,
          recentTransactions: [],
          analysis: [],
        ),
        spendingTarget: {'amount': 1000.0},
      );

      await controller.fetchAllData();

      // 400 / 1000 * 100 = 40%
      expect(controller.analysisBudgetPercentage, closeTo(40.0, 0.01));
    });

    test('isBelowAnalysisBudget is true when expense < target', () async {
      _setupFullMocks(
        mockRepository,
        dashboardData: AppData(
          initialBalance: 0, totalIncome: 1000, totalExpense: 400,
          recentTransactions: [], analysis: [],
        ),
        spendingTarget: {'amount': 1000.0},
      );

      await controller.fetchAllData();
      expect(controller.isBelowAnalysisBudget, true);
    });

    test('isBelowAnalysisBudget is false when expense > target', () async {
      _setupFullMocks(
        mockRepository,
        dashboardData: AppData(
          initialBalance: 0, totalIncome: 3000, totalExpense: 1500,
          recentTransactions: [], analysis: [],
        ),
        spendingTarget: {'amount': 1000.0},
      );

      await controller.fetchAllData();
      expect(controller.isBelowAnalysisBudget, false);
    });

    test('analysisHeroDailyValues returns correct values from weekly pulse', () async {
      final pulse = {'values': [100.0, 200.0, 0.0, 500.0, 100.0, 0.0, 0.0]};
      _setupFullMocks(mockRepository, weeklyPulse: pulse);

      await controller.fetchAllData();
      
      final values = controller.analysisHeroDailyValues;
      expect(values.length, 7);
      expect(values[0], 100.0);
      expect(values[1], 200.0);
      expect(values[3], 500.0);
    });

    test('analysisHeroDailyValues returns defaults when no pulse data', () {
      // Before fetchAllData() – weeklyPulse is null
      expect(controller.analysisHeroDailyValues, [0, 0, 0, 0, 0, 0, 0]);
    });

    test('analysisTrendSpots maps daily values to FlSpots', () async {
      final pulse = {'values': [100.0, 200.0, 300.0, 400.0, 500.0, 600.0, 700.0]};
      _setupFullMocks(mockRepository, weeklyPulse: pulse);

      await controller.fetchAllData();

      final spots = controller.analysisTrendSpots;
      expect(spots.length, 7);
      expect(spots[0], const FlSpot(0, 100.0));
      expect(spots[6], const FlSpot(6, 700.0));
    });

    test('analysisTrendSpots returns empty list when no pulse data', () {
      expect(controller.analysisTrendSpots, isEmpty);
    });

    test('getSpentAmountFor calculates correctly from transactions', () {
      controller.setTransactions([
        Transaction(
          id: '1', title: 'Makan', amount: 50000,
          category: 'Food', date: '2026-05-01', type: TransactionType.expense,
        ),
        Transaction(
          id: '2', title: 'Kopi', amount: 30000,
          category: 'Food', date: '2026-05-10', type: TransactionType.expense,
        ),
        Transaction(
          id: '3', title: 'Gaji', amount: 5000000,
          category: 'Salary', date: '2026-05-01', type: TransactionType.income,
        ),
      ]);

      // Only expenses for 'Food' in 2026-05
      final spent = controller.getSpentAmountFor('Food', '2026-05');
      expect(spent, 80000.0);
    });

    test('getSpentAmountFor excludes income transactions', () {
      controller.setTransactions([
        Transaction(
          id: '1', title: 'Gaji', amount: 5000000,
          category: 'Salary', date: '2026-05-01', type: TransactionType.income,
        ),
      ]);

      final spent = controller.getSpentAmountFor('Salary', '2026-05');
      expect(spent, 0.0); // Income should not count as spending
    });

    test('getSpentAmountFor returns 0 when no transactions', () {
      // No transactions set
      final spent = controller.getSpentAmountFor('Food', '2026-05');
      expect(spent, 0.0);
    });

    test('isLoading is false by default', () {
      expect(controller.isLoading, false);
    });

    test('nudges list is empty by default', () {
      expect(controller.nudges, isEmpty);
    });

    test('notifications list is empty by default', () {
      expect(controller.notifications, isEmpty);
    });

    test('unreadNotificationsCount returns 0 when no notifications', () {
      expect(controller.unreadNotificationsCount, 0);
    });

    test('categories falls back to defaults when no fetched categories', () {
      // No fetchAllData() called yet, categories should use defaults
      expect(controller.categories, isNotEmpty);
    });
  });

  group('FinanceController Nudge Logic Tests', () {
    test('latestUnreadNudge returns null when nudges are empty', () {
      expect(controller.latestUnreadNudge, isNull);
    });

    test('fetchAllData injects mock nudge into nudges list', () async {
      _setupFullMocks(mockRepository);
      await controller.fetchAllData();

      // The injected mock nudge should be in the list
      expect(controller.nudges, isNotEmpty);
      final mockNudge = controller.nudges.firstWhere(
        (n) => n.id == '00000000-0000-0000-0000-000000000000',
        orElse: () => throw Exception('Mock nudge not found'),
      );
      expect(mockNudge.type, NudgeType.positive);
      expect(mockNudge.isRead, false);
    });
  });
}
