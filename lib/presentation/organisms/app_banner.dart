import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../atoms/app_heading.dart';
import '../atoms/app_icon_container.dart';

class AppBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const AppBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          AppIconContainer(
            icon: icon,
            color: color,
            size: 48,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeading(
                  title,
                  size: AppHeadingSize.subtitle,
                ),
                AppHeading(
                  subtitle,
                  size: AppHeadingSize.caption,
                  color: KineticVaultTheme.onSurfaceVariant,
                  isBold: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
