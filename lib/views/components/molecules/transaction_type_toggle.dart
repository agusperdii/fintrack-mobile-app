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
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainerLowOf(context),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          _buildToggleItem(
            context: context,
            label: 'Pengeluaran',
            icon: Icons.arrow_outward,
            isActive: currentType == 'Expense',
            activeColor: SavaioTheme.errorContainer,
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
        ],
      ),
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive ? activeTextColor : onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isActive ? activeTextColor : onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
