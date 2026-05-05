import 'package:flutter/material.dart';
import 'package:savaio/others.dart';
import 'package:savaio/views/components/atoms/app_avatar.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class ProfileHeroSection extends StatelessWidget {
  final Map<String, String> profile;

  const ProfileHeroSection({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          children: [
            AppAvatar(imageUrl: profile['avatar'] ?? ''),
            const SizedBox(height: 12),
            AppHeading(
              profile['name'] ?? 'User',
              size: AppHeadingSize.h2,
            ),
            const SizedBox(height: 2),
            AppHeading(
              profile['handle'] ?? '@user',
              size: AppHeadingSize.subtitle,
              color: SavaioTheme.primary,
            ),
            const SizedBox(height: 4),
            AppHeading(
              profile['email'] ?? '',
              size: AppHeadingSize.caption,
              color: SavaioTheme.onSurfaceVariant.withValues(alpha: 0.7),
              isBold: false,
            ),
          ],
        ),
      ),
    );
  }
}
