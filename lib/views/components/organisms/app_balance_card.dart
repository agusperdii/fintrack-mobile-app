import 'package:flutter/material.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/molecules/app_balance_mini_item.dart';

class AppBalanceCard extends StatelessWidget {
  final String balanceText;
  final String incomeText;
  final String expenseText;
  final bool isLoading;
  final VoidCallback? onIncomeTap;
  final VoidCallback? onExpenseTap;
  final String labelText;

  const AppBalanceCard({
    super.key,
    required this.balanceText,
    required this.incomeText,
    required this.expenseText,
    this.isLoading = false,
    this.onIncomeTap,
    this.onExpenseTap,
    this.labelText = 'TOTAL SALDO ANDA',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      container: true,
      label: 'Balance Card',
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 32,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppHeading(
                  labelText.toUpperCase(),
                  size: AppHeadingSize.caption,
                  color: colorScheme.onSurfaceVariant,
                  isBold: true,
                ),
                Icon(Icons.wallet_rounded, color: colorScheme.primary, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            AppHeading(
              balanceText,
              size: AppHeadingSize.h1,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppBalanceMiniItem(
                  label: 'Pemasukan',
                  amount: incomeText,
                  icon: Icons.south_west_rounded,
                  color: colorScheme.tertiary,
                  onTap: onIncomeTap,
                ),
                AppBalanceMiniItem(
                  label: 'Pengeluaran',
                  amount: expenseText,
                  icon: Icons.north_east_rounded,
                  color: colorScheme.error,
                  onTap: onExpenseTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
