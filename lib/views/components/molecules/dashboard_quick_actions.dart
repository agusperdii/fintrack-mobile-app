import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'app_icon_button.dart';

class DashboardQuickActions extends StatelessWidget {
  final VoidCallback onIncomeTap;
  final VoidCallback onExpenseTap;
  final VoidCallback onScanTap;

  const DashboardQuickActions({
    super.key,
    required this.onIncomeTap,
    required this.onExpenseTap,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        AppIconButton(
          icon: Icons.add_rounded,
          label: 'Pemasukan',
          color: SavaioTheme.tertiary,
          onTap: onIncomeTap,
        ),
        AppIconButton(
          icon: Icons.receipt_long,
          label: 'Scan Struk',
          variant: AppIconButtonVariant.gradient,
          onTap: onScanTap,
        ),
        AppIconButton(
          icon: Icons.remove_rounded,
          label: 'Pengeluaran',
          color: SavaioTheme.error,
          onTap: onExpenseTap,
        ),
      ],
    );
  }
}
