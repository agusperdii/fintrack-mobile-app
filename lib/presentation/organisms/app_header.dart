import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../pages/notifications_page.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final String? avatarUrl;

  const AppHeader({
    super.key,
    this.title,
    this.showBackButton = false,
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
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: KineticVaultTheme.surfaceContainer,
                border: Border.all(color: KineticVaultTheme.primary.withValues(alpha: 0.2), width: 1),
                image: avatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : const DecorationImage(
                        image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBMPbqgPW0U1I0ZLTEdyp4cMS9mMTL9aOZnhYRlJg_1r-fji7TncBWRh_5UtIydurWHahNW0HuUvVxmgOoxZ1zNdy6jeoDVZTdamUIKzg30UsXOIdNYaXkrq2kMPsMUSgyPaZrTziXTS-qT6GIjQUOzpBzq7Jsl3Sgnhm3bIsYs_ANLI58aEINqkI-Eh1o4mpHYTHrnc7bz5SEKFjUsLbjfpzeO4-S4tzjJKDK_DMBii_xy_idr26SoZuBB7Y39ig1w_8n_3u2h8dY'),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          ShaderMask(
            shaderCallback: (bounds) => KineticVaultTheme.primaryGradient.createShader(bounds),
            child: Text(
              title ?? 'The Kinetic Vault',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      actions: [
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
