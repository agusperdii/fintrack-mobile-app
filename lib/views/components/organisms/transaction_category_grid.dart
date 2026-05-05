import 'package:flutter/material.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_icon_container.dart';

class CategoryItem {
  final String name;
  final dynamic icon;
  final Color? color;

  const CategoryItem({
    required this.name,
    required this.icon,
    this.color,
  });
}

class TransactionCategoryGrid extends StatelessWidget {
  final List<CategoryItem> categories;
  final String? selectedCategory;
  final Function(String) onCategorySelected;
  final VoidCallback onAddCategoryTap;
  final String title;
  final String addLabel;

  const TransactionCategoryGrid({
    super.key,
    required this.categories,
    required this.onCategorySelected,
    required this.onAddCategoryTap,
    this.selectedCategory,
    this.title = 'Pilih Kategori',
    this.addLabel = '+ Tambah',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: AppHeading(
                title,
                size: AppHeadingSize.h3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: 'Add Category',
              child: GestureDetector(
                onTap: onAddCategoryTap,
                child: AppHeading(
                  addLabel,
                  size: AppHeadingSize.subtitle,
                  color: colorScheme.primary,
                  isBold: true,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
            final isSelected = selectedCategory == cat.name;
            final effectiveColor = cat.color ?? colorScheme.primary;

            return Semantics(
              button: true,
              selected: isSelected,
              label: 'Select category ${cat.name}',
              child: GestureDetector(
                onTap: () => onCategorySelected(cat.name),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? effectiveColor.withValues(alpha: 0.5) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppIconContainer(
                        icon: cat.icon,
                        color: isSelected ? effectiveColor : colorScheme.onSurfaceVariant,
                        size: 40,
                        opacity: isSelected ? 0.2 : 0.1,
                        iconColor: isSelected ? effectiveColor : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          cat.name.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? effectiveColor : colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
