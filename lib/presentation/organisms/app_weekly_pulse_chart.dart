import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../atoms/app_heading.dart';

class AppWeeklyPulseChart extends StatelessWidget {
  final double growth;
  final List<double> values; // Normalized values 0.0 to 1.0

  const AppWeeklyPulseChart({
    super.key,
    required this.growth,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KineticVaultTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppHeading(
                    'WEEKLY PULSE',
                    size: AppHeadingSize.caption,
                    color: KineticVaultTheme.onSurfaceVariant,
                    isBold: true,
                  ),
                  AppHeading(
                    'Growth ${growth > 0 ? "+" : ""}${growth.toStringAsFixed(0)}%',
                    size: AppHeadingSize.h3,
                    color: growth > 0 ? KineticVaultTheme.tertiary : KineticVaultTheme.error,
                  ),
                ],
              ),
              Icon(Icons.insights, color: KineticVaultTheme.onSurfaceVariant.withValues(alpha: 0.3), size: 18),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: values.map((val) => _buildPulseBar(val, val == values.reduce((a, b) => a > b ? a : b))).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseBar(double heightFactor, bool isHighlighted) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        height: 48 * heightFactor.clamp(0.1, 1.0),
        decoration: BoxDecoration(
          color: isHighlighted ? KineticVaultTheme.tertiary : KineticVaultTheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isHighlighted ? [
            BoxShadow(
              color: KineticVaultTheme.tertiary.withValues(alpha: 0.3),
              blurRadius: 10,
            )
          ] : null,
        ),
      ),
    );
  }
}
