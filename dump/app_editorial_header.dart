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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeading(
            category.toUpperCase(), 
            size: AppHeadingSize.caption, 
            color: colorScheme.primary, 
            isBold: true,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          AppHeading(
            title, 
            size: AppHeadingSize.h2,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
