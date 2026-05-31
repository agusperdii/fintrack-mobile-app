import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/controllers/auth_controller.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/molecules/app_balance_mini_item.dart';

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
    final currency = context.watch<AuthController>().currency;
    final placeholder = currency == 'USD' ? r'$ --.--' : (currency == 'IDR' ? 'Rp --.---.---' : '$currency --.--');
    final placeholderSmall = currency == 'USD' ? r'$ --.--' : (currency == 'IDR' ? 'Rp --.---' : '$currency --.--');

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
            isLoading ? placeholder : SavaioTheme.formatCurrency(balance, currency: currency),
            size: AppHeadingSize.h1,
          ),
          const SizedBox(height: SavaioTheme.spacingXl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppBalanceMiniItem(
                label: 'Pemasukan',
                amount: isLoading ? placeholderSmall : SavaioTheme.formatCurrency(income, currency: currency),
                icon: Icons.south_west_rounded,
                color: SavaioTheme.tertiary,
                onTap: onIncomeTap,
              ),
              AppBalanceMiniItem(
                label: 'Pengeluaran',
                amount: isLoading ? placeholderSmall : SavaioTheme.formatCurrency(expense, currency: currency),
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
