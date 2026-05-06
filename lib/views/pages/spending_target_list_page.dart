import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/controllers/budget_controller.dart';
import 'package:savaio/controllers/transaction_controller.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_progress_bar.dart';
import 'package:savaio/views/components/atoms/app_icon_container.dart';
import 'package:savaio/views/components/molecules/app_date_time_picker.dart';
import 'package:savaio/views/pages/spending_target_page.dart';
import 'package:savaio/models/app_data.dart';

class SpendingTargetListPage extends StatefulWidget {
  const SpendingTargetListPage({super.key});

  @override
  State<SpendingTargetListPage> createState() => _SpendingTargetListPageState();
}

class _SpendingTargetListPageState extends State<SpendingTargetListPage> {
  late String _selectedMonth;
  String? _formattedMonth;
  bool _isMonthLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    _updateFormattedMonth();
    
    final hasCache = sl.budgetController.allBudgets.isNotEmpty;
    Future.microtask(() => _fetchMonthData(showGlobalLoading: !hasCache));
  }

  void _updateFormattedMonth() {
    final parts = _selectedMonth.split('-');
    if (parts.length != 2) {
      _formattedMonth = _selectedMonth;
      return;
    }
    const months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    final m = int.tryParse(parts[1]) ?? 0;
    _formattedMonth = '${months[m]} ${parts[0]}';
  }

  Future<void> _fetchMonthData({bool showGlobalLoading = false}) async {
    if (showGlobalLoading && mounted) {
      setState(() => _isMonthLoading = true);
    }
    
    try {
      await Future.wait([
        sl.budgetController.fetchAll(silent: !showGlobalLoading),
        sl.transactionController.fetchTransactions(month: _selectedMonth),
      ]);
    } catch (e) {
      debugPrint('Fetch data failed: $e');
    } finally {
      if (mounted && showGlobalLoading) {
        setState(() => _isMonthLoading = false);
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchMonthData(showGlobalLoading: false);
  }

  Future<void> _handleNavigateToEdit(String categoryName) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpendingTargetPage(initialCategory: categoryName),
      ),
    );

    if (result == true && mounted) {
      // Data updated optimistically in the page, sync already triggered in controller.
    }
  }

  void _showMonthPicker() async {
    if (_isMonthLoading) return;
    
    final picked = await AppDateTimePicker.showMonthPicker(
      context: context,
      initialMonth: _selectedMonth,
    );
    
    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = picked;
        _updateFormattedMonth();
      });
      await _fetchMonthData(showGlobalLoading: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SavaioTheme.background,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: SavaioTheme.primary,
        backgroundColor: SavaioTheme.surfaceContainerHigh,
        child: Selector2<BudgetController, TransactionController, List<SpendingTargetItemVM>>(
          selector: (context, budgetCtrl, txCtrl) => budgetCtrl.getSpendingTargetsForMonth(
            month: _selectedMonth,
            getSpentAmount: txCtrl.getSpentAmountFor,
          ),
          builder: (context, vms, _) {
            if (vms.isEmpty && !_isMonthLoading) {
              return _buildEmptyState();
            }
            
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
              itemCount: vms.length,
              itemBuilder: (context, index) {
                final vm = vms[index];
                
                return SpendingTargetCard(
                  key: ValueKey('${vm.category}_${vm.syncStatus}_$_selectedMonth'),
                  vm: vm,
                  onTap: () => _handleNavigateToEdit(vm.category),
                );
              },
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: SavaioTheme.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: SavaioTheme.primary, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: AppHeading(_formattedMonth ?? '', size: AppHeadingSize.h3),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.calendar_month_rounded, 
            color: _isMonthLoading ? SavaioTheme.onSurfaceVariant.withValues(alpha: 0.3) : SavaioTheme.primary
          ),
          onPressed: _isMonthLoading ? null : _showMonthPicker,
        ),
      ],
      bottom: _isMonthLoading 
        ? const PreferredSize(
            preferredSize: Size.fromHeight(2),
            child: LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(SavaioTheme.primary),
            ),
          )
        : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: SavaioTheme.onSurfaceVariant.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const AppHeading('Belum ada kategori', size: AppHeadingSize.subtitle, color: SavaioTheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class SpendingTargetCard extends StatefulWidget {
  final SpendingTargetItemVM vm;
  final VoidCallback? onTap;

  const SpendingTargetCard({
    super.key,
    required this.vm,
    this.onTap,
  });

  @override
  State<SpendingTargetCard> createState() => _SpendingTargetCardState();
}

class _SpendingTargetCardState extends State<SpendingTargetCard> {
  double _oldProgress = 0.0;
  bool _showSuccessCheck = false;

  @override
  void didUpdateWidget(covariant SpendingTargetCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vm.progress != widget.vm.progress) {
      _oldProgress = oldWidget.vm.progress;
    }
    
    // Success feedback
    if (oldWidget.vm.syncStatus != SyncStatus.synced && widget.vm.syncStatus == SyncStatus.synced) {
      _triggerSuccessCheck();
    }
  }

  void _triggerSuccessCheck() {
    if (!mounted) return;
    setState(() => _showSuccessCheck = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSuccessCheck = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.vm.category == 'All' ? 'Total Pengeluaran' : widget.vm.category;
    final isSyncing = widget.vm.syncStatus == SyncStatus.syncing;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isSyncing ? 0.75 : 1.0,
        child: InkWell(
          onTap: isSyncing ? null : widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 20,
            child: Column(
              children: [
                Row(
                  children: [
                    AppIconContainer(
                      icon: widget.vm.iconData ?? widget.vm.emoji ?? Icons.category,
                      size: 40,
                      color: SavaioTheme.primary,
                      opacity: 0.1,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppHeading(displayName, size: AppHeadingSize.subtitle),
                          const SizedBox(height: 4),
                          Text(
                            widget.vm.target > 0 
                                ? 'Target: ${SavaioTheme.formatCurrency(widget.vm.target)}'
                                : 'Target belum diatur',
                            style: TextStyle(
                              fontSize: 12, 
                              color: widget.vm.target > 0 ? SavaioTheme.onSurfaceVariant : SavaioTheme.onSurfaceVariant.withValues(alpha: 0.5)
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSyncStatusIndicator(),
                  ],
                ),
                if (widget.vm.target > 0) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${SavaioTheme.formatCurrency(widget.vm.spent)} terpakai',
                        style: const TextStyle(fontSize: 11, color: SavaioTheme.onSurfaceVariant),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          widget.vm.isOver ? 'Over Budget!' : '${(widget.vm.progress * 100).toStringAsFixed(0)}%',
                          key: ValueKey('${widget.vm.category}_${widget.vm.progress}_${widget.vm.syncStatus}'),
                          style: TextStyle(
                            fontSize: 11, 
                            fontWeight: FontWeight.bold,
                            color: widget.vm.isOver ? SavaioTheme.error : SavaioTheme.tertiary
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(begin: _oldProgress, end: widget.vm.progress),
                    builder: (context, value, _) {
                      return AppProgressBar(
                        value: value,
                        color: widget.vm.isOver ? SavaioTheme.error : (value > 0.8 ? Colors.orange : SavaioTheme.tertiary),
                        height: 6,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncStatusIndicator() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _showSuccessCheck 
        ? const Icon(Icons.check_circle_rounded, color: SavaioTheme.tertiary, size: 20, key: ValueKey('success'))
        : _getIconForStatus(widget.vm.syncStatus),
    );
  }

  Widget _getIconForStatus(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return const Icon(Icons.chevron_right_rounded, color: SavaioTheme.onSurfaceVariant, key: ValueKey('idle'));
      case SyncStatus.pending:
        return const Icon(Icons.cloud_upload_outlined, color: SavaioTheme.onSurfaceVariant, size: 20, key: ValueKey('pending'));
      case SyncStatus.syncing:
        return const SizedBox(
          width: 16,
          height: 16,
          key: ValueKey('syncing'),
          child: CircularProgressIndicator(strokeWidth: 2, color: SavaioTheme.primary),
        );
      case SyncStatus.failed:
        return const Icon(Icons.error_outline_rounded, color: SavaioTheme.error, size: 20, key: ValueKey('failed'));
      case SyncStatus.synced:
        return const Icon(Icons.chevron_right_rounded, color: SavaioTheme.onSurfaceVariant, key: ValueKey('synced'));
    }
  }
}
