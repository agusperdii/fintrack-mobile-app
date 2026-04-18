import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/api_service.dart';
import 'theme/kinetic_vault_theme.dart';
import 'widgets/ambient_glow.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, String>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KineticVaultTheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: KineticVaultTheme.background,
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: KineticVaultTheme.surfaceContainerHighest,
                        border: Border.all(color: KineticVaultTheme.outlineVariant.withValues(alpha: 0.2)),
                        image: const DecorationImage(
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCTNhk8aetsWVOgR4RQisJGd8tGKvajRnSSKLj4DMHsOL2MZ1TC75GZYRHNKzOSdkaXB3Zyq9dNc-Md9dj24rhAsAS4H8IJVrM9epttGZUiZuvV0RRdXZ3H2Z6FsNCjmUEetFThNZmmky2O53rlK9PtrBwXyklcvoRsC_BEWX_DrXUT8C-kr1ASZKVKVrbV3OVF1GiLD1enFvqJwERAo3TBAsYVhOkH6bY8zmikfPvW7Zn3nxUMIDxCk6NROMPYRrBjoBBQjMMWrww'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ShaderMask(
                      shaderCallback: (bounds) => KineticVaultTheme.primaryGradient.createShader(bounds),
                      child: Text(
                        'The Kinetic Vault',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_outlined, 
                    color: KineticVaultTheme.primary, 
                    size: 20
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Using mock data from HTML instead of API to match design exactly
          const userName = 'Leonardo Da’vinci';
          const userHandle = '@agusperdii';
          const userEmail = 'leonardo.davinci@kineticvault.com';
          const avatarUrl = 'https://lh3.googleusercontent.com/aida-public/AB6AXuCiFGzVgecqCYvbjM6FhDdTQVz1EKQsOleuJYWkMVimedbVz2KlbE9qZRle-eJwhTo_mV7NS_eR4jGNdnWrVD_7msFNNylsPL2r2IrK7FgJONfpwhwisWyxPR5Ot-qLnPQ2xmgXgL-AfGcZGchFV402cdgb0LuGOY4PmolelofW2jEO-eVSthHdXkjuMqhhA0_8Oq92iwdV59onMMEpwCeeIo0A90nzAnmh2Za2yRGwbwrxJAKJCkq0jwF4Ra2ylZExQgsJRg2tpDQ';

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
                                  backgroundImage: const NetworkImage(avatarUrl),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              userName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: KineticVaultTheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userHandle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: KineticVaultTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userEmail,
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
                      onTap: () {},
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
                                      'Atur target pengeluaran',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: KineticVaultTheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      'Kendali finansial di tanganmu',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: KineticVaultTheme.onSurfaceVariant,
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
                      ),
                      _buildProfileItem(
                        icon: Icons.alternate_email_rounded,
                        title: 'Ganti username',
                      ),
                      _buildProfileItem(
                        icon: Icons.lock_reset_rounded,
                        title: 'Ganti password',
                      ),
                      _buildProfileItem(
                        icon: Icons.delete_forever_rounded,
                        title: 'Hapus akun saya',
                        isDestructive: true,
                        isBottom: true,
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
                      onTap: () {},
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
    bool isDestructive = false,
    bool isTop = false,
    bool isBottom = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
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
