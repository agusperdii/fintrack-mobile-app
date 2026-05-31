import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_icon_container.dart';

class TransactionCategoryGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String? selectedCategoryId;
  final Function(Map<String, dynamic>) onCategorySelected;
  final VoidCallback onAddCategoryTap;

  const TransactionCategoryGrid({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
    required this.onAddCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
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
              child: const AppHeading(
                '+ Tambah',
                size: AppHeadingSize.subtitle,
                color: SavaioTheme.primary,
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
            childAspectRatio: 0.85,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final isSelected = selectedCategoryId == cat['id']?.toString();
            return GestureDetector(
              onTap: () => onCategorySelected(cat),
              child: Container(
                decoration: BoxDecoration(
                  color: SavaioTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? SavaioTheme.primary.withValues(alpha: 0.5) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIconContainer(
                      icon: cat['icon'] ?? cat['emoji'] ?? '📦',
                      color: isSelected ? SavaioTheme.primary : SavaioTheme.onSurfaceVariant,
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
                          color: isSelected ? SavaioTheme.primary : SavaioTheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
