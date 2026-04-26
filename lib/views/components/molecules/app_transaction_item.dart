import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/service_locator.dart';
import '../../../models/entities/app_data.dart';
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
    final isExpense = transaction.type == TransactionType.expense;
    final categoryIcon = sl.financeController.getCategoryIcon(transaction.category);
    final accentColor = isExpense ? KineticVaultTheme.error : KineticVaultTheme.tertiary;

    String formattedSubtitle = transaction.date;
    try {
      final dateTime = DateTime.parse(transaction.date);
      formattedSubtitle = '${DateFormat('d MMM yyyy').format(dateTime)} @${DateFormat('HH:mm').format(dateTime)}';
    } catch (e) {
      // Fallback if parsing fails
    }

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
              icon: categoryIcon,
              color: accentColor,
              shape: AppIconShape.rounded,
              size: 48,
              opacity: 0.15,
              iconColor: accentColor,
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
                    formattedSubtitle,
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
                  '${isExpense ? "-" : "+"}${KineticVaultTheme.formatCurrencyShorthand(transaction.amount, isExpense: isExpense)}',
                  size: AppHeadingSize.subtitle,
                  color: isExpense ? KineticVaultTheme.onSurface : KineticVaultTheme.primary,
                  isBold: true,
                ),
                const SizedBox(height: KineticVaultTheme.spacingXs),
                AppHeading(
                  isExpense ? 'Expense' : 'Income',
                  size: AppHeadingSize.caption,
                  color: accentColor.withValues(alpha: 0.7),
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
