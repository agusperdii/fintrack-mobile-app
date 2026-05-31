import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/controllers/budget_controller.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/controllers/auth_controller.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_icon_container.dart';

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
    final budgetController = context.watch<BudgetController>();
    
    // Use emoji from category object if available, otherwise fallback to budgetController lookup by name
    final categoryIcon = transaction.category?.emoji ?? 
                        budgetController.getCategoryIcon(transaction.category?.name ?? "");
    
    final accentColor = isExpense ? SavaioTheme.error : SavaioTheme.tertiary;

    // Handle background sync status feedback
    final isPending = transaction.syncStatus == SyncStatus.pending;
    final isFailed = transaction.syncStatus == SyncStatus.failed;
    final contentOpacity = (isPending || isFailed) ? 0.6 : 1.0;

    String formattedSubtitle = transaction.date.toIso8601String();
    try {
      final dateTime = transaction.date;
      formattedSubtitle = '${DateFormat('d MMM yyyy').format(dateTime)} @${DateFormat('HH:mm').format(dateTime)}';
    } catch (e) {
      // Fallback if parsing fails
    }

    return Opacity(
      opacity: contentOpacity,
      child: InkWell(
        onTap: isPending ? null : onTap, // Disable interaction while pending
        borderRadius: BorderRadius.circular(SavaioTheme.radiusL),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SavaioTheme.spacingM,
            vertical: SavaioTheme.spacingM,
          ),
          decoration: BoxDecoration(
            color: SavaioTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(SavaioTheme.radiusL),
            border: isFailed ? Border.all(color: SavaioTheme.error.withValues(alpha: 0.3)) : null,
          ),
          child: Row(
            children: [
              AppIconContainer(
                icon: isFailed ? Icons.sync_problem_rounded : categoryIcon,
                color: isFailed ? SavaioTheme.error : accentColor,
                shape: AppIconShape.rounded,
                size: 48,
                opacity: 0.15,
                iconColor: isFailed ? SavaioTheme.error : accentColor,
              ),
              const SizedBox(width: SavaioTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppHeading(
                            transaction.title,
                            size: AppHeadingSize.subtitle,
                            isBold: true,
                          ),
                        ),
                        if (isPending)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2, color: SavaioTheme.primary),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: SavaioTheme.spacingXs),
                    AppHeading(
                      isFailed ? 'Gagal sinkronisasi' : formattedSubtitle,
                      size: AppHeadingSize.caption,
                      color: isFailed ? SavaioTheme.error : SavaioTheme.onSurfaceVariant,
                      isBold: false,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppHeading(
                    '${isExpense ? "-" : "+"}${SavaioTheme.formatCurrencyShorthand(transaction.amount, isExpense: isExpense, currency: context.watch<AuthController>().currency)}',
                    size: AppHeadingSize.subtitle,
                    color: isFailed ? SavaioTheme.error : (isExpense ? SavaioTheme.onSurface : SavaioTheme.primary),
                    isBold: true,
                  ),
                  const SizedBox(height: SavaioTheme.spacingXs),
                  AppHeading(
                    isExpense ? 'Expense' : 'Income',
                    size: AppHeadingSize.caption,
                    color: isFailed ? SavaioTheme.error.withValues(alpha: 0.7) : accentColor.withValues(alpha: 0.7),
                    isBold: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
