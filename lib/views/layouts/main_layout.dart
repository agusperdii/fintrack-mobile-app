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
      extendBody: true, 
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildModernBottomNav(theme),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SavaioTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionPage(),
            ),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add_rounded,
          color: SavaioTheme.onPrimaryFixed,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildModernBottomNav(ThemeData theme) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(32.0),
      ),
      child: BottomAppBar(

        height: 70, 
        padding: EdgeInsets.zero,
        
        shape: const CircularNotchedRectangle(),
        notchMargin: 14.0, 
        
        color: theme.scaffoldBackgroundColor, 
        shadowColor: theme.shadowColor.withValues(alpha: 0.04),
        elevation: 16,
        
        child: SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded),
              _buildNavItem(1, Icons.pie_chart_outline_rounded, Icons.pie_chart_rounded),
              const SizedBox(width: 78), 
              _buildNavItem(2, Icons.wallet_outlined, Icons.wallet_rounded),
              _buildNavItem(3, Icons.person_outline_rounded, Icons.person_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData inactiveIcon, IconData activeIcon) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutQuint,
          child: Center(
            child: Icon(
              isSelected ? activeIcon : inactiveIcon,
              size: isSelected ? 30 : 28,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}