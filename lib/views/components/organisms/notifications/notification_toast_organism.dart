// notification_toast_organism.dart
// Toast notifikasi ringkas yang muncul sementara di bagian atas layar dan
// otomatis hilang setelah beberapa detik.

import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/models/notification_data.dart';

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
        color = SavaioTheme.warningOf(context);
        icon = Icons.warning_amber_rounded;
        break;
      case NotificationSeverity.danger:
        color = SavaioTheme.errorOf(context);
        icon = Icons.error_outline_rounded;
        break;
      case NotificationSeverity.info:
        color = SavaioTheme.primaryOf(context);
        icon = Icons.info_outline_rounded;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: SavaioTheme.surfaceContainerHighestOf(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: SavaioTheme.onSurfaceOf(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: SavaioTheme.onSurfaceOf(context).withValues(alpha: 0.68),
                        fontSize: 11,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDismiss != null) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onDismiss,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      color: SavaioTheme.onSurfaceVariantOf(context).withValues(alpha: 0.7),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static void show(
    BuildContext context,
    NotificationData notification, {
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: NotificationToastOrganism(
                notification: notification,
                onDismiss: () {
                  if (entry.mounted) entry.remove();
                },
                onTap: () {
                  onTap?.call();
                  if (entry.mounted) entry.remove();
                },
              ),
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