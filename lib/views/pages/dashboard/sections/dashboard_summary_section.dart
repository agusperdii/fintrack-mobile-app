import 'package:flutter/material.dart';
import 'package:savaio/others.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/views/components/organisms/app_balance_card.dart';
import 'package:savaio/views/pages/dashboard/dashboard_routes.dart';

class DashboardSummarySection extends StatelessWidget {
  final AppData? data;
  final bool isLoading;

  const DashboardSummarySection({
    super.key,
    this.data,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading || data == null) {
      return const AppBalanceCard(
        balanceText: 'Rp --.---.---',
        incomeText: 'Rp --.---',
        expenseText: 'Rp --.---',
        isLoading: true,
      );
    }

    return AppBalanceCard(
      balanceText: SavaioTheme.formatCurrency(data!.balance),
      incomeText: SavaioTheme.formatCurrency(data!.totalIncome),
      expenseText: SavaioTheme.formatCurrency(data!.totalExpense),
      onIncomeTap: () => DashboardRoutes.navigateToAddTransaction(context, type: 'Income'),
      onExpenseTap: () => DashboardRoutes.navigateToAddTransaction(context, type: 'Expense'),
    );
  }
}
