import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/controllers/auth_controller.dart';
import 'package:savaio/controllers/dashboard_controller.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

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
    final dashboardController = context.watch<DashboardController>();
    final isVisible = dashboardController.isBalanceVisible;
    
    final placeholder = currency == 'USD' ? r'$ --.--' : (currency == 'IDR' ? 'Rp --.---.---' : '$currency --.--');
    final maskedBalance = currency == 'USD' ? r'$ *****' : (currency == 'IDR' ? 'Rp **********' : '$currency *****');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SavaioTheme.spacingXl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(SavaioTheme.radiusXl),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => dashboardController.toggleBalanceVisibility(),
            borderRadius: BorderRadius.circular(SavaioTheme.radiusS),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppHeading(
                    'TOTAL SALDO ANDA'.toUpperCase(),
                    size: AppHeadingSize.caption,
                    color: SavaioTheme.onSurfaceVariant,
                    isBold: true,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, 
                    color: SavaioTheme.onSurfaceVariant, 
                    size: 16
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: SavaioTheme.spacingS),
          FittedBox(
            child: Text(
              isLoading 
                  ? placeholder 
                  : (isVisible ? SavaioTheme.formatCurrency(balance, currency: currency) : maskedBalance),
              style: GoogleFonts.inter(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: SavaioTheme.onSurfaceOf(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
