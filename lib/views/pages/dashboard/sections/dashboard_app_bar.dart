import 'package:flutter/material.dart';
import 'package:savaio/controllers/finance_controller.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/pages/dashboard/dashboard_routes.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final FinanceController controller;

  const DashboardAppBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final streakCount = controller.checkInStatus?.streakCount ?? 0;
    final txCount = controller.dashboardData?.recentTransactions.length ?? 0;
    final theme = Theme.of(context);

    return AppHeader(
      unreadCount: controller.unreadNotificationsCount,
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
                  color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 20),
                  onPressed: () => DashboardRoutes.navigateToStreak(context),
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
                      border: Border.all(color: theme.colorScheme.surface, width: 2),
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
                  color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.receipt_long_rounded, color: theme.colorScheme.primary, size: 20),
                  onPressed: () {
                    DashboardRoutes.navigateToAllTransactions(
                      context,
                      controller.dashboardData?.recentTransactions ?? [],
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
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.surface, width: 2),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      txCount > 99 ? '99+' : txCount.toString(),
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
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
      onNotificationTap: () => DashboardRoutes.navigateToNotifications(context),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
