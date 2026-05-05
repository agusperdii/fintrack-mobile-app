import 'package:flutter/material.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class TransactionAmountInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(double) onQuickAmountTap;
  final String label;
  final String currencySymbol;

  const TransactionAmountInput({
    super.key,
    required this.controller,
    required this.onQuickAmountTap,
    this.label = 'JUMLAH NOMINAL',
    this.currencySymbol = 'Rp',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        AppHeading(
          label,
          size: AppHeadingSize.caption,
          color: colorScheme.onSurfaceVariant,
          isBold: true,
        ),
        const SizedBox(height: 16),
        Semantics(
          label: 'Amount input field',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AppHeading(
                currencySymbol,
                size: AppHeadingSize.h2,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              IntrinsicWidth(
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.2)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildQuickAmount(context, 10000),
            const SizedBox(width: 8),
            _buildQuickAmount(context, 50000),
            const SizedBox(width: 8),
            _buildQuickAmount(context, 100000),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAmount(BuildContext context, double amount) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Semantics(
      button: true,
      label: 'Quick add $amount',
      child: InkWell(
        onTap: () => onQuickAmountTap(amount),
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
          ),
          child: Text(
            '+${(amount / 1000).toStringAsFixed(0)}rb',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
