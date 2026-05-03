import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_button.dart';

class AddCategorySheet extends StatefulWidget {
  final Function(String name, String icon) onAdd;

  const AddCategorySheet({super.key, required this.onAdd});

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
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: SavaioTheme.surfaceContainer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppHeading('Tambah Kategori Baru', size: AppHeadingSize.h3),
          const SizedBox(height: 8),
          const AppHeading('Sesuaikan dengan kebutuhan mahasiswa kamu!', size: AppHeadingSize.caption, color: SavaioTheme.onSurfaceVariant),
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
                    fillColor: SavaioTheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
                    fillColor: SavaioTheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'TAMBAH KATEGORI',
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
