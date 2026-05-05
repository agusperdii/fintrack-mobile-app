import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:savaio/others.dart';
import 'package:savaio/models/app_data.dart';
import '../molecules/app_section_header.dart';
import '../molecules/app_transaction_item.dart';

class DashboardRecentTransactions extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback onViewAllTap;
  final Function(Transaction) onTransactionTap;
  final bool isLoading;

  const DashboardRecentTransactions({
    super.key,
    required this.transactions,
    required this.onViewAllTap,
    required this.onTransactionTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Riwayat Terbaru',
          actionLabel: 'Lihat Semua',
          onActionTap: onViewAllTap,
        ),
        const SizedBox(height: 16),
        if (isLoading)
          _buildSkeleton()
        else if (transactions.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Belum ada transaksi', style: TextStyle(color: SavaioTheme.onSurfaceVariant)),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length > 5 ? 5 : transactions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final isExpense = tx.type == TransactionType.expense;
              final accentColor = isExpense ? theme.colorScheme.error : theme.colorScheme.tertiary;
              
              String subtitle = tx.date;
              try {
                final dt = DateTime.parse(tx.date);
                subtitle = '${DateFormat('d MMM yyyy').format(dt)} @${DateFormat('HH:mm').format(dt)}';
              } catch (_) {}

              return AppTransactionItem(
                title: tx.title,
                subtitle: subtitle,
                icon: sl.financeController.getCategoryIcon(tx.category),
                amountText: '${isExpense ? "-" : "+"}${SavaioTheme.formatCurrencyShorthand(tx.amount, isExpense: isExpense)}',
                amountColor: isExpense ? theme.colorScheme.onSurface : theme.colorScheme.primary,
                statusText: isExpense ? 'Expense' : 'Income',
                statusColor: accentColor.withValues(alpha: 0.7),
                iconBgColor: accentColor,
                onTap: () => onTransactionTap(tx),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: List.generate(3, (index) => Container(
        height: 70,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: SavaioTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
      )),
    );
  }
}
