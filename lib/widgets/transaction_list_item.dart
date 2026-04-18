import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../theme/kinetic_vault_theme.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.amount > 0;
    final accentColor = isIncome ? KineticVaultTheme.tertiary : KineticVaultTheme.error;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: accentColor.withValues(alpha: 0.1),
        child: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: accentColor,
        ),
      ),
      title: Text(
        transaction.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${transaction.category} • ${transaction.date}',
        style: TextStyle(color: KineticVaultTheme.onSurfaceVariant),
      ),
      trailing: Text(
        'Rp ${transaction.amount.abs().toStringAsFixed(0)}',
        style: TextStyle(
          color: accentColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
