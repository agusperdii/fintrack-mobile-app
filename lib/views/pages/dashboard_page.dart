import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/controllers/dashboard_controller.dart';
import 'package:savaio/controllers/profile_controller.dart';
import 'package:savaio/controllers/budget_controller.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/models/notification_data.dart';
import 'package:savaio/views/components/organisms/app_balance_card.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/components/organisms/app_weekly_pulse_chart.dart';
import 'package:savaio/views/components/organisms/dashboard_recent_transactions.dart';
import 'package:savaio/views/components/molecules/dashboard_quick_actions.dart';
import 'package:savaio/views/components/molecules/app_greeting_header.dart';
import 'package:savaio/views/components/molecules/budget_donut_card.dart';
import 'package:savaio/views/components/molecules/consistency_card.dart';
import 'package:savaio/views/pages/notifications_page.dart';
import 'package:savaio/views/pages/all_transactions_page.dart';
import 'package:savaio/views/pages/transaction_detail_page.dart';
import 'package:savaio/views/pages/ocr_scan_page.dart';
import 'package:savaio/views/pages/add_transaction_page.dart';
import 'package:savaio/views/pages/streak_page.dart';
import 'package:savaio/views/pages/spending_target_page.dart';
import 'package:savaio/views/pages/summary_page.dart';
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

  Future<void> _handleRefresh() async {
    final now = DateTime.now();
    final currentMonth = sl.dashboardController.data?.targetPeriod ??
        "${now.year}-${now.month.toString().padLeft(2, '0')}";

    await Future.wait([
      sl.dashboardController.fetchDashboardData(),
      sl.budgetController.fetchAll(month: currentMonth),
      sl.profileController.fetchProfile(),
      sl.analyticsController.fetchAll(),
      sl.notificationController.fetchAll(),
    ]);
  }

  void _navigateToAddTransaction({required String type, String? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionPage(initialType: type, initialCategory: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<DashboardController, bool>((c) => c.isLoading);
    final hasData = context.select<DashboardController, bool>((c) => c.data != null);
    final checkInStatus = context.select<DashboardController, dynamic>((c) => c.checkInStatus);

    if (isLoading && !hasData) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // UX: Idealnya gunakan Shimmer Loading di sini untuk retensi persepsi performa
        body: const Center(child: CircularProgressIndicator(color: SavaioTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: SavaioTheme.primary,
        backgroundColor: SavaioTheme.surfaceContainerHigh,
        child: SingleChildScrollView(
          // UX: Padding dikurangi sedikit agar konten terasa lebih lega di layar kecil
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Alert / Actionable Nudge (Di atas agar langsung terlihat)
              if (checkInStatus?.isCheckedInToday == false) ...[
                const DailyCheckInCard(),
                const SizedBox(height: 20),
              ],

              // 2. Main Hero Section (Saldo)
              const _DashboardBalanceSection(),
              const SizedBox(height: 20),

              // 3. Quick Actions (Primary Actions)
              DashboardQuickActions(
                onIncomeTap: () => _navigateToAddTransaction(type: 'Income'),
                onExpenseTap: () => _navigateToAddTransaction(type: 'Expense'),
                onScanTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OcrScanPage()),
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 12),
              const _DashboardBudgetSection(),
              const SizedBox(height: 28),
              ConsistencyCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SummaryPage()),
                ),
              ),
              const SizedBox(height: 28),

              // 5. Recent Activity (Kontekstual)
              const _DashboardRecentTransactionsSection(),

              // 6. Analytics (Di bawah karena butuh waktu untuk dicerna)

              // UX: Memberikan ruang aman untuk navigasi bawah atau FAB
              const SizedBox(height: 50), 
            ],
          ),
        ),
      ),
      // UX Suggestion: Pertimbangkan menggunakan FloatingActionButton (FAB)
      // untuk menambah transaksi agar bisa diakses walau di-scroll ke bawah.
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final userProfile = context.watch<ProfileController>().userProfile;
    final streakCount = context.select<DashboardController, int>((c) => c.checkInStatus?.streakCount ?? 0);
    final isSyncing = context.select<DashboardController, bool>((c) => c.isSyncingTransaction);
    
    // Determine overall budget status
    final budgetStatuses = context.select<BudgetController, List>((c) => c.budgetStatuses);
    String overallStatus = 'active';
    if (budgetStatuses.any((s) => s.status == 'exceeded')) {
      overallStatus = 'exceeded';
    } else if (budgetStatuses.any((s) => s.status == 'warning')) {
      overallStatus = 'warning';
    }

    return AppHeader(
      centerTitle: false,
      titleWidget: Padding(
        padding: const EdgeInsets.only(left: SavaioTheme.spacingXl),
        child: AppGreetingHeader(
          userName: userProfile?.fullName.split(' ').first ?? 'User',
          budgetStatus: overallStatus,
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
                  borderRadius: BorderRadius.circular(SavaioTheme.radiusM),
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
        const SizedBox(width: 12),
      ],
      onNotificationTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationsPage()),
        );
      },
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
      // UX Fix: Hapus aksi tap di sini jika sudah ada di DashboardQuickActions
      // Pastikan widget AppBalanceCard Anda mendukung parameter null untuk fungsi ini.
      onIncomeTap: null, 
      onExpenseTap: null,
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

class _DashboardBudgetSection extends StatelessWidget {
  const _DashboardBudgetSection();

  @override
  Widget build(BuildContext context) {
    final budgetController = context.watch<BudgetController>();
    final dashboardController = context.watch<DashboardController>();
    
    final monthlyBudget = budgetController.totalMonthlyBudget;
    final monthlySpent = budgetController.totalMonthlySpent;
    
    final weeklyPulse = dashboardController.data?.weeklyPulse;
    final todaySpent = weeklyPulse?.weeklySpending.isNotEmpty == true 
        ? weeklyPulse!.weeklySpending.last.amount 
        : 0.0;
        
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final dailyBudget = monthlyBudget / daysInMonth;

    return Row(
      children: [
        Expanded(
          child: BudgetDonutCard(
            title: 'Bulanan', // UX Fix: Singkat judul agar tidak overflow
            spent: monthlySpent,
            total: monthlyBudget,
            color: SavaioTheme.primary,
          ),
        ),
        const SizedBox(width: 16), // UX Fix: Jarak dikurangi agar proporsional
        Expanded(
          child: BudgetDonutCard(
            title: 'Harian',
            spent: todaySpent,
            total: dailyBudget,
            color: SavaioTheme.secondary,
          ),
        ),
      ],
    );
  }
}