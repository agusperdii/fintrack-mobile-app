import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../atoms/app_heading.dart';
import '../atoms/app_icon_container.dart';
import '../atoms/glass_card.dart';

enum AppNotificationVariant { info, warning, success, streak }

class AppNotificationCard extends StatelessWidget {
  final String category;
  final String time;
  final Widget content;
  final AppNotificationVariant variant;
  final List<Widget>? actions;
  final Widget? footer;
  final bool isRead;

  const AppNotificationCard({
    super.key,
    required this.category,
    required this.time,
    required this.content,
    this.variant = AppNotificationVariant.info,
    this.actions,
    this.footer,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (variant) {
      case AppNotificationVariant.warning:
        color = SavaioTheme.error;
        icon = Icons.warning;
        break;
      case AppNotificationVariant.success:
        color = SavaioTheme.tertiary;
        icon = Icons.check_circle;
        break;
      case AppNotificationVariant.streak:
        color = SavaioTheme.secondary;
        icon = Icons.fireplace;
        break;
      case AppNotificationVariant.info:
        color = SavaioTheme.primary;
        icon = Icons.lightbulb;
        break;
    }

    // Dim color if read
    final effectiveColor = isRead ? color.withValues(alpha: 0.5) : color;

    return GlassCard(
      padding: EdgeInsets.zero,
      borderColor: variant == AppNotificationVariant.warning && !isRead
          ? color.withValues(alpha: 0.5) 
          : SavaioTheme.onSurfaceVariant.withValues(alpha: 0.1),
      borderWidth: 1,
      child: Opacity(
        opacity: isRead ? 0.6 : 1.0,
        child: Container(
          decoration: variant == AppNotificationVariant.warning && !isRead ? BoxDecoration(
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
