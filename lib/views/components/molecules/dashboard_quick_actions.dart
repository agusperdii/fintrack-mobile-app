// dashboard_quick_actions.dart
// Widget molecule berisi tiga tombol aksi cepat di dashboard (Income,
// Scan, Expense) menggunakan AppIconButton.

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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppIconButton(
          icon: Icons.south_west_rounded,
          label: 'Income',
          color: SavaioTheme.tertiaryOf(context),
          onTap: onIncomeTap,
        ),
        AppIconButton(
          icon: Icons.qr_code_scanner_rounded,
          label: 'Scan',
          variant: AppIconButtonVariant.gradient,
          onTap: onScanTap,
        ),
        AppIconButton(
          icon: Icons.north_east_rounded,
          label: 'Expense',
          color: SavaioTheme.errorOf(context),
          onTap: onExpenseTap,

        ),
      ],
    );
  }
}
