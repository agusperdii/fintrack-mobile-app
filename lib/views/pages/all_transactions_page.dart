import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/models/monthly_summary_model.dart';
import 'package:savaio/controllers/analytics_controller.dart';
import 'package:savaio/controllers/transaction_controller.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/pages/transaction_detail_page.dart';

class AllTransactionsPage extends StatefulWidget {
  final String? initialMonth;
  final List<Transaction>? initialTransactions;
  const AllTransactionsPage({super.key, this.initialMonth, this.initialTransactions});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  String? _selectedMonth;
  String _selectedType = 'all';
  AnalyticsController? _analyticsController;

  @override
  void initState() {
    super.initState();
    if (widget.initialMonth != null) {
      _selectedMonth = widget.initialMonth;
      sl.transactionController.fetchMonthTransactions(_selectedMonth!);
    } else {
      sl.transactionController.fetchTransactions();
    }
    
    // Add error listener for export
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _analyticsController = context.read<AnalyticsController>();
      _analyticsController?.addListener(_onAnalyticsChange);
    });
  }

  @override
  void dispose() {
    _analyticsController?.removeListener(_onAnalyticsChange);
    super.dispose();
  }

  void _onAnalyticsChange() {
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

  String _formatMonth(String month) {
    if (month.isEmpty) return 'Bulan';
    final parts = month.split('-');
    if (parts.length != 2) return month;
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    try {
      final m = int.parse(parts[1]);
      if (m >= 1 && m <= 12) {
        return '${months[m]} ${parts[0]}';
      }
    } catch (_) {}
    return month;
  }

  List<Transaction> _filteredTransactions(List<Transaction> all) {
    return all.where((t) {
      if (_selectedType == 'income' && t.type != TransactionType.income) return false;
      if (_selectedType == 'expense' && t.type != TransactionType.expense) return false;
      if (_selectedMonth != null && !t.date.toIso8601String().startsWith(_selectedMonth!)) return false;
      return true;
    }).toList();
  }

  Map<String, List<Transaction>> _groupByDate(List<Transaction> txs) {
    final map = <String, List<Transaction>>{};
    for (final t in txs) {
      final dateStr = t.date.toIso8601String();
      final dateOnly = dateStr.length >= 10 ? dateStr.substring(0, 10) : dateStr;
      map.putIfAbsent(dateOnly, () => []).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TransactionController>();
    final allTxs = controller.transactions ?? [];
    final currency = controller.currency;
    final summary = controller.monthSummary;
    
    // Build unique months for filter from data
    final months = allTxs
        .where((t) => t.date.toIso8601String().length >= 7)
        .map((t) => t.date.toIso8601String().substring(0, 7))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final dropdownMonths = List<String>.from(months);
    if (_selectedMonth != null && !dropdownMonths.contains(_selectedMonth)) {
        dropdownMonths.add(_selectedMonth!);
        dropdownMonths.sort((a, b) => b.compareTo(a));
    }

    final filtered = _filteredTransactions(allTxs);
    final grouped = _groupByDate(filtered);
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: SavaioTheme.background,
      appBar: const AppHeader(title: 'Semua Transaksi', showBackButton: true, showNotification: false),
      body: Column(
        children: [
          // Summary Header (from drill-down API)
          if (summary != null && _selectedMonth != null)
            _buildSummaryHeader(summary, currency),

          // Filter bar
          Container(
            height: 44,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                _TypeChip(label: 'Semua', value: 'all', selected: _selectedType == 'all', onTap: () => setState(() { _selectedType = 'all'; })),
                const SizedBox(width: 4),
                _TypeChip(label: 'Masuk', value: 'income', selected: _selectedType == 'income', onTap: () => setState(() { _selectedType = 'income'; })),
                const SizedBox(width: 4),
                _TypeChip(label: 'Keluar', value: 'expense', selected: _selectedType == 'expense', onTap: () => setState(() { _selectedType = 'expense'; })),
                const Spacer(),
                if (dropdownMonths.isNotEmpty)
                  DropdownButton<String?>(
                    value: _selectedMonth,
                    hint: Text('Bulan', style: GoogleFonts.inter(fontSize: 11, color: SavaioTheme.onSurfaceVariant)),
                    dropdownColor: SavaioTheme.surfaceContainerHigh,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.expand_more, color: SavaioTheme.onSurfaceVariant, size: 14),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null, 
                        child: Text('Semua', style: GoogleFonts.inter(fontSize: 11, color: SavaioTheme.onSurface))
                      ),
                      ...dropdownMonths.map((m) => DropdownMenuItem<String?>(
                        value: m, 
                        child: Text(_formatMonth(m), style: GoogleFonts.inter(fontSize: 11, color: SavaioTheme.onSurface))
                      )),
                    ],
                    onChanged: (v) {
                      setState(() => _selectedMonth = v);
                      if (v != null) {
                        controller.fetchMonthTransactions(v);
                      } else {
                        controller.fetchTransactions();
                      }
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (controller.isLoading && allTxs.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator(color: SavaioTheme.primary)))
          else if (filtered.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 64, color: SavaioTheme.onSurfaceVariant.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    AppHeading(
                      _selectedMonth != null 
                          ? 'Belum ada transaksi di ${_formatMonth(_selectedMonth!)}'
                          : 'Tidak ada transaksi', 
                      size: AppHeadingSize.subtitle, 
                      color: SavaioTheme.onSurfaceVariant
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _selectedMonth != null 
                    ? controller.fetchMonthTransactions(_selectedMonth!) 
                    : controller.fetchTransactions(),
                color: SavaioTheme.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, i) {
                    final date = sortedDates[i];
                    final txs = grouped[date]!;
                    
                    String displayDate = date;
                    try {
                      final dt = DateTime.parse(date);
                      displayDate = DateFormat('d MMMM yyyy').format(dt);
                    } catch (_) {}

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            displayDate,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: SavaioTheme.onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        ...txs.map((tx) => _TransactionListItem(
                          transaction: tx,
                          currency: currency,
                          onTap: () async {
                            final deleted = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(builder: (_) => TransactionDetailPage(transaction: tx)),
                            );
                            if (deleted == true) {
                              if (_selectedMonth != null) {
                                controller.fetchMonthTransactions(_selectedMonth!);
                              } else {
                                controller.fetchTransactions();
                              }
                            }
                          },
                        )),
                      ],
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(MonthSummary summary, String currency) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SavaioTheme.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: _SummaryItem(label: 'Masuk', value: summary.totalIncome, color: SavaioTheme.tertiary, currency: currency)),
                Flexible(child: _SummaryItem(label: 'Keluar', value: summary.totalExpense, color: SavaioTheme.error, currency: currency)),
                Flexible(child: _SummaryItem(label: 'Kas', value: summary.netCashflow, color: summary.netCashflow >= 0 ? SavaioTheme.primary : SavaioTheme.error, currency: currency)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 24, color: SavaioTheme.outlineVariant.withValues(alpha: 0.1)),
          const SizedBox(width: 8),
          _ExportButton(
            onXlsx: () => context.read<AnalyticsController>().exportReport(_selectedMonth!, 'xlsx'),
            onPdf: () => context.read<AnalyticsController>().exportReport(_selectedMonth!, 'pdf'),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label, value;
  final bool selected;
  final VoidCallback onTap;
  const _TypeChip({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: SavaioTheme.durationFast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? SavaioTheme.primary.withValues(alpha: 0.15) : SavaioTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? SavaioTheme.primary.withValues(alpha: 0.5) : Colors.transparent),
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: selected ? SavaioTheme.primary : SavaioTheme.onSurfaceVariant)),
      ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final String currency;
  final VoidCallback onTap;
  const _TransactionListItem({required this.transaction, required this.onTap, required this.currency});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: SavaioTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: (isIncome ? SavaioTheme.tertiary : SavaioTheme.error).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(isIncome ? Icons.south_west : Icons.north_east, color: isIncome ? SavaioTheme.tertiary : SavaioTheme.error, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: SavaioTheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(
                      '${transaction.category?.name ?? "Tanpa Kategori"} @${DateFormat('HH:mm').format(transaction.date)}',
                      style: GoogleFonts.inter(fontSize: 11, color: SavaioTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'}${SavaioTheme.formatCurrency(transaction.amount, currency: currency)}',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: isIncome ? SavaioTheme.tertiary : SavaioTheme.error),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String currency;
  const _SummaryItem({required this.label, required this.value, required this.color, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label, 
          style: GoogleFonts.inter(fontSize: 9, color: SavaioTheme.onSurfaceVariant),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          SavaioTheme.formatCurrencyShorthand(value, currency: currency),
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: SavaioTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: SavaioTheme.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.file_download_outlined,
              size: 14,
              color: SavaioTheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'LAPORAN',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: SavaioTheme.primary,
                letterSpacing: 0.5,
              ),
            ),
          ],
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
