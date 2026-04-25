import 'package:flutter/material.dart';
import '../atoms/app_heading.dart';
import '../../../core/theme/app_theme.dart';

class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AppHeading(
          title,
          size: AppHeadingSize.h3,
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onActionTap,
            child: AppHeading(
              actionLabel!,
              size: AppHeadingSize.subtitle,
              color: KineticVaultTheme.primary,
              isBold: true,
            ),
          ),
      ],
    );
  }
}
