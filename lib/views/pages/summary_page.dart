import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/controllers/analytics_controller.dart';
import 'package:savaio/controllers/dashboard_controller.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/pages/all_transactions_page.dart';
import 'package:savaio/models/monthly_summary_model.dart';

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
      
      // Add error listener
      controller.addListener(_onControllerChange);
    });
  }

  @override
  void dispose() {
    // We need to be careful here as the controller might outlive the page
    // but in this app it's usually a singleton/long-lived provider.
    // However, it's better to remove the listener.
    // Since we are using context.read in initState, we should store the reference.
    super.dispose();
  }

  // To properly remove listener, we should store the controller reference
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: SavaioTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
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
      backgroundColor: SavaioTheme.background,
      appBar: AppHeader(
        title: 'Laporan Tahunan',
        showNotification: false,
        actions: [
          if (isSyncing || isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: SavaioTheme.primary),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchMonthlySummary(year: selectedYear),
        color: SavaioTheme.primary,
        child: summary == null
            ? const Center(child: CircularProgressIndicator(color: SavaioTheme.primary))
            : CustomScrollView(
                slivers: [
                  // Year Selector & Total Summary
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

                  // Active Months Header
                  if (activeMonths.isNotEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: AppHeading('AKTIVITAS BULANAN', size: AppHeadingSize.caption, color: SavaioTheme.onSurfaceVariant, isBold: true),
                      ),
                    ),

                  // Active Months Grid
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
                            const Icon(Icons.folder_off_outlined, size: 48, color: SavaioTheme.onSurfaceVariant),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada aktivitas transaksi ditahun ini',
                              style: GoogleFonts.inter(color: SavaioTheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
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
          color: SavaioTheme.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: SavaioTheme.primary, size: 20),
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
    final double net = totalIn - totalOut;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: SavaioTheme.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppHeading('CASHFLOW BERSIH', size: AppHeadingSize.caption, color: SavaioTheme.onSurfaceVariant, isBold: true),
              Icon(
                net >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: net >= 0 ? SavaioTheme.tertiary : SavaioTheme.error,
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppHeading(SavaioTheme.formatCurrency(net, currency: currency), size: AppHeadingSize.h1),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SavaioTheme.background.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _YearStat(label: 'Pemasukan', value: totalIn, color: SavaioTheme.tertiary, currency: currency),
                Container(width: 1, height: 30, color: SavaioTheme.outlineVariant.withValues(alpha: 0.2)),
                _YearStat(label: 'Pengeluaran', value: totalOut, color: SavaioTheme.error, currency: currency),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _YearStat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String currency;
  const _YearStat({required this.label, required this.value, required this.color, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: SavaioTheme.onSurfaceVariant, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        Text(
          SavaioTheme.formatCurrencyShorthand(value, currency: currency),
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: color),
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
        color: SavaioTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SavaioTheme.outlineVariant.withValues(alpha: 0.1)),
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
                        color: SavaioTheme.primary.withValues(alpha: 0.6)
                      ),
                    ),
                  ),
                  if (model.topCategory != null)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: SavaioTheme.background.withValues(alpha: 0.3),
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
              Text('PENGELUARAN', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: SavaioTheme.onSurfaceVariant, letterSpacing: 0.5)),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isPositive ? SavaioTheme.tertiary : SavaioTheme.error).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 10,
            color: isPositive ? SavaioTheme.tertiary : SavaioTheme.error,
          ),
          const SizedBox(width: 4),
          Text(
            '${value.toStringAsFixed(0)}%',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isPositive ? SavaioTheme.tertiary : SavaioTheme.error,
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
      color: SavaioTheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) {
        if (value == 'xlsx') onXlsx();
        if (value == 'pdf') onPdf();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: SavaioTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: SavaioTheme.primary.withValues(alpha: 0.2)),
        ),
        child: const Icon(
          Icons.file_download_outlined,
          size: 18,
          color: SavaioTheme.primary,
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
