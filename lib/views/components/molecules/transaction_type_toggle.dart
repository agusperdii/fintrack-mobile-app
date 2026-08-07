// transaction_type_toggle.dart
// Widget molecule toggle untuk memilih jenis transaksi (Pengeluaran,
// Pemasukan, Tabungan) dalam bentuk chip yang dapat dipilih.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savaio/core/theme/app_theme.dart';

class TransactionTypeToggle extends StatelessWidget {
  final String currentType;
  final Function(String) onTypeChanged;

  const TransactionTypeToggle({
    super.key,
    required this.currentType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _buildToggleItem(
          context: context,
          label: 'Pengeluaran',
          icon: Icons.arrow_outward,
          isActive: currentType == 'Expense',
          activeColor: isDark ? SavaioTheme.errorContainer : SavaioTheme.lightErrorContainer,
          activeTextColor: isDark ? Colors.white : SavaioTheme.lightOnSurface,
          onTap: () => onTypeChanged('Expense'),
        ),
        _buildToggleItem(
          context: context,
          label: 'Pemasukan',
          icon: Icons.south_west,
          isActive: currentType == 'Income',
          activeColor: SavaioTheme.surfaceContainerHighestOf(context),
          activeTextColor: isDark ? Colors.white : SavaioTheme.lightOnSurface,
          onTap: () => onTypeChanged('Income'),
        ),
        _buildToggleItem(
          context: context,
          label: 'Tabungan',
          icon: Icons.savings_outlined,
          isActive: currentType == 'Savings',
          activeColor: SavaioTheme.primaryOf(context).withValues(alpha: 0.2),
          activeTextColor: isDark ? Colors.white : SavaioTheme.lightOnSurface,
          onTap: () => onTypeChanged('Savings'),
        ),
      ],
    );
  }

  Widget _buildToggleItem({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required Color activeTextColor,
    required VoidCallback onTap,
  }) {
    final onSurfaceVariant = SavaioTheme.onSurfaceVariantOf(context);
    final bgColor = isActive ? activeColor : SavaioTheme.surfaceContainerLowOf(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(SavaioTheme.radiusL),
          border: Border.all(
            color: isActive ? activeTextColor.withValues(alpha: 0.1) : Colors.transparent,
            width: 1,
          ),
          boxShadow: isActive ? [
            BoxShadow(
              color: activeColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? activeTextColor : onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? activeTextColor : onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
