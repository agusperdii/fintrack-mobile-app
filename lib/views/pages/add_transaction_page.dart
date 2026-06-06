import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/controllers/budget_controller.dart';
import 'package:savaio/controllers/transaction_controller.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_button.dart';
import 'package:savaio/views/components/atoms/app_progress_bar.dart';
import 'package:savaio/views/components/molecules/app_date_time_picker.dart';
import 'package:savaio/views/components/molecules/transaction_amount_input.dart';
import 'package:savaio/views/components/molecules/transaction_type_toggle.dart';
import 'package:savaio/views/components/organisms/transaction_category_grid.dart';
import 'package:savaio/views/components/organisms/add_category_sheet.dart';
import 'package:savaio/views/components/organisms/notifications/app_snackbar.dart';
import 'package:savaio/views/pages/ocr_scan_page.dart';

class AddTransactionPage extends StatefulWidget {
  final String? initialTitle;
  final double? initialAmount;
  final String? initialCategory;
  final String? initialType;
  final String? initialReceiptId;
  final String? source;

  const AddTransactionPage({
    super.key,
    this.initialTitle,
    this.initialAmount,
    this.initialCategory,
    this.initialType,
    this.initialReceiptId,
    this.source,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  String _type = 'Expense'; 
  late final TextEditingController _titleController; 
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  String? _selectedCategoryId;
  String _selectedCategoryName = 'Food';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? 'Expense';
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController();
    _amountController = TextEditingController(
      text: widget.initialAmount != null ? widget.initialAmount!.toStringAsFixed(0) : '',
    );
    
    // Initial category logic
    final categories = sl.budgetController.categories.where(
      (c) => c['type'].toString().toLowerCase() == _type.toLowerCase()
    ).toList();
    final initialName = widget.initialCategory ?? (widget.initialType == 'Income' ? 'Salary' : 'Food');
    
    try {
      final cat = categories.firstWhere(
        (c) => c['name'].toString().toLowerCase() == initialName.toLowerCase(),
        orElse: () => categories.first,
      );
      _selectedCategoryId = cat['id']?.toString();
      _selectedCategoryName = cat['name'].toString();
    } catch (_) {
      if (categories.isNotEmpty) {
        _selectedCategoryId = categories.first['id']?.toString();
        _selectedCategoryName = categories.first['name'].toString();
      } else {
        _selectedCategoryName = initialName;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onQuickAmountTap(double amount) {
    final current = double.tryParse(_amountController.text) ?? 0.0;
    _amountController.text = (current + amount).toStringAsFixed(0);
    setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await AppDateTimePicker.show(
      context: context,
      initialDate: _selectedDate,
      mode: CupertinoDatePickerMode.date,
      title: 'Pilih Tanggal',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await AppDateTimePicker.show(
      context: context,
      initialDate: _selectedDate,
      mode: CupertinoDatePickerMode.time,
      title: 'Pilih Jam',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _submitData() async {
    // 1. Validation
    if (_amountController.text.isEmpty || double.tryParse(_amountController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tolong masukkan nominal yang valid')));
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tolong pilih kategori')));
      return;
    }

    // 2. Create Transaction
    final transactionController = context.read<TransactionController>();
    
    try {
      await transactionController.createTransactionOptimistic(
        dashboardController: sl.dashboardController,
        title: _titleController.text.isEmpty ? 'Transaksi $_selectedCategoryName' : _titleController.text,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        categoryId: _selectedCategoryId!,
        type: _type.toLowerCase() == 'expense' ? 'expense' : 'income',
        date: _selectedDate,
        receiptId: widget.initialReceiptId,
        source: widget.source ?? 'manual',
      );

      // 3. Navigation back to Dashboard on success
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan transaksi: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  void _showAddCategorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCategorySheet(
        type: _type,
        onAdd: (name, icon) async {
          final id = await sl.budgetController.addCustomCategory(name, icon, type: _type.toLowerCase());
          if (mounted) {
            setState(() {
              _selectedCategoryId = id;
              _selectedCategoryName = name;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetController = context.watch<BudgetController>();

    return Scaffold(
      backgroundColor: SavaioTheme.backgroundOf(context),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TransactionAmountInput(
                  controller: _amountController,
                  onQuickAmountTap: _onQuickAmountTap,
                ),
                const SizedBox(height: 32),
                TransactionTypeToggle(
                  currentType: _type,
                  onTypeChanged: (type) {
                    setState(() {
                      _type = type;
                      // Update categories based on new type
                      final filtered = budgetController.categories.where(
                        (c) => c['type'].toString().toLowerCase() == type.toLowerCase()
                      ).toList();
                      
                      // If current selected category is not in the filtered list, pick first one
                      if (_selectedCategoryId != null) {
                        final isStillValid = filtered.any((c) => c['id'] == _selectedCategoryId);
                        if (!isStillValid && filtered.isNotEmpty) {
                          _selectedCategoryId = filtered.first['id']?.toString();
                          _selectedCategoryName = filtered.first['name'].toString();
                        }
                      } else if (filtered.isNotEmpty) {
                        _selectedCategoryId = filtered.first['id']?.toString();
                        _selectedCategoryName = filtered.first['name'].toString();
                      }
                    });
                  },
                ),
                const SizedBox(height: 40),
                _buildTitleSection(),
                const SizedBox(height: 16),
                _buildDateTimeSection(),
                const SizedBox(height: 32),
                TransactionCategoryGrid(
                  categories: budgetController.categories.where(
                    (c) => c['type'].toString().toLowerCase() == _type.toLowerCase()
                  ).toList(),
                  selectedCategoryId: _selectedCategoryId,
                  onCategorySelected: (cat) {
                    setState(() {
                      _selectedCategoryId = cat['id']?.toString();
                      _selectedCategoryName = cat['name'].toString();
                    });
                  },
                  onDeleteCategory: (id) async {
                    final success = await sl.budgetController.deleteCategory(id);
                    if (!context.mounted) return;
                    if (success) {
                      AppSnackBar.show(
                        context, 
                        'Kategori berhasil dihapus',
                        type: AppSnackBarType.success,
                        minimal: true,
                        duration: const Duration(milliseconds: 500),
                      );
                      // Reset selection if deleted category was selected
                      if (_selectedCategoryId == id) {
                        final remaining = budgetController.categories.where(
                          (c) => c['type'].toString().toLowerCase() == _type.toLowerCase()
                        ).toList();
                        if (remaining.isNotEmpty) {
                          setState(() {
                            _selectedCategoryId = remaining.first['id']?.toString();
                            _selectedCategoryName = remaining.first['name'].toString();
                          });
                        }
                      }
                    } else {
                      AppSnackBar.show(
                        context, 
                        sl.budgetController.error ?? 'Gagal menghapus kategori',
                        type: AppSnackBarType.error,
                      );
                    }
                  },
                  onAddCategoryTap: _showAddCategorySheet,
                ),
                const SizedBox(height: 32),
                _buildNotesSection(),
                const SizedBox(height: 24),
                _buildProgressCard(),
                const SizedBox(height: 120), 
              ],
            ),
          ),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: SavaioTheme.backgroundOf(context),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.close, color: Theme.of(context).colorScheme.primary),
        onPressed: () => Navigator.pop(context),
      ),
      title: AppHeading(
        'Tambah Transaksi',
        size: AppHeadingSize.h3,
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OcrScanPage()),
            );
          },
          icon: Icon(Icons.document_scanner_outlined, color: Theme.of(context).colorScheme.primary),
          tooltip: 'Scan Struk (OCR)',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTitleSection() {
    return _buildBentoContainer(
      icon: Icons.title_rounded,
      iconColor: Theme.of(context).colorScheme.primary,
      title: 'Judul Transaksi',
      child: TextField(
        controller: _titleController,
        style: GoogleFonts.inter(fontSize: 13, color: SavaioTheme.onSurfaceOf(context)),
        decoration: InputDecoration(
          hintText: 'Misal: Makan Siang di Kantin',
          hintStyle: TextStyle(color: SavaioTheme.onSurfaceVariantOf(context).withValues(alpha: 0.5)),
          border: InputBorder.none,
          fillColor: SavaioTheme.surfaceContainerHighestOf(context).withValues(alpha: 0.5),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return _buildBentoContainer(
      icon: Icons.calendar_today,
      iconColor: Theme.of(context).colorScheme.secondary,
      title: 'Waktu & Tanggal',
      child: Column(
        children: [
          _buildBentoValueItem(
            label: DateFormat('EEEE, d MMMM yyyy').format(_selectedDate),
            icon: Icons.calendar_today,
            onTap: _pickDate,
          ),
          const SizedBox(height: 8),
          _buildBentoValueItem(
            label: '${DateFormat('HH:mm').format(_selectedDate)} WIB',
            icon: Icons.schedule,
            onTap: _pickTime,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildBentoContainer(
      icon: Icons.description,
      iconColor: isDark ? SavaioTheme.tertiary : SavaioTheme.lightTertiary,
      title: 'Catatan Tambahan',
      child: TextField(
        controller: _descriptionController,
        maxLines: 3,
        style: GoogleFonts.inter(fontSize: 12, color: SavaioTheme.onSurfaceOf(context)),
        decoration: InputDecoration(
          hintText: 'Makan siang bareng temen...',
          hintStyle: TextStyle(color: SavaioTheme.onSurfaceVariantOf(context).withValues(alpha: 0.5)),
          border: InputBorder.none,
          fillColor: SavaioTheme.surfaceContainerHighestOf(context).withValues(alpha: 0.5),
          filled: true,
          contentPadding: const EdgeInsets.all(12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
          ),
        ),
      ),
    );
  }

  Widget _buildBentoContainer({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainerOf(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              AppHeading(
                title,
                size: AppHeadingSize.subtitle,
                isBold: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildBentoValueItem({required String label, required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SavaioTheme.surfaceContainerHighestOf(context).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: onTap != null
              ? Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(fontSize: 11, color: SavaioTheme.onSurfaceOf(context)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(icon, color: SavaioTheme.onSurfaceVariantOf(context), size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiaryColor = isDark ? SavaioTheme.tertiary : SavaioTheme.lightTertiary;
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 16,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppHeading(
                    'Progress Tabungan',
                    size: AppHeadingSize.subtitle,
                    color: tertiaryColor,
                    isBold: true,
                  ),
                  AppHeading(
                    'Sisa budget makan kamu masih aman!',
                    size: AppHeadingSize.caption,
                    isBold: false,
                  ),
                ],
              ),
              const AppHeading(
                '82%',
                size: AppHeadingSize.h3,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppProgressBar(
            value: 0.82,
            color: tertiaryColor,
            height: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final bgColor = SavaioTheme.backgroundOf(context);
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor.withValues(alpha: 0), bgColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<TransactionController>(
          builder: (context, controller, child) => AppButton(
            label: 'SIMPAN TRANSAKSI',
            isLoading: controller.isAddingTransaction,
            onTap: controller.isAddingTransaction ? null : _submitData,
          ),
        ),
      ),
    );
  }
}
