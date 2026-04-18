import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../atoms/glass_card.dart';
import '../atoms/ambient_glow.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KineticVaultTheme.background,
      appBar: AppBar(
        title: const Text('The Kinetic Vault'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: KineticVaultTheme.surfaceContainerHighest,
            shape: const CircleBorder(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: KineticVaultTheme.primary.withValues(alpha: 0.2),
              child: ClipOval(
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCH1C206xwMbUM87RGxGStHoDKvmKWS40yu6hm0NmBZdFkYQWq1c_sok0uwSgyajjEL3xyfbf27YunHZxcbmOaFP0NU0a1SkfuvobwtHFkOLGjnHbJ74EMNq18a1XIKqnTnqHJoX3L1QMhF7JeDSirbMcbIXBkyEdIbtVVJakA6YbZk4fu6LACe_0xOcwTaJZVqXyo2NNAuXX0Xpg4VS3m3MzuJ2-lJXzfxA9jojNgO7PY2WrfUrpu7Qv-dJ0vFQiQcr5LrZpkU0aA',
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACTIVITY HUB',
                          style: GoogleFonts.plusJakartaSans(
                            color: KineticVaultTheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Notifikasi',
                          style: GoogleFonts.plusJakartaSans(
                            color: KineticVaultTheme.onSurface,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Tandai semua dibaca',
                        style: GoogleFonts.inter(
                          color: KineticVaultTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Notification Feed
                _buildBudgetAlert(),
                const SizedBox(height: 16),
                _buildSmartInsight(),
                const SizedBox(height: 16),
                _buildStreakReminder(),
                const SizedBox(height: 16),
                _buildWeeklyRecap(),

                const SizedBox(height: 48),

                // Suggestion Section
                Text(
                  'Terlewatkan?',
                  style: GoogleFonts.plusJakartaSans(
                    color: KineticVaultTheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
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

  Widget _buildBudgetAlert() {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderColor: KineticVaultTheme.error.withValues(alpha: 0.5),
      borderWidth: 0,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: KineticVaultTheme.error.withValues(alpha: 0.5),
              width: 4,
            ),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: KineticVaultTheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning, color: KineticVaultTheme.error, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BUDGET ALERT',
                        style: GoogleFonts.plusJakartaSans(
                          color: KineticVaultTheme.error,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'Baru saja',
                        style: GoogleFonts.inter(
                          color: KineticVaultTheme.onSurface.withValues(alpha: 0.4),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        color: KineticVaultTheme.onSurface,
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        const TextSpan(text: 'Batas harian hampir tercapai! Sisa '),
                        const TextSpan(
                          text: 'Rp20.000',
                          style: TextStyle(color: KineticVaultTheme.error),
                        ),
                        const TextSpan(text: ' untuk hari ini. Mau masak sendiri aja biar hemat?'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KineticVaultTheme.surfaceContainerHighest,
                          foregroundColor: KineticVaultTheme.onSurface,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'ABAIKAN',
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KineticVaultTheme.error,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'LIHAT BUDGET',
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartInsight() {
    return GlassCard(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            right: -40,
            top: -40,
            child: AmbientGlow(size: 120, color: KineticVaultTheme.primary, opacity: 0.05),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: KineticVaultTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lightbulb, color: KineticVaultTheme.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SMART INSIGHT',
                          style: GoogleFonts.plusJakartaSans(
                            color: KineticVaultTheme.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          '45 mnt lalu',
                          style: GoogleFonts.inter(
                            color: KineticVaultTheme.onSurface.withValues(alpha: 0.4),
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          color: KineticVaultTheme.onSurface,
                          fontSize: 12,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'Wah, pengeluaran kopi kamu minggu ini naik '),
                          const TextSpan(
                            text: '15%',
                            style: TextStyle(color: KineticVaultTheme.primary, fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: '. Coba kurangi 1 gelas buat nambah tabungan konsert!'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakReminder() {
    return GlassCard(
      borderColor: KineticVaultTheme.onSurfaceVariant.withValues(alpha: 0.1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: KineticVaultTheme.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.fireplace, color: KineticVaultTheme.secondary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STREAK BONUS',
                      style: GoogleFonts.plusJakartaSans(
                        color: KineticVaultTheme.secondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      '2 jam yang lalu',
                      style: GoogleFonts.inter(
                        color: KineticVaultTheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Jangan putus streak-nya! Catat pengeluaran makan siangmu sekarang dan dapatkan bonus poin.',
                  style: GoogleFonts.inter(
                    color: KineticVaultTheme.onSurface,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.8,
                          backgroundColor: KineticVaultTheme.surfaceContainerHighest,
                          valueColor: const AlwaysStoppedAnimation<Color>(KineticVaultTheme.secondary),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '4/5 Days',
                      style: GoogleFonts.plusJakartaSans(
                        color: KineticVaultTheme.secondary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyRecap() {
    return GlassCard(
      borderColor: KineticVaultTheme.onSurfaceVariant.withValues(alpha: 0.1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: KineticVaultTheme.tertiary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: KineticVaultTheme.tertiary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'WEEKLY RECAP',
                      style: GoogleFonts.plusJakartaSans(
                        color: KineticVaultTheme.tertiary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      'Kemarin',
                      style: GoogleFonts.inter(
                        color: KineticVaultTheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      color: KineticVaultTheme.onSurface,
                      fontSize: 12,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'Laporan mingguan sudah siap. Kamu lebih hemat '),
                      const TextSpan(
                        text: '10%',
                        style: TextStyle(color: KineticVaultTheme.tertiary, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' dari minggu lalu! Mantap!'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: KineticVaultTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 28,
                            width: 28,
                            decoration: BoxDecoration(
                              color: KineticVaultTheme.tertiary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.trending_down, color: KineticVaultTheme.tertiary, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Efisiensi Belanja',
                            style: GoogleFonts.inter(
                              color: KineticVaultTheme.onSurface,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '+Rp145k',
                        style: GoogleFonts.inter(
                          color: KineticVaultTheme.tertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
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
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    color: KineticVaultTheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: KineticVaultTheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
