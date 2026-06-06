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
    final colorScheme = Theme.of(context).colorScheme;
    final isExpense = transaction.type == TransactionType.expense;
    final budgetController = context.watch<BudgetController>();
    
    // Use emoji from category object if available, otherwise fallback to budgetController lookup by id
    final categoryIcon = transaction.category?.emoji ?? 
                        budgetController.getCategoryIcon(transaction.categoryId);
    
    final accentColor = isExpense ? colorScheme.error : colorScheme.tertiary;

    // Handle background sync status feedback
    final isPending = transaction.syncStatus == SyncStatus.pending;
    final isSyncing = transaction.syncStatus == SyncStatus.syncing;
    final isFailed = transaction.syncStatus == SyncStatus.failed;
    final isSynced = transaction.syncStatus == SyncStatus.synced;
    
    final contentOpacity = (!isSynced) ? 0.6 : 1.0;

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
        onTap: !isSynced ? null : onTap, // Disable interaction unless fully synced
        borderRadius: BorderRadius.circular(SavaioTheme.radiusL),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SavaioTheme.spacingM,
            vertical: SavaioTheme.spacingM,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(SavaioTheme.radiusL),
            border: isFailed ? Border.all(color: colorScheme.error.withValues(alpha: 0.3)) : null,
          ),
          child: Row(
            children: [
              AppIconContainer(
                icon: isFailed ? Icons.sync_problem_rounded : categoryIcon,
                color: isFailed ? colorScheme.error : accentColor,
                shape: AppIconShape.rounded,
                size: 48,
                opacity: 0.15,
                iconColor: isFailed ? colorScheme.error : accentColor,
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
                        if (isPending || isSyncing)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: SavaioTheme.spacingXs),
                    AppHeading(
                      isFailed ? 'Gagal sinkronisasi' : formattedSubtitle,
                      size: AppHeadingSize.caption,
                      color: isFailed ? colorScheme.error : colorScheme.onSurfaceVariant,
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
                    color: isFailed ? colorScheme.error : (isExpense ? colorScheme.onSurface : colorScheme.primary),
                    isBold: true,
                  ),
                  const SizedBox(height: SavaioTheme.spacingXs),
                  AppHeading(
                    isExpense ? 'Expense' : 'Income',
                    size: AppHeadingSize.caption,
                    color: isFailed ? colorScheme.error.withValues(alpha: 0.7) : accentColor.withValues(alpha: 0.7),
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
