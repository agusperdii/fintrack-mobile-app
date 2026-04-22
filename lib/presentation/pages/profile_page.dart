import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/service_locator.dart';
import '../atoms/ambient_glow.dart';
import '../atoms/app_avatar.dart';
import '../atoms/app_button.dart';
import '../organisms/app_header.dart';
import '../molecules/app_profile_menu_item.dart';
import '../molecules/app_section_header.dart';
import '../atoms/app_heading.dart';
import '../atoms/app_icon_container.dart';
import 'spending_target_page.dart';
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
      listenable: sl.financeProvider,
      builder: (context, _) {
        final provider = sl.financeProvider;
        
        if (provider.isLoading || provider.userProfile == null || provider.spendingTarget == null) {
          return const Scaffold(
            backgroundColor: KineticVaultTheme.background,
            body: Center(child: CircularProgressIndicator(color: KineticVaultTheme.primary)),
          );
        }

        final profile = provider.userProfile!;
        final targetData = provider.spendingTarget!;
        
        final targetAmount = targetData['amount'] as double;
        final targetPeriod = targetData['period'] as String;

        return Scaffold(
          backgroundColor: KineticVaultTheme.background,
          appBar: AppHeader(
            title: 'Profil',
            avatarUrl: profile['avatar'],
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -96,
                        right: -96,
                        child: AmbientGlow(
                          size: 240,
                          color: KineticVaultTheme.primary,
                          opacity: 0.15,
                        ),
                      ),
                      Center(
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
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),

                // App Settings Section
                const AppSectionHeader(title: 'APLIKASI'),
                const SizedBox(height: 12),
                
                // Hero Spending Card
                Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        KineticVaultTheme.primary.withValues(alpha: 0.1),
                        KineticVaultTheme.secondary.withValues(alpha: 0.1)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: KineticVaultTheme.outlineVariant.withValues(alpha: 0.1)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SpendingTargetPage()),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const AppIconContainer(
                                  icon: Icons.track_changes,
                                  color: KineticVaultTheme.primary,
                                  size: 40,
                                  opacity: 0.2,
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const AppHeading(
                                      'Target Pengeluaran',
                                      size: AppHeadingSize.subtitle,
                                    ),
                                    AppHeading(
                                      '${KineticVaultTheme.formatCurrency(targetAmount)} / $targetPeriod',
                                      size: AppHeadingSize.caption,
                                      color: KineticVaultTheme.primary,
                                      isBold: true,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Icon(Icons.chevron_right, color: KineticVaultTheme.primary, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Profile Management Section
                const AppSectionHeader(title: 'PROFIL'),
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
                        onTap: () => _navigateToPlaceholder('Edit Nama'),
                      ),
                      AppProfileMenuItem(
                        icon: Icons.alternate_email_rounded,
                        title: 'Ganti username',
                        onTap: () => _navigateToPlaceholder('Ganti Username'),
                      ),
                      AppProfileMenuItem(
                        icon: Icons.lock_reset_rounded,
                        title: 'Ganti password',
                        onTap: () => _navigateToPlaceholder('Ganti Password'),
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
                  onTap: () => _navigateToPlaceholder('Logout'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
