import 'package:flutter/material.dart';
import '../atoms/app_heading.dart';
import '../../core/theme/app_theme.dart';

class AppEditorialHeader extends StatelessWidget {
  final String category;
  final String title;

  const AppEditorialHeader({
    super.key,
    required this.category,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppHeading(category.toUpperCase(), size: AppHeadingSize.caption, color: KineticVaultTheme.primary, isBold: true),
        const SizedBox(height: 4),
        AppHeading(title, size: AppHeadingSize.h2),
      ],
    );
  }
}
