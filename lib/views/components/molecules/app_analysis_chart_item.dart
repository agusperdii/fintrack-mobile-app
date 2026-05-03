import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class AppAnalysisChartItem extends StatelessWidget {
  final AnalysisData data;

  const AppAnalysisChartItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse('FF${data.colorHex}', radix: 16));
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              AppHeading(
                data.label,
                size: AppHeadingSize.subtitle,
                isBold: false,
              ),
            ],
          ),
          AppHeading(
            SavaioTheme.formatCurrency(data.amount),
            size: AppHeadingSize.subtitle,
            isBold: true,
          ),
        ],
      ),
    );
  }
}
