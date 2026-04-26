import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/service_locator.dart';
import '../components/atoms/app_avatar.dart';
import '../components/atoms/app_button.dart';
import '../components/organisms/app_header.dart';
import '../components/molecules/app_profile_menu_item.dart';
import '../components/molecules/app_section_header.dart';
import '../components/atoms/app_heading.dart';
import 'spending_target_page.dart';
import 'edit_profile_page.dart';
import 'change_username_page.dart';
import 'change_password_page.dart';
import 'placeholder_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _navigateToPlaceholder(String feature) {
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
        
        if (provider.isLoading || provider.userProfile == null) {
          return const Scaffold(
            backgroundColor: KineticVaultTheme.background,
            body: Center(child: CircularProgressIndicator(color: KineticVaultTheme.primary)),
          );
        }

        final profile = provider.userProfile!;

        return Scaffold(
          backgroundColor: KineticVaultTheme.background,
          appBar: AppHeader(
            title: 'Profil',
            showNotification: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Hero Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: KineticVaultTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        AppAvatar(imageUrl: profile['avatar']!),
                        const SizedBox(height: 12),
                        AppHeading(
                          profile['name']!,
                          size: AppHeadingSize.h2,
                        ),
                        const SizedBox(height: 2),
                        AppHeading(
                          profile['handle'] ?? '@user',
                          size: AppHeadingSize.subtitle,
                          color: KineticVaultTheme.primary,
                        ),
                        const SizedBox(height: 4),
                        AppHeading(
                          profile['email']!,
                          size: AppHeadingSize.caption,
                          color: KineticVaultTheme.onSurfaceVariant.withValues(alpha: 0.7),
                          isBold: false,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),

                // Spending Targets Section
                const AppSectionHeader(title: 'Keuangan'),
                const SizedBox(height: 12),
                
                Container(
                  decoration: BoxDecoration(
                    color: KineticVaultTheme.surfaceContainerLow,
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
                        MaterialPageRoute(builder: (context) => const SpendingTargetPage()),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Profile Management Section
                const AppSectionHeader(title: 'Profil'),
                const SizedBox(height: 12),
                
                Container(
                  decoration: BoxDecoration(
                    color: KineticVaultTheme.surfaceContainerLow,
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
                        onTap: () => _navigateToPlaceholder('Hapus Akun'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Logout Button
                AppButton(
                  label: 'Log Out',
                  variant: AppButtonVariant.error,
                  icon: Icons.logout_rounded,
                  width: 200,
                  onTap: () async {
                    await sl.authController.logout();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
