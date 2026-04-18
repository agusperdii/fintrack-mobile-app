import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../theme/kinetic_vault_theme.dart';

class AnalysisChartItem extends StatelessWidget {
  final AnalysisData data;
  final double maxAmount;

  const AnalysisChartItem({
    super.key,
    required this.data,
    this.maxAmount = 5000000,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Rp ${data.amount.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: data.amount / maxAmount,
              minHeight: 12,
              backgroundColor: KineticVaultTheme.surfaceContainerHighest,
              color: Color(int.parse('0xFF${data.colorHex}')),
            ),
          ),
        ],
      ),
    );
  }
}
