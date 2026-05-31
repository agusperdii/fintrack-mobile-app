import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/controllers/notification_controller.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/molecules/app_notification_card.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:intl/intl.dart';

import 'package:savaio/models/notification_data.dart' as model;

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotificationController>();
    final notifications = controller.notifications;

    return Scaffold(
      backgroundColor: SavaioTheme.background,
      appBar: const AppHeader(
        title: 'Notifikasi',
        showBackButton: true,
        showNotification: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchAll(),
        color: SavaioTheme.primary,
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
                  if (notifications.any((n) => !n.isRead))
                    TextButton(
                      onPressed: () {
                        for (var n in notifications) {
                          if (!n.isRead) controller.markAsRead(n.id);
                        }
                      },
                      child: const Text(
                        'Baca semua',
                        style: TextStyle(color: SavaioTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),

              if (notifications.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 100),
                      Icon(Icons.notifications_none_rounded, size: 64, color: SavaioTheme.onSurfaceVariant.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      const AppHeading('Belum ada notifikasi', size: AppHeadingSize.subtitle, color: SavaioTheme.onSurfaceVariant),
                    ],
                  ),
                )
              else
                ...notifications.map((notif) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildNotificationCard(context, controller, notif),
                )),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationController controller, model.NotificationData notif) {
    List<Widget>? actions;
    if (!notif.isRead) {
      actions = [
        GestureDetector(
          onTap: () => controller.markAsRead(notif.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: SavaioTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: SavaioTheme.primary.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'TANDAI DIBACA',
              style: TextStyle(color: SavaioTheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ];
    }

    return GestureDetector(
      onTap: () {
        if (!notif.isRead) {
          controller.markAsRead(notif.id);
        }
      },
      child: AppNotificationCard(
        category: notif.type.name.toUpperCase(),
        time: _formatTime(notif.createdAt),
        severity: notif.severity,
        presentation: notif.presentation,
        actions: actions,
        isRead: notif.isRead,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notif.title,
              style: TextStyle(
                color: notif.isRead ? SavaioTheme.onSurfaceVariant : SavaioTheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              notif.message,
              style: TextStyle(
                color: notif.isRead ? SavaioTheme.onSurfaceVariant : SavaioTheme.onSurface.withValues(alpha: 0.8),
                fontSize: 13,
                height: 1.5,
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
