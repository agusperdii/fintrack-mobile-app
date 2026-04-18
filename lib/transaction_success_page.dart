import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/kinetic_vault_theme.dart';
import 'widgets/ambient_glow.dart';

class TransactionSuccessPage extends StatelessWidget {
  const TransactionSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KineticVaultTheme.background,
      appBar: AppBar(
        backgroundColor: KineticVaultTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: KineticVaultTheme.onSurfaceVariant),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Daily Reward',
          style: GoogleFonts.plusJakartaSans(
            color: KineticVaultTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background content mock (blurred appearance)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Opacity(
              opacity: 0.1, // Simulating blur/background effect
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: KineticVaultTheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(child: Container(height: 100, decoration: BoxDecoration(color: KineticVaultTheme.surfaceContainerLow, borderRadius: BorderRadius.circular(16)))),
                      const SizedBox(width: 16),
                      Expanded(child: Container(height: 100, decoration: BoxDecoration(color: KineticVaultTheme.surfaceContainerLow, borderRadius: BorderRadius.circular(16)))),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Modal Overlay
          Container(
            color: KineticVaultTheme.background.withValues(alpha: 0.6),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF23262C).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: KineticVaultTheme.outlineVariant.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Abstract Glows
                    Positioned(
                      top: -40,
                      left: -40,
                      child: AmbientGlow(size: 160, color: KineticVaultTheme.primary, opacity: 0.1),
                    ),
                    Positioned(
                      bottom: -40,
                      right: -40,
                      child: AmbientGlow(size: 160, color: KineticVaultTheme.secondary, opacity: 0.1),
                    ),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Glowing Badge
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background Glows
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: KineticVaultTheme.primary.withValues(alpha: 0.2), blurRadius: 40, spreadRadius: 10),
                                    BoxShadow(color: KineticVaultTheme.secondary.withValues(alpha: 0.1), blurRadius: 40, spreadRadius: 20),
                                  ],
                                ),
                              ),
                              // Fire Icon
                              Container(
                                width: 128,
                                height: 128,
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [KineticVaultTheme.primary, KineticVaultTheme.secondary],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF0C0E12),
                                  ),
                                  child: Center(
                                    child: Image.network(
                                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDFPeTBcl5r9_eGeGuYqVQZnL46xVIxnp_B1Y1m5HB3v0cy5DV9cVbljocKHhjkNp36kijVMOt-tK2gizBuCScAINLNTStcXIaNdSWt4FFNfFHoBywh9k58LHRcWSZREzJcKDcekcM7zZffTqp6uGrvFNAZwIM9eXyOQvt-LAgYa2aOR7IRARbzB2zMfEzeUQSH9JY2ZgFuy97ghJzftkm6MB3z4mvIiQbQ8-raB2gxUOOSOr6xKULxaqZ3YAT_ltSnFm5uThdxAYc',
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              // Days Badge
                              Positioned(
                                bottom: -4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: KineticVaultTheme.primary,
                                    borderRadius: BorderRadius.circular(100),
                                    boxShadow: [
                                      BoxShadow(
                                        color: KineticVaultTheme.primary.withValues(alpha: 0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '7 Hari Berturut-turut!',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: KineticVaultTheme.onPrimaryFixed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        Text(
                          'Mantap! Pencatatan Selesai.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: KineticVaultTheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Kamu selangkah lebih dekat dengan target tabunganmu bulan ini.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: KineticVaultTheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Action Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: KineticVaultTheme.primary.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Close success page
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KineticVaultTheme.primary,
                              foregroundColor: KineticVaultTheme.onPrimaryFixed,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              elevation: 0,
                            ),
                            child: Text(
                              'Lanjutkan',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
