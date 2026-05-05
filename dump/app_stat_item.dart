import 'package:flutter/material.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class AppStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const AppStatItem({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: '$label: $value',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeading(
            label,
            size: AppHeadingSize.caption,
            color: colorScheme.onSurfaceVariant,
            isBold: false,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          AppHeading(
            value,
            size: AppHeadingSize.h3,
            color: valueColor ?? colorScheme.onSurface,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
