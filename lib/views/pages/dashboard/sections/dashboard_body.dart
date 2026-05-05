import 'package:flutter/material.dart';
import 'package:savaio/others.dart';
import 'package:savaio/controllers/finance_controller.dart';
import 'package:savaio/views/components/molecules/app_greeting_header.dart';
import 'package:savaio/views/components/molecules/daily_checkin_card.dart';
import 'package:savaio/views/components/molecules/dashboard_quick_actions.dart';
import 'package:savaio/views/pages/dashboard/dashboard_routes.dart';
import 'package:savaio/views/pages/dashboard/sections/dashboard_summary_section.dart';
import 'package:savaio/views/pages/dashboard/sections/dashboard_recent_transactions_section.dart';
import 'package:savaio/views/pages/dashboard/sections/dashboard_weekly_pulse_section.dart';

class DashboardBody extends StatelessWidget {
  final FinanceController controller;

  const DashboardBody({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.loadInitialData(),
      color: SavaioTheme.primary,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            const SizedBox(height: 16),
            _buildCheckInCard(),
            const SizedBox(height: 16),
            _buildSummary(),
            const SizedBox(height: 32),
            _buildQuickActions(context),
            const SizedBox(height: 40),
            _buildRecentTransactions(),
            const SizedBox(height: 32),
            _buildWeeklyPulse(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final profile = controller.userProfile;
        final firstName = profile?['name']?.split(' ').first ?? 'User';
        return AppGreetingHeader(
          title: 'Hi, $firstName!',
          subtitle: 'Selamat Datang!',
        );
      },
    );
  }

  Widget _buildCheckInCard() {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.checkInStatus?.isCheckedInToday == false) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: DailyCheckInCard(
              subtitle: 'Ayo check-in hari ini untuk jaga streak kamu!',
              onTap: () => controller.performCheckIn(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSummary() {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return DashboardSummarySection(
          data: controller.dashboardData,
          isLoading: controller.isLoading && controller.dashboardData == null,
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return DashboardQuickActions(
      onIncomeTap: () => DashboardRoutes.navigateToAddTransaction(context, type: 'Income'),
      onExpenseTap: () => DashboardRoutes.navigateToAddTransaction(context, type: 'Expense'),
      onScanTap: () => DashboardRoutes.navigateToOcrScan(context),
    );
  }

  Widget _buildRecentTransactions() {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return DashboardRecentTransactionsSection(
          transactions: controller.dashboardData?.recentTransactions ?? [],
          isLoading: controller.isLoading && controller.dashboardData == null,
        );
      },
    );
  }

  Widget _buildWeeklyPulse() {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return DashboardWeeklyPulseSection(
          weeklyPulse: controller.weeklyPulse,
        );
      },
    );
  }
}
