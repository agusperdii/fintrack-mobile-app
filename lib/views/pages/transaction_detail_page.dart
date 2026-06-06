import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:savaio/controllers/auth_controller.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_icon_container.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/components/organisms/notifications/app_snackbar.dart';

class TransactionDetailPage extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailPage({
    super.key,
    required this.transaction,
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  bool _isDeleting = false;

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy, HH:mm').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _handleDelete() async {
    if (_isDeleting) return;

    final confirm = await _showConfirmDialog();
    if (confirm != true || !mounted) return;

    setState(() => _isDeleting = true);

    if (mounted) {
      Navigator.pop(context, true);
    }

    sl.transactionController
        .deleteTransaction(
      widget.transaction.id,
      dashboardController: sl.dashboardController,
    )
        .then((success) {
      if (!mounted) return;

      if (success) {
        AppSnackBar.show(
          context,
          'Transaksi berhasil dihapus',
          type: AppSnackBarType.success,
          minimal: true,
          duration: const Duration(milliseconds: 500),
        );
        return;
      }

      AppSnackBar.show(
        context,
        'Gagal menghapus transaksi. Silakan coba lagi.',
        type: AppSnackBarType.error,
      );
    });
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool dialogLoading = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final textTheme = Theme.of(context).textTheme;

            return AlertDialog(
              backgroundColor: SavaioTheme.surfaceContainerHighOf(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SavaioTheme.radiusL),
              ),
              title: Text(
                'Hapus Transaksi?',
                style: textTheme.titleLarge?.copyWith(
                  color: SavaioTheme.onSurfaceOf(context),
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: Text(
                'Transaksi ini akan dihapus secara permanen dari catatan keuangan Anda.',
                style: textTheme.bodyMedium?.copyWith(
                  color: SavaioTheme.onSurfaceVariantOf(context),
                  height: 1.45,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: dialogLoading
                      ? null
                      : () {
                          Navigator.pop(dialogContext, false);
                        },
                  child: Text(
                    'Batal',
                    style: textTheme.labelLarge?.copyWith(
                      color: SavaioTheme.onSurfaceVariantOf(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: dialogLoading
                      ? null
                      : () {
                          setDialogState(() => dialogLoading = true);
                          Navigator.pop(dialogContext, true);
                        },
                  child: dialogLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: SavaioTheme.errorOf(context),
                          ),
                        )
                      : Text(
                          'Hapus',
                          style: textTheme.labelLarge?.copyWith(
                            color: SavaioTheme.errorOf(context),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.transaction.type == TransactionType.income;
    final currency = context.watch<AuthController>().currency;
    final textTheme = Theme.of(context).textTheme;
    final transactionColor = isIncome
        ? SavaioTheme.tertiaryOf(context)
        : SavaioTheme.errorOf(context);

    return Scaffold(
      backgroundColor: SavaioTheme.backgroundOf(context),
      appBar: const AppHeader(
        title: 'Detail Transaksi',
        showBackButton: true,
        showNotification: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SavaioTheme.spacingXl),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: SavaioTheme.spacing3xl,
                horizontal: SavaioTheme.spacingXl,
              ),
              decoration: BoxDecoration(
                color: SavaioTheme.surfaceContainerLowOf(context),
                borderRadius: BorderRadius.circular(SavaioTheme.radiusXl),
                border: Border.all(
                  color: SavaioTheme.outlineVariantOf(context).withValues(
                    alpha: 0.35,
                  ),
                ),
              ),
              child: Column(
                children: [
                  AppIconContainer(
                    icon: isIncome
                        ? Icons.south_west_rounded
                        : Icons.north_east_rounded,
                    color: transactionColor,
                    size: 64,
                    opacity: 0.15,
                  ),
                  const SizedBox(height: SavaioTheme.spacingXl),
                  AppHeading(
                    '${isIncome ? "+" : "-"}${SavaioTheme.formatCurrency(
                      widget.transaction.amount,
                      currency: currency,
                    )}',
                    size: AppHeadingSize.h1,
                    color: isIncome
                        ? SavaioTheme.tertiaryOf(context)
                        : SavaioTheme.onSurfaceOf(context),
                  ),
                  const SizedBox(height: SavaioTheme.spacingS),
                  Text(
                    isIncome ? 'Pemasukan Berhasil' : 'Pengeluaran Berhasil',
                    style: textTheme.labelSmall?.copyWith(
                      color: SavaioTheme.onSurfaceVariantOf(context),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SavaioTheme.spacing2xl),
            Align(
              alignment: Alignment.centerLeft,
              child: AppHeading(
                'INFORMASI TRANSAKSI',
                size: AppHeadingSize.caption,
                color: SavaioTheme.primaryOf(context),
                isBold: true,
              ),
            ),
            const SizedBox(height: SavaioTheme.spacingL),
            GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: SavaioTheme.radiusL,
              child: Column(
                children: [
                  _DetailItem(
                    icon: Icons.title_rounded,
                    label: 'Judul Transaksi',
                    value: widget.transaction.title,
                    isFirst: true,
                  ),
                  if (widget.transaction.description != null &&
                      widget.transaction.description!.isNotEmpty)
                    _DetailItem(
                      icon: Icons.notes_rounded,
                      label: 'Catatan',
                      value: widget.transaction.description!,
                    ),
                  _DetailItem(
                    icon: Icons.category_rounded,
                    label: 'Kategori',
                    value: widget.transaction.category?.name ??
                        widget.transaction.categoryId ??
                        '-',
                  ),
                  _DetailItem(
                    icon: Icons.calendar_today_rounded,
                    label: 'Waktu & Tanggal',
                    value: _formatDate(
                      widget.transaction.date.toIso8601String(),
                    ),
                  ),
                  _DetailItem(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Sumber Dana',
                    value: widget.transaction.source,
                  ),
                  _DetailItem(
                    icon: Icons.tag_rounded,
                    label: 'ID Transaksi',
                    value: widget.transaction.id.split('-').first.toUpperCase(),
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: SavaioTheme.spacing3xl),
            OutlinedButton.icon(
              onPressed: _isDeleting ? null : _handleDelete,
              icon: _isDeleting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: SavaioTheme.errorOf(context),
                      ),
                    )
                  : Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: SavaioTheme.errorOf(context),
                    ),
              label: Text(_isDeleting ? 'MENGHAPUS...' : 'HAPUS DATA INI'),
              style: OutlinedButton.styleFrom(
                foregroundColor: SavaioTheme.errorOf(context),
                disabledForegroundColor:
                    SavaioTheme.onSurfaceVariantOf(context),
                side: BorderSide(
                  color: SavaioTheme.errorOf(context).withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: SavaioTheme.spacingL,
                  horizontal: SavaioTheme.spacing2xl,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SavaioTheme.radiusFull),
                ),
                textStyle: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: SavaioTheme.spacing3xl),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        if (!isFirst)
          Divider(
            height: 1,
            indent: 56,
            endIndent: SavaioTheme.spacingXl,
            color: SavaioTheme.outlineVariantOf(context).withValues(
              alpha: 0.25,
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(SavaioTheme.spacingL),
          child: Row(
            children: [
              AppIconContainer(
                icon: icon,
                color: SavaioTheme.primaryOf(context),
                size: 40,
                opacity: 0.1,
                iconColor: SavaioTheme.onSurfaceVariantOf(context),
              ),
              const SizedBox(width: SavaioTheme.spacingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: textTheme.labelSmall?.copyWith(
                        color: SavaioTheme.onSurfaceVariantOf(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: textTheme.bodyMedium?.copyWith(
                        color: SavaioTheme.onSurfaceOf(context),
                        fontWeight: FontWeight.w800,
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