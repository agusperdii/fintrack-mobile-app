import 'package:flutter/material.dart';
import '../atoms/app_heading.dart';
import '../../../core/theme/app_theme.dart';

class AppGreetingHeader extends StatelessWidget {
  final String userName;

  const AppGreetingHeader({
    super.key, 
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppHeading('Hi, $userName!', size: AppHeadingSize.h2),
        const AppHeading(
          'Selamat Datang!', 
          size: AppHeadingSize.subtitle, 
          color: SavaioTheme.onSurfaceVariant,
          isBold: false,
        ),
      ],
    );
  }
}
