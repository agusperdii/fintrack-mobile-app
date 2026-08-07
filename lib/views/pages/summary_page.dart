// summary_page.dart
// Halaman laporan tahunan yang menampilkan ringkasan cashflow per bulan
// beserta rincian pemasukan, pengeluaran, dan tabungan.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/controllers/analytics_controller.dart';
import 'package:savaio/controllers/dashboard_controller.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/organisms/notifications/app_snackbar.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/pages/all_transactions_page.dart';
import 'package:savaio/models/monthly_summary_model.dart';

import 'package:savaio/views/components/atoms/app_grid_background.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<AnalyticsController>();
      controller.fetchMonthlySummary();
      controller.addListener(_onControllerChange);
    });
  }

  /// Controller mungkin lebih lama hidup dari halaman ini (biasanya
  /// singleton/provider berumur panjang), tapi listener tetap harus
  /// dilepas. Karena controller diambil lewat context.read di initState,
  /// referensinya disimpan di _analyticsController agar bisa dilepas
  /// dengan aman saat deactivate.
  @override
  void dispose() {
    super.dispose();
  }

  AnalyticsController? _analyticsController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _analyticsController ??= context.read<AnalyticsController>();
  }

  @override
  void deactivate() {
    _analyticsController?.removeListener(_onControllerChange);
    super.deactivate();
  }

  void _onControllerChange() {
    if (!mounted) return;
    final error = _analyticsController?.error;
    if (error != null) {
      AppSnackBar.show(
        context,
        error,
        type: AppSnackBarType.error,
      );
      _analyticsController?.clearError();
    }
  }

  void _changeYear(int delta) {
    final controller = context.read<AnalyticsController>();
    final newYear = controller.selectedYear + delta;
    if (newYear >= 2000 && newYear <= 2100) {
      controller.fetchMonthlySummary(year: newYear);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AnalyticsController>();
    final summary = controller.monthlySummary;
    final selectedYear = controller.selectedYear;
    final isSyncing = context.select<DashboardController, bool>((c) => c.isSyncingTransaction);
    final isLoading = controller.isLoading;
    final currency = controller.summaryCurrency;

    final activeMonths = summary?.where((m) => m.hasTransactions).toList() ?? [];

    return Scaffold(
      backgroundColor: SavaioTheme.backgroundOf(context),
      appBar: AppHeader(
        title: 'Laporan Tahunan',
        showNotification: false,
        actions: [
          if (isSyncing || isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: AppGridBackground(
        child: RefreshIndicator(
          onRefresh: () => controller.fetchMonthlySummary(year: selectedYear),
          color: Theme.of(context).colorScheme.primary,
        child: controller.error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      controller.error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.fetchMonthlySummary(year: selectedYear),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            : summary == null
                ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppHeading('$selectedYear', size: AppHeadingSize.h1),
                              Row(
                                children: [
                                  _YearNavButton(icon: Icons.chevron_left_rounded, onTap: () => _changeYear(-1)),
                                  const SizedBox(width: 12),
                                  _YearNavButton(icon: Icons.chevron_right_rounded, onTap: () => _changeYear(1)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          _YearlyTotalCard(summary: summary, currency: currency),
                        ],
                      ),
                    ),
                  ),

                  if (activeMonths.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: AppHeading(
                          'Aktivitas Bulanan',
                          size: AppHeadingSize.caption,
                          isBold: true,
                        ),
                      ),
                    ),

                  if (activeMonths.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.82,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _MonthlySummaryCard(
                              model: activeMonths[index],
                              currency: currency,
                            );
                          },
                          childCount: activeMonths.length,
                        ),
                      ),
                    )
                  else
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_off_outlined,
                              size: 48,
                              color: SavaioTheme.onSurfaceVariantOf(context),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada aktivitas transaksi ditahun ini',
                              style: GoogleFonts.inter(color: SavaioTheme.onSurfaceVariantOf(context)),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
        ),
      ),
    );
  }
}

class _YearNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _YearNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: SavaioTheme.surfaceContainerHighOf(context),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
      ),
    );
  }
}


class _YearlyTotalCard extends StatelessWidget {
  final List<MonthlySummaryModel> summary;
  final String currency;

  const _YearlyTotalCard({required this.summary, required this.currency});

  @override
  Widget build(BuildContext context) {
    final double totalIn = summary.fold(0, (sum, m) => sum + m.totalIncome);
    final double totalOut = summary.fold(0, (sum, m) => sum + m.totalExpense);
    final double totalSav = summary.fold(0, (sum, m) => sum + m.totalSavings);
    final double net = totalIn - totalOut - totalSav;

    final bool isPositive = net >= 0;
    
    final Color successColor = SavaioTheme.tertiaryOf(context);
    final Color errorColor = Theme.of(context).colorScheme.error;

    final double totalFlow = totalIn + totalOut;
    final double inPercentage = totalFlow == 0 ? 0.5 : totalIn / totalFlow;
    final double outPercentage = totalFlow == 0 ? 0.5 : totalOut / totalFlow;

    final symbol = currency == 'USD' ? r'$' : (currency == 'IDR' ? 'Rp' : currency);
    final formattedNet = SavaioTheme.formatCurrency(net, currency: currency).replaceAll(symbol, '').trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SavaioTheme.spacing2xl),
      decoration: BoxDecoration(
        color: SavaioTheme.primaryOf(context).withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(SavaioTheme.radiusXl),
        border: Border.all(
          color: SavaioTheme.primaryOf(context).withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: SavaioTheme.primaryOf(context).withValues(alpha: 0.05),
            blurRadius: 32,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Cashflow Bersih',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: SavaioTheme.onSurfaceVariantOf(context),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? successColor : errorColor).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      color: isPositive ? successColor : errorColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPositive ? 'Surplus' : 'Defisit',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isPositive ? successColor : errorColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SavaioTheme.spacingL),

          FittedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, right: 6.0),
                  child: Text(
                    symbol,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: SavaioTheme.onSurfaceOf(context).withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Text(
                  formattedNet,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: SavaioTheme.onSurfaceOf(context),
                    height: 1.1,
                    letterSpacing: -1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  Expanded(
                    flex: (inPercentage * 100).toInt(),
                    child: Container(color: successColor),
                  ),
                  if (totalIn > 0 && totalOut > 0)
                    Container(width: 2, color: SavaioTheme.surfaceContainerHighestOf(context)), 
                  Expanded(
                    flex: (outPercentage * 100).toInt(),
                    child: Container(color: errorColor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _buildModernStat(
                  context: context,
                  label: 'Pemasukan',
                  amount: totalIn,
                  currency: currency,
                  symbol: symbol,
                  color: successColor,
                ),
              ),
              Expanded(
                child: _buildModernStat(
                  context: context,
                  label: 'Pengeluaran',
                  amount: totalOut,
                  currency: currency,
                  symbol: symbol,
                  color: errorColor,
                ),
              ),
              Expanded(
                child: _buildModernStat(
                  context: context,
                  label: 'Tabungan',
                  amount: totalSav,
                  currency: currency,
                  symbol: symbol,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernStat({
    required BuildContext context,
    required String label,
    required double amount,
    required String currency,
    required String symbol,
    required Color color,
  }) {
    final formatted = SavaioTheme.formatCurrency(amount, currency: currency).replaceAll(symbol, '').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: SavaioTheme.onSurfaceVariantOf(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FittedBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0, right: 2.0),
                child: Text(
                  symbol,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: SavaioTheme.onSurfaceOf(context).withValues(alpha: 0.6),
                  ),
                ),
              ),
              Text(
                formatted,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: SavaioTheme.onSurfaceOf(context),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}



class _MonthlySummaryCard extends StatelessWidget {
  final MonthlySummaryModel model;
  final String currency;

  const _MonthlySummaryCard({required this.model, required this.currency});

  @override
  Widget build(BuildContext context) {
    final bool isPositive = model.netCashflow >= 0;

    return Container(
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainerOf(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllTransactionsPage(initialMonth: model.month),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      model.label.split(' ').first.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  if (model.topCategory != null)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: SavaioTheme.backgroundOf(context).withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Text(model.topCategory!.emoji, style: GoogleFonts.inter(fontSize: 14)),
                    ),
                ],
              ),
              const Spacer(),
              AppHeading(
                SavaioTheme.formatCurrencyShorthand(model.totalExpense, isExpense: true, currency: currency),
                size: AppHeadingSize.h2,
              ),
              Text(
                'Pengeluaran',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: SavaioTheme.onSurfaceVariantOf(context),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              AppHeading(
                SavaioTheme.formatCurrencyShorthand(model.totalSavings, currency: currency),
                size: AppHeadingSize.h3,
                color: Colors.blueAccent,
              ),
              Text(
                'Tabungan',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: SavaioTheme.onSurfaceVariantOf(context),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TrendBadge(isPositive: isPositive, value: model.savingRate),
                  _ExportButton(
                    onXlsx: () => context.read<AnalyticsController>().exportReport(model.month, 'xlsx'),
                    onPdf: () => context.read<AnalyticsController>().exportReport(model.month, 'pdf'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  final bool isPositive;
  final double value;
  const _TrendBadge({required this.isPositive, required this.value});

  @override
  Widget build(BuildContext context) {
    final color = isPositive
        ? SavaioTheme.tertiaryOf(context)
        : Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SavaioTheme.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '${value.toStringAsFixed(0)}%',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final VoidCallback onXlsx;
  final VoidCallback onPdf;

  const _ExportButton({required this.onXlsx, required this.onPdf});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Download Laporan',
      offset: const Offset(0, 45),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) {
        if (value == 'xlsx') onXlsx();
        if (value == 'pdf') onPdf();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: Icon(
          Icons.file_download_outlined,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'xlsx',
          child: Row(
            children: [
              const Icon(Icons.table_chart_rounded, size: 18, color: Colors.green),
              const SizedBox(width: 12),
              Text('Excel (.xlsx)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'pdf',
          child: Row(
            children: [
              const Icon(Icons.picture_as_pdf_rounded, size: 18, color: Colors.red),
              const SizedBox(width: 12),
              Text('PDF (.pdf)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
