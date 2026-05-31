import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/controllers/auth_controller.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_icon_container.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';

class TransactionDetailPage extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  bool _isDeleting = false;

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _handleDelete() async {
    if (_isDeleting) return;

    final confirm = await _showConfirmDialog();
    if (confirm != true || !mounted) return;

    setState(() => _isDeleting = true);

    // 1. Optimistic Feedback: Show SnackBar immediately
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Menghapus transaksi...'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );

    // 2. Instant Close: Pop page immediately
    if (mounted) {
      Navigator.pop(context, true);
    }

    // 3. Background Processing: Delete and refresh dashboard
    sl.transactionController.deleteTransaction(
      widget.transaction.id,
      dashboardController: sl.dashboardController,
    ).then((success) {
      if (success) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil dihapus'),
            backgroundColor: SavaioTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus transaksi. Silakan coba lagi.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        bool dialogLoading = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: SavaioTheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Hapus Transaksi?', 
                style: GoogleFonts.inter(color: SavaioTheme.onSurface, fontWeight: FontWeight.bold)
              ),
              content: Text(
                'Transaksi ini akan dihapus secara permanen dari catatan keuangan Anda.', 
                style: GoogleFonts.inter(color: SavaioTheme.onSurfaceVariant, fontSize: 14)
              ),
              actions: [
                TextButton(
                  onPressed: dialogLoading ? null : () => Navigator.pop(ctx, false),
                  child: Text('Batal', style: TextStyle(color: SavaioTheme.onSurfaceVariant)),
                ),
                TextButton(
                  onPressed: dialogLoading ? null : () {
                    setDialogState(() => dialogLoading = true);
                    Navigator.pop(ctx, true);
                  },
                  child: dialogLoading 
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: SavaioTheme.error)
                      )
                    : Text('Hapus', style: TextStyle(color: SavaioTheme.error, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.transaction.type == TransactionType.income;

    return Scaffold(
      backgroundColor: SavaioTheme.background,
      appBar: const AppHeader(title: 'Detail Transaksi', showBackButton: true, showNotification: false),
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
                    '${isIncome ? "+" : "-"}${SavaioTheme.formatCurrency(widget.transaction.amount, currency: context.watch<AuthController>().currency)}',
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
            const AppHeading('INFORMASI TRANSAKSI', size: AppHeadingSize.caption, color: SavaioTheme.primary, isBold: true),
            const SizedBox(height: 16),
            
            GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: 20,
              child: Column(
                children: [
                  _buildDetailItem(
                    icon: Icons.title_rounded, 
                    label: 'Judul Transaksi', 
                    value: widget.transaction.title,
                    isFirst: true,
                  ),
                  if (widget.transaction.description != null && widget.transaction.description!.isNotEmpty)
                    _buildDetailItem(
                      icon: Icons.notes_rounded, 
                      label: 'Catatan', 
                      value: widget.transaction.description!,
                    ),
                  _buildDetailItem(
                    icon: Icons.category_rounded,
                    label: 'Kategori',
                    value: widget.transaction.category?.name ?? widget.transaction.categoryId ?? '-',
                  ),
                  _buildDetailItem(
                    icon: Icons.calendar_today_rounded,
                    label: 'Waktu & Tanggal',
                    value: _formatDate(widget.transaction.date.toIso8601String()),
                  ),
                  _buildDetailItem(
                    icon: Icons.account_balance_wallet_rounded, 
                    label: 'Sumber Dana', 
                    value: widget.transaction.source,
                  ),
                  _buildDetailItem(
                    icon: Icons.tag_rounded, 
                    label: 'ID Transaksi', 
                    value: widget.transaction.id.split('-').first.toUpperCase(),
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Actions
            OutlinedButton.icon(
              onPressed: _isDeleting ? null : _handleDelete,
              icon: _isDeleting 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.delete_outline_rounded, size: 20),
              label: Text(_isDeleting ? 'MENGHAPUS...' : 'HAPUS DATA INI'),
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
