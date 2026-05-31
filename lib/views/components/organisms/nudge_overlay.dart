import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/models/notification_data.dart';
import 'package:savaio/views/pages/spending_target_page.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_button.dart';
import 'package:savaio/views/components/atoms/app_icon_container.dart';

class AppNotificationOverlay extends StatelessWidget {
  final NotificationData notification;
  final VoidCallback onDismiss;

  const AppNotificationOverlay({
    super.key,
    required this.notification,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.budgetExceeded:
        icon = Icons.error_outline_rounded;
        color = SavaioTheme.error;
        break;
      case NotificationType.budgetReached:
        icon = Icons.warning_amber_rounded;
        color = Colors.orange;
        break;
      case NotificationType.newTransaction:
        icon = Icons.receipt_long_rounded;
        color = SavaioTheme.tertiary;
        break;
      case NotificationType.welcome:
        icon = Icons.sentiment_very_satisfied_rounded;
        color = SavaioTheme.primary;
        break;
      case NotificationType.streak:
        icon = Icons.local_fire_department_rounded;
        color = Colors.orange;
        break;
      default:
        icon = Icons.notifications_none_rounded;
        color = SavaioTheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SavaioTheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: SavaioTheme.onSurfaceVariant.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          AppIconContainer(
            icon: icon,
            color: color,
            size: 80,
            opacity: 0.15,
          ),
          const SizedBox(height: 24),
          AppHeading(
            notification.title,
            size: AppHeadingSize.h2,
            color: color,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            notification.message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: SavaioTheme.onSurface,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          AppButton(
            label: 'SAYA MENGERTI',
            onTap: onDismiss,
          ),
          if (notification.type == NotificationType.budgetReached || notification.type == NotificationType.budgetExceeded) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                onDismiss();
                final categoryId = notification.metadata?['category_id']?.toString();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SpendingTargetPage(initialCategoryId: categoryId)),
                );
              },
              child: const Text(
                'LIHAT BUDGET KATEGORI',
                style: TextStyle(color: SavaioTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static void show(BuildContext context, NotificationData notification, VoidCallback onRead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppNotificationOverlay(
        notification: notification,
        onDismiss: () {
          onRead();
          Navigator.pop(context);
        },
      ),
    );
  }
}
