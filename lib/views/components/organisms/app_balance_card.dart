import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../atoms/glass_card.dart';
import '../atoms/app_heading.dart';
import '../molecules/app_balance_mini_item.dart';

class AppBalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;
  final bool isLoading;
  final VoidCallback? onIncomeTap;
  final VoidCallback? onExpenseTap;

  const AppBalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
    this.isLoading = false,
    this.onIncomeTap,
    this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(SavaioTheme.spacingXl),
      borderRadius: SavaioTheme.radius2xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppHeading(
                'TOTAL SALDO ANDA'.toUpperCase(),
                size: AppHeadingSize.caption,
                color: SavaioTheme.onSurfaceVariant,
                isBold: true,
              ),
              const Icon(Icons.wallet_rounded, color: SavaioTheme.primary, size: 20),
            ],
          ),
          const SizedBox(height: SavaioTheme.spacingS),
          AppHeading(
            isLoading ? 'Rp --.---.---' : SavaioTheme.formatCurrency(balance),
            size: AppHeadingSize.h1,
          ),
          const SizedBox(height: SavaioTheme.spacingXl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppBalanceMiniItem(
                label: 'Pemasukan',
                amount: isLoading ? 'Rp --.---' : SavaioTheme.formatCurrency(income),
                icon: Icons.south_west_rounded,
                color: SavaioTheme.tertiary,
                onTap: onIncomeTap,
              ),
              AppBalanceMiniItem(
                label: 'Pengeluaran',
                amount: isLoading ? 'Rp --.---' : SavaioTheme.formatCurrency(expense),
                icon: Icons.north_east_rounded,
                color: SavaioTheme.error,
                onTap: onExpenseTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
