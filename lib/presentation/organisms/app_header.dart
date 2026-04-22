import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../pages/notifications_page.dart';
import '../atoms/app_avatar.dart';
import '../atoms/app_heading.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showNotification;
  final String? avatarUrl;

  const AppHeader({
    super.key,
    this.title,
    this.showBackButton = false,
    this.showNotification = true,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: KineticVaultTheme.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: kToolbarHeight + KineticVaultTheme.spacingM,
      leading: showBackButton
          ? Center(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: KineticVaultTheme.primary, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      title: Row(
        children: [
          if (!showBackButton) ...[
            AppAvatar(
              imageUrl: avatarUrl ?? 'https://i.pravatar.cc/150?u=aida',
              size: 36,
              showBorder: true,
            ),
            const SizedBox(width: KineticVaultTheme.spacingM),
          ],
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) => KineticVaultTheme.primaryGradient.createShader(bounds),
              child: AppHeading(
                title ?? 'The Kinetic Vault',
                size: AppHeadingSize.h3,
                color: Colors.white,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (showNotification) ...[
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: KineticVaultTheme.primary, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
          const SizedBox(width: KineticVaultTheme.spacingS),
        ],
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + KineticVaultTheme.spacingM);
}
