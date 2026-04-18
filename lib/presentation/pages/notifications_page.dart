import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../atoms/ambient_glow.dart';
import '../atoms/app_heading.dart';
import '../atoms/app_icon_container.dart';
import '../atoms/app_button.dart';
import '../atoms/app_progress_bar.dart';
import '../molecules/app_notification_card.dart';
import '../molecules/app_editorial_header.dart';
import '../organisms/app_header.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KineticVaultTheme.background,
      appBar: const AppHeader(
        title: 'Notifikasi', 
        showBackButton: true,
        showNotification: false,
      ),
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            right: -100,
            child: AmbientGlow(size: 400, color: KineticVaultTheme.primary, opacity: 0.05),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const AppEditorialHeader(
                      category: 'ACTIVITY HUB',
                      title: 'Notifikasi',
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const AppHeading(
                        'Tandai semua dibaca',
                        size: AppHeadingSize.subtitle,
                        color: KineticVaultTheme.primary,
                        isBold: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Notification Feed
                AppNotificationCard(
                  category: 'BUDGET ALERT',
                  time: 'Baru saja',
                  variant: AppNotificationVariant.warning,
                  content: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        color: KineticVaultTheme.onSurface,
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(text: 'Batas harian hampir tercapai! Sisa '),
                        TextSpan(
                          text: 'Rp20.000',
                          style: TextStyle(color: KineticVaultTheme.error),
                        ),
                        TextSpan(text: ' untuk hari ini. Mau masak sendiri aja biar hemat?'),
                      ],
                    ),
                  ),
                  actions: [
                    AppButton(
                      label: 'ABAIKAN',
                      variant: AppButtonVariant.secondary,
                      width: 100,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      label: 'LIHAT BUDGET',
                      variant: AppButtonVariant.error,
                      width: 120,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppNotificationCard(
                  category: 'SMART INSIGHT',
                  time: '45 mnt lalu',
                  variant: AppNotificationVariant.info,
                  content: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        color: KineticVaultTheme.onSurface,
                        fontSize: 12,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(text: 'Wah, pengeluaran kopi kamu minggu ini naik '),
                        TextSpan(
                          text: '15%',
                          style: TextStyle(color: KineticVaultTheme.primary, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '. Coba kurangi 1 gelas buat nambah tabungan konsert!'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppNotificationCard(
                  category: 'STREAK BONUS',
                  time: '2 jam yang lalu',
                  variant: AppNotificationVariant.streak,
                  content: const AppHeading(
                    'Jangan putus streak-nya! Catat pengeluaran makan siangmu sekarang dan dapatkan bonus poin.',
                    size: AppHeadingSize.subtitle,
                    isBold: false,
                  ),
                  footer: Row(
                    children: [
                      const Expanded(
                        child: AppProgressBar(
                          value: 0.8,
                          color: KineticVaultTheme.secondary,
                          height: 4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const AppHeading(
                        '4/5 Days',
                        size: AppHeadingSize.caption,
                        color: KineticVaultTheme.secondary,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppNotificationCard(
                  category: 'WEEKLY RECAP',
                  time: 'Kemarin',
                  variant: AppNotificationVariant.success,
                  content: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        color: KineticVaultTheme.onSurface,
                        fontSize: 12,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(text: 'Laporan mingguan sudah siap. Kamu lebih hemat '),
                        TextSpan(
                          text: '10%',
                          style: TextStyle(color: KineticVaultTheme.tertiary, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' dari minggu lalu! Mantap!'),
                      ],
                    ),
                  ),
                  footer: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: KineticVaultTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            AppIconContainer(
                              icon: Icons.trending_down,
                              color: KineticVaultTheme.tertiary,
                              size: 28,
                              shape: AppIconShape.rounded,
                            ),
                            SizedBox(width: 12),
                            AppHeading(
                              'Efisiensi Belanja',
                              size: AppHeadingSize.caption,
                              isBold: true,
                            ),
                          ],
                        ),
                        AppHeading(
                          '+Rp145k',
                          size: AppHeadingSize.subtitle,
                          color: KineticVaultTheme.tertiary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Suggestion Section
                const AppHeading(
                  'Terlewatkan?',
                  size: AppHeadingSize.h3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSuggestionCard(
                        icon: Icons.account_balance_wallet,
                        label: 'Wallet',
                        title: 'Cek Saldo Gopay Kamu',
                        color: KineticVaultTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSuggestionCard(
                        icon: Icons.savings,
                        label: 'Vault',
                        title: 'Target Konsert: 85%',
                        color: KineticVaultTheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard({
    required IconData icon,
    required String label,
    required String title,
    required Color color,
  }) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KineticVaultTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeading(
                  label.toUpperCase(),
                  size: AppHeadingSize.caption,
                  color: KineticVaultTheme.onSurface.withValues(alpha: 0.5),
                  isBold: true,
                ),
                const SizedBox(height: 4),
                AppHeading(
                  title,
                  size: AppHeadingSize.subtitle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
