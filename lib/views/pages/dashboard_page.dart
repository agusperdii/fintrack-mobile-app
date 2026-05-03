import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/controllers/finance_controller.dart';
import 'package:savaio/views/components/organisms/app_balance_card.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/components/organisms/app_weekly_pulse_chart.dart';
import 'package:savaio/views/components/organisms/dashboard_recent_transactions.dart';
import 'package:savaio/views/components/molecules/dashboard_quick_actions.dart';
import 'package:savaio/views/components/molecules/app_section_header.dart';
import 'package:savaio/views/components/molecules/app_greeting_header.dart';
import 'package:savaio/views/pages/notifications_page.dart';
import 'package:savaio/views/pages/all_transactions_page.dart';
import 'package:savaio/views/pages/transaction_detail_page.dart';
import 'package:savaio/views/pages/ocr_scan_page.dart';
import 'package:savaio/views/pages/add_transaction_page.dart';
import 'package:savaio/views/pages/streak_page.dart';
import 'package:savaio/views/components/organisms/nudge_overlay.dart';
import 'package:savaio/views/components/molecules/daily_checkin_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final controller = sl.financeController;
    if (controller.dashboardData == null && !controller.isLoading) {
      controller.loadInitialData();
    }
    _checkAndShowNudge();
  }

  void _checkAndShowNudge() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nudge = sl.financeController.latestUnreadNudge;
      if (nudge != null && mounted) {
        NudgeOverlay.show(context, nudge, () {
          sl.financeController.markNudgeAsRead(nudge.id);
        });
      }
    });
  }

  void _navigateToAddTransaction({required String type, String? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionPage(
          initialType: type,
          initialCategory: category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sl.financeController,
      builder: (context, _) {
        final provider = sl.financeController;
        
        if (provider.isLoading && provider.dashboardData == null) {
          return const Scaffold(
            backgroundColor: SavaioTheme.background,
            body: Center(child: CircularProgressIndicator(color: SavaioTheme.primary)),
          );
        }

        final data = provider.dashboardData;
        final profile = provider.userProfile;
        
        return Scaffold(
          backgroundColor: SavaioTheme.background,
          appBar: _buildAppBar(provider),
          body: RefreshIndicator(
            onRefresh: () => provider.loadInitialData(),
            color: SavaioTheme.primary,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppGreetingHeader(
                    userName: profile?['name']?.split(' ').first ?? 'User',
                  ),
                  const SizedBox(height: 16),
                  if (provider.checkInStatus?.isCheckedInToday == false) ...[
                    const DailyCheckInCard(),
                    const SizedBox(height: 24),
                  ],

                  _buildBalanceCard(data),
                  const SizedBox(height: 32),

                  DashboardQuickActions(
                    onIncomeTap: () => _navigateToAddTransaction(type: 'Income'),
                    onExpenseTap: () => _navigateToAddTransaction(type: 'Expense'),
                    onScanTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OcrScanPage()),
                    ),
                  ),
                  const SizedBox(height: 40),

                  DashboardRecentTransactions(
                    transactions: data?.recentTransactions ?? [],
                    onViewAllTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AllTransactionsPage(
                          initialTransactions: data?.recentTransactions ?? [],
                        ),
                      ),
                    ),
                    onTransactionTap: (tx) => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TransactionDetailPage(transaction: tx)),
                    ),
                    isLoading: data == null,
                  ),

                  const SizedBox(height: 32),

                  _buildWeeklyPulseSection(provider),
                  
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(FinanceController provider) {
    final streakCount = provider.checkInStatus?.streakCount ?? 0;
    final txCount = provider.dashboardData?.recentTransactions.length ?? 0;

    return AppHeader(
      leading: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: SavaioTheme.surfaceContainerHigh.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StreakPage()),
                    );
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
              if (streakCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(color: SavaioTheme.background, width: 2),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      streakCount > 99 ? '99+' : streakCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: SavaioTheme.surfaceContainerHigh.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.receipt_long_rounded, color: SavaioTheme.primary, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AllTransactionsPage(
                          initialTransactions: provider.dashboardData?.recentTransactions ?? [],
                        ),
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
              if (txCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: SavaioTheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: SavaioTheme.background, width: 2),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      txCount > 99 ? '99+' : txCount.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
      onNotificationTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationsPage()),
        );
      },
    );
  }
  Widget _buildBalanceCard(dynamic data) {
    if (data != null) {
      return AppBalanceCard(
        balance: data.balance,
        income: data.totalIncome,
        expense: data.totalExpense,
        onIncomeTap: () => _navigateToAddTransaction(type: 'Income'),
        onExpenseTap: () => _navigateToAddTransaction(type: 'Expense'),
      );
    }
    return const AppBalanceCard(
      balance: 0,
      income: 0,
      expense: 0,
      isLoading: true,
    );
  }

  Widget _buildWeeklyPulseSection(dynamic provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Wawasan Mingguan'),
        const SizedBox(height: 16),
        if (provider.weeklyPulse != null)
          AppWeeklyPulseChart(
            growth: (provider.weeklyPulse!['growth'] as num).toDouble(),
            values: (provider.weeklyPulse!['values'] as List).map((v) => (v as num).toDouble()).toList(),
          )
        else
          const AppWeeklyPulseChart(
            growth: 0,
            values: [0, 0, 0, 0, 0, 0, 0],
          ),
      ],
    );
  }
}
