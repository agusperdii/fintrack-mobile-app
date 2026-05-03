import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_button.dart';
import 'package:savaio/views/components/atoms/app_progress_bar.dart';
import 'package:savaio/views/components/molecules/app_date_time_picker.dart';
import 'package:savaio/views/components/molecules/transaction_amount_input.dart';
import 'package:savaio/views/components/molecules/transaction_type_toggle.dart';
import 'package:savaio/views/components/organisms/transaction_category_grid.dart';
import 'package:savaio/views/components/organisms/add_category_sheet.dart';
import 'package:savaio/views/pages/transaction_success_page.dart';
import 'package:savaio/views/pages/ocr_scan_page.dart';

class AddTransactionPage extends StatefulWidget {
  final String? initialTitle;
  final double? initialAmount;
  final String? initialCategory;
  final String? initialType;

  const AddTransactionPage({
    super.key,
    this.initialTitle,
    this.initialAmount,
    this.initialCategory,
    this.initialType,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
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
      final success = await sl.financeController.addTransaction(
        title: _titleController.text.isEmpty ? 'Transaksi $_selectedCategory' : _titleController.text,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        type: _type,
        date: _selectedDate,
      );

      if (success && mounted) {
        sl.financeController.fetchNudges();
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
        onAdd: (name, icon) {
          sl.financeController.addCustomCategory(name, icon);
          setState(() {
            _selectedCategory = name;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sl.financeController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: SavaioTheme.background,
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
                      onTypeChanged: (type) => setState(() => _type = type),
                    ),
                    const SizedBox(height: 40),
                    _buildTitleSection(),
                    const SizedBox(height: 16),
                    _buildDateTimeSection(),
                    const SizedBox(height: 32),
                    TransactionCategoryGrid(
                      categories: sl.financeController.categories,
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
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
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: SavaioTheme.background,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.close, color: SavaioTheme.primary),
        onPressed: () => Navigator.pop(context), 
      ),
      title: const AppHeading(
        'Tambah Transaksi',
        size: AppHeadingSize.h3,
        color: SavaioTheme.onSurface,
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OcrScanPage()),
            );
          },
          icon: const Icon(Icons.document_scanner_outlined, color: SavaioTheme.primary),
          tooltip: 'Scan Struk (OCR)',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTitleSection() {
    return _buildBentoContainer(
      icon: Icons.title_rounded,
      iconColor: SavaioTheme.primary,
      title: 'Judul Transaksi',
      child: TextField(
        controller: _titleController,
        style: GoogleFonts.inter(fontSize: 13, color: SavaioTheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Misal: Makan Siang di Kantin',
          hintStyle: TextStyle(color: SavaioTheme.onSurfaceVariant.withValues(alpha: 0.5)),
          border: InputBorder.none,
          fillColor: SavaioTheme.surfaceContainerHighest.withValues(alpha: 0.5),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: SavaioTheme.primary.withValues(alpha: 0.3)),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return _buildBentoContainer(
      icon: Icons.calendar_today,
      iconColor: SavaioTheme.secondary,
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
    return _buildBentoContainer(
      icon: Icons.description,
      iconColor: SavaioTheme.tertiary,
      title: 'Catatan Tambahan',
      child: TextField(
        controller: _descriptionController,
        maxLines: 3,
        style: GoogleFonts.inter(fontSize: 12, color: SavaioTheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Makan siang bareng temen...',
          hintStyle: TextStyle(color: SavaioTheme.onSurfaceVariant.withValues(alpha: 0.5)),
          border: InputBorder.none,
          fillColor: SavaioTheme.surfaceContainerHighest.withValues(alpha: 0.5),
          filled: true,
          contentPadding: const EdgeInsets.all(12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: SavaioTheme.primary.withValues(alpha: 0.3)),
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
        color: SavaioTheme.surfaceContainer,
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
          color: SavaioTheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: onTap != null ? Border.all(color: SavaioTheme.primary.withValues(alpha: 0.2)) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(fontSize: 11, color: SavaioTheme.onSurface),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(icon, color: SavaioTheme.onSurfaceVariant, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return const GlassCard(
      padding: EdgeInsets.all(24),
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
                    color: SavaioTheme.tertiary,
                    isBold: true,
                  ),
                  AppHeading(
                    'Sisa budget makan kamu masih aman!',
                    size: AppHeadingSize.caption,
                    color: SavaioTheme.onSurfaceVariant,
                    isBold: false,
                  ),
                ],
              ),
              AppHeading(
                '82%',
                size: AppHeadingSize.h3,
              ),
            ],
          ),
          SizedBox(height: 16),
          AppProgressBar(
            value: 0.82,
            color: SavaioTheme.tertiary,
            height: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [SavaioTheme.background.withValues(alpha: 0), SavaioTheme.background],
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
