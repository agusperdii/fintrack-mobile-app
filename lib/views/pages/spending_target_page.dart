import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/controllers/budget_controller.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';
import 'package:savaio/views/components/atoms/app_button.dart';
import 'package:savaio/views/components/atoms/app_icon_container.dart';
import 'package:savaio/controllers/auth_controller.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_progress_bar.dart';
import 'package:savaio/views/components/molecules/app_date_time_picker.dart';
import 'package:savaio/views/components/molecules/selection_card.dart';
import 'package:savaio/models/budget_model.dart';
import 'package:savaio/models/app_data.dart' as model;

class SpendingTargetPage extends StatefulWidget {
  final String? initialCategoryId;
  final String? initialMonth;
  const SpendingTargetPage({super.key, this.initialCategoryId, this.initialMonth});

  @override
  State<SpendingTargetPage> createState() => _SpendingTargetPageState();
}

class _SpendingTargetPageState extends State<SpendingTargetPage> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedCategoryId;
  String _selectedMonth = '';
  double _originalAmount = 0.0;
  bool _isSavingLocal = false; 

  @override
  void initState() {
    super.initState();
    if (widget.initialMonth != null) {
      _selectedMonth = widget.initialMonth!;
    } else {
      final now = DateTime.now();
      _selectedMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    }
    
    final categories = sl.budgetController.categories.where((c) => c['type'] == 'expense').toList();
    if (widget.initialCategoryId != null) {
      _selectedCategoryId = widget.initialCategoryId;
    } else if (categories.isNotEmpty) {
      _selectedCategoryId = categories.first['id'] as String;
    }
    
    _loadBudgetData();
    sl.budgetController.fetchAll(month: _selectedMonth);
  }

  void _loadBudgetData() {
    if (_selectedCategoryId == null) return;

    final budgets = sl.budgetController.allBudgets;
    
    // Find precise match for this month
    final budget = budgets.firstWhere(
      (b) => b.categoryId == _selectedCategoryId && b.startMonth == _selectedMonth,
      orElse: () => BudgetModel(
        id: '',
        amount: 0.0,
        startMonth: _selectedMonth,
        categoryId: _selectedCategoryId,
        syncStatus: model.SyncStatus.idle,
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

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tolong pilih kategori')),
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
      categoryId: _selectedCategoryId!,
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
    final currency = context.watch<AuthController>().currency;

    final categories = budgetController.categories.where((c) => c['type'] == 'expense').toList();
    
    // Find current status for selected category
    SpendingTargetItemVM? currentTarget;
    try {
      final targets = budgetController.getSpendingTargetsForMonth(month: _selectedMonth);
      currentTarget = targets.firstWhere((t) => t.categoryId == _selectedCategoryId);
    } catch (_) {}

    final currentSpent = currentTarget?.spent ?? 0.0;
    final inputAmount = double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0.0;
    final progress = inputAmount > 0 ? (currentSpent / inputAmount).clamp(0.0, 1.0) : 0.0;
    final isOver = currentSpent > inputAmount && inputAmount > 0;
    
    final isUnchanged = inputAmount == _originalAmount || inputAmount <= 0;

    return Scaffold(
      backgroundColor: SavaioTheme.backgroundOf(context),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSelection(budgetController, categories),
            SizedBox(height: 32),
            _buildAmountInputCard(),
            if (budgetController.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Text(
                    budgetController.error!,
                    style: TextStyle(color: SavaioTheme.errorOf(context), fontSize: 12),
                  ),
                ),
              ),
            SizedBox(height: 32),
            _buildStatusSection(currentSpent, inputAmount, progress, isOver, currency),
            SizedBox(height: 24),
            _buildInsightCard(inputAmount, currentSpent, isOver, currency),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(isUnchanged),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: SavaioTheme.backgroundOf(context),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: SavaioTheme.primaryOf(context)),
        onPressed: () => Navigator.pop(context),
      ),
      title: AppHeading('Atur Budget', size: AppHeadingSize.h3),
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
        SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: SelectionCard(
            label: 'KATEGORI',
            value: budgetController.getCategoryName(_selectedCategoryId),
            icon: budgetController.getCategoryIcon(_selectedCategoryId),
            onTap: () => _showCategoryPicker(categories, budgetController),
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
          AppHeading(
            'LIMIT PENGELUARAN',
            size: AppHeadingSize.caption,
            color: SavaioTheme.onSurfaceVariantOf(context),
            isBold: true,
          ),
          SizedBox(height: 16),
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
                  color: SavaioTheme.primaryOf(context),
                ),
              ),
              SizedBox(width: 8),
              IntrinsicWidth(
                child: TextField(
                  controller: _amountController,
                  autofocus: false,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: SavaioTheme.onSurfaceOf(context),
                    letterSpacing: -1,
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: SavaioTheme.onSurfaceOf(context).withValues(alpha: 0.2)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuickAdd(100000),
              SizedBox(width: 8),
              _buildQuickAdd(500000),
              SizedBox(width: 8),
              _buildQuickAdd(1000000),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(double currentSpent, double targetAmount, double progress, bool isOver, String currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppHeading('STATUS PENGGUNAAN', size: AppHeadingSize.caption, color: SavaioTheme.primaryOf(context), isBold: true),
        SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: SavaioTheme.surfaceContainerLowOf(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SavaioTheme.outlineVariantOf(context).withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Terpakai saat ini', style: TextStyle(fontSize: 12, color: SavaioTheme.onSurfaceVariantOf(context))),
                      SizedBox(height: 4),
                      AppHeading(SavaioTheme.formatCurrency(currentSpent, currency: currency), size: AppHeadingSize.subtitle),
                    ],
                  ),
                  if (targetAmount > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Sisa', style: TextStyle(fontSize: 12, color: SavaioTheme.onSurfaceVariantOf(context))),
                        SizedBox(height: 4),
                        AppHeading(
                          SavaioTheme.formatCurrency(isOver ? 0 : targetAmount - currentSpent, currency: currency),
                          size: AppHeadingSize.subtitle,
                          color: isOver ? SavaioTheme.errorOf(context) : SavaioTheme.tertiaryOf(context),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 20),
              AppProgressBar(
                value: progress,
                color: isOver ? SavaioTheme.errorOf(context) : (progress > 0.8 ? SavaioTheme.errorOf(context).withValues(alpha: 0.7) : SavaioTheme.tertiaryOf(context)),
                height: 8,
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isOver ? 'Melebihi Budget!' : '${(progress * 100).toStringAsFixed(0)}% Terpakai',
                    style: TextStyle(
                      fontSize: 11, 
                      fontWeight: FontWeight.bold,
                      color: isOver ? SavaioTheme.errorOf(context) : SavaioTheme.onSurfaceVariantOf(context)
                    ),
                  ),
                  Text(
                    'Target: ${SavaioTheme.formatCurrency(targetAmount, currency: currency)}',
                    style: TextStyle(fontSize: 11, color: SavaioTheme.onSurfaceVariantOf(context)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(double targetAmount, double currentSpent, bool isOver, String currency) {
    if (targetAmount <= 0) return const SizedBox.shrink();
    
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      color: SavaioTheme.surfaceContainerHighestOf(context).withValues(alpha: 0.3),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: SavaioTheme.secondaryOf(context), size: 20),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              isOver 
                ? 'Waduh! Pengeluaran kamu sudah lewat dari target. Yuk, lebih ketat lagi!'
                : 'Batas harian kamu: ${SavaioTheme.formatCurrency((targetAmount - currentSpent) / 30, currency: currency)} untuk sisa bulan ini.',
              style: TextStyle(fontSize: 12, color: SavaioTheme.onSurfaceOf(context), height: 1.5),
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
          colors: [SavaioTheme.backgroundOf(context).withValues(alpha: 0), SavaioTheme.backgroundOf(context)],
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
        final currentText = _amountController.text.replaceAll('.', '');
        final current = double.tryParse(currentText) ?? 0.0;
        _amountController.text = (current + amount).toStringAsFixed(0);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: SavaioTheme.primaryOf(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: SavaioTheme.primaryOf(context).withValues(alpha: 0.2)),
        ),
        child: Text(
          '+${(amount/1000).toStringAsFixed(0)}rb',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: SavaioTheme.primaryOf(context)),
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
        sl.budgetController.fetchAll(month: _selectedMonth);
      });
    }
  }

  void _showCategoryPicker(List<Map<String, dynamic>> categories, BudgetController budgetController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SavaioTheme.surfaceContainerOf(context),
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
            AppHeading('Pilih Kategori', size: AppHeadingSize.h3),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  final id = cat['id'] as String;
                  final name = cat['name'] as String;
                  return ListTile(
                    leading: AppIconContainer(
                      icon: cat['icon'],
                      size: 32,
                      color: _selectedCategoryId == id ? SavaioTheme.primaryOf(context) : SavaioTheme.onSurfaceVariantOf(context),
                      opacity: 0.1,
                    ),
                    title: Text(name, 
                      style: TextStyle(color: _selectedCategoryId == id ? SavaioTheme.primaryOf(context) : SavaioTheme.onSurfaceOf(context))),
                    trailing: _selectedCategoryId == id ? Icon(Icons.check_circle, color: SavaioTheme.primaryOf(context)) : null,
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = id;
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
