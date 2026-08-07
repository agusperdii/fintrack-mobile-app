// transaction_amount_input.dart
// Widget molecule input nominal transaksi dengan prefix "Rp" serta
// tombol pintasan nominal cepat (quick amount).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class TransactionAmountInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(double) onQuickAmountTap;

  const TransactionAmountInput({
    super.key,
    required this.controller,
    required this.onQuickAmountTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = SavaioTheme.onSurfaceOf(context);
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                // UX: format "Rp" dibuat kecil di pojok kiri atas
                const Padding(
                  // Dinaikkan sedikit agar sejajar secara visual
                  padding: EdgeInsets.only(bottom: 24.0),
                  child: AppHeading(
                    'Rp',
                    size: AppHeadingSize.h3,
                    color: SavaioTheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                IntrinsicWidth(
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: onSurface,
                      letterSpacing: -1,
                    ),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.2)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildQuickAmount(10000),
            const SizedBox(width: 8),
            _buildQuickAmount(50000),
            const SizedBox(width: 8),
            _buildQuickAmount(100000),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAmount(double amount) {
    return InkWell(
      onTap: () => onQuickAmountTap(amount),
      borderRadius: BorderRadius.circular(SavaioTheme.radiusL),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: SavaioTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(SavaioTheme.radiusL),
          border: Border.all(color: SavaioTheme.primary.withValues(alpha: 0.2)),
        ),
        child: Text(
          '+${(amount / 1000).toStringAsFixed(0)}rb',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: SavaioTheme.primary,
          ),
        ),
      ),
    );
  }
}
