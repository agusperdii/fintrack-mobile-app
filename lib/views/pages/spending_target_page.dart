import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/service_locator.dart';
import '../components/atoms/glass_card.dart';
import '../components/atoms/app_button.dart';
import '../components/atoms/app_icon_container.dart';
import '../components/atoms/app_heading.dart';
import '../components/atoms/app_progress_bar.dart';

class SpendingTargetPage extends StatefulWidget {
  final String? initialCategory;
  const SpendingTargetPage({super.key, this.initialCategory});

  @override
  State<SpendingTargetPage> createState() => _SpendingTargetPageState();
}

class _SpendingTargetPageState extends State<SpendingTargetPage> {
  final _amountController = TextEditingController();
  late String _selectedCategory;
  late String _selectedMonth;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    
    // Normalize category selection: Find case-insensitive match
    String initial = widget.initialCategory ?? 'All';
    final categories = sl.financeController.categories;
    try {
      final match = categories.firstWhere(
        (c) => c['name'].toString().toLowerCase() == initial.toLowerCase(),
      );
      _selectedCategory = match['name'] as String;
    } catch (_) {
      _selectedCategory = 'All';
    }
    
    _loadBudgetData();
    // Ensure transactions are loaded for spending comparison
    sl.financeController.fetchTransactions(month: _selectedMonth);
  }

  void _loadBudgetData() {
    final budgets = sl.financeController.allBudgets;
    final budget = budgets.firstWhere(
      (b) => b['category'] == _selectedCategory && b['period'] == _selectedMonth,
      orElse: () => budgets.firstWhere(
        (b) => b['category'] == _selectedCategory,
        orElse: () => {'amount': 0.0, 'period': 'Bulanan'},
      ),
    );
    
    _amountController.text = (budget['amount'] as double) > 0 
        ? (budget['amount'] as double).toStringAsFixed(0) 
        : '';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveTarget() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal target pengeluaran'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal tidak valid'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    await sl.financeController.updateSpendingTarget(
      amount, 
      'Bulanan', 
      category: _selectedCategory,
      month: _selectedMonth,
    );
    
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Target pengeluaran berhasil disimpan'),
          backgroundColor: KineticVaultTheme.tertiary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
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
    return ListenableBuilder(
      listenable: sl.financeController,
      builder: (context, _) {
        final provider = sl.financeController;
        final categories = [
          {'name': 'All', 'icon': Icons.all_inclusive, 'isEmoji': false},
          ...provider.categories
        ];

        // Generate months
        final now = DateTime.now();
        final monthList = List.generate(6, (i) {
          final date = DateTime(now.year, now.month - 2 + i, 1);
          return "${date.year}-${date.month.toString().padLeft(2, '0')}";
        });

        final currentSpent = provider.getSpentAmountFor(_selectedCategory, _selectedMonth);
        final targetAmount = double.tryParse(_amountController.text) ?? 0.0;
        final progress = targetAmount > 0 ? (currentSpent / targetAmount).clamp(0.0, 1.0) : 0.0;
        final isOver = currentSpent > targetAmount && targetAmount > 0;

        return Scaffold(
          backgroundColor: KineticVaultTheme.background,
          appBar: AppBar(
            backgroundColor: KineticVaultTheme.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: KineticVaultTheme.primary),
              onPressed: () => Navigator.pop(context),
            ),
            title: AppHeading('Atur Alokasi Dana', size: AppHeadingSize.h3),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Month & Category Selection Row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildSelectionCard(
                        label: 'BULAN',
                        value: _formatMonth(_selectedMonth),
                        icon: Icons.calendar_month_rounded,
                        onTap: () => _showMonthPicker(monthList),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: _buildSelectionCard(
                        label: 'KATEGORI',
                        value: _selectedCategory == 'All' ? 'Total' : _selectedCategory,
                        icon: provider.getCategoryIcon(_selectedCategory) is IconData 
                            ? provider.getCategoryIcon(_selectedCategory) as IconData
                            : Icons.category_rounded,
                        onTap: () => _showCategoryPicker(categories),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // 2. Main Input Card
                GlassCard(
                  padding: const EdgeInsets.all(32),
                  borderRadius: 24,
                  child: Column(
                    children: [
                      AppHeading(
                        'LIMIT PENGELUARAN',
                        size: AppHeadingSize.caption,
                        color: KineticVaultTheme.onSurfaceVariant,
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
                              color: KineticVaultTheme.primary,
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
                                color: KineticVaultTheme.onSurface,
                                letterSpacing: -1,
                              ),
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(color: KineticVaultTheme.onSurface.withValues(alpha: 0.2)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Quick actions
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
                ),
                
                const SizedBox(height: 32),

                // 3. Dynamic Progress/Insight Section
                AppHeading('STATUS PENGGUNAAN', size: AppHeadingSize.caption, color: KineticVaultTheme.primary, isBold: true),
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: KineticVaultTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: KineticVaultTheme.outlineVariant.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Terpakai saat ini', style: TextStyle(fontSize: 12, color: KineticVaultTheme.onSurfaceVariant)),
                              const SizedBox(height: 4),
                              AppHeading(KineticVaultTheme.formatCurrency(currentSpent), size: AppHeadingSize.subtitle),
                            ],
                          ),
                          if (targetAmount > 0)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Sisa', style: TextStyle(fontSize: 12, color: KineticVaultTheme.onSurfaceVariant)),
                                const SizedBox(height: 4),
                                AppHeading(
                                  KineticVaultTheme.formatCurrency(isOver ? 0 : targetAmount - currentSpent),
                                  size: AppHeadingSize.subtitle,
                                  color: isOver ? KineticVaultTheme.error : KineticVaultTheme.tertiary,
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AppProgressBar(
                        value: progress,
                        color: isOver ? KineticVaultTheme.error : (progress > 0.8 ? Colors.orange : KineticVaultTheme.tertiary),
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
                              color: isOver ? KineticVaultTheme.error : KineticVaultTheme.onSurfaceVariant
                            ),
                          ),
                          Text(
                            'Target: ${KineticVaultTheme.formatCurrency(targetAmount)}',
                            style: const TextStyle(fontSize: 11, color: KineticVaultTheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                
                // 4. Smart Insight Card
                if (targetAmount > 0)
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 16,
                    color: KineticVaultTheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: KineticVaultTheme.secondary, size: 20),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            isOver 
                              ? 'Waduh! Pengeluaran kamu sudah lewat dari target. Yuk, lebih ketat lagi!'
                              : 'Batas harian kamu: ${KineticVaultTheme.formatCurrency((targetAmount - currentSpent) / 30)} untuk sisa bulan ini.',
                            style: const TextStyle(fontSize: 12, color: KineticVaultTheme.onSurface, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [KineticVaultTheme.background.withValues(alpha: 0), KineticVaultTheme.background],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: AppButton(
              label: 'SIMPAN PERUBAHAN',
              isLoading: _isSaving,
              onTap: _saveTarget,
            ),
          ),
        );
      }
    );
  }

  Widget _buildSelectionCard({
    required String label,
    required String value,
    required dynamic icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KineticVaultTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: KineticVaultTheme.outlineVariant.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: KineticVaultTheme.primary, letterSpacing: 1)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icon is IconData ? icon : Icons.category, size: 16, color: KineticVaultTheme.onSurface),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value, 
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: KineticVaultTheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
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
          color: KineticVaultTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: KineticVaultTheme.primary.withValues(alpha: 0.2)),
        ),
        child: Text(
          '+${(amount/1000).toStringAsFixed(0)}rb',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: KineticVaultTheme.primary),
        ),
      ),
    );
  }

  void _showMonthPicker(List<String> months) {
    showModalBottomSheet(
      context: context,
      backgroundColor: KineticVaultTheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppHeading('Pilih Bulan', size: AppHeadingSize.h3),
            const SizedBox(height: 20),
            ...months.map((m) => ListTile(
              title: Text(_formatMonth(m), style: TextStyle(color: _selectedMonth == m ? KineticVaultTheme.primary : KineticVaultTheme.onSurface)),
              trailing: _selectedMonth == m ? const Icon(Icons.check_circle, color: KineticVaultTheme.primary) : null,
              onTap: () {
                setState(() {
                  _selectedMonth = m;
                  _loadBudgetData();
                  sl.financeController.fetchTransactions(month: _selectedMonth);
                });
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(List<Map<String, dynamic>> categories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: KineticVaultTheme.surfaceContainer,
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
                      color: _selectedCategory == name ? KineticVaultTheme.primary : KineticVaultTheme.onSurfaceVariant,
                      opacity: 0.1,
                    ),
                    title: Text(name == 'All' ? 'Total Semua' : name, 
                      style: TextStyle(color: _selectedCategory == name ? KineticVaultTheme.primary : KineticVaultTheme.onSurface)),
                    trailing: _selectedCategory == name ? const Icon(Icons.check_circle, color: KineticVaultTheme.primary) : null,
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
