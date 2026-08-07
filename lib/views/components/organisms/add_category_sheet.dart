// add_category_sheet.dart
// Bottom sheet untuk menambahkan kategori transaksi baru (pemasukan atau
// pengeluaran) dengan input emoji dan nama kategori.

import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_button.dart';

class AddCategorySheet extends StatefulWidget {
  final String type;
  final Function(String name, String icon) onAdd;

  const AddCategorySheet({super.key, required this.onAdd, this.type = 'expense'});

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  final _nameController = TextEditingController();
  final _emojiController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.type.toLowerCase() == 'income';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainerOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeading('Tambah Kategori ${isIncome ? 'Pemasukan' : 'Pengeluaran'}', size: AppHeadingSize.h3),
          const SizedBox(height: 8),
          AppHeading(
            isIncome ? 'Catat sumber cuan kamu di sini!' : 'Sesuaikan dengan kebutuhan mahasiswa kamu!',
            size: AppHeadingSize.caption,
            color: SavaioTheme.onSurfaceVariantOf(context),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _emojiController,
                  decoration: InputDecoration(
                    labelText: 'Emoji',
                    hintText: '🚀',
                    filled: true,
                    fillColor: SavaioTheme.surfaceContainerHighestOf(context).withValues(alpha: 0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Kategori',
                    hintText: 'Misal: Fotocopy',
                    filled: true,
                    fillColor: SavaioTheme.surfaceContainerHighestOf(context).withValues(alpha: 0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Tambah Kategori',
            onTap: () {
              if (_nameController.text.isNotEmpty && _emojiController.text.isNotEmpty) {
                widget.onAdd(_nameController.text, _emojiController.text);
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
