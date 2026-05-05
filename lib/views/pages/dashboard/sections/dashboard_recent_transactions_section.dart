import 'package:flutter/material.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/views/components/organisms/dashboard_recent_transactions.dart';
import 'package:savaio/views/pages/dashboard/dashboard_routes.dart';

class DashboardRecentTransactionsSection extends StatelessWidget {
  final List<Transaction> transactions;
  final bool isLoading;

  const DashboardRecentTransactionsSection({
    super.key,
    required this.transactions,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardRecentTransactions(
      transactions: transactions,
      onViewAllTap: () => DashboardRoutes.navigateToAllTransactions(context, transactions),
      onTransactionTap: (tx) => DashboardRoutes.navigateToTransactionDetail(context, tx),
      isLoading: isLoading,
    );
  }
}
