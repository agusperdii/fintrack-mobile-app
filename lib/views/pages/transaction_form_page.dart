// transaction_form_page.dart
// Halaman form untuk menambah atau mengedit transaksi (pemasukan,
// pengeluaran, tabungan), termasuk validasi saldo dan sumber dana.

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/controllers/budget_controller.dart';
import 'package:savaio/controllers/transaction_controller.dart';
import 'package:savaio/controllers/auth_controller.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_button.dart';
import 'package:savaio/views/components/molecules/app_date_time_picker.dart';
import 'package:savaio/views/components/molecules/transaction_amount_input.dart';
import 'package:savaio/views/components/molecules/transaction_type_toggle.dart';
import 'package:savaio/views/components/organisms/transaction_category_grid.dart';
import 'package:savaio/views/components/organisms/add_category_sheet.dart';
import 'package:savaio/views/components/organisms/notifications/app_snackbar.dart';
import 'package:savaio/views/pages/ocr_scan_page.dart';
import 'package:savaio/models/app_data.dart';

class TransactionFormPage extends StatefulWidget {
  final Transaction? transaction;

  final String? initialTitle;
  final double? initialAmount;
  final String? initialCategory;
  final String? initialType;
  final String? initialReceiptId;
  final String? source;

  const TransactionFormPage({
    super.key,
    this.transaction,
    this.initialTitle,
    this.initialAmount,
    this.initialCategory,
    this.initialType,
    this.initialReceiptId,
    this.source,
  });

  bool get isEditMode => transaction != null;

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  String _type = 'Expense'; 
  late final TextEditingController _titleController; 
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  String? _selectedCategoryId;
  String _selectedCategoryName = 'Food';
  DateTime _selectedDate = DateTime.now();
  String _fundSource = 'primary';

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;

    // PERBAIKAN 1: Memastikan pengecekan tipe lebih kebal terhadap perbedaan enum vs string
    if (tx != null) {
      final typeString = tx.type.toString().toLowerCase();
      if (typeString.contains('income')) {
        _type = 'Income';
      } else if (typeString.contains('savings')) {
        _type = 'Savings';
        // Nominal negatif menandakan aksi Tarik Tabungan, jadi fundSource diset ke savings.
        if (tx.amount < 0) {
          _fundSource = 'savings';
        }
      } else {
        _type = 'Expense';
        // Untuk expense, default ke primary karena model belum menyimpan fundSource.
      }
    } else {
      _type = widget.initialType ?? 'Expense';
    }

    _titleController = TextEditingController(
      text: tx?.title ?? widget.initialTitle,
    );

    _descriptionController = TextEditingController(
      text: tx?.description ?? '',
    );

    _amountController = TextEditingController(
      text: tx != null
          ? tx.amount.abs().toStringAsFixed(0)
          : widget.initialAmount?.abs().toStringAsFixed(0) ?? '',
    );

    _selectedDate = tx?.date ?? DateTime.now();

    // PERBAIKAN 2: Pemanggilan inisialisasi kategori (tx?.categoryId diurus di dalam fungsi ini)
    _initCategory();
  }

  void _initCategory({bool fromEdit = true}) {
    final tx = widget.transaction;

    if (tx != null && fromEdit) {
      _selectedCategoryId = tx.category?.id;
      _selectedCategoryName = tx.category?.name ?? 'Food';
      return;
    }

    final categories = sl.budgetController.categories.where(
      (c) => c['type'].toString().toLowerCase() == _type.toLowerCase(),
    ).toList();

    final initialName = widget.initialCategory ??
        (widget.initialType == 'Income' ? 'Salary' : (widget.initialType == 'Savings' ? 'Tabungan' : 'Food'));

    if (categories.isEmpty) {
      _selectedCategoryName = initialName;
      _createDefaultCategoryIfMissing(initialName, _type.toLowerCase());
      return;
    }

    try {
      final cat = categories.firstWhere(
        (c) => c['name'].toString().toLowerCase() == initialName.toLowerCase(),
      );
      _selectedCategoryId = cat['id']?.toString();
      _selectedCategoryName = cat['name'].toString();
    } catch (_) {
      // Jika kategori sudah ada tapi initialName tidak ditemukan, kategori
      // tersebut dibuat otomatis agar nudge tetap berjalan tanpa memaksa
      // pengguna memilih kategori default seperti 'Food'.
      if (widget.initialCategory != null) {
        _selectedCategoryName = initialName;
        _createDefaultCategoryIfMissing(initialName, _type.toLowerCase());
      } else {
        _selectedCategoryId = categories.first['id']?.toString();
        _selectedCategoryName = categories.first['name'].toString();
      }
    }
  }

  Future<void> _createDefaultCategoryIfMissing(String name, String type) async {
    final id = await sl.budgetController.addCustomCategory(name, '💰', type: type);
    if (id != null && mounted) {
      setState(() {
        _selectedCategoryId = id;
        _selectedCategoryName = name;
      });
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
    if (_amountController.text.isEmpty ||
        double.tryParse(_amountController.text) == null) {
      AppSnackBar.show(
        context,
        'Tolong masukkan nominal yang valid',
        type: AppSnackBarType.error,
      );
      return;
    }

    if (_type.toLowerCase() != 'savings' && _selectedCategoryId == null) {
      AppSnackBar.show(
        context,
        'Tolong pilih kategori',
        type: AppSnackBarType.error,
      );
      return;
    }

    final transactionController = context.read<TransactionController>();

    try {
      final title = _titleController.text.isEmpty
          ? (_type.toLowerCase() == 'savings' ? 'Tabungan' : 'Transaksi $_selectedCategoryName')
          : _titleController.text;

      final amountStr = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final amount = double.parse(amountStr.isEmpty ? '0' : amountStr);

      bool useOverdraft = false;

      // VALIDASI SALDO UNTUK PENGELUARAN (OVERDRAFT DAN FUND SOURCE)
      if (_type.toLowerCase() == 'expense') {
        final currentBalance = sl.dashboardController.data?.balance ?? 0.0;
        final totalSavings = sl.dashboardController.data?.totalSavings ?? 0.0;
        
        if (_fundSource == 'savings') {
          if (amount > totalSavings) {
             AppSnackBar.show(
                context,
                'Saldo tabungan tidak mencukupi untuk transaksi ini.',
                type: AppSnackBarType.error,
              );
              return;
          } else {
             final authController = context.read<AuthController>();
             final formattedAmount = SavaioTheme.formatCurrency(amount, currency: authController.currency);
             
             final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: SavaioTheme.surfaceContainerOf(context),
                  title: AppHeading('Gunakan Tabungan?', size: AppHeadingSize.h3),
                  content: Text(
                    'Anda akan memotong seluruh transaksi sebesar $formattedAmount dari Tabungan Anda.',
                    style: TextStyle(color: SavaioTheme.onSurfaceOf(context)),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false), 
                      child: Text('Batal', style: TextStyle(color: SavaioTheme.onSurfaceVariantOf(context)))
                    ),
                    AppButton(
                      label: 'Lanjutkan', 
                      onTap: () => Navigator.pop(context, true),
                      variant: AppButtonVariant.primary,
                      small: true,
                    ),
                  ],
                ),
             );
             if (confirm != true) return;
          }
        } else {
          // Logika overdraft default: jika saldo utama tidak cukup, selisihnya
          // ditawarkan untuk diambil otomatis dari tabungan.
          double simulatedBalance = currentBalance;
          if (widget.isEditMode && widget.transaction != null) {
            final typeString = widget.transaction!.type.toString().toLowerCase();
            if (typeString.contains('expense')) {
               simulatedBalance += widget.transaction!.amount;
            }
          }
          
          if (amount > simulatedBalance) {
             final shortfall = amount - simulatedBalance;
             if (shortfall > totalSavings) {
               AppSnackBar.show(
                  context,
                  'Dana gabungan (Saldo + Tabungan) tidak mencukupi untuk transaksi ini.',
                  type: AppSnackBarType.error,
                );
                return;
             } else {
               final authController = context.read<AuthController>();
               final formattedShortfall = SavaioTheme.formatCurrency(shortfall, currency: authController.currency);

               final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: SavaioTheme.surfaceContainerOf(context),
                    title: AppHeading('Saldo Utama Tidak Cukup', size: AppHeadingSize.h3),
                    content: Text(
                      'Apakah Anda ingin mengambil kekurangan sebesar $formattedShortfall otomatis dari tabungan Anda?',
                      style: TextStyle(color: SavaioTheme.onSurfaceOf(context)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false), 
                        child: Text('Batal', style: TextStyle(color: SavaioTheme.onSurfaceVariantOf(context)))
                      ),
                      AppButton(
                        label: 'Ya, Ambil', 
                        onTap: () => Navigator.pop(context, true),
                        variant: AppButtonVariant.primary,
                        small: true,
                      ),
                    ],
                  ),
               );
               if (confirm != true) return;
               useOverdraft = true;
             }
          }
        }
      }

      // VALIDASI SALDO UNTUK TABUNGAN
      if (_type.toLowerCase() == 'savings') {
        final currentBalance = sl.dashboardController.data?.balance ?? 0.0;
        final totalSavings = sl.dashboardController.data?.totalSavings ?? 0.0;
        
        if (_fundSource == 'savings') {
          // Tarik Tabungan (withdrawal)
          double maxWithdrawal = totalSavings;
          if (widget.isEditMode && widget.transaction != null) {
            final typeString = widget.transaction!.type.toString().toLowerCase();
            if (typeString.contains('savings') && widget.transaction!.amount < 0) {
              maxWithdrawal += widget.transaction!.amount.abs();
            }
          }
          if (amount > maxWithdrawal) {
            final formattedMax = SavaioTheme.formatCurrency(maxWithdrawal, currency: transactionController.currency); 
            if (!mounted) return;
            AppSnackBar.show(
              context,
              'Saldo tabungan tidak mencukupi. Maksimal ditarik: $formattedMax.',
              type: AppSnackBarType.error,
            );
            return;
          }
        } else {
          // Setor Tabungan (deposit)
          double maxAllowed = currentBalance;
          if (widget.isEditMode && widget.transaction != null) {
            final typeString = widget.transaction!.type.toString().toLowerCase();
            if (typeString.contains('savings') && widget.transaction!.amount > 0) {
              maxAllowed += widget.transaction!.amount;
            }
          }
          
          if (maxAllowed <= 0 && amount > 0) {
            if (!mounted) return;
            AppSnackBar.show(
              context,
              'Saldo utama habis. Tambahkan pemasukan dahulu sebelum menabung.',
              type: AppSnackBarType.error,
            );
            return;
          }
          
          if (amount > maxAllowed) {
            final formattedMax = SavaioTheme.formatCurrency(maxAllowed, currency: transactionController.currency); 
            if (!mounted) return;
            AppSnackBar.show(
              context,
              'Maksimal tabungan: $formattedMax. Tambahkan pemasukan dahulu.',
              type: AppSnackBarType.error,
            );
            return;
          }
        }
      }

      String? finalCategoryId = _selectedCategoryId;
      if (_type.toLowerCase() == 'savings') {
        if (!mounted) return;
        final budgetController = context.read<BudgetController>();
        final savingsCategory = budgetController.categories.firstWhere(
          (c) => c['type'].toString().toLowerCase() == 'savings',
          orElse: () => <String, dynamic>{},
        );
        finalCategoryId = savingsCategory['id']?.toString();
      }

      if (widget.isEditMode) {
        final updatedTx = await transactionController.updateTransaction(
          id: widget.transaction!.id,
          dashboardController: sl.dashboardController,
          title: title,
          description: _descriptionController.text,
          amount: amount,
          categoryId: finalCategoryId ?? '',
          date: _selectedDate,
          fundSource: _fundSource,
          useOverdraft: useOverdraft,
        );

        if (mounted) {
          Navigator.pop(context, updatedTx);
        }
      } else {
        await transactionController.createTransactionOptimistic(
          dashboardController: sl.dashboardController,
          title: title,
          description: _descriptionController.text,
          amount: amount,
          categoryId: finalCategoryId ?? '',
          type: _type.toLowerCase(),
          date: _selectedDate,
          receiptId: widget.initialReceiptId,
          source: widget.source ?? 'manual',
          fundSource: _fundSource,
          useOverdraft: useOverdraft,
        );

        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (!mounted) return;

      AppSnackBar.show(
        context,
        'Gagal menyimpan: $e',
        type: AppSnackBarType.error,
      );
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

    // MODIFIKASI: Bungkus Scaffold dengan GestureDetector untuk menghilangkan keyboard saat klik di luar area textfield
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: SavaioTheme.backgroundOf(context),
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TransactionTypeToggle(
                    currentType: _type,
                    onTypeChanged: (type) {
                      setState(() {
                        _type = type;
                        if (_type.toLowerCase() == 'savings') {
                          // Saat berpindah ke tipe savings, fundSource direset
                          // ke primary (default aksi Setor).
                          _fundSource = 'primary';
                        }
                        // fromEdit: false agar kategori direset mengikuti tipe baru.
                        _initCategory(fromEdit: false);
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  TransactionAmountInput(
                    controller: _amountController,
                    onQuickAmountTap: _onQuickAmountTap,
                  ),
                  const SizedBox(height: 24),

                  _buildTitleSection(),
                  const SizedBox(height: 32),

                  if (_type.toLowerCase() == 'expense')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppHeading('Sumber Dana', size: AppHeadingSize.subtitle),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFundSourceOption('primary', 'Saldo Utama', Icons.account_balance_wallet),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildFundSourceOption('savings', 'Tabungan', Icons.savings),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),

                  if (_type.toLowerCase() == 'savings')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppHeading('Aksi Tabungan', size: AppHeadingSize.subtitle),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFundSourceOption('primary', 'Setor', Icons.arrow_downward),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildFundSourceOption('savings', 'Tarik', Icons.arrow_upward),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),

                  if (_type.toLowerCase() != 'savings')
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

                  _buildDateTimeSection(),
                  const SizedBox(height: 24),

                  _buildNoteSection(),
                  // Tinggi ekstra agar konten tidak tertutup floating submit button.
                  const SizedBox(height: 120),
                ],
              ),
            ),
            _buildSubmitButton(),
          ],
        ),
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
      widget.isEditMode ? 'Edit Transaksi' : 'Tambah Transaksi',
      size: AppHeadingSize.h3,
    ),
    actions: [
      if (!widget.isEditMode) ...[
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OcrScanPage()),
          ),
          icon: Icon(Icons.document_scanner_outlined, color: Theme.of(context).colorScheme.primary),
          tooltip: 'Scan Struk (OCR)',
        ),
        const SizedBox(width: 8),
      ],
    ],
  );
  }

  Widget _buildFundSourceOption(String value, String label, IconData icon) {
    final isSelected = _fundSource == value;
    final color = isSelected ? Theme.of(context).colorScheme.primary : SavaioTheme.onSurfaceVariantOf(context);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _fundSource = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : SavaioTheme.surfaceContainerOf(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
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
            label: widget.isEditMode
                  ? 'Simpan Perubahan'
                  : 'Simpan Transaksi',
            isLoading: widget.isEditMode
                  ? controller.isUpdatingTransaction
                  : controller.isAddingTransaction,
            onTap: (controller.isAddingTransaction ||
                    controller.isUpdatingTransaction)
                  ? null
                  : _submitData,
          ),
        ),
      ),
    );
  }
}