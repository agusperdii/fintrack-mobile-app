import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:savaio/controllers/analytics_controller.dart';
import 'package:savaio/controllers/transaction_controller.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/models/monthly_summary_model.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/molecules/app_transaction_item.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/pages/transaction_detail_page.dart';

class AllTransactionsPage extends StatefulWidget {
  final String? initialMonth;
  final List<Transaction>? initialTransactions;

  const AllTransactionsPage({
    super.key,
    this.initialMonth,
    this.initialTransactions,
  });

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
    if (error == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: SavaioTheme.errorOf(context),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _analyticsController?.clearError();
  }

  String _formatMonth(String month) {
    if (month.isEmpty) return 'Bulan';

    final parts = month.split('-');
    if (parts.length != 2) return month;

    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    try {
      final m = int.parse(parts[1]);
      if (m >= 1 && m <= 12) {
        return '${months[m]} ${parts[0]}';
      }
    } catch (_) {}

    return month;
  }

  List<Transaction> _filteredTransactions(List<Transaction> all) {
    return all.where((transaction) {
      if (_selectedType == 'income' &&
          transaction.type != TransactionType.income) {
        return false;
      }

      if (_selectedType == 'expense' &&
          transaction.type != TransactionType.expense) {
        return false;
      }

      if (_selectedMonth != null &&
          !transaction.date.toIso8601String().startsWith(_selectedMonth!)) {
        return false;
      }

      return true;
    }).toList();
  }

  Map<String, List<Transaction>> _groupByDate(List<Transaction> transactions) {
    final grouped = <String, List<Transaction>>{};

    for (final transaction in transactions) {
      final dateString = transaction.date.toIso8601String();
      final dateOnly =
          dateString.length >= 10 ? dateString.substring(0, 10) : dateString;

      grouped.putIfAbsent(dateOnly, () => []).add(transaction);
    }

    return grouped;
  }

  Future<void> _refreshTransactions(TransactionController controller) {
    if (_selectedMonth != null) {
      return controller.fetchMonthTransactions(_selectedMonth!);
    }

    return controller.fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TransactionController>();
    final allTransactions = controller.transactions ?? [];
    final currency = controller.currency;
    final summary = controller.monthSummary;
    final textTheme = Theme.of(context).textTheme;

    final months = allTransactions
        .where((transaction) => transaction.date.toIso8601String().length >= 7)
        .map((transaction) => transaction.date.toIso8601String().substring(0, 7))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final dropdownMonths = List<String>.from(months);

    if (_selectedMonth != null && !dropdownMonths.contains(_selectedMonth)) {
      dropdownMonths.add(_selectedMonth!);
      dropdownMonths.sort((a, b) => b.compareTo(a));
    }

    final filteredTransactions = _filteredTransactions(allTransactions);
    final groupedTransactions = _groupByDate(filteredTransactions);
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: SavaioTheme.backgroundOf(context),
      appBar: const AppHeader(
        title: 'Semua Transaksi',
        showBackButton: true,
        showNotification: false,
      ),
      body: Column(
        children: [
          if (summary != null && _selectedMonth != null)
            _buildSummaryHeader(
              context,
              summary: summary,
              currency: currency,
            ),
          Container(
            height: 44,
            margin: const EdgeInsets.fromLTRB(
              SavaioTheme.spacingL,
              0,
              SavaioTheme.spacingL,
              0,
            ),
            child: Row(
              children: [
                _TypeChip(
                  label: 'Semua',
                  selected: _selectedType == 'all',
                  onTap: () {
                    setState(() => _selectedType = 'all');
                  },
                ),
                const SizedBox(width: SavaioTheme.spacingXs),
                _TypeChip(
                  label: 'Masuk',
                  selected: _selectedType == 'income',
                  onTap: () {
                    setState(() => _selectedType = 'income');
                  },
                ),
                const SizedBox(width: SavaioTheme.spacingXs),
                _TypeChip(
                  label: 'Keluar',
                  selected: _selectedType == 'expense',
                  onTap: () {
                    setState(() => _selectedType = 'expense');
                  },
                ),
                const Spacer(),
                if (dropdownMonths.isNotEmpty)
                  DropdownButton<String?>(
                    value: _selectedMonth,
                    hint: Text(
                      'Bulan',
                      style: textTheme.labelSmall?.copyWith(
                        color: SavaioTheme.onSurfaceVariantOf(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    dropdownColor:
                        SavaioTheme.surfaceContainerHighOf(context),
                    underline: const SizedBox(),
                    icon: Icon(
                      Icons.expand_more,
                      color: SavaioTheme.onSurfaceVariantOf(context),
                      size: 14,
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(
                          'Semua',
                          style: textTheme.labelSmall?.copyWith(
                            color: SavaioTheme.onSurfaceOf(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ...dropdownMonths.map(
                        (month) => DropdownMenuItem<String?>(
                          value: month,
                          child: Text(
                            _formatMonth(month),
                            style: textTheme.labelSmall?.copyWith(
                              color: SavaioTheme.onSurfaceOf(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedMonth = value);

                      if (value != null) {
                        controller.fetchMonthTransactions(value);
                      } else {
                        controller.fetchTransactions();
                      }
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: SavaioTheme.spacingS),
          if (controller.isLoading && allTransactions.isEmpty)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: SavaioTheme.primaryOf(context),
                ),
              ),
            )
          else if (filteredTransactions.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: SavaioTheme.onSurfaceVariantOf(context)
                          .withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: SavaioTheme.spacingL),
                    AppHeading(
                      _selectedMonth != null
                          ? 'Belum ada transaksi di ${_formatMonth(_selectedMonth!)}'
                          : 'Tidak ada transaksi',
                      size: AppHeadingSize.subtitle,
                      color: SavaioTheme.onSurfaceVariantOf(context),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _refreshTransactions(controller),
                color: SavaioTheme.primaryOf(context),
                backgroundColor: SavaioTheme.surfaceContainerOf(context),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    SavaioTheme.spacingL,
                    SavaioTheme.spacingS,
                    SavaioTheme.spacingL,
                    SavaioTheme.spacing2xl,
                  ),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final date = sortedDates[index];
                    final transactions = groupedTransactions[date]!;

                    String displayDate = date;

                    try {
                      final parsedDate = DateTime.parse(date);
                      displayDate = DateFormat('d MMMM yyyy').format(parsedDate);
                    } catch (_) {}

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: SavaioTheme.spacingM,
                          ),
                          child: Text(
                            displayDate,
                            style: textTheme.labelSmall?.copyWith(
                              color: SavaioTheme.onSurfaceVariantOf(context),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        ...transactions.map(
                          (transaction) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: SavaioTheme.spacingS,
                            ),
                            child: AppTransactionItem(
                              transaction: transaction,
                              onTap: () async {
                                final deleted = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TransactionDetailPage(
                                      transaction: transaction,
                                    ),
                                  ),
                                );

                                if (deleted == true) {
                                  await _refreshTransactions(controller);
                                }
                              },
                            ),
                          ),
                        ),
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

  Widget _buildSummaryHeader(
    BuildContext context, {
    required MonthSummary summary,
    required String currency,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SavaioTheme.spacingL,
        vertical: SavaioTheme.spacingM,
      ),
      margin: const EdgeInsets.fromLTRB(
        SavaioTheme.spacingL,
        0,
        SavaioTheme.spacingL,
        SavaioTheme.spacingL,
      ),
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainerOf(context),
        borderRadius: BorderRadius.circular(SavaioTheme.radiusL),
        border: Border.all(
          color: SavaioTheme.outlineVariantOf(context).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: _SummaryItem(
                    label: 'Masuk',
                    value: summary.totalIncome,
                    color: SavaioTheme.tertiaryOf(context),
                    currency: currency,
                  ),
                ),
                Flexible(
                  child: _SummaryItem(
                    label: 'Keluar',
                    value: summary.totalExpense,
                    color: SavaioTheme.errorOf(context),
                    currency: currency,
                  ),
                ),
                Flexible(
                  child: _SummaryItem(
                    label: 'Kas',
                    value: summary.netCashflow,
                    color: summary.netCashflow >= 0
                        ? SavaioTheme.primaryOf(context)
                        : SavaioTheme.errorOf(context),
                    currency: currency,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SavaioTheme.spacingS),
          Container(
            width: 1,
            height: 24,
            color: SavaioTheme.outlineVariantOf(context).withValues(alpha: 0.25),
          ),
          const SizedBox(width: SavaioTheme.spacingS),
          _ExportButton(
            onXlsx: () {
              context.read<AnalyticsController>().exportReport(
                    _selectedMonth!,
                    'xlsx',
                  );
            },
            onPdf: () {
              context.read<AnalyticsController>().exportReport(
                    _selectedMonth!,
                    'pdf',
                  );
            },
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: SavaioTheme.durationFast,
        curve: SavaioTheme.curveDefault,
        padding: const EdgeInsets.symmetric(
          horizontal: SavaioTheme.spacingM,
          vertical: SavaioTheme.spacingS,
        ),
        decoration: BoxDecoration(
          color: selected
              ? SavaioTheme.primaryOf(context).withValues(alpha: 0.15)
              : SavaioTheme.surfaceContainerHighOf(context),
          borderRadius: BorderRadius.circular(SavaioTheme.radiusFull),
          border: Border.all(
            color: selected
                ? SavaioTheme.primaryOf(context).withValues(alpha: 0.5)
                : SavaioTheme.outlineVariantOf(context).withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: selected
                ? SavaioTheme.primaryOf(context)
                : SavaioTheme.onSurfaceVariantOf(context),
            fontWeight: FontWeight.w800,
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

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: SavaioTheme.onSurfaceVariantOf(context),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          SavaioTheme.formatCurrencyShorthand(value, currency: currency),
          style: textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
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

  const _ExportButton({
    required this.onXlsx,
    required this.onPdf,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopupMenuButton<String>(
      tooltip: 'Download Laporan',
      offset: const Offset(0, 45),
      color: SavaioTheme.surfaceContainerHighestOf(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SavaioTheme.radiusL),
      ),
      onSelected: (value) {
        if (value == 'xlsx') onXlsx();
        if (value == 'pdf') onPdf();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SavaioTheme.spacingM,
          vertical: SavaioTheme.spacingS,
        ),
        decoration: BoxDecoration(
          color: SavaioTheme.primaryOf(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(SavaioTheme.radiusM),
          border: Border.all(
            color: SavaioTheme.primaryOf(context).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.file_download_outlined,
              size: 14,
              color: SavaioTheme.primaryOf(context),
            ),
            const SizedBox(width: SavaioTheme.spacingXs),
            Text(
              'LAPORAN',
              style: textTheme.labelSmall?.copyWith(
                color: SavaioTheme.primaryOf(context),
                fontWeight: FontWeight.w800,
                fontSize: 9,
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
              Icon(
                Icons.table_chart_rounded,
                size: 18,
                color: SavaioTheme.successOf(context),
              ),
              const SizedBox(width: SavaioTheme.spacingM),
              Text(
                'Excel (.xlsx)',
                style: textTheme.labelMedium?.copyWith(
                  color: SavaioTheme.onSurfaceOf(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'pdf',
          child: Row(
            children: [
              Icon(
                Icons.picture_as_pdf_rounded,
                size: 18,
                color: SavaioTheme.errorOf(context),
              ),
              const SizedBox(width: SavaioTheme.spacingM),
              Text(
                'PDF (.pdf)',
                style: textTheme.labelMedium?.copyWith(
                  color: SavaioTheme.onSurfaceOf(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}