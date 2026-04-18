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
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: KineticVaultTheme.primary, size: 20),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: Row(
        children: [
          if (!showBackButton) ...[
            AppAvatar(
              imageUrl: avatarUrl ?? 'https://lh3.googleusercontent.com/aida-public/AB6AXuBMPbqgPW0U1I0ZLTEdyp4cMS9mMTL9aOZnhYRlJg_1r-fji7TncBWRh_5UtIydurWHahNW0HuUvVxmgOoxZ1zNdy6jeoDVZTdamUIKzg30UsXOIdNYaXkrq2kMPsMUSgyPaZrTziXTS-qT6GIjQUOzpBzq7Jsl3Sgnhm3bIsYs_ANLI58aEINqkI-Eh1o4mpHYTHrnc7bz5SEKFjUsLbjfpzeO4-S4tzjJKDK_DMBii_xy_idr26SoZuBB7Y39ig1w_8n_3u2h8dY',
              size: 32,
              showBorder: true,
            ),
            const SizedBox(width: 12),
          ],
          ShaderMask(
            shaderCallback: (bounds) => KineticVaultTheme.primaryGradient.createShader(bounds),
            child: AppHeading(
              title ?? 'The Kinetic Vault',
              size: AppHeadingSize.h3,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        if (showNotification) ...[
          IconButton(
            icon: const Icon(Icons.notifications_none, color: KineticVaultTheme.primary, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
