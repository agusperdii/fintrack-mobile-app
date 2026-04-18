import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../atoms/glass_card.dart';

class BalanceCard extends StatelessWidget {
  final double balance;

  const BalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL SALDO ANDA',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: KineticVaultTheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              const Icon(Icons.wallet, color: KineticVaultTheme.primary, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            KineticVaultTheme.formatCurrency(balance),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: KineticVaultTheme.onSurface,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceMiniItem(
                label: 'Pemasukan',
                amount: 'Rp12.450.000',
                icon: Icons.south_west,
                color: KineticVaultTheme.tertiary,
              ),
              _buildBalanceMiniItem(
                label: 'Pengeluaran',
                amount: 'Rp5.200.000',
                icon: Icons.north_east,
                color: KineticVaultTheme.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceMiniItem({
    required String label,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: KineticVaultTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: KineticVaultTheme.onSurface,
          ),
        ),
      ],
    );
  }
}
