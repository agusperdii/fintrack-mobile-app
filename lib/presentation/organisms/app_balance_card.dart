import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../atoms/glass_card.dart';
import '../atoms/app_heading.dart';
import '../molecules/app_balance_mini_item.dart';

class AppBalanceCard extends StatelessWidget {
  final double balance;

  const AppBalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppHeading(
                'TOTAL SALDO ANDA',
                size: AppHeadingSize.caption,
                color: KineticVaultTheme.onSurfaceVariant,
                isBold: false,
              ),
              Icon(Icons.wallet, color: KineticVaultTheme.primary, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          AppHeading(
            KineticVaultTheme.formatCurrency(balance),
            size: AppHeadingSize.h1,
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppBalanceMiniItem(
                label: 'Pemasukan',
                amount: 'Rp12.450.000',
                icon: Icons.south_west,
                color: KineticVaultTheme.tertiary,
              ),
              AppBalanceMiniItem(
                label: 'Pengeluaran',
                amount: 'Rp5.200.000',
                icon: Icons.north_east,
                color: KineticVaultTheme.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
