import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingMockTransactionItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final double barWidth;

  const OnboardingMockTransactionItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.barWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 14),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: barWidth,
                height: 8,
                decoration: BoxDecoration(
                  color: KineticVaultTheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: barWidth * 0.5,
                height: 6,
                decoration: BoxDecoration(
                  color: KineticVaultTheme.onSurfaceVariant.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
