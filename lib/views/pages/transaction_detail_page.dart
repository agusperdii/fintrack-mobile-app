import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/service_locator.dart';
import '../../models/entities/app_data.dart';
import '../components/organisms/app_header.dart';
import '../components/atoms/app_heading.dart';
import '../components/atoms/app_icon_container.dart';
import '../components/atoms/glass_card.dart';

class TransactionDetailPage extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: KineticVaultTheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Transaksi?', style: GoogleFonts.inter(color: KineticVaultTheme.onSurface, fontWeight: FontWeight.bold)),
        content: Text('Transaksi ini akan dihapus secara permanen dari catatan keuangan Anda.', style: GoogleFonts.inter(color: KineticVaultTheme.onSurfaceVariant, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: KineticVaultTheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus', style: TextStyle(color: KineticVaultTheme.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && transaction.id != null) {
      final success = await sl.financeController.deleteTransaction(transaction.id!);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil dihapus'), 
            backgroundColor: KineticVaultTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;

    return Scaffold(
      backgroundColor: KineticVaultTheme.background,
      appBar: AppHeader(title: 'Detail Transaksi', showBackButton: true, showNotification: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Amount Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: KineticVaultTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: KineticVaultTheme.outlineVariant.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  AppIconContainer(
                    icon: isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
                    color: isIncome ? KineticVaultTheme.tertiary : KineticVaultTheme.error,
                    size: 64,
                    opacity: 0.15,
                  ),
                  const SizedBox(height: 20),
                  AppHeading(
                    '${isIncome ? "+" : "-"}${KineticVaultTheme.formatCurrency(transaction.amount)}',
                    size: AppHeadingSize.h1,
                    color: isIncome ? KineticVaultTheme.tertiary : KineticVaultTheme.onSurface,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isIncome ? 'Pemasukan Berhasil' : 'Pengeluaran Berhasil',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: KineticVaultTheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // Details Section
            AppHeading('INFORMASI TRANSAKSI', size: AppHeadingSize.caption, color: KineticVaultTheme.primary, isBold: true),
            const SizedBox(height: 16),
            
            GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: 20,
              child: Column(
                children: [
                  _buildDetailItem(
                    icon: Icons.notes_rounded, 
                    label: 'Keterangan', 
                    value: transaction.title,
                    isFirst: true,
                  ),
                  _buildDetailItem(
                    icon: Icons.category_rounded, 
                    label: 'Kategori', 
                    value: transaction.category,
                  ),
                  _buildDetailItem(
                    icon: Icons.calendar_today_rounded, 
                    label: 'Waktu & Tanggal', 
                    value: _formatDate(transaction.date),
                  ),
                  _buildDetailItem(
                    icon: Icons.account_balance_wallet_rounded, 
                    label: 'Sumber Dana', 
                    value: transaction.source ?? 'Dompet Utama',
                  ),
                  if (transaction.id != null)
                    _buildDetailItem(
                      icon: Icons.tag_rounded, 
                      label: 'ID Transaksi', 
                      value: transaction.id!.split('-').first.toUpperCase(),
                      isLast: true,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Actions
            if (transaction.id != null)
              OutlinedButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                label: const Text('HAPUS DATA INI'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: KineticVaultTheme.error,
                  side: BorderSide(color: KineticVaultTheme.error.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  textStyle: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.1),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon, 
    required String label, 
    required String value,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        if (!isFirst) 
          Divider(
            height: 1, 
            indent: 56, 
            endIndent: 20, 
            color: KineticVaultTheme.outlineVariant.withValues(alpha: 0.1),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AppIconContainer(
                icon: icon,
                color: KineticVaultTheme.primary,
                size: 40,
                opacity: 0.1,
                iconColor: KineticVaultTheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: KineticVaultTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: 180,
                    child: Text(
                      value,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: KineticVaultTheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
