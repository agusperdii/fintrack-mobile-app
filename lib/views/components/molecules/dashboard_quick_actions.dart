import 'package:flutter/material.dart';
import 'app_icon_button.dart';

class DashboardQuickActions extends StatelessWidget {
  final VoidCallback onIncomeTap;
  final VoidCallback onExpenseTap;
  final VoidCallback onScanTap;
  final String incomeLabel;
  final String expenseLabel;
  final String scanLabel;

  const DashboardQuickActions({
    super.key,
    required this.onIncomeTap,
    required this.onExpenseTap,
    required this.onScanTap,
    this.incomeLabel = 'Pemasukan',
    this.expenseLabel = 'Pengeluaran',
    this.scanLabel = 'Scan Struk',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        AppIconButton(
          icon: Icons.add_rounded,
          label: incomeLabel,
          color: colorScheme.tertiary,
          onTap: onIncomeTap,
        ),
        AppIconButton(
          icon: Icons.receipt_long,
          label: scanLabel,
          variant: AppIconButtonVariant.gradient,
          onTap: onScanTap,
        ),
        AppIconButton(
          icon: Icons.remove_rounded,
          label: expenseLabel,
          color: colorScheme.error,
          onTap: onExpenseTap,
        ),
      ],
    );
  }
}
