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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KineticVaultTheme.radiusL),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KineticVaultTheme.spacingM,
          vertical: KineticVaultTheme.spacingM,
        ),
        decoration: BoxDecoration(
          color: KineticVaultTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(KineticVaultTheme.radiusL),
        ),
        child: Row(
          children: [
            AppIconContainer(
              icon: isExpense ? Icons.coffee_rounded : Icons.shopping_bag_rounded,
              color: isExpense ? KineticVaultTheme.secondary : KineticVaultTheme.primary,
              shape: AppIconShape.rounded,
              size: 48,
              opacity: 0.15,
              iconColor: isExpense ? KineticVaultTheme.secondary : KineticVaultTheme.primary,
            ),
            const SizedBox(width: KineticVaultTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppHeading(
                    transaction.title,
                    size: AppHeadingSize.subtitle,
                    isBold: true,
                  ),
                  const SizedBox(height: KineticVaultTheme.spacingXs),
                  AppHeading(
                    '${transaction.date} • ${transaction.category}',
                    size: AppHeadingSize.caption,
                    color: KineticVaultTheme.onSurfaceVariant,
                    isBold: false,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppHeading(
                  '${isExpense ? "-" : "+"} ${KineticVaultTheme.formatCurrency(transaction.amount.abs())}',
                  size: AppHeadingSize.subtitle,
                  color: isExpense ? KineticVaultTheme.onSurface : KineticVaultTheme.primary,
                  isBold: true,
                ),
                const SizedBox(height: KineticVaultTheme.spacingXs),
                AppHeading(
                  'Success',
                  size: AppHeadingSize.caption,
                  color: Colors.greenAccent.withValues(alpha: 0.7),
                  isBold: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
