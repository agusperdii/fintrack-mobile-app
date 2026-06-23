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
          backgroundColor: Theme.of(context).colorScheme.error,
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
      body: RefreshIndicator(
        onRefresh: () => controller.fetchMonthlySummary(year: selectedYear),
        color: Theme.of(context).colorScheme.primary,
        child: summary == null
            ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
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
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: AppHeading(
                          'AKTIVITAS BULANAN',
                          size: AppHeadingSize.caption,
                          isBold: true,
                        ),
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
    final double net = totalIn - totalOut;

    final bool isPositive = net >= 0;
    
    // Menggunakan color dari SavaioTheme / Material Theme Anda
    final Color successColor = SavaioTheme.tertiaryOf(context);
    final Color errorColor = Theme.of(context).colorScheme.error;
    final Color surfaceColor = SavaioTheme.surfaceContainerOf(context);

    // Kalkulasi rasio untuk Visual Bar Indicator
    final double totalFlow = totalIn + totalOut;
    final double inPercentage = totalFlow == 0 ? 0.5 : totalIn / totalFlow;
    final double outPercentage = totalFlow == 0 ? 0.5 : totalOut / totalFlow;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER & STATUS CHIP SECTION ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppHeading(
                'CASHFLOW BERSIH',
                size: AppHeadingSize.caption,
                isBold: true,
              ),
              // Modern Status Chip (Surplus/Defisit)
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
                    AppHeading(
                      isPositive ? 'Surplus' : 'Defisit',
                      size: AppHeadingSize.caption,
                      isBold: true,
                      // Uncomment jika AppHeading mendukung property color:
                      // color: isPositive ? successColor : errorColor, 
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- NET AMOUNT (HERO) SECTION ---
          AppHeading(
            SavaioTheme.formatCurrency(net, currency: currency),
            size: AppHeadingSize.h1,
          ),
          const SizedBox(height: 24),

          // --- VISUAL PROGRESS BAR SECTION ---
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: (inPercentage * 100).toInt(),
                    child: Container(color: successColor),
                  ),
                  if (totalIn > 0 && totalOut > 0)
                    Container(width: 2, color: surfaceColor), 
                  Expanded(
                    flex: (outPercentage * 100).toInt(),
                    child: Container(color: errorColor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- STATS (IN & OUT) SECTION ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Pemasukan
              Expanded(
                child: _buildStatItem(
                  context: context,
                  label: 'Pemasukan',
                  amountText: SavaioTheme.formatCurrency(totalIn, currency: currency),
                  color: successColor,
                  icon: Icons.south_west_rounded,
                ),
              ),
              const SizedBox(width: 16),
              // Pengeluaran
              Expanded(
                child: _buildStatItem(
                  context: context,
                  label: 'Pengeluaran',
                  amountText: SavaioTheme.formatCurrency(totalOut, currency: currency),
                  color: errorColor,
                  icon: Icons.north_east_rounded,
                  isAlignRight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGET ---
  Widget _buildStatItem({
    required BuildContext context,
    required String label,
    required String amountText,
    required Color color,
    required IconData icon,
    bool isAlignRight = false,
  }) {
    return Column(
      crossAxisAlignment: isAlignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isAlignRight) ...[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
            ],
            AppHeading(
              label,
              size: AppHeadingSize.caption,
            ),
            if (isAlignRight) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 14, color: color),
            ],
          ],
        ),
        const SizedBox(height: 4),
        AppHeading(
          amountText,
          size: AppHeadingSize.h3, // Gunakan size h3/h4 agar cukup untuk menampung nilai "full"
          isBold: true,
        ),
      ],
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
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: SavaioTheme.onSurfaceVariantOf(context),
            letterSpacing: 0.5,
          ),
        ),
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
                'PENGELUARAN',
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
        borderRadius: BorderRadius.circular(100),
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
