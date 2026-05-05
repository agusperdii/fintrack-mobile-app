import 'package:flutter/material.dart';
import 'package:savaio/views/components/atoms/app_progress_bar.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_icon_container.dart';

class AppCategoryCard extends StatelessWidget {
  final dynamic icon;
  final String title;
  final String amount;
  final double progress;
  final String limit;
  final String status;
  final Color accentColor;
  final VoidCallback onTap;

  const AppCategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.amount,
    required this.progress,
    required this.limit,
    required this.status,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      label: 'Category: $title, $amount used of $limit',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        AppIconContainer(
                          icon: icon,
                          color: accentColor,
                          shape: AppIconShape.rounded,
                          size: 40,
                          iconColor: accentColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppHeading(
                            title,
                            size: AppHeadingSize.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppHeading(
                    amount,
                    size: AppHeadingSize.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppProgressBar(value: progress, color: accentColor, height: 4),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AppHeading(
                      limit,
                      size: AppHeadingSize.caption,
                      color: colorScheme.onSurfaceVariant,
                      isBold: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppHeading(
                    status.toUpperCase(),
                    size: AppHeadingSize.caption,
                    color: status == 'Aman' || status == 'Stabil' 
                      ? colorScheme.tertiary 
                      : colorScheme.error,
                    isBold: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
