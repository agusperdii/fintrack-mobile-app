import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/controllers/budget_controller.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/controllers/auth_controller.dart';
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
      final categoryName = transaction.category?.name ?? budgetController.getCategoryName(transaction.categoryId);
      formattedSubtitle = '${DateFormat('HH:mm').format(dateTime)} • $categoryName';
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
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(SavaioTheme.radiusL),
            border: Border.all(
              color: isFailed ? colorScheme.error.withValues(alpha: 0.5) : colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              AppIconContainer(
                icon: isFailed ? Icons.sync_problem_rounded : categoryIcon,
                color: isFailed ? colorScheme.error : colorScheme.surfaceContainerHighest,
                shape: AppIconShape.rounded,
                size: 48,
                opacity: 1.0,
                iconColor: isFailed ? colorScheme.onError : accentColor,
              ),
              const SizedBox(width: SavaioTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            transaction.title,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
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
                    Text(
                      isFailed ? 'Gagal sinkronisasi' : formattedSubtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isFailed ? colorScheme.error : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isExpense ? "-" : "+"}${SavaioTheme.formatCurrency(transaction.amount, currency: context.watch<AuthController>().currency)}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isFailed ? colorScheme.error : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
