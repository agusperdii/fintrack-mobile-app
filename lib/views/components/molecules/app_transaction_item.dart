import 'package:flutter/material.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_icon_container.dart';

class AppTransactionItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final dynamic icon;
  final String amountText;
  final Color? amountColor;
  final String? statusText;
  final Color? statusColor;
  final Color? iconColor;
  final Color? iconBgColor;
  final VoidCallback? onTap;

  const AppTransactionItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.amountText,
    this.amountColor,
    this.statusText,
    this.statusColor,
    this.iconColor,
    this.iconBgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: 'Transaction: $title, $amountText',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              AppIconContainer(
                icon: icon,
                color: iconBgColor ?? colorScheme.primary,
                shape: AppIconShape.rounded,
                size: 48,
                opacity: 0.15,
                iconColor: iconColor ?? iconBgColor ?? colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppHeading(
                      title,
                      size: AppHeadingSize.subtitle,
                      isBold: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    AppHeading(
                      subtitle,
                      size: AppHeadingSize.caption,
                      color: colorScheme.onSurfaceVariant,
                      isBold: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppHeading(
                    amountText,
                    size: AppHeadingSize.subtitle,
                    color: amountColor ?? colorScheme.onSurface,
                    isBold: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (statusText != null) ...[
                    const SizedBox(height: 4),
                    AppHeading(
                      statusText!,
                      size: AppHeadingSize.caption,
                      color: statusColor ?? colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      isBold: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
