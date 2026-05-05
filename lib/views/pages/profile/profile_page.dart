import 'package:flutter/material.dart';
import 'package:savaio/others.dart';
import 'package:savaio/views/components/atoms/app_button.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/components/molecules/app_profile_menu_item.dart';
import 'package:savaio/views/components/molecules/app_section_header.dart';
import 'package:savaio/views/pages/budget/spending_target_list_page.dart';
import 'package:savaio/views/pages/auth/login_page.dart';
import 'package:savaio/views/pages/profile/edit_profile_page.dart';
import 'package:savaio/views/pages/profile/change_username_page.dart';
import 'package:savaio/views/pages/profile/change_password_page.dart';
import 'package:savaio/views/pages/placeholder_page.dart';
import 'package:savaio/views/pages/profile/profile_hero_section.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _navigateToPlaceholder(BuildContext context, String feature) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlaceholderPage(featureName: feature)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sl.financeController,
      builder: (context, _) {
        final provider = sl.financeController;
        final theme = Theme.of(context);
        
        if (provider.isLoading || provider.userProfile == null) {
          return const Scaffold(
            backgroundColor: SavaioTheme.background,
            body: Center(child: CircularProgressIndicator(color: SavaioTheme.primary)),
          );
        }

        final profile = provider.userProfile!;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppHeader(
            title: 'Profil',
            showBackButton: true,
            onBackTap: () => Navigator.pop(context),
            unreadCount: provider.unreadNotificationsCount,
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfileHeroSection(profile: profile),
                const SizedBox(height: 32),

                const AppSectionHeader(title: 'Keuangan'),
                const SizedBox(height: 12),
                _buildFinanceMenu(context),

                const SizedBox(height: 32),

                const AppSectionHeader(title: 'Profil'),
                const SizedBox(height: 12),
                _buildProfileMenu(context, profile),

                const SizedBox(height: 48),

                AppButton(
                  label: 'Log Out',
                  variant: AppButtonVariant.error,
                  icon: Icons.logout_rounded,
                  width: 200,
                  onTap: () async {
                    await sl.authController.logout();
                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFinanceMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AppProfileMenuItem(
        icon: Icons.track_changes_rounded,
        title: 'Target Pengeluaran',
        isTop: true,
        isBottom: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SpendingTargetListPage()),
          );
        },
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context, Map<String, String> profile) {
    return Container(
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          AppProfileMenuItem(
            icon: Icons.person_outline_rounded,
            title: 'Edit nama',
            isTop: true,
            onTap: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfilePage(currentName: profile['name'] ?? ''),
                ),
              );
              if (updated == true) {
                sl.financeController.fetchAllData();
              }
            },
          ),
          AppProfileMenuItem(
            icon: Icons.alternate_email_rounded,
            title: 'Ganti username',
            onTap: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeUsernamePage(
                    currentUsername: profile['username'] ?? '',
                    currentFullName: profile['name'] ?? '',
                  ),
                ),
              );
              if (updated == true) {
                sl.financeController.fetchAllData();
              }
            },
          ),
          AppProfileMenuItem(
            icon: Icons.lock_reset_rounded,
            title: 'Ganti password',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
            ),
          ),
          AppProfileMenuItem(
            icon: Icons.delete_forever_rounded,
            title: 'Hapus akun saya',
            isDestructive: true,
            isBottom: true,
            onTap: () => _navigateToPlaceholder(context, 'Hapus Akun'),
          ),
        ],
      ),
    );
  }
}
