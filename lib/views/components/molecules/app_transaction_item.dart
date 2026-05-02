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
    final accentColor = isExpense ? SavaioTheme.error : SavaioTheme.tertiary;

    String formattedSubtitle = transaction.date;
    try {
      final dateTime = DateTime.parse(transaction.date);
      formattedSubtitle = '${DateFormat('d MMM yyyy').format(dateTime)} @${DateFormat('HH:mm').format(dateTime)}';
    } catch (e) {
      // Fallback if parsing fails
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SavaioTheme.radiusL),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SavaioTheme.spacingM,
          vertical: SavaioTheme.spacingM,
        ),
        decoration: BoxDecoration(
          color: SavaioTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(SavaioTheme.radiusL),
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
            const SizedBox(width: SavaioTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppHeading(
                    transaction.title,
                    size: AppHeadingSize.subtitle,
                    isBold: true,
                  ),
                  const SizedBox(height: SavaioTheme.spacingXs),
                  AppHeading(
                    formattedSubtitle,
                    size: AppHeadingSize.caption,
                    color: SavaioTheme.onSurfaceVariant,
                    isBold: false,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppHeading(
                  '${isExpense ? "-" : "+"}${SavaioTheme.formatCurrencyShorthand(transaction.amount, isExpense: isExpense)}',
                  size: AppHeadingSize.subtitle,
                  color: isExpense ? SavaioTheme.onSurface : SavaioTheme.primary,
                  isBold: true,
                ),
                const SizedBox(height: SavaioTheme.spacingXs),
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
