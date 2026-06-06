import 'package:flutter/material.dart';
import 'package:savaio/models/notification_data.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_icon_container.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';

class NotificationBadgeOrganism extends StatelessWidget {
  final NotificationData notification;
  final VoidCallback? onTap;

  const NotificationBadgeOrganism({
    super.key,
    required this.notification,
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
        color = Theme.of(context).colorScheme.error;
        icon = Icons.error_outline_rounded;
        break;
      case NotificationSeverity.info:
        color = Theme.of(context).colorScheme.primary;
        icon = Icons.info_outline_rounded;
        break;
    }

    final effectiveColor = notification.isRead ? color.withValues(alpha: 0.5) : color;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 100, // Make it a pill
        borderColor: !notification.isRead
            ? color.withValues(alpha: 0.4)
            : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
        borderWidth: 1.5,
        color: !notification.isRead 
            ? color.withValues(alpha: 0.05) 
            : Theme.of(context).colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
        child: Row(
          children: [
            AppIconContainer(
              icon: icon,
              color: effectiveColor,
              size: 32,
              opacity: 0.15,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppHeading(
                        notification.title,
                        size: AppHeadingSize.caption,
                        color: effectiveColor,
                        isBold: !notification.isRead,
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                        ),
                    ],
                  ),
                  Text(
                    notification.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: notification.isRead 
                          ? Theme.of(context).colorScheme.onSurfaceVariant 
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
