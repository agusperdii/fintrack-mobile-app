import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
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
              return AppTransactionItem(
                transaction: tx,
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
