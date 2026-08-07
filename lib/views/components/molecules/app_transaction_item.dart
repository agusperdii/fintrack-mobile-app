// app_transaction_item.dart
// Widget molecule untuk menampilkan satu baris item transaksi (judul,
// kategori, waktu, nominal) beserta status sinkronisasinya.

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
    final isSavings = transaction.type == TransactionType.savings;
    final budgetController = context.watch<BudgetController>();
    
    final isSavingsWithdrawal = isSavings && transaction.amount < 0;
    final isAutoWithdrawal = isSavingsWithdrawal && transaction.source.toLowerCase() == 'system';
    
    // Gunakan emoji dari objek category jika tersedia, jika tidak gunakan
    // hasil lookup dari budgetController berdasarkan id
    final categoryIcon = transaction.category?.emoji ??
                        budgetController.getCategoryIcon(transaction.categoryId);
    
    final accentColor = isSavingsWithdrawal
        ? colorScheme.error
        : (isExpense 
            ? colorScheme.error 
            : (isSavings ? SavaioTheme.successOf(context) : colorScheme.tertiary));

    // Status untuk feedback proses sinkronisasi data di background
    final isPending = transaction.syncStatus == SyncStatus.pending;
    final isSyncing = transaction.syncStatus == SyncStatus.syncing;
    final isFailed = transaction.syncStatus == SyncStatus.failed;
    final isSynced = transaction.syncStatus == SyncStatus.synced;
    
    final contentOpacity = (!isSynced) ? 0.6 : 1.0;
    final isTemp = transaction.id.startsWith('temp_');

    String formattedSubtitle = transaction.date.toIso8601String();
    try {
      final dateTime = transaction.date;
      final categoryName = transaction.category?.name ?? budgetController.getCategoryName(transaction.categoryId);
      if (isAutoWithdrawal) {
        formattedSubtitle = '${DateFormat('HH:mm').format(dateTime)} • Tabungan ➔ Utama';
      } else if (isSavings && transaction.amount > 0) {
        formattedSubtitle = '${DateFormat('HH:mm').format(dateTime)} • Utama ➔ Tabungan';
      } else {
        formattedSubtitle = '${DateFormat('HH:mm').format(dateTime)} • $categoryName';
      }
    } catch (e) {
      // Fallback jika parsing gagal
    }

    return Opacity(
      opacity: contentOpacity,
      child: InkWell(
        // Izinkan tap pada transaksi penarikan (withdrawal)
        onTap: (isTemp || !isSynced) ? null : onTap,
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
              color: isFailed 
                  ? colorScheme.error.withValues(alpha: 0.5) 
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              AppIconContainer(
                icon: isFailed ? Icons.sync_problem_rounded : (isAutoWithdrawal ? Icons.auto_awesome_rounded : categoryIcon),
                color: isFailed || isSavingsWithdrawal 
                    ? colorScheme.error 
                    : (isSavings ? SavaioTheme.successOf(context) : colorScheme.surfaceContainerHighest),
                shape: AppIconShape.rounded,
                size: 48,
                opacity: (isSavingsWithdrawal || isSavings) ? 0.15 : 1.0,
                iconColor: isFailed || isSavingsWithdrawal ? colorScheme.error : accentColor,
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
                isAutoWithdrawal
                    ? '➔ ${SavaioTheme.formatCurrency(transaction.amount.abs(), currency: context.watch<AuthController>().currency)}'
                    : '${isExpense ? "-" : (isSavingsWithdrawal ? "-" : (isSavings ? "+" : "+"))}${SavaioTheme.formatCurrency(transaction.amount.abs(), currency: context.watch<AuthController>().currency)}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isFailed 
                      ? colorScheme.error 
                      : (isSavingsWithdrawal ? colorScheme.error : (isSavings ? SavaioTheme.successOf(context) : colorScheme.onSurface)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
