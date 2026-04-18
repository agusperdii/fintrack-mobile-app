import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/kinetic_vault_theme.dart';
import 'widgets/glass_card.dart';
import 'widgets/ambient_glow.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KineticVaultTheme.background,
      appBar: AppBar(
        backgroundColor: KineticVaultTheme.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: KineticVaultTheme.surfaceContainer,
                border: Border.all(color: KineticVaultTheme.onSurfaceVariant.withValues(alpha: 0.2)),
                image: const DecorationImage(
                  image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBYzFgqNTt25JiwF_nn8Ik2_pS8Mk0TItC-YVLKFs6M5nQnHwXk_zkzynncRDvlU2pUPVtdHrvAnLvpMAuuV07tVaCYan7mLrnlq3lpeJyvl3orRP11NY0aLenJJs4HOZwrrb-v3ctG1VW4T6Vod_faqH3EfTy_I42be2X1pAoPz1k8QkHdgLoEz4VpZf1qbxgSgcJbJalr1Hev2o8YBdUPSMG8QM-l1-ifMni7yBwMOIvs1yYU4V2y_f45D5-TuEEgVv7iLEICazs'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: KineticVaultTheme.primary, size: 20),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Text(
              'MONTHLY SUMMARY ARCHIVE',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                color: KineticVaultTheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ringkasan Transaksi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: KineticVaultTheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildHeroArchiveCard(),
            
            const SizedBox(height: 40),

            // Year Group 2026
            _buildYearHeader('2026', KineticVaultTheme.secondary),
            const SizedBox(height: 20),
            _buildMonthGrid([
              _buildMonthCard(
                month: 'Maret 2026',
                transactions: '1476 Transaksi',
                isHighlight: true,
              ),
              _buildMonthCard(
                month: 'Februari 2026',
                transactions: '1242 Transaksi',
              ),
              _buildMonthCard(
                month: 'Januari 2026',
                transactions: '980 Transaksi',
              ),
            ]),

            const SizedBox(height: 40),

            // Year Group 2025
            _buildYearHeader('2025', KineticVaultTheme.onSurfaceVariant),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 1,
              mainAxisSpacing: 12,
              childAspectRatio: 3.5,
              children: [
                _buildSmallMonthCard('Desember 2025', '1104 TX'),
                _buildSmallMonthCard('November 2025', '892 TX'),
                _buildSmallMonthCard('Oktober 2025', '1020 TX'),
                _buildSmallMonthCard('September 2025', '945 TX'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroArchiveCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(24.0),
        borderRadius: 16,
        color: const Color(0x9923262C),
        child: Stack(
          children: [
            const Positioned(
              right: -60,
              top: -60,
              child: AmbientGlow(size: 160, color: KineticVaultTheme.primary, opacity: 0.1),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL ARCHIVIST',
                  style: GoogleFonts.plusJakartaSans(
                    color: KineticVaultTheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: KineticVaultTheme.onSurface,
                    ),
                    children: const [
                      TextSpan(text: '24'),
                      TextSpan(
                        text: '.',
                        style: TextStyle(color: KineticVaultTheme.primary),
                      ),
                      TextSpan(text: 'Bulan'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: KineticVaultTheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Text(
                    'Data Terproteksi • Enkripsi AES-256',
                    style: GoogleFonts.inter(
                      color: KineticVaultTheme.onSurface,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearHeader(String year, Color color) {
    return Row(
      children: [
        Text(
          year,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.3), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthGrid(List<Widget> children) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 1,
      mainAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: children,
    );
  }

  Widget _buildMonthCard({
    required String month,
    required String transactions,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KineticVaultTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    month,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: KineticVaultTheme.onSurface,
                    ),
                  ),
                  Text(
                    transactions,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: KineticVaultTheme.tertiary,
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: KineticVaultTheme.surfaceContainerHighest,
                ),
                child: const Icon(
                  Icons.history_edu,
                  color: KineticVaultTheme.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          isHighlight 
            ? HighlightButton(onPressed: () {}, label: 'Download Laporan')
            : ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download Laporan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KineticVaultTheme.surfaceContainerHighest,
                  foregroundColor: KineticVaultTheme.onSurface,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildSmallMonthCard(String month, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: KineticVaultTheme.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KineticVaultTheme.onSurfaceVariant.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                month,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: KineticVaultTheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              Text(
                count,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: KineticVaultTheme.onSurface.withValues(alpha: 0.4),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: KineticVaultTheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.download, color: KineticVaultTheme.primary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'PDF',
                        style: GoogleFonts.inter(
                          color: KineticVaultTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: KineticVaultTheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.visibility,
                  color: KineticVaultTheme.onSurface.withValues(alpha: 0.6),
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom wrapper to allow highlight button to use gradient
class HighlightButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const HighlightButton({super.key, required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        gradient: KineticVaultTheme.primaryGradient,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(100),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.download, color: KineticVaultTheme.onPrimaryFixed, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: KineticVaultTheme.onPrimaryFixed,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
