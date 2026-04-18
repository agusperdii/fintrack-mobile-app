import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/app_data.dart';
import '../atoms/app_heading.dart';
import '../atoms/app_icon_container.dart';

class AppTransactionItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const AppTransactionItem({
    super.key, 
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.amount < 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: KineticVaultTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            AppIconContainer(
              icon: isExpense ? Icons.coffee : Icons.shopping_bag,
              color:  KineticVaultTheme.surfaceContainerHigh,
              shape: AppIconShape.rounded,
              size: 40,
              opacity: 1.0,
              iconColor: isExpense ? KineticVaultTheme.secondary : KineticVaultTheme.primary,
            ),
            // Re-evaluating the above: AppIconContainer default opacity is 0.1, but here it was surfaceContainerHighest.
            // Let's use it properly.
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppHeading(
                    transaction.title,
                    size: AppHeadingSize.subtitle,
                    isBold: true,
                  ),
                  AppHeading(
                    '${transaction.date} • 09:41',
                    size: AppHeadingSize.caption,
                    color: KineticVaultTheme.onSurfaceVariant,
                    isBold: false,
                  ),
                ],
              ),
            ),
            AppHeading(
              '${isExpense ? "-" : "+"} ${KineticVaultTheme.formatCurrency(transaction.amount.abs())}',
              size: AppHeadingSize.subtitle,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }
}
