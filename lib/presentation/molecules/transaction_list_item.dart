import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/app_data.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.amount < 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KineticVaultTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: KineticVaultTheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isExpense ? Icons.coffee : Icons.shopping_bag,
              color: isExpense ? KineticVaultTheme.secondary : KineticVaultTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: KineticVaultTheme.onSurface,
                  ),
                ),
                Text(
                  '${transaction.date} • 09:41',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: KineticVaultTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isExpense ? "-" : "+"} ${KineticVaultTheme.formatCurrency(transaction.amount.abs())}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: KineticVaultTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
