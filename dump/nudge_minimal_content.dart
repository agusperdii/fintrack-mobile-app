import 'package:flutter/material.dart';
import 'package:savaio/others.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class NudgeMinimalContent extends StatelessWidget {
  final String title;
  final String message;

  const NudgeMinimalContent({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeading(
          title.toUpperCase(),
          size: AppHeadingSize.h2,
          color: SavaioTheme.tertiary,
          isBold: true,
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: SavaioTheme.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
