import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/controllers/dashboard_controller.dart';
import 'package:savaio/controllers/profile_controller.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/models/notification_data.dart';
import 'package:savaio/views/components/organisms/app_balance_card.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/components/organisms/app_weekly_pulse_chart.dart';
import 'package:savaio/views/components/organisms/dashboard_recent_transactions.dart';
import 'package:savaio/views/components/molecules/dashboard_quick_actions.dart';
import 'package:savaio/views/components/molecules/app_greeting_header.dart';
import 'package:savaio/views/pages/notifications_page.dart';
import 'package:savaio/views/pages/all_transactions_page.dart';
import 'package:savaio/views/pages/transaction_detail_page.dart';
import 'package:savaio/views/pages/ocr_scan_page.dart';
import 'package:savaio/views/pages/add_transaction_page.dart';
import 'package:savaio/views/pages/streak_page.dart';
import 'package:savaio/views/pages/spending_target_page.dart';
import 'package:savaio/views/components/organisms/notifications/notification_popup_organism.dart';
import 'package:savaio/views/components/molecules/daily_checkin_card.dart';
import 'package:savaio/views/components/molecules/app_section_header.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _checkAndShowNudge();
  }

  void _checkAndShowNudge() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notification = sl.notificationController.latestUnreadPopup;
      if (notification != null && mounted) {
        final isBudgetNotif = notification.type == NotificationType.budgetReached || 
                             notification.type == NotificationType.budgetExceeded;
        
        NotificationPopupOrganism.show(
          context, 
          notification, 
          onRead: () => sl.notificationController.markAsRead(notification.id),
          actionLabel: isBudgetNotif ? 'LIHAT BUDGET' : null,
          onAction: isBudgetNotif ? () {
            sl.notificationController.markAsRead(notification.id);
            final categoryId = notification.metadata?['category_id']?.toString();
            final month = notification.metadata?['month']?.toString();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SpendingTargetPage(
                  initialCategoryId: categoryId,
                  initialMonth: month,
                ),
              ),
            );
          } : null,
        );
      }
    });
  }

  void _navigateToAddTransaction({required String type, String? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddTransactionPage(initialType: type, initialCategory: category),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      sl.dashboardController.fetchDashboardData(),
      sl.profileController.fetchProfile(),
      sl.analyticsController.fetchAll(),
      sl.notificationController.fetchAll(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Optimization: Watch only specific parts of the state to avoid full rebuilds
    final isLoading = context.select<DashboardController, bool>((c) => c.isLoading);
    final hasData = context.select<DashboardController, bool>((c) => c.data != null);
    final userProfile = context.watch<ProfileController>().userProfile;
    final checkInStatus = context.select<DashboardController, dynamic>((c) => c.checkInStatus);

    if (isLoading && !hasData) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: SavaioTheme.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: SavaioTheme.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppGreetingHeader(
                userName: userProfile?.fullName.split(' ').first ?? 'User',
              ),
              const SizedBox(height: 16),
              if (checkInStatus?.isCheckedInToday == false) ...[
                const DailyCheckInCard(),
                const SizedBox(height: 24),
              ],

              // Optimized Balance Card
              const _DashboardBalanceSection(),
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

              // Optimized Recent Transactions
              const _DashboardRecentTransactionsSection(),

              const SizedBox(height: 32),

              _buildWeeklyPulseSection(context),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final streakCount = context.select<DashboardController, int>((c) => c.checkInStatus?.streakCount ?? 0);
    final txCount = context.select<DashboardController, int>((c) => c.data?.recentTransactions.length ?? 0);
    final isSyncing = context.select<DashboardController, bool>((c) => c.isSyncingTransaction);

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
                  icon: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StreakPage(),
                      ),
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
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      streakCount > 99 ? '99+' : streakCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (isSyncing)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: SavaioTheme.primary),
              ),
            ),
          ),
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
                          initialTransactions: sl.dashboardController.data?.recentTransactions ?? [],
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
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      txCount > 99 ? '99+' : txCount.toString(),
                      style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
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

  Widget _buildWeeklyPulseSection(BuildContext context) {
    final weeklyPulse = context.select<DashboardController, WeeklyPulseVM?>((c) => c.data?.weeklyPulse);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Wawasan Mingguan'),
        const SizedBox(height: 16),
        if (weeklyPulse != null && weeklyPulse.weeklySpending.isNotEmpty)
          AppWeeklyPulseChart(
            growth: weeklyPulse.growth,
            values: weeklyPulse.values,
          )
        else
          const AppWeeklyPulseChart(growth: 0, values: [0, 0, 0, 0, 0, 0, 0]),
      ],
    );
  }
}

class _DashboardBalanceSection extends StatelessWidget {
  const _DashboardBalanceSection();

  @override
  Widget build(BuildContext context) {
    final balance = context.select<DashboardController, double>((c) => c.data?.balance ?? 0.0);
    final income = context.select<DashboardController, double>((c) => c.data?.totalIncome ?? 0.0);
    final expense = context.select<DashboardController, double>((c) => c.data?.totalExpense ?? 0.0);
    final hasData = context.select<DashboardController, bool>((c) => c.data != null);

    return AppBalanceCard(
      balance: balance,
      income: income,
      expense: expense,
      onIncomeTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTransactionPage(initialType: 'Income')),
        );
      },
      onExpenseTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTransactionPage(initialType: 'Expense')),
        );
      },
      isLoading: !hasData,
    );
  }
}

class _DashboardRecentTransactionsSection extends StatelessWidget {
  const _DashboardRecentTransactionsSection();

  @override
  Widget build(BuildContext context) {
    final transactions = context.select<DashboardController, List>((c) => c.data?.recentTransactions ?? []);
    final hasData = context.select<DashboardController, bool>((c) => c.data != null);

    return DashboardRecentTransactions(
      transactions: List.from(transactions),
      onViewAllTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AllTransactionsPage(
            initialTransactions: List.from(transactions),
          ),
        ),
      ),
      onTransactionTap: (tx) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TransactionDetailPage(transaction: tx)),
      ),
      isLoading: !hasData,
    );
  }
}
