// dashboard_recent_transactions.dart
// Menampilkan daftar transaksi terbaru di dashboard, termasuk state kosong
// dan skeleton loading saat data belum tersedia.

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
          title: 'Riwayat Hari ini',
          actionLabel: 'Lihat Semua',
          onActionTap: onViewAllTap,
        ),
        const SizedBox(height: 16),
        if (isLoading)
          _buildSkeleton()
        else if (transactions.isEmpty)
          Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: SavaioTheme.surfaceContainerLowOf(context).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(SavaioTheme.radiusXl),
                border: Border.all(
                  color: SavaioTheme.outlineVariantOf(context).withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: SavaioTheme.primaryOf(context).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: SavaioTheme.primaryOf(context).withValues(alpha: 0.7),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada transaksi',
                    style: TextStyle(
                      color: SavaioTheme.onSurfaceOf(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Transaksi terbarumu akan muncul di sini',
                    style: TextStyle(
                      color: SavaioTheme.onSurfaceVariantOf(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
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
