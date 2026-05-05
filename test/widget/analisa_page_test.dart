import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:savaio/views/pages/analysis/analisa_page.dart';
import 'package:savaio/controllers/finance_controller.dart';
import 'package:savaio/others.dart';
import 'package:savaio/models/app_data.dart';
import 'package:provider/provider.dart';

class MockFinanceController extends Mock implements FinanceController {}

/// Shared setup: creates a fully-stubbed MockFinanceController and registers
/// it in the ServiceLocator, then tears it down after each test.
MockFinanceController _buildMockController({
  AppData? dashboardData,
  List<Map<String, dynamic>>? allBudgets,
  double budgetPercentage = 50.0,
  bool isBelowBudget = true,
  bool isLoading = false,
  List<Map<String, dynamic>>? monthlySummary,
}) {
  final mock = MockFinanceController();
  final data = dashboardData ??
      AppData(
        initialBalance: 1000000,
        totalIncome: 5000000,
        totalExpense: 1500000,
        recentTransactions: [],
        analysis: [
          AnalysisData(label: 'Food', amount: 300000, colorHex: 'FF4242'),
          AnalysisData(label: 'Transport', amount: 150000, colorHex: '4285F4'),
        ],
      );

  when(() => mock.dashboardData).thenReturn(data);
  when(() => mock.analysisBudgetPercentage).thenReturn(budgetPercentage);
  when(() => mock.isBelowAnalysisBudget).thenReturn(isBelowBudget);
  when(() => mock.analysisHeroDailyValues)
      .thenReturn([10000, 20000, 30000, 40000, 50000, 60000, 70000]);
  when(() => mock.analysisTrendSpots).thenReturn([
    const FlSpot(0, 10000),
    const FlSpot(1, 20000),
    const FlSpot(2, 30000),
    const FlSpot(3, 40000),
    const FlSpot(4, 50000),
    const FlSpot(5, 60000),
    const FlSpot(6, 70000),
  ]);
  when(() => mock.allBudgets).thenReturn(allBudgets ?? [
    {'category': 'Food', 'amount': 500000.0},
  ]);
  when(() => mock.spendingTarget).thenReturn({'amount': 3000000.0});
  when(() => mock.isLoading).thenReturn(isLoading);
  when(() => mock.monthlySummary).thenReturn(monthlySummary ?? [
    {'month': '2026-05', 'income': 5000000.0, 'expense': 1500000.0, 'count': 10},
    {'month': '2026-04', 'income': 4000000.0, 'expense': 2000000.0, 'count': 8},
  ]);
  when(() => mock.nudges).thenReturn([]);
  when(() => mock.notifications).thenReturn([]);

  // addListener / removeListener must be stubbed for ChangeNotifier contracts
  when(() => mock.addListener(any())).thenReturn(null);
  when(() => mock.removeListener(any())).thenReturn(null);

  return mock;
}

void main() {
  late MockFinanceController mockController;

  setUp(() {
    mockController = _buildMockController();
    sl.financeController = mockController;
  });

  tearDown(() {
    sl.reset();
  });

  // ─── Helper ──────────────────────────────────────────────────────────

  Future<void> pumpPage(WidgetTester tester, {MockFinanceController? ctrl}) async {
    final c = ctrl ?? mockController;
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<FinanceController>.value(
          value: c,
          child: const AnalisaPage(),
        ),
      ),
    );
    await tester.pump(); // resolve post-frame callbacks
    await tester.pump(const Duration(milliseconds: 100));
  }

  // ─── Tests ───────────────────────────────────────────────────────────

  testWidgets('shows correct app bar title', (tester) async {
    await pumpPage(tester);
    expect(find.text('Analisa Pengeluaran'), findsOneWidget);
  });

  testWidgets('displays budget percentage in hero card', (tester) async {
    await pumpPage(tester);
    expect(find.textContaining('50%'), findsAtLeastNWidgets(1));
  });

  testWidgets('shows AMAN badge when below budget', (tester) async {
    await pumpPage(tester);
    expect(find.textContaining('AMAN'), findsAtLeastNWidgets(1));
  });

  testWidgets('shows category breakdown header', (tester) async {
    await pumpPage(tester);
    expect(find.text('Breakdown Kategori'), findsOneWidget);
  });

  testWidgets('renders Food and Transport category cards', (tester) async {
    await pumpPage(tester);
    expect(find.text('Food'), findsAtLeastNWidgets(1));
    expect(find.text('Transport'), findsAtLeastNWidgets(1));
  });

  testWidgets('displays formatted category amounts', (tester) async {
    await pumpPage(tester);
    expect(find.textContaining('Rp300'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Rp150'), findsAtLeastNWidgets(1));
  });

  testWidgets('shows month filter chips (Mei)', (tester) async {
    await pumpPage(tester);
    expect(find.textContaining('Mei'), findsAtLeastNWidgets(1));
  });

  testWidgets('shows loading state when isLoading=true and data=null', (tester) async {
    final ctrl = _buildMockController(isLoading: true);
    when(() => ctrl.dashboardData).thenReturn(null);
    // Must set BEFORE pumpPage so initState picks up the right controller
    sl.financeController = ctrl;

    await pumpPage(tester, ctrl: ctrl);
    expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    expect(find.text('Memuat data analisa...'), findsOneWidget);
  });

  testWidgets('shows empty category state when analysis is empty', (tester) async {
    final ctrl = _buildMockController(
      dashboardData: AppData(
        initialBalance: 0, totalIncome: 0, totalExpense: 0,
        recentTransactions: [], analysis: [],
      ),
    );
    // Must be set BEFORE pumpPage
    sl.financeController = ctrl;
    await pumpPage(tester, ctrl: ctrl);
    expect(find.textContaining('Tidak ada data pengeluaran'), findsAtLeastNWidgets(1));
  });

  testWidgets('shows Smart Insight card with top category', (tester) async {
    await pumpPage(tester);
    expect(find.text('Wawasan Pintar'), findsOneWidget);
    expect(find.textContaining('Food'), findsAtLeastNWidgets(1));
  });

  testWidgets('renders Tren Ledger chart section', (tester) async {
    await pumpPage(tester);
    expect(find.text('Tren Ledger'), findsOneWidget);
  });

  testWidgets('shows AMAN when Food budget=500k and spent=300k (60%)', (tester) async {
    await pumpPage(tester);
    expect(find.text('AMAN'), findsAtLeastNWidgets(1));
  });

  testWidgets('shows OVER when spending exceeds budget', (tester) async {
    // Override allBudgets on the SAME controller that setUp registered.
    // AnalisaPage.initState() already subscribed to mockController, so
    // a brand-new controller would not be observed by the page.
    when(() => mockController.allBudgets)
        .thenReturn([{'category': 'Food', 'amount': 100000.0}]); // 300k > 100k → OVER

    await pumpPage(tester); // uses the setUp mockController via sl
    // Food: 300k spent / 100k budget = 300% → OVER
    expect(find.text('OVER'), findsAtLeastNWidgets(1));
  });

  testWidgets('does NOT trigger any network calls on initial render', (tester) async {
    // No async methods should be called during a normal page open
    await pumpPage(tester);
    // If any Supabase call was made on build(), this would fail or cause exceptions
    verifyNever(() => mockController.fetchAllData());
  });
}
