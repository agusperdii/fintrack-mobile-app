import 'package:flutter/material.dart';
import '../atoms/app_heading.dart';
import '../atoms/app_avatar.dart';
import '../../core/theme/app_theme.dart';

class AppGreetingHeader extends StatelessWidget {
  final String userName;
  final String? avatarUrl;

  const AppGreetingHeader({
    super.key, 
    required this.userName,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (avatarUrl != null) ...[
          AppAvatar(imageUrl: avatarUrl!, size: 48),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeading('Hi, $userName!', size: AppHeadingSize.h2),
              const AppHeading(
                'Selamat Datang!', 
                size: AppHeadingSize.subtitle, 
                color: KineticVaultTheme.onSurfaceVariant,
                isBold: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
