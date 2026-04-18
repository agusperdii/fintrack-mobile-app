import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/kinetic_vault_theme.dart';
import 'widgets/glass_card.dart';
import 'widgets/ambient_glow.dart';

class AnalisaPage extends StatefulWidget {
  const AnalisaPage({super.key});

  @override
  State<AnalisaPage> createState() => _AnalisaPageState();
}

class _AnalisaPageState extends State<AnalisaPage> {
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
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: KineticVaultTheme.primary.withValues(alpha: 0.2), width: 2),
                image: const DecorationImage(
                  image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuB4484-TFf7yc7icxQ_yqrdT5pkDeT3QwX3GftAiTx2d4Aqj-u5Bl6x0Apg_yL1E3XujsEMnjvmWSPhMHcgni4amYSSCdFRSuSXwZduYuMwpxpOMMuIoHe9r9O-ukjIH0LSLLqd7mrfCFCEfPZR3evY8fuUh6psnlaoF3fwhvtro5PGnLkQAvVwe0v_0IeYsrwYGTC1bWxBxzoHxSbgIh_ZXBHaC1Rr0tbqQnpuqmy8P339f2CsnM6ZZQdGubKANOBgIR6er6yTakw'),
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
            // Editorial Header
            Text(
              'LAPORAN MINGGUAN',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                color: KineticVaultTheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Analisa Pengeluaran',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: KineticVaultTheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),

            // Hero Analysis Card
            _buildHeroAnalysisCard(),
            
            const SizedBox(height: 20),

            // Bento Card: Smart Insights
            _buildSmartInsightsCard(),

            const SizedBox(height: 32),

            // Category Breakdown Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Breakdown Kategori',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: KineticVaultTheme.onSurface,
                  ),
                ),
                Text(
                  'Lihat Semua',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: KineticVaultTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            _buildCategoryCard(
              icon: Icons.directions_car,
              title: 'Transportasi',
              amount: 'Rp850.000',
              progress: 0.65,
              limit: 'Batas: Rp1.300.000',
              status: 'Aman',
              accentColor: KineticVaultTheme.primary,
            ),
            const SizedBox(height: 16),
            _buildCategoryCard(
              icon: Icons.restaurant,
              title: 'Makanan',
              amount: 'Rp1.420.000',
              progress: 0.88,
              limit: 'Batas: Rp1.500.000',
              status: 'Hampir Habis',
              accentColor: KineticVaultTheme.secondary,
            ),
            const SizedBox(height: 16),
            _buildCategoryCard(
              icon: Icons.category,
              title: 'Lainnya',
              amount: 'Rp320.000',
              progress: 0.32,
              limit: 'Batas: Rp1.000.000',
              status: 'Stabil',
              accentColor: KineticVaultTheme.tertiary,
            ),

            const SizedBox(height: 32),

            // Weekly Trend Visualization
            _buildWeeklyTrendCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroAnalysisCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 16,
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
                'DAILY AVERAGE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: KineticVaultTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rp125.000,00',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: KineticVaultTheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: KineticVaultTheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: KineticVaultTheme.tertiary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_down, color: KineticVaultTheme.tertiary, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '12% BELOW BUDGET',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: KineticVaultTheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 80,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBar(0.4),
                    _buildBar(0.65),
                    _buildBar(0.45),
                    _buildBar(0.9, isHighlighted: true),
                    _buildBar(0.55),
                    _buildBar(0.7),
                    _buildBar(0.35),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'].map((day) {
                  final isToday = day == 'KAM';
                  return Text(
                    day,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      color: isToday ? KineticVaultTheme.primary : KineticVaultTheme.onSurfaceVariant,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double factor, {bool isHighlighted = false}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 80 * factor,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          gradient: isHighlighted ? KineticVaultTheme.primaryGradient : null,
          color: isHighlighted ? null : KineticVaultTheme.surfaceContainerHigh,
          boxShadow: isHighlighted ? [
            BoxShadow(color: KineticVaultTheme.primary.withValues(alpha: 0.4), blurRadius: 10)
          ] : null,
        ),
      ),
    );
  }

  Widget _buildSmartInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: KineticVaultTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wawasan Pintar',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: KineticVaultTheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 13,
                color: KineticVaultTheme.onSurfaceVariant,
                height: 1.5,
              ),
              children: const [
                TextSpan(text: 'Pengeluaran transportasi Anda turun '),
                TextSpan(
                  text: '15%',
                  style: TextStyle(color: KineticVaultTheme.tertiary, fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' minggu ini. Anda berada di jalur yang tepat untuk menabung lebih banyak bulan ini.'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: KineticVaultTheme.primaryGradient,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'DETAIL PENGHEMATAN',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: KineticVaultTheme.onPrimaryFixed,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: KineticVaultTheme.onPrimaryFixed, size: 14),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String amount,
    required double progress,
    required String limit,
    required String status,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KineticVaultTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accentColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: KineticVaultTheme.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                amount,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: KineticVaultTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: KineticVaultTheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                limit,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: KineticVaultTheme.onSurfaceVariant,
                ),
              ),
              Text(
                status.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: status == 'Aman' || status == 'Stabil' ? KineticVaultTheme.tertiary : KineticVaultTheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrendCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tren Ledger',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: KineticVaultTheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: KineticVaultTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: KineticVaultTheme.outlineVariant.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    _buildToggleButton('Minggu Ini', true),
                    _buildToggleButton('Bulan Ini', false),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: TrendLinePainter(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'].map((day) {
              return Text(
                day,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: day == 'KAM' ? KineticVaultTheme.primary : KineticVaultTheme.onSurfaceVariant,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? KineticVaultTheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isActive ? KineticVaultTheme.onPrimaryFixed : KineticVaultTheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class TrendLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [KineticVaultTheme.primary, KineticVaultTheme.secondary],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.15, size.height * 0.8, size.width * 0.3, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.45, size.height * 0.5, size.width * 0.6, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.6, size.width * 0.9, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.5);

    // Glow effect
    final shadowPaint = Paint()
      ..color = KineticVaultTheme.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    // Draw active point
    final pointPaint = Paint()
      ..color = KineticVaultTheme.primary
      ..style = PaintingStyle.fill;
    
    final glowPaint = Paint()
      ..color = KineticVaultTheme.primary.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final activeX = size.width * 0.6;
    const activeY = 30.0; // Approximation from path
    canvas.drawCircle(Offset(activeX, activeY), 8, glowPaint);
    canvas.drawCircle(Offset(activeX, activeY), 4, pointPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
