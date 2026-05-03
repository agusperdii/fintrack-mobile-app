import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppHeading(
          label,
          size: AppHeadingSize.caption,
          color: SavaioTheme.onSurfaceVariant,
          isBold: false,
        ),
        AppHeading(
          value,
          size: AppHeadingSize.h3,
          color: valueColor,
        ),
      ],
    );
  }
}
