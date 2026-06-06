import 'package:flutter/material.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

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
        AppHeading(
          'Selamat Datang!', 
          size: AppHeadingSize.subtitle, 
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          isBold: false,
        ),
      ],
    );
  }
}
