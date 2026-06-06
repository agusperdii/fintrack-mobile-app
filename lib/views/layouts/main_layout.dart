import 'dart:async';
import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/pages/dashboard_page.dart';
import 'package:savaio/views/pages/analisa_page.dart';
import 'package:savaio/views/pages/profile_page.dart';
import 'package:savaio/views/pages/summary_page.dart';
import 'package:savaio/views/pages/add_transaction_page.dart';
import 'package:savaio/views/pages/spending_target_page.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/views/components/organisms/notifications/notification_popup_organism.dart';
import 'package:savaio/views/components/organisms/notifications/notification_banner_organism.dart';
import 'package:savaio/views/components/organisms/notifications/notification_toast_organism.dart';
import 'package:savaio/models/notification_data.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  StreamSubscription? _notifSubscription;

  final List<Widget> _pages = [
    const DashboardPage(),
    const AnalisaPage(),
    const SummaryPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAppData();
      _initWebSocket();
    });
  }

  void _initAppData() {
    if (sl.dashboardController.data == null &&
        !sl.dashboardController.isLoading) {
      Future(() async {
        await Future.wait([
          sl.dashboardController.fetchDashboardData(),
          sl.budgetController.fetchAll(),
          sl.profileController.fetchProfile(),
          sl.analyticsController.fetchAll(),
          sl.notificationController.fetchAll(),
        ]);

        final now = DateTime.now();
        final currentMonth = sl.dashboardController.data?.targetPeriod ??
            "${now.year}-${now.month.toString().padLeft(2, '0')}";

        await sl.transactionController.fetchTransactions(month: currentMonth);
      });
    }
  }

  void _initWebSocket() {
    final userId = sl.authController.userId;

    if (userId != null) {
      sl.notificationSupabaseService.subscribe(userId);
    }

    _notifSubscription?.cancel();
    _notifSubscription =
        sl.notificationController.realtimeNotifications.listen((notif) {
      if (!mounted) return;

      final isBudgetNotif =
          notif.type == NotificationType.budgetReached ||
          notif.type == NotificationType.budgetExceeded;

      switch (notif.presentation) {
        case NotificationPresentation.popup:
          NotificationPopupOrganism.show(
            context,
            notif,
            onRead: () => sl.notificationController.markAsRead(notif.id),
            actionLabel: isBudgetNotif ? 'LIHAT BUDGET' : null,
            onAction: isBudgetNotif
                ? () {
                    sl.notificationController.markAsRead(notif.id);

                    final categoryId =
                        notif.metadata?['category_id']?.toString();
                    final month = notif.metadata?['month']?.toString();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpendingTargetPage(
                          initialCategoryId: categoryId,
                          initialMonth: month,
                        ),
                      ),
                    );
                  }
                : null,
          );
          break;

        case NotificationPresentation.banner:
          NotificationBannerOrganism.show(
            context,
            notif,
            onRead: () => sl.notificationController.markAsRead(notif.id),
          );
          break;

        case NotificationPresentation.toast:
          NotificationToastOrganism.show(
            context,
            notif,
            onTap: () => sl.notificationController.markAsRead(notif.id),
          );
          break;

        case NotificationPresentation.badge:
          break;
      }
    });
  }

  @override
  void dispose() {
    _notifSubscription?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.25),
              width: 0.7,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _buildNavItem(0, Icons.grid_view_rounded, 'Home'),
                _buildNavItem(1, Icons.bar_chart_rounded, 'Analisa'),
                _buildAddButton(),
                _buildNavItem(2, Icons.history_edu_rounded, 'Laporan'),
                _buildNavItem(3, Icons.person_rounded, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                height: 1,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddTransactionPage(),
              ),
            );
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 48,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: SavaioTheme.primaryGradient,
            ),
            child: const Icon(
              Icons.add_rounded,
              color: SavaioTheme.onPrimaryFixed,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}