import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:savaio/others.dart';
import 'package:savaio/controllers/finance_controller.dart';
import 'package:savaio/views/components/atoms/app_button.dart';
import 'package:savaio/views/components/molecules/app_date_time_picker.dart';
import 'package:savaio/views/components/molecules/transaction_amount_input.dart';
import 'package:savaio/views/components/molecules/transaction_type_toggle.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/components/organisms/transaction_category_grid.dart';
import 'package:savaio/views/components/organisms/add_category_sheet.dart';
import 'package:savaio/views/pages/transactions/transaction_success_page.dart';
import 'package:savaio/views/pages/transactions/ocr_scan_page.dart';
import 'package:savaio/views/pages/transactions/sections/add_transaction_form_section.dart';
import 'package:savaio/views/pages/transactions/sections/add_transaction_progress_section.dart';

class AddTransactionPage extends StatefulWidget {
  final String? initialTitle;
  final double? initialAmount;
  final String? initialCategory;
  final String? initialType;
  final FinanceController? controller;

  const AddTransactionPage({
    super.key,
    this.initialTitle,
    this.initialAmount,
    this.initialCategory,
    this.initialType,
    this.controller,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  late FinanceController _controller;
  String _type = 'Expense'; 
  late final TextEditingController _titleController; 
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  String _selectedCategory = 'Food';
  bool _isSubmitting = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? sl.financeController;
    _type = widget.initialType ?? 'Expense';
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController();
    _amountController = TextEditingController(
      text: widget.initialAmount != null ? widget.initialAmount!.toStringAsFixed(0) : '',
    );
    _selectedCategory = widget.initialCategory ?? (widget.initialType == 'Income' ? 'Salary' : 'Food');
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
    if (_amountController.text.isEmpty || double.tryParse(_amountController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tolong masukkan nominal yang valid')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await _controller.addTransaction(
        title: _titleController.text.isEmpty ? 'Transaksi $_selectedCategory' : _titleController.text,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        type: _type,
        date: _selectedDate,
      );

      if (success && mounted) {
        _controller.fetchNudges();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TransactionSuccessPage()),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showAddCategorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCategorySheet(
        onAdd: (name, icon) async {
          await _controller.addCustomCategory(name, icon);
          if (context.mounted) {
            setState(() {
              _selectedCategory = name;
            });
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: _buildAppBar(context),
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
                    _buildTypeToggle(colorScheme),
                    const SizedBox(height: 40),
                    AddTransactionFormSection(
                      titleController: _titleController,
                      descriptionController: _descriptionController,
                      selectedDate: _selectedDate,
                      onPickDate: _pickDate,
                      onPickTime: _pickTime,
                    ),
                    const SizedBox(height: 32),
                    TransactionCategoryGrid(
                      categories: _controller.categories.map((c) => CategoryItem(
                        name: c['name'],
                        icon: c['icon'],
                      )).toList(),
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
                      onAddCategoryTap: _showAddCategorySheet,
                    ),
                    const SizedBox(height: 32),
                    const AddTransactionProgressSection(
                      progress: 0.82,
                      label: 'Progress Tabungan',
                      description: 'Sisa budget makan kamu masih aman!',
                    ),
                    const SizedBox(height: 120), 
                  ],
                ),
              ),
              _buildSubmitButton(colorScheme),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppHeader(
      title: 'Tambah Transaksi',
      leading: IconButton(
        icon: Icon(Icons.close, color: colorScheme.primary),
        onPressed: () => Navigator.pop(context),
      ),
      unreadCount: _controller.unreadNotificationsCount,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OcrScanPage()),
            );
          },
          icon: Icon(Icons.document_scanner_outlined, color: colorScheme.primary),
          tooltip: 'Scan Struk (OCR)',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTypeToggle(ColorScheme colorScheme) {
    return TransactionTypeToggle(
      currentValue: _type,
      onChanged: (type) => setState(() => _type = type),
      options: [
        TransactionTypeToggleOption(
          label: 'Pengeluaran',
          value: 'Expense',
          icon: Icons.arrow_outward,
          activeColor: colorScheme.error,
        ),
        TransactionTypeToggleOption(
          label: 'Pemasukan',
          value: 'Income',
          icon: Icons.south_west,
          activeColor: colorScheme.tertiary,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ColorScheme colorScheme) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.surface.withValues(alpha: 0), colorScheme.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: AppButton(
          label: 'SIMPAN TRANSAKSI',
          isLoading: _isSubmitting,
          onTap: _submitData,
        ),
      ),
    );
  }
}
