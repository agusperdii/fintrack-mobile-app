import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/service_locator.dart';
import '../atoms/ambient_glow.dart';
import '../organisms/app_header.dart';
import 'spending_target_page.dart';
import 'placeholder_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, String>> _profileFuture;
  late Future<Map<String, dynamic>> _targetFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = sl.financeRepository.getUserProfile();
    _targetFuture = sl.financeRepository.getSpendingTarget();
  }

  void _navigateToPlaceholder(String feature) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlaceholderPage(featureName: feature)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KineticVaultTheme.background,
      appBar: const AppHeader(title: 'Profil'),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_profileFuture, _targetFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final profile = snapshot.data![0] as Map<String, String>;
          final targetData = snapshot.data![1] as Map<String, dynamic>;
          
          final targetAmount = targetData['amount'] as double;
          final targetPeriod = targetData['period'] as String;

          return SingleChildScrollView(
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
                            Container(
                              width: 80,
                              height: 80,
                              padding: const EdgeInsets.all(1),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [KineticVaultTheme.primary, KineticVaultTheme.secondary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: KineticVaultTheme.surface,
                                ),
                                child: CircleAvatar(
                                  radius: 38,
                                  backgroundImage: NetworkImage(profile['avatar']!),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              profile['name']!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: KineticVaultTheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              profile['handle'] ?? '@user',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: KineticVaultTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile['email']!,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: KineticVaultTheme.onSurfaceVariant.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),

                // App Settings Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 12),
                    child: Text(
                      'APLIKASI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: KineticVaultTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                
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
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SpendingTargetPage()),
                        );
                        // Refresh data after returning
                        setState(() {
                          _targetFuture = sl.financeRepository.getSpendingTarget();
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: KineticVaultTheme.primary.withValues(alpha: 0.2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: KineticVaultTheme.primary.withValues(alpha: 0.1),
                                        blurRadius: 15,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.track_changes, color: KineticVaultTheme.primary, size: 18),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Target Pengeluaran',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: KineticVaultTheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      '${KineticVaultTheme.formatCurrency(targetAmount)} / $targetPeriod',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: KineticVaultTheme.primary,
                                      ),
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 12),
                    child: Text(
                      'PROFIL',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: KineticVaultTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                
                Container(
                  decoration: BoxDecoration(
                    color: KineticVaultTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildProfileItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Edit nama',
                        isTop: true,
                        onTap: () => _navigateToPlaceholder('Edit Nama'),
                      ),
                      _buildProfileItem(
                        icon: Icons.alternate_email_rounded,
                        title: 'Ganti username',
                        onTap: () => _navigateToPlaceholder('Ganti Username'),
                      ),
                      _buildProfileItem(
                        icon: Icons.lock_reset_rounded,
                        title: 'Ganti password',
                        onTap: () => _navigateToPlaceholder('Ganti Password'),
                      ),
                      _buildProfileItem(
                        icon: Icons.delete_forever_rounded,
                        title: 'Hapus akun saya',
                        isDestructive: true,
                        isBottom: true,
                        onTap: () => _navigateToPlaceholder('Hapus Akun'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Logout Button
                Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _navigateToPlaceholder('Logout'),
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        decoration: BoxDecoration(
                          color: KineticVaultTheme.errorContainer.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: KineticVaultTheme.error.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.logout_rounded, color: KineticVaultTheme.error, size: 18),
                            const SizedBox(width: 12),
                            Text(
                              'Log Out',
                              style: GoogleFonts.plusJakartaSans(
                                color: KineticVaultTheme.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isTop = false,
    bool isBottom = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isTop ? const Radius.circular(8) : Radius.zero,
          bottom: isBottom ? const Radius.circular(8) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: isTop ? null : Border(
              top: BorderSide(color: KineticVaultTheme.outlineVariant.withValues(alpha: 0.1)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon, 
                    color: isDestructive ? KineticVaultTheme.error.withValues(alpha: 0.6) : KineticVaultTheme.onSurfaceVariant, 
                    size: 18
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: isDestructive ? KineticVaultTheme.error.withValues(alpha: 0.8) : KineticVaultTheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: KineticVaultTheme.outline.withValues(alpha: 0.4),
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
