import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/service_locator.dart';
import '../../models/entities/app_data.dart';
import '../components/organisms/app_header.dart';

class TransactionDetailPage extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  String _formatAmount(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: KineticVaultTheme.surfaceContainerHigh,
        title: Text('Hapus Transaksi?', style: GoogleFonts.plusJakartaSans(color: KineticVaultTheme.onSurface, fontWeight: FontWeight.bold)),
        content: Text('Transaksi ini akan dihapus permanen.', style: GoogleFonts.inter(color: KineticVaultTheme.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: KineticVaultTheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus', style: TextStyle(color: KineticVaultTheme.error)),
          ),
        ],
      ),
    );

    if (confirm == true && transaction.id != null) {
      final success = await sl.financeController.deleteTransaction(transaction.id!);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil dihapus'), backgroundColor: KineticVaultTheme.tertiary),
        );
        Navigator.pop(context, true); // Return true to signal deletion
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;

    return Scaffold(
      backgroundColor: KineticVaultTheme.background,
      appBar: AppHeader(title: 'Detail Transaksi', showBackButton: true, showNotification: false),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Amount Hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isIncome
                      ? [KineticVaultTheme.tertiary.withValues(alpha: 0.15), KineticVaultTheme.tertiary.withValues(alpha: 0.05)]
                      : [KineticVaultTheme.error.withValues(alpha: 0.15), KineticVaultTheme.error.withValues(alpha: 0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: (isIncome ? KineticVaultTheme.tertiary : KineticVaultTheme.error).withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isIncome ? KineticVaultTheme.tertiary : KineticVaultTheme.error).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      isIncome ? 'PEMASUKAN' : 'PENGELUARAN',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: isIncome ? KineticVaultTheme.tertiary : KineticVaultTheme.error),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _formatAmount(transaction.amount),
                    style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w900, color: KineticVaultTheme.onSurface),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Detail rows
            _buildDetailCard([
              _DetailRow(icon: Icons.notes_rounded, label: 'Keterangan', value: transaction.title),
              _DetailRow(icon: Icons.category_rounded, label: 'Kategori', value: transaction.category),
              _DetailRow(icon: Icons.calendar_today_rounded, label: 'Tanggal', value: transaction.date),
              _DetailRow(icon: Icons.swap_vert_rounded, label: 'Tipe', value: isIncome ? 'Pemasukan' : 'Pengeluaran'),
              if (transaction.id != null)
                _DetailRow(icon: Icons.tag_rounded, label: 'ID', value: transaction.id!.substring(0, 8).toUpperCase()),
            ]),

            const Spacer(),

            // Delete button
            if (transaction.id != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text('Hapus Transaksi', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KineticVaultTheme.errorContainer,
                    foregroundColor: KineticVaultTheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(List<_DetailRow> rows) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: KineticVaultTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: rows.map((row) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(row.icon, size: 18, color: KineticVaultTheme.onSurfaceVariant),
              const SizedBox(width: 16),
              Text(row.label, style: GoogleFonts.inter(fontSize: 13, color: KineticVaultTheme.onSurfaceVariant)),
              const Spacer(),
              Flexible(child: Text(row.value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: KineticVaultTheme.onSurface), textAlign: TextAlign.end, maxLines: 2)),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

class _DetailRow {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});
}
