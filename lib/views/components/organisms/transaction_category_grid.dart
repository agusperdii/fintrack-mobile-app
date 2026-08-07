// transaction_category_grid.dart
// Grid pemilihan kategori transaksi dengan opsi tambah kategori baru dan
// hapus kategori custom melalui long-press.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_icon_container.dart';

class TransactionCategoryGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String? selectedCategoryId;
  final Function(Map<String, dynamic>) onCategorySelected;
  final Function(String)? onDeleteCategory;
  final VoidCallback onAddCategoryTap;

  const TransactionCategoryGrid({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
    this.onDeleteCategory,
    required this.onAddCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppHeading(
              'Pilih Kategori',
              size: AppHeadingSize.h3,
            ),
            GestureDetector(
              onTap: onAddCategoryTap,
              child: AppHeading(
                '+ Tambah',
                size: AppHeadingSize.subtitle,
                color: colorScheme.primary,
                isBold: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final id = cat['id']?.toString() ?? '';
            final isSelected = selectedCategoryId == id;
            final isDefault = cat['isDefault'] == true;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () => onCategorySelected(cat),
                  onLongPress: !isDefault && onDeleteCategory != null ? () => _showDeleteConfirm(context, cat) : null,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? colorScheme.primary.withValues(alpha: 0.5) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIconContainer(
                          icon: cat['icon'] ?? cat['emoji'] ?? '📦',
                          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                          size: 40,
                          opacity: isSelected ? 0.2 : 0.1,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            cat['name'].toString().toUpperCase(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isDefault && onDeleteCategory != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: GestureDetector(
                      onTap: () => _showDeleteConfirm(context, cat),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                        ),
                        child: const Icon(Icons.close, size: 10, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showDeleteConfirm(BuildContext context, Map<String, dynamic> cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        title: const Text('Hapus Kategori?'),
        content: Text('Apakah Anda yakin ingin menghapus kategori "${cat['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDeleteCategory?.call(cat['id'].toString());
            },
            child: Text('Hapus', style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
