import 'package:flutter/material.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

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
        AppHeading(category.toUpperCase(), size: AppHeadingSize.caption, color: Theme.of(context).colorScheme.primary, isBold: true),
        const SizedBox(height: 4),
        AppHeading(title, size: AppHeadingSize.h2),
      ],
    );
  }
}
