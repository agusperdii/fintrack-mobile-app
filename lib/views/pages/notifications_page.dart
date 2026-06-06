import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/controllers/notification_controller.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/organisms/notifications/notification_badge_organism.dart';
import 'package:savaio/views/components/organisms/notifications/notification_banner_organism.dart';
import 'package:savaio/views/components/organisms/notifications/notification_popup_organism.dart';
import 'package:savaio/views/components/organisms/notifications/notification_toast_organism.dart';
import 'package:savaio/views/components/organisms/app_header.dart';

import 'package:savaio/models/notification_data.dart' as model;

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotificationController>();
    final notifications = controller.notifications;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppHeader(
        title: 'Notifikasi',
        showBackButton: true,
        showNotification: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchAll(),
        color: Theme.of(context).colorScheme.primary,
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
                      child: Text(
                        'Baca semua',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
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
                      Icon(Icons.notifications_none_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      AppHeading('Belum ada notifikasi', size: AppHeadingSize.subtitle, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ],
                  ),
                )
              else
                ...notifications.map((notif) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildNotificationItem(context, controller, notif),
                )),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationController controller, model.NotificationData notif) {
    List<Widget> actions = [];
    if (!notif.isRead) {
      actions.add(
        GestureDetector(
          onTap: () => controller.markAsRead(notif.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
            ),
            child: Text(
              'BACA',
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    void onTap() {
      if (!notif.isRead) {
        controller.markAsRead(notif.id);
      }
      
      if (notif.presentation == model.NotificationPresentation.popup) {
        NotificationPopupOrganism.show(context, notif, onRead: () => controller.markAsRead(notif.id));
      } else if (notif.presentation == model.NotificationPresentation.toast) {
        NotificationToastOrganism.show(context, notif);
      }
    }

    switch (notif.presentation) {
      case model.NotificationPresentation.badge:
        return NotificationBadgeOrganism(
          notification: notif,
          onTap: onTap,
        );
      case model.NotificationPresentation.toast:
        return NotificationToastOrganism(
          notification: notif,
          onTap: onTap,
        );
      case model.NotificationPresentation.banner:
      case model.NotificationPresentation.popup:
        return NotificationBannerOrganism(
          notification: notif,
          onTap: onTap,
          actions: actions,
        );
    }
  }
}
