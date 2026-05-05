import 'package:flutter/material.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class AppBalanceMiniItem extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const AppBalanceMiniItem({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: onTap != null,
      label: '$label: $amount',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 12),
                const SizedBox(width: 4),
                Expanded(
                  child: AppHeading(
                    label,
                    size: AppHeadingSize.caption,
                    color: colorScheme.onSurfaceVariant,
                    isBold: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            AppHeading(
              amount,
              size: AppHeadingSize.subtitle,
              isBold: true,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
