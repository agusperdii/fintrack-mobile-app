import 'package:flutter/material.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_button.dart';

class AddCategorySheet extends StatefulWidget {
  final Function(String name, String icon) onAdd;
  final bool isLoading;
  final String title;
  final String subtitle;
  final String nameLabel;
  final String emojiLabel;
  final String buttonLabel;

  const AddCategorySheet({
    super.key, 
    required this.onAdd,
    this.isLoading = false,
    this.title = 'Tambah Kategori Baru',
    this.subtitle = 'Sesuaikan dengan kebutuhan mahasiswa kamu!',
    this.nameLabel = 'Nama Kategori',
    this.emojiLabel = 'Emoji',
    this.buttonLabel = 'TAMBAH KATEGORI',
  });

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emojiController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onAdd(_nameController.text.trim(), _emojiController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeading(widget.title, size: AppHeadingSize.h3),
                const SizedBox(height: 8),
                AppHeading(
                  widget.subtitle, 
                  size: AppHeadingSize.caption, 
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Semantics(
                        label: widget.emojiLabel,
                        child: TextFormField(
                          controller: _emojiController,
                          enabled: !widget.isLoading,
                          decoration: InputDecoration(
                            labelText: widget.emojiLabel,
                            hintText: '🚀',
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12), 
                              borderSide: BorderSide.none,
                            ),
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Wajib';
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: Semantics(
                        label: widget.nameLabel,
                        child: TextFormField(
                          controller: _nameController,
                          enabled: !widget.isLoading,
                          decoration: InputDecoration(
                            labelText: widget.nameLabel,
                            hintText: 'Misal: Fotocopy',
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12), 
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Wajib isi nama';
                            if (value.length > 20) return 'Maks 20 karakter';
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: widget.buttonLabel,
                  isLoading: widget.isLoading,
                  onTap: widget.isLoading ? null : _handleSubmit,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
