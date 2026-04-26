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

  const AppBalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(KineticVaultTheme.spacingXl),
      borderRadius: KineticVaultTheme.radius2xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppHeading(
                'TOTAL SALDO ANDA'.toUpperCase(),
                size: AppHeadingSize.caption,
                color: KineticVaultTheme.onSurfaceVariant,
                isBold: true,
              ),
              const Icon(Icons.wallet_rounded, color: KineticVaultTheme.primary, size: 20),
            ],
          ),
          const SizedBox(height: KineticVaultTheme.spacingS),
          AppHeading(
            isLoading ? 'Rp --.---.---' : KineticVaultTheme.formatCurrency(balance),
            size: AppHeadingSize.h1,
          ),
          const SizedBox(height: KineticVaultTheme.spacingXl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppBalanceMiniItem(
                label: 'Pemasukan',
                amount: isLoading ? 'Rp --.---' : KineticVaultTheme.formatCurrency(income),
                icon: Icons.south_west_rounded,
                color: KineticVaultTheme.tertiary,
              ),
              AppBalanceMiniItem(
                label: 'Pengeluaran',
                amount: isLoading ? 'Rp --.---' : KineticVaultTheme.formatCurrency(expense),
                icon: Icons.north_east_rounded,
                color: KineticVaultTheme.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
