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
    return Column(
      children: [
        const AppHeading(
          'JUMLAH NOMINAL',
          size: AppHeadingSize.caption,
          color: SavaioTheme.onSurfaceVariant,
          isBold: true,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const AppHeading(
              'Rp',
              size: AppHeadingSize.h2,
              color: SavaioTheme.primary,
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
                  color: SavaioTheme.onSurface,
                  letterSpacing: -1,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(color: SavaioTheme.onSurface.withValues(alpha: 0.2)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
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
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: SavaioTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(100),
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
