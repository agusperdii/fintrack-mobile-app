import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/service_locator.dart';
import '../components/atoms/app_heading.dart';
import '../components/molecules/app_notification_card.dart';
import '../components/organisms/app_header.dart';
import '../../models/entities/nudge_data.dart';
import 'package:intl/intl.dart';

import 'spending_target_page.dart';
import 'analisa_page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sl.financeController,
      builder: (context, _) {
        final provider = sl.financeController;
        final nudges = provider.nudges;

        return Scaffold(
          backgroundColor: KineticVaultTheme.background,
          appBar: const AppHeader(
            title: 'Notifikasi',
            showBackButton: true,
            showNotification: false,
          ),
          body: RefreshIndicator(
            onRefresh: () => provider.fetchNudges(),
            color: KineticVaultTheme.primary,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppHeading('Notifikasi', size: AppHeadingSize.h2),
                      if (nudges.any((n) => !n.isRead))
                        TextButton(
                          onPressed: () {
                            for (var n in nudges) {
                              if (!n.isRead) provider.markNudgeAsRead(n.id);
                            }
                          },
                          child: const Text(
                            'Baca semua',
                            style: TextStyle(color: KineticVaultTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  if (nudges.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 100),
                          Icon(Icons.notifications_none_rounded, size: 64, color: KineticVaultTheme.onSurfaceVariant.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          const AppHeading('Belum ada notifikasi', size: AppHeadingSize.subtitle, color: KineticVaultTheme.onSurfaceVariant),
                        ],
                      ),
                    )
                  else
                    ...nudges.map((nudge) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildNudgeCard(context, nudge),
                    )),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNudgeCard(BuildContext context, NudgeData nudge) {
    final provider = sl.financeController;
    AppNotificationVariant variant = AppNotificationVariant.info;
    if (nudge.type == NudgeType.warning) variant = AppNotificationVariant.warning;
    if (nudge.type == NudgeType.positive) variant = AppNotificationVariant.success;

    List<Widget>? actions;
    if (!nudge.isRead) {
      actions = [
        if (nudge.type == NudgeType.warning) ...[
          GestureDetector(
            onTap: () {
              provider.markNudgeAsRead(nudge.id);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SpendingTargetPage(initialCategory: nudge.targetCategory)),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: KineticVaultTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: KineticVaultTheme.error.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'LIHAT BUDGET',
                style: TextStyle(color: KineticVaultTheme.error, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        GestureDetector(
          onTap: () => provider.markNudgeAsRead(nudge.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: KineticVaultTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: KineticVaultTheme.primary.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'TANDAI DIBACA',
              style: TextStyle(color: KineticVaultTheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ];
    }

    return GestureDetector(
      onTap: () {
        if (!nudge.isRead) {
          provider.markNudgeAsRead(nudge.id);
        }
        
        // Intelligent Redirection
        if (nudge.type == NudgeType.warning) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SpendingTargetPage(initialCategory: nudge.targetCategory)),
          );
        } else if (nudge.type == NudgeType.positive) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AnalisaPage()),
          );
        } else {
          // For info/reminder, we might just stay or go to Dashboard
          Navigator.pop(context); // Go back to dashboard
        }
      },
      child: AppNotificationCard(
        category: nudge.type.name.toUpperCase(),
        time: _formatTime(nudge.createdAt),
        variant: variant,
        actions: actions,
        isRead: nudge.isRead,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nudge.message,
              style: TextStyle(
                color: nudge.isRead ? KineticVaultTheme.onSurfaceVariant : KineticVaultTheme.onSurface,
                fontSize: 13,
                height: 1.5,
                fontWeight: nudge.isRead ? FontWeight.normal : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('dd MMM').format(date);
  }
}
