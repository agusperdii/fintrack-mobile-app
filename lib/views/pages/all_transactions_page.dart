import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/service_locator.dart';
import '../../models/entities/app_data.dart';
import '../components/organisms/app_header.dart';
import '../components/atoms/app_heading.dart';
import 'transaction_detail_page.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.initialMonth != null) {
      _selectedMonth = widget.initialMonth;
    }
    if (widget.initialTransactions != null) {
      // Use microtask to avoid calling notifyListeners during build/init if possible, 
      // though here it's initState so it's usually fine.
      Future.microtask(() => sl.financeController.setTransactions(widget.initialTransactions!));
    }
    sl.financeController.fetchTransactions();
  }

  String _formatMonth(String month) {
    final parts = month.split('-');
    if (parts.length != 2) return month;
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final m = int.tryParse(parts[1]) ?? 0;
    return '${months[m]} ${parts[0]}';
  }

  List<Transaction> _filteredTransactions(List<Transaction> all) {
    return all.where((t) {
      if (_selectedType == 'income' && t.type != TransactionType.income) return false;
      if (_selectedType == 'expense' && t.type != TransactionType.expense) return false;
      if (_selectedMonth != null && !t.date.startsWith(_selectedMonth!)) return false;
      return true;
    }).toList();
  }

  Map<String, List<Transaction>> _groupByDate(List<Transaction> txs) {
    final map = <String, List<Transaction>>{};
    for (final t in txs) {
      map.putIfAbsent(t.date, () => []).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KineticVaultTheme.background,
      appBar: AppHeader(title: 'Semua Transaksi', showBackButton: true),
      body: ListenableBuilder(
        listenable: sl.financeController,
        builder: (context, _) {
          final controller = sl.financeController;
          final allTxs = controller.transactions ?? [];
          final filtered = _filteredTransactions(allTxs);
          final grouped = _groupByDate(filtered);
          final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

          // Build unique months for filter
          final months = allTxs
              .where((t) => t.date.length >= 7)
              .map((t) => t.date.substring(0, 7))
              .toSet()
              .toList()
            ..sort((a, b) => b.compareTo(a));

          return Column(
            children: [
              // Filter bar
              Container(
                height: 44,
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    // Type filter
                    _TypeChip(label: 'Semua', value: 'all', selected: _selectedType == 'all', onTap: () => setState(() { _selectedType = 'all'; })),
                    const SizedBox(width: 8),
                    _TypeChip(label: 'Pemasukan', value: 'income', selected: _selectedType == 'income', onTap: () => setState(() { _selectedType = 'income'; })),
                    const SizedBox(width: 8),
                    _TypeChip(label: 'Pengeluaran', value: 'expense', selected: _selectedType == 'expense', onTap: () => setState(() { _selectedType = 'expense'; })),
                    const Spacer(),
                    // Month dropdown
                    if (months.isNotEmpty)
                      DropdownButton<String?>(
                        value: _selectedMonth,
                        hint: Text('Bulan', style: GoogleFonts.inter(fontSize: 12, color: KineticVaultTheme.onSurfaceVariant)),
                        dropdownColor: KineticVaultTheme.surfaceContainerHigh,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.expand_more, color: KineticVaultTheme.onSurfaceVariant, size: 16),
                        items: [
                          DropdownMenuItem<String?>(value: null, child: Text('Semua', style: GoogleFonts.inter(fontSize: 12, color: KineticVaultTheme.onSurface))),
                          ...months.map((m) => DropdownMenuItem<String?>(value: m, child: Text(_formatMonth(m), style: GoogleFonts.inter(fontSize: 12, color: KineticVaultTheme.onSurface)))),
                        ],
                        onChanged: (v) => setState(() => _selectedMonth = v),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (controller.isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator(color: KineticVaultTheme.primary)))
              else if (filtered.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: KineticVaultTheme.onSurfaceVariant.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        AppHeading('Tidak ada transaksi', size: AppHeadingSize.h3, color: KineticVaultTheme.onSurfaceVariant),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => sl.financeController.fetchTransactions(),
                    color: KineticVaultTheme.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: sortedDates.length,
                      itemBuilder: (context, i) {
                        final date = sortedDates[i];
                        final txs = grouped[date]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(date, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: KineticVaultTheme.onSurfaceVariant, letterSpacing: 0.5)),
                            ),
                            ...txs.map((tx) => _TransactionListItem(
                              transaction: tx,
                              onTap: () async {
                                final deleted = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(builder: (_) => TransactionDetailPage(transaction: tx)),
                                );
                                if (deleted == true) {
                                  sl.financeController.fetchTransactions();
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
          );
        },
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
        duration: KineticVaultTheme.durationFast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? KineticVaultTheme.primary.withValues(alpha: 0.15) : KineticVaultTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? KineticVaultTheme.primary.withValues(alpha: 0.5) : Colors.transparent),
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: selected ? KineticVaultTheme.primary : KineticVaultTheme.onSurfaceVariant)),
      ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;
  const _TransactionListItem({required this.transaction, required this.onTap});

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
            color: KineticVaultTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: (isIncome ? KineticVaultTheme.tertiary : KineticVaultTheme.error).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(isIncome ? Icons.south_west : Icons.north_east, color: isIncome ? KineticVaultTheme.tertiary : KineticVaultTheme.error, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: KineticVaultTheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(transaction.category, style: GoogleFonts.inter(fontSize: 11, color: KineticVaultTheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'}Rp ${transaction.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: isIncome ? KineticVaultTheme.tertiary : KineticVaultTheme.error),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
