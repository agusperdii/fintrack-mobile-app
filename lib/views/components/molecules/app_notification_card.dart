import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_icon_container.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';

import 'package:savaio/models/notification_data.dart';

class AppNotificationCard extends StatelessWidget {
  final String category;
  final String time;
  final Widget content;
  final NotificationSeverity severity;
  final NotificationPresentation presentation;
  final List<Widget>? actions;
  final Widget? footer;
  final bool isRead;

  const AppNotificationCard({
    super.key,
    required this.category,
    required this.time,
    required this.content,
    this.severity = NotificationSeverity.info,
    this.presentation = NotificationPresentation.banner,
    this.actions,
    this.footer,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (severity) {
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

    // Special icon for badge presentation if needed
    if (presentation == NotificationPresentation.badge) {
      icon = Icons.circle;
    }

    // Dim color if read
    final effectiveColor = isRead ? color.withValues(alpha: 0.5) : color;

    return GlassCard(
      padding: EdgeInsets.zero,
      borderColor: !isRead
          ? color.withValues(alpha: 0.3) 
          : SavaioTheme.onSurfaceVariant.withValues(alpha: 0.1),
      borderWidth: 1,
      child: Opacity(
        opacity: isRead ? 0.7 : 1.0,
        child: Container(
          decoration: !isRead ? BoxDecoration(
            border: Border(
              left: BorderSide(
                color: color.withValues(alpha: 0.5),
                width: 4,
              ),
            ),
          ) : null,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIconContainer(
                icon: icon,
                color: effectiveColor,
                size: 40,
                opacity: 0.1,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppHeading(
                          category,
                          size: AppHeadingSize.caption,
                          color: effectiveColor,
                          isBold: !isRead,
                        ),
                        AppHeading(
                          time,
                          size: AppHeadingSize.caption,
                          color: SavaioTheme.onSurface.withValues(alpha: 0.4),
                          isBold: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    content,
                    if (actions != null && actions!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(children: actions!),
                    ],
                    if (footer != null) ...[
                      const SizedBox(height: 12),
                      footer!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
