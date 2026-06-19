import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/controllers/budget_controller.dart';
import 'package:savaio/controllers/transaction_controller.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_button.dart';
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
    
    _initCategory();
  }

  void _initCategory() {
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
          picked.year, picked.month, picked.day,
          _selectedDate.hour, _selectedDate.minute,
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
          _selectedDate.year, _selectedDate.month, _selectedDate.day,
          picked.hour, picked.minute,
        );
      });
    }
  }

  Future<void> _submitData() async {
    if (_amountController.text.isEmpty || double.tryParse(_amountController.text) == null) {
      AppSnackBar.show(context, 'Tolong masukkan nominal yang valid', type: AppSnackBarType.error);
      return;
    }

    if (_selectedCategoryId == null) {
      AppSnackBar.show(context, 'Tolong pilih kategori', type: AppSnackBarType.error);
      return;
    }

    final transactionController = context.read<TransactionController>();
    
    try {
      await transactionController.createTransactionOptimistic(
        dashboardController: sl.dashboardController,
        title: _titleController.text.isEmpty ? 'Transaksi $_selectedCategoryName' : _titleController.text,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        categoryId: _selectedCategoryId!,
        type: _type.toLowerCase(),
        date: _selectedDate,
        receiptId: widget.initialReceiptId,
        source: widget.source ?? 'manual',
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, 'Gagal menyimpan: $e', type: AppSnackBarType.error);
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
    final currentCategories = budgetController.categories.where(
      (c) => c['type'].toString().toLowerCase() == _type.toLowerCase()
    ).toList();

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
                // 1. Pilih Tipe Transaksi
                TransactionTypeToggle(
                  currentType: _type,
                  onTypeChanged: (type) {
                    setState(() {
                      _type = type;
                      _initCategory(); // Reset kategori sesuai tipe
                    });
                  },
                ),
                const SizedBox(height: 24),
                
                // 2. Input Nominal
                TransactionAmountInput(
                  controller: _amountController,
                  onQuickAmountTap: _onQuickAmountTap,
                ),
                const SizedBox(height: 24),

                // 3. Input Judul (Dinaikkan dan dibuat lebih clean)
                _buildTitleSection(),
                const SizedBox(height: 32),
                
                // 4. Pilih Kategori
                TransactionCategoryGrid(
                  categories: currentCategories,
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
                      AppSnackBar.show(context, 'Kategori berhasil dihapus', type: AppSnackBarType.success, minimal: true);
                      if (_selectedCategoryId == id) _initCategory();
                    } else {
                      AppSnackBar.show(context, sl.budgetController.error ?? 'Gagal menghapus', type: AppSnackBarType.error);
                    }
                  },
                  onAddCategoryTap: _showAddCategorySheet,
                ),

                // 5. Pengaturan Waktu
                _buildDateTimeSection(),
                const SizedBox(height: 24),

                // 6. Catatan Tambahan (Diturunkan paling bawah)
                _buildNoteSection(),
                const SizedBox(height: 120), // Padding untuk Floating Button
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
      title: const AppHeading('Tambah Transaksi', size: AppHeadingSize.h3),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => const OcrScanPage())
          ),
          icon: Icon(Icons.document_scanner_outlined, color: Theme.of(context).colorScheme.primary),
          tooltip: 'Scan Struk (OCR)',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Container(
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainerOf(context),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: _titleController,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: SavaioTheme.onSurfaceOf(context),
        ),
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          hintText: 'Judul (Misal: Makan Siang)',
          hintStyle: TextStyle(
            color: SavaioTheme.onSurfaceVariantOf(context).withValues(alpha: 0.5),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          icon: Icon(
            Icons.edit_note_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return _buildBentoContainer(
      icon: Icons.notes_rounded,
      iconColor: Theme.of(context).colorScheme.secondary,
      title: 'Catatan Tambahan',
      child: _buildTextField(
        controller: _descriptionController,
        hint: 'Tulis detail tambahan di sini...',
        maxLines: 3,
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return _buildBentoContainer(
      icon: Icons.calendar_today,
      iconColor: Theme.of(context).colorScheme.secondary,
      title: 'Waktu Transaksi',
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildBentoValueItem(
              label: DateFormat('dd MMM yyyy').format(_selectedDate),
              icon: Icons.calendar_month,
              onTap: _pickDate,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _buildBentoValueItem(
              label: DateFormat('HH:mm').format(_selectedDate),
              icon: Icons.access_time,
              onTap: _pickTime,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required int maxLines}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(fontSize: 13, color: SavaioTheme.onSurfaceOf(context)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: SavaioTheme.onSurfaceVariantOf(context).withValues(alpha: 0.5), fontSize: 13),
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
              AppHeading(title, size: AppHeadingSize.subtitle, isBold: true),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: SavaioTheme.onSurfaceOf(context)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(icon, color: SavaioTheme.onSurfaceVariantOf(context), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final bgColor = SavaioTheme.backgroundOf(context);
    return Positioned(
      bottom: 0, left: 0, right: 0,
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