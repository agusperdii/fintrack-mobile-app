// app_balance_card.dart
// Kartu utama dashboard yang menampilkan saldo (saldo utama atau tabungan)
// beserta kontrol untuk berpindah tampilan dan menyembunyikan/menampilkan saldo.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/controllers/auth_controller.dart';
import 'package:savaio/controllers/dashboard_controller.dart';

class AppBalanceCard extends StatelessWidget {
  final double balance;
  final double savingsBalance;
  final double income;
  final double expense;
  final bool isLoading;
  final VoidCallback? onIncomeTap;
  final VoidCallback? onExpenseTap;

  const AppBalanceCard({
    super.key,
    required this.balance,
    this.savingsBalance = 0.0,
    required this.income,
    required this.expense,
    this.isLoading = false,
    this.onIncomeTap,
    this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<AuthController>().currency;
    final dashboardController = context.watch<DashboardController>();
    final isVisible = dashboardController.isBalanceVisible;
    final isShowingSavings = dashboardController.isShowingSavingsBalance;
    
    final symbol = currency == 'USD' ? r'$' : (currency == 'IDR' ? 'Rp' : currency);
    final placeholderNum = currency == 'USD' ? '--.--' : '--.---.---';
    final maskedBalanceNum = '**********';

    final displayBalance = isShowingSavings ? savingsBalance : balance;
    final formattedNumber = isVisible 
      ? SavaioTheme.formatCurrency(displayBalance, currency: currency).replaceAll(symbol, '').trim() 
      : maskedBalanceNum;

    final displayNum = isLoading ? placeholderNum : formattedNumber;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SavaioTheme.spacing2xl),
      decoration: BoxDecoration(
        color: SavaioTheme.primaryOf(context).withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(SavaioTheme.radiusXl),
        border: Border.all(
          color: SavaioTheme.primaryOf(context).withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: SavaioTheme.primaryOf(context).withValues(alpha: 0.05),
            blurRadius: 32,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 236,
            height: 44,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: SavaioTheme.surfaceContainerLowOf(context).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(SavaioTheme.radiusL),
              border: Border.all(
                color: SavaioTheme.outlineVariantOf(context).withValues(alpha: 0.3),
              ),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  alignment: isShowingSavings ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 114,
                    decoration: BoxDecoration(
                      color: SavaioTheme.primaryOf(context),
                      borderRadius: BorderRadius.circular(SavaioTheme.radiusL),
                      boxShadow: [
                        BoxShadow(
                          color: SavaioTheme.primaryOf(context).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (isShowingSavings) dashboardController.toggleBalanceType();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Text(
                            'Saldo Utama',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: !isShowingSavings ? FontWeight.w700 : FontWeight.w600,
                              color: !isShowingSavings ? SavaioTheme.onPrimaryFixedOf(context) : SavaioTheme.onSurfaceVariantOf(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!isShowingSavings) dashboardController.toggleBalanceType();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Text(
                            'Tabungan',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: isShowingSavings ? FontWeight.w700 : FontWeight.w600,
                              color: isShowingSavings ? SavaioTheme.onPrimaryFixedOf(context) : SavaioTheme.onSurfaceVariantOf(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: SavaioTheme.spacingXl),
          InkWell(
            onTap: () => dashboardController.toggleBalanceVisibility(),
            borderRadius: BorderRadius.circular(SavaioTheme.radiusS),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isShowingSavings ? 'Total Tabungan' : 'Total Saldo',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: SavaioTheme.onSurfaceVariantOf(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, 
                    color: SavaioTheme.onSurfaceVariantOf(context), 
                    size: 16
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: SavaioTheme.spacingM),
          FittedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, right: 6.0),
                  child: Text(
                    symbol,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: SavaioTheme.onSurfaceOf(context).withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Text(
                  displayNum,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: SavaioTheme.onSurfaceOf(context),
                    height: 1.1,
                    letterSpacing: -1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
