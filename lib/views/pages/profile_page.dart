import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/controllers/profile_controller.dart';
import 'package:savaio/controllers/theme_controller.dart';
import 'package:savaio/views/components/atoms/app_avatar.dart';
import 'package:savaio/views/components/atoms/app_button.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/components/molecules/app_profile_menu_item.dart';
import 'package:savaio/views/components/molecules/app_section_header.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/pages/spending_target_list_page.dart';
import 'package:savaio/views/pages/landing_page.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileController>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();

    if (controller.error != null && controller.userProfile == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  isBold: false,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Coba Lagi',
                  variant: AppButtonVariant.primary,
                  icon: Icons.refresh_rounded,
                  width: double.infinity,
                  onTap: () {
                    controller.clearError();
                    controller.fetchProfile();
                  },
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Log Out',
                  variant: AppButtonVariant.error,
                  icon: Icons.logout_rounded,
                  width: double.infinity,
                  onTap: () async {
                    await sl.authController.logout(resetLanding: true);
                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LandingPage()),
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

    if (controller.isLoading && controller.userProfile != null) {
      return _ProfileContent(profile: controller.userProfile!, controller: controller);
    }

    if (controller.isLoading || controller.userProfile == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator(color: SavaioTheme.primary)),
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

  void _showThemeSelection(BuildContext context, ThemeController themeController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeading('Mode Tampilan', size: AppHeadingSize.h3),
            const SizedBox(height: 24),
            _buildThemeOption(context, 'Otomatis (Sistem)', ThemeMode.system, themeController),
            _buildThemeOption(context, 'Mode Terang', ThemeMode.light, themeController),
            _buildThemeOption(context, 'Mode Gelap', ThemeMode.dark, themeController),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, String label, ThemeMode mode, ThemeController themeController) {
    final isSelected = themeController.themeMode == mode;
    return InkWell(
      onTap: () {
        themeController.setThemeMode(mode);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary, size: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppHeader(
        title: 'Profil',
        showNotification: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: AppAvatar(imageUrl: profile.avatarUrl ?? ''),
                  ),
                  const SizedBox(height: 16),
                  AppHeading(
                    profile.fullName,
                    size: AppHeadingSize.h2,
                  ),
                  const SizedBox(height: 4),
                  AppHeading(
                    profile.email,
                    size: AppHeadingSize.subtitle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: AppHeading(
                      'ID ${profile.id.split('-').first.toUpperCase()}',
                      size: AppHeadingSize.caption,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      isBold: true,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            const AppSectionHeader(title: 'Preferensi'),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AppProfileMenuItem(
                  icon: themeController.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  title: 'Mode Tampilan',
                  trailing: Text(
                    themeController.themeMode == ThemeMode.system 
                        ? 'Otomatis' 
                        : (themeController.isDarkMode ? 'Gelap' : 'Terang'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  isTop: true,
                  isBottom: true,
                  onTap: () {
                    _showThemeSelection(context, themeController);
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),

            const AppSectionHeader(title: 'Keuangan'),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
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
            ),

            const SizedBox(height: 32),

            const AppSectionHeader(title: 'Profil'),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
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
                      icon: Icons.lock_outline_rounded,
                      title: 'Ganti password',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                      ),
                    ),
                    AppProfileMenuItem(
                      icon: Icons.delete_outline_rounded,
                      title: 'Hapus akun saya',
                      isDestructive: true,
                      isBottom: true,
                      onTap: () => _navigateToPlaceholder(context, 'Hapus Akun'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),

            AppButton(
              label: 'Log Out',
              variant: AppButtonVariant.error,
              icon: Icons.logout_rounded,
              width: double.infinity,
              onTap: () async {
                await sl.authController.logout(resetLanding: true);
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LandingPage()),
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