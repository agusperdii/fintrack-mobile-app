import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/models/notification_data.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';

class NotificationToastOrganism extends StatelessWidget {
  final NotificationData notification;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  const NotificationToastOrganism({
    super.key,
    required this.notification,
    this.onDismiss,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (notification.severity) {
      case NotificationSeverity.warning:
        color = Colors.orange;
        icon = Icons.warning_amber_rounded;
        break;
      case NotificationSeverity.danger:
        color = SavaioTheme.error;
        icon = Icons.error_outline_rounded;
        break;
      case NotificationSeverity.info:
        color = SavaioTheme.primary;
        icon = Icons.info_outline_rounded;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        borderRadius: 100, // Pill shape
        borderColor: color.withValues(alpha: 0.5),
        borderWidth: 1.5,
        color: SavaioTheme.surfaceContainerHighest.withValues(alpha: 0.95),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      color: SavaioTheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    notification.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: SavaioTheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (onDismiss != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDismiss,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: SavaioTheme.onSurfaceVariant.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: SavaioTheme.onSurfaceVariant, size: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, NotificationData notification, {VoidCallback? onTap}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: NotificationToastOrganism(
              notification: notification,
              onDismiss: () => entry.remove(),
              onTap: () {
                onTap?.call();
                entry.remove();
              },
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) entry.remove();
    });
  }
}
