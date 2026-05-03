import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_icon_container.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';

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
        backgroundColor: SavaioTheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Transaksi?', style: GoogleFonts.inter(color: SavaioTheme.onSurface, fontWeight: FontWeight.bold)),
        content: Text('Transaksi ini akan dihapus secara permanen dari catatan keuangan Anda.', style: GoogleFonts.inter(color: SavaioTheme.onSurfaceVariant, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: SavaioTheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus', style: TextStyle(color: SavaioTheme.error, fontWeight: FontWeight.bold)),
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
            backgroundColor: SavaioTheme.error,
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
      backgroundColor: SavaioTheme.background,
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
                color: SavaioTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: SavaioTheme.outlineVariant.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  AppIconContainer(
                    icon: isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
                    color: isIncome ? SavaioTheme.tertiary : SavaioTheme.error,
                    size: 64,
                    opacity: 0.15,
                  ),
                  const SizedBox(height: 20),
                  AppHeading(
                    '${isIncome ? "+" : "-"}${SavaioTheme.formatCurrency(transaction.amount)}',
                    size: AppHeadingSize.h1,
                    color: isIncome ? SavaioTheme.tertiary : SavaioTheme.onSurface,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isIncome ? 'Pemasukan Berhasil' : 'Pengeluaran Berhasil',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: SavaioTheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // Details Section
            AppHeading('INFORMASI TRANSAKSI', size: AppHeadingSize.caption, color: SavaioTheme.primary, isBold: true),
            const SizedBox(height: 16),
            
            GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: 20,
              child: Column(
                children: [
                  _buildDetailItem(
                    icon: Icons.title_rounded, 
                    label: 'Judul Transaksi', 
                    value: transaction.title,
                    isFirst: true,
                  ),
                  if (transaction.description != null && transaction.description!.isNotEmpty)
                    _buildDetailItem(
                      icon: Icons.notes_rounded, 
                      label: 'Catatan', 
                      value: transaction.description!,
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
                  foregroundColor: SavaioTheme.error,
                  side: BorderSide(color: SavaioTheme.error.withValues(alpha: 0.5)),
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
            color: SavaioTheme.outlineVariant.withValues(alpha: 0.1),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AppIconContainer(
                icon: icon,
                color: SavaioTheme.primary,
                size: 40,
                opacity: 0.1,
                iconColor: SavaioTheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: SavaioTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: SavaioTheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
