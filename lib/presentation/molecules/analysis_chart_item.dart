import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/app_data.dart';

class AnalysisChartItem extends StatelessWidget {
  final AnalysisData data;

  const AnalysisChartItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse('FF${data.colorHex}', radix: 16));
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KineticVaultTheme.surfaceContainer,
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
              Text(
                data.label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: KineticVaultTheme.onSurface,
                ),
              ),
            ],
          ),
          Text(
            KineticVaultTheme.formatCurrency(data.amount),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: KineticVaultTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
