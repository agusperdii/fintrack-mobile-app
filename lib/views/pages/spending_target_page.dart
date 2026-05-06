import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/controllers/budget_controller.dart';
import 'package:savaio/controllers/transaction_controller.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';
import 'package:savaio/views/components/atoms/app_button.dart';
import 'package:savaio/views/components/atoms/app_icon_container.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_progress_bar.dart';
import 'package:savaio/views/components/molecules/app_date_time_picker.dart';
import 'package:savaio/views/components/molecules/selection_card.dart';
import 'package:savaio/models/budget_model.dart';
import 'package:savaio/models/app_data.dart';

class SpendingTargetPage extends StatefulWidget {
  final String? initialCategory;
  const SpendingTargetPage({super.key, this.initialCategory});

  @override
  State<SpendingTargetPage> createState() => _SpendingTargetPageState();
}

class _SpendingTargetPageState extends State<SpendingTargetPage> {
  final TextEditingController _amountController = TextEditingController();
  late String _selectedCategory = 'All';
  String _selectedMonth = '';
  double _originalAmount = 0.0;
  bool _isSavingLocal = false; 

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    
    String initial = widget.initialCategory ?? 'All';
    final categories = sl.budgetController.categories;
    try {
      final match = categories.firstWhere(
        (c) => c['name'].toString().toLowerCase() == initial.toLowerCase(),
      );
      _selectedCategory = match['name'] as String;
    } catch (_) {
      _selectedCategory = 'All';
    }
    
    _loadBudgetData();
    sl.transactionController.fetchTransactions(month: _selectedMonth);
  }

  void _loadBudgetData() {
    final budgets = sl.budgetController.allBudgets;
    
    // Find precise match or fallback
    final budget = budgets.firstWhere(
      (b) => b.category.toLowerCase() == _selectedCategory.toLowerCase() && b.month == _selectedMonth,
      orElse: () => budgets.firstWhere(
        (b) => b.category.toLowerCase() == _selectedCategory.toLowerCase(),
        orElse: () => BudgetModel(
          id: '', 
          amount: 0.0, 
          periodType: 'monthly', 
          month: _selectedMonth, 
          category: _selectedCategory,
          syncStatus: SyncStatus.idle,
        ),
      ),
    );
    
    _originalAmount = budget.amount;
    _amountController.text = budget.amount > 0 
        ? budget.amount.toStringAsFixed(0) 
        : '';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _saveTarget() {
    final amountText = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(amountText) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tolong masukkan nominal yang valid di atas 0')),
      );
      return;
    }

    if (amount == _originalAmount) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isSavingLocal = true);

    sl.budgetController.updateSpendingTargetOptimistic(
      amount,
      'monthly',
      category: _selectedCategory,
      month: _selectedMonth,
    );

    Navigator.pop(context, true);
  }

  String _formatMonth(String month) {
    final parts = month.split('-');
    if (parts.length != 2) return month;
    const months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    final m = int.tryParse(parts[1]) ?? 0;
    return '${months[m]} ${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    final budgetController = context.watch<BudgetController>();
    final transactionController = context.watch<TransactionController>();

    final categories = [
      {'name': 'All', 'icon': Icons.all_inclusive, 'isEmoji': false},
      ...budgetController.categories
    ];

    final currentSpent = transactionController.getSpentAmountFor(_selectedCategory, _selectedMonth);
    final inputAmount = double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0.0;
    final progress = inputAmount > 0 ? (currentSpent / inputAmount).clamp(0.0, 1.0) : 0.0;
    final isOver = currentSpent > inputAmount && inputAmount > 0;
    
    final isUnchanged = inputAmount == _originalAmount || inputAmount <= 0;

    return Scaffold(
      backgroundColor: SavaioTheme.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSelection(budgetController, categories),
            const SizedBox(height: 32),
            _buildAmountInputCard(),
            if (budgetController.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Text(
                    budgetController.error!,
                    style: const TextStyle(color: SavaioTheme.error, fontSize: 12),
                  ),
                ),
              ),
            const SizedBox(height: 32),
            _buildStatusSection(currentSpent, inputAmount, progress, isOver),
            const SizedBox(height: 24),
            _buildInsightCard(inputAmount, currentSpent, isOver),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(isUnchanged),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: SavaioTheme.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: SavaioTheme.primary),
        onPressed: () => Navigator.pop(context),
      ),
      title: const AppHeading('Atur Alokasi Dana', size: AppHeadingSize.h3),
      centerTitle: true,
    );
  }

  Widget _buildHeaderSelection(BudgetController budgetController, List<Map<String, dynamic>> categories) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SelectionCard(
            label: 'BULAN',
            value: _formatMonth(_selectedMonth),
            icon: Icons.calendar_month_rounded,
            onTap: _showMonthPicker,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: SelectionCard(
            label: 'KATEGORI',
            value: _selectedCategory == 'All' ? 'Total' : _selectedCategory,
            icon: budgetController.getCategoryIcon(_selectedCategory),
            onTap: () => _showCategoryPicker(categories),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInputCard() {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      borderRadius: 24,
      child: Column(
        children: [
          const AppHeading(
            'LIMIT PENGELUARAN',
            size: AppHeadingSize.caption,
            color: SavaioTheme.onSurfaceVariant,
            isBold: true,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Rp',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: SavaioTheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              IntrinsicWidth(
                child: TextField(
                  controller: _amountController,
                  autofocus: false,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: SavaioTheme.onSurface,
                    letterSpacing: -1,
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: SavaioTheme.onSurface.withValues(alpha: 0.2)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuickAdd(100000),
              const SizedBox(width: 8),
              _buildQuickAdd(500000),
              const SizedBox(width: 8),
              _buildQuickAdd(1000000),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(double currentSpent, double targetAmount, double progress, bool isOver) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppHeading('STATUS PENGGUNAAN', size: AppHeadingSize.caption, color: SavaioTheme.primary, isBold: true),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: SavaioTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SavaioTheme.outlineVariant.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Terpakai saat ini', style: TextStyle(fontSize: 12, color: SavaioTheme.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      AppHeading(SavaioTheme.formatCurrency(currentSpent), size: AppHeadingSize.subtitle),
                    ],
                  ),
                  if (targetAmount > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Sisa', style: TextStyle(fontSize: 12, color: SavaioTheme.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        AppHeading(
                          SavaioTheme.formatCurrency(isOver ? 0 : targetAmount - currentSpent),
                          size: AppHeadingSize.subtitle,
                          color: isOver ? SavaioTheme.error : SavaioTheme.tertiary,
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 20),
              AppProgressBar(
                value: progress,
                color: isOver ? SavaioTheme.error : (progress > 0.8 ? Colors.orange : SavaioTheme.tertiary),
                height: 8,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isOver ? 'Melebihi Budget!' : '${(progress * 100).toStringAsFixed(0)}% Terpakai',
                    style: TextStyle(
                      fontSize: 11, 
                      fontWeight: FontWeight.bold,
                      color: isOver ? SavaioTheme.error : SavaioTheme.onSurfaceVariant
                    ),
                  ),
                  Text(
                    'Target: ${SavaioTheme.formatCurrency(targetAmount)}',
                    style: const TextStyle(fontSize: 11, color: SavaioTheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(double targetAmount, double currentSpent, bool isOver) {
    if (targetAmount <= 0) return const SizedBox.shrink();
    
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      color: SavaioTheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: SavaioTheme.secondary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isOver 
                ? 'Waduh! Pengeluaran kamu sudah lewat dari target. Yuk, lebih ketat lagi!'
                : 'Batas harian kamu: ${SavaioTheme.formatCurrency((targetAmount - currentSpent) / 30)} untuk sisa bulan ini.',
              style: const TextStyle(fontSize: 12, color: SavaioTheme.onSurface, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(bool isUnchanged) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [SavaioTheme.background.withValues(alpha: 0), SavaioTheme.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: AppButton(
        label: isUnchanged ? 'TIDAK ADA PERUBAHAN' : 'SIMPAN PERUBAHAN',
        variant: isUnchanged ? AppButtonVariant.secondary : AppButtonVariant.primary,
        onTap: (isUnchanged || _isSavingLocal) ? null : _saveTarget,
      ),
    );
  }

  Widget _buildQuickAdd(double amount) {
    return InkWell(
      onTap: () {
        final current = double.tryParse(_amountController.text) ?? 0.0;
        _amountController.text = (current + amount).toStringAsFixed(0);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: SavaioTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: SavaioTheme.primary.withValues(alpha: 0.2)),
        ),
        child: Text(
          '+${(amount/1000).toStringAsFixed(0)}rb',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: SavaioTheme.primary),
        ),
      ),
    );
  }

  void _showMonthPicker() async {
    final picked = await AppDateTimePicker.showMonthPicker(
      context: context,
      initialMonth: _selectedMonth,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
        _loadBudgetData();
        sl.transactionController.fetchTransactions(month: _selectedMonth);
      });
    }
  }

  void _showCategoryPicker(List<Map<String, dynamic>> categories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SavaioTheme.surfaceContainer,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppHeading('Pilih Kategori', size: AppHeadingSize.h3),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  final name = cat['name'] as String;
                  return ListTile(
                    leading: AppIconContainer(
                      icon: cat['icon'],
                      size: 32,
                      color: _selectedCategory == name ? SavaioTheme.primary : SavaioTheme.onSurfaceVariant,
                      opacity: 0.1,
                    ),
                    title: Text(name == 'All' ? 'Total Semua' : name, 
                      style: TextStyle(color: _selectedCategory == name ? SavaioTheme.primary : SavaioTheme.onSurface)),
                    trailing: _selectedCategory == name ? const Icon(Icons.check_circle, color: SavaioTheme.primary) : null,
                    onTap: () {
                      setState(() {
                        _selectedCategory = name;
                        _loadBudgetData();
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
