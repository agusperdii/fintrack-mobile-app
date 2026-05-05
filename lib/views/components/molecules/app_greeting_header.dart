import 'package:flutter/material.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class AppGreetingHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const AppGreetingHeader({
    super.key, 
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeading(
            title, 
            size: AppHeadingSize.h2,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            AppHeading(
              subtitle!, 
              size: AppHeadingSize.subtitle, 
              color: theme.colorScheme.onSurfaceVariant,
              isBold: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
