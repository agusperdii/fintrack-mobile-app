import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/controllers/profile_controller.dart';
import 'package:savaio/views/components/atoms/app_avatar.dart';
import 'package:savaio/views/components/atoms/app_button.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/components/molecules/app_profile_menu_item.dart';
import 'package:savaio/views/components/molecules/app_section_header.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/pages/spending_target_list_page.dart';
import 'package:savaio/views/pages/login_page.dart';
import 'package:savaio/views/pages/edit_profile_page.dart';
import 'package:savaio/views/pages/change_username_page.dart';
import 'package:savaio/views/pages/change_password_page.dart';
import 'package:savaio/views/pages/placeholder_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load profile immediately when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileController>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();

    // Show error state with logout option
    if (controller.error != null && controller.userProfile == null) {
      return Scaffold(
        backgroundColor: SavaioTheme.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: SavaioTheme.error,
                ),
                const SizedBox(height: 16),
                AppHeading(
                  'Gagal Memuat Profil',
                  size: AppHeadingSize.h2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                AppHeading(
                  controller.error!,
                  size: AppHeadingSize.caption,
                  color: SavaioTheme.onSurfaceVariant,
                  isBold: false,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Coba Lagi',
                  variant: AppButtonVariant.primary,
                  icon: Icons.refresh_rounded,
                  onTap: () {
                    controller.clearError();
                    controller.fetchProfile();
                  },
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Log Out',
                  variant: AppButtonVariant.error,
                  icon: Icons.logout_rounded,
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
        ),
      );
    }

    // Show cached profile while loading (instant display, no spinner)
    if (controller.isLoading && controller.userProfile != null) {
      return _ProfileContent(profile: controller.userProfile!, controller: controller);
    }

    // Full loading state when no cached profile exists
    if (controller.isLoading || controller.userProfile == null) {
      return const Scaffold(
        backgroundColor: SavaioTheme.background,
        body: Center(child: CircularProgressIndicator(color: SavaioTheme.primary)),
      );
    }

    final profile = controller.userProfile!;
    return _ProfileContent(profile: profile, controller: controller);
  }
}

class _ProfileContent extends StatelessWidget {
  final dynamic profile;
  final ProfileController controller;

  const _ProfileContent({required this.profile, required this.controller});

  void _navigateToPlaceholder(BuildContext context, String feature) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlaceholderPage(featureName: feature)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SavaioTheme.background,
      appBar: const AppHeader(
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
                color: SavaioTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  children: [
                    AppAvatar(imageUrl: profile.avatarUrl ?? ''),
                    const SizedBox(height: 12),
                    AppHeading(
                      profile.fullName,
                      size: AppHeadingSize.h2,
                    ),
                    const SizedBox(height: 2),
                    AppHeading(
                      profile.email,
                      size: AppHeadingSize.subtitle,
                      color: SavaioTheme.primary,
                    ),
                    const SizedBox(height: 4),
                    AppHeading(
                      profile.id.split('-').first.toUpperCase(),
                      size: AppHeadingSize.caption,
                      color: SavaioTheme.onSurfaceVariant.withValues(alpha: 0.7),
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
            ),

            const SizedBox(height: 32),

            // Profile Management Section
            const AppSectionHeader(title: 'Profil'),
            const SizedBox(height: 12),

            Container(
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
                          builder: (_) => EditProfilePage(currentName: profile.fullName),
                        ),
                      );
                      if (updated == true) {
                        controller.fetchProfile();
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
                            currentUsername: profile.email.split('@').first,
                            currentFullName: profile.fullName,
                          ),
                        ),
                      );
                      if (updated == true) {
                        controller.fetchProfile();
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
  }
}