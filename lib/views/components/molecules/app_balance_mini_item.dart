import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../atoms/app_heading.dart';

class AppBalanceMiniItem extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;

  const AppBalanceMiniItem({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
            AppHeading(
              label,
              size: AppHeadingSize.caption,
              color: KineticVaultTheme.onSurfaceVariant,
              isBold: false,
            ),
          ],
        ),
        const SizedBox(height: 4),
        AppHeading(
          amount,
          size: AppHeadingSize.subtitle,
          isBold: true,
        ),
      ],
    );
  }
}
