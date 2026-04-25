import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../atoms/app_progress_bar.dart';
import '../atoms/app_heading.dart';
import '../atoms/app_icon_container.dart';

class AppCategoryCard extends StatelessWidget {
  final IconData icon;
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: KineticVaultTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AppIconContainer(
                      icon: icon,
                      color: accentColor,
                      shape: AppIconShape.rounded,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    AppHeading(
                      title,
                      size: AppHeadingSize.subtitle,
                    ),
                  ],
                ),
                AppHeading(
                  amount,
                  size: AppHeadingSize.h3,
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppProgressBar(value: progress, color: accentColor, height: 4),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppHeading(
                  limit,
                  size: AppHeadingSize.caption,
                  color: KineticVaultTheme.onSurfaceVariant,
                  isBold: true,
                ),
                AppHeading(
                  status.toUpperCase(),
                  size: AppHeadingSize.caption,
                  color: status == 'Aman' || status == 'Stabil' ? KineticVaultTheme.tertiary : KineticVaultTheme.error,
                  isBold: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
