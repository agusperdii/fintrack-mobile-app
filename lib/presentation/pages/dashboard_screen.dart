import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/service_locator.dart';
import '../../data/models/app_data.dart';
import '../organisms/balance_card.dart';
import '../organisms/app_header.dart';
import 'placeholder_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<AppData> _dashboardDataFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _dashboardDataFuture = sl.financeRepository.getDashboardData();
    });
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
      appBar: const AppHeader(),
      body: FutureBuilder<AppData>(
        future: _dashboardDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: KineticVaultTheme.primary));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            color: KineticVaultTheme.primary,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Text(
                    'Hi, Kadek!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: KineticVaultTheme.onSurface,
                    ),
                  ),
                  Text(
                    'Selamat Datang!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: KineticVaultTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Hero Balance Card
                  BalanceCard(balance: data.balance),
                  const SizedBox(height: 32),

                  // Quick Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCircularAction(
                        icon: Icons.call_made,
                        label: 'Pengeluaran',
                        color: KineticVaultTheme.error,
                        onTap: () => _navigateToPlaceholder('Detail Pengeluaran'),
                      ),
                      _buildGradientAction(
                        icon: Icons.receipt_long,
                        label: 'Scan Struk',
                        onTap: () => _navigateToPlaceholder('Scan Struk AI'),
                      ),
                      _buildCircularAction(
                        icon: Icons.call_received,
                        label: 'Pemasukan',
                        color: KineticVaultTheme.tertiary,
                        onTap: () => _navigateToPlaceholder('Detail Pemasukan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Recent History
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Riwayat Hari ini',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: KineticVaultTheme.onSurface,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _navigateToPlaceholder('Semua Riwayat'),
                        child: Text(
                          'Semua Riwayat',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: KineticVaultTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.recentTransactions.length > 2 ? 2 : data.recentTransactions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final tx = data.recentTransactions[index];
                      return _buildHistoryItem(tx);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Weekly Pulse Visualization
                  _buildWeeklyPulse(),
                  
                  const SizedBox(height: 100), // Spacing for BottomNav
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircularAction({
    required IconData icon, 
    required String label, 
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: KineticVaultTheme.surfaceContainerHighest,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: KineticVaultTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientAction({
    required IconData icon, 
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: KineticVaultTheme.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: KineticVaultTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                ),
              ],
            ),
            child: const Icon(Icons.receipt_long, color: KineticVaultTheme.onPrimaryFixed, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: KineticVaultTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Transaction tx) {
    final isExpense = tx.amount < 0;
    return GestureDetector(
      onTap: () => _navigateToPlaceholder('Detail Transaksi'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: KineticVaultTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: KineticVaultTheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isExpense ? Icons.coffee : Icons.shopping_bag,
                color: isExpense ? KineticVaultTheme.secondary : KineticVaultTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: KineticVaultTheme.onSurface,
                    ),
                  ),
                  Text(
                    '${tx.date} • 09:41',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: KineticVaultTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isExpense ? "-" : "+"} ${KineticVaultTheme.formatCurrency(tx.amount.abs())}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: KineticVaultTheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyPulse() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KineticVaultTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WEEKLY PULSE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: KineticVaultTheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Growth +12%',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: KineticVaultTheme.tertiary,
                    ),
                  ),
                ],
              ),
              Icon(Icons.insights, color: KineticVaultTheme.onSurfaceVariant.withValues(alpha: 0.3), size: 18),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildPulseBar(heightFactor: 0.5),
                _buildPulseBar(heightFactor: 0.8),
                _buildPulseBar(heightFactor: 0.4),
                _buildPulseBar(heightFactor: 1.0, isHighlighted: true),
                _buildPulseBar(heightFactor: 0.7),
                _buildPulseBar(heightFactor: 0.5),
                _buildPulseBar(heightFactor: 0.8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseBar({required double heightFactor, bool isHighlighted = false}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        height: 48 * heightFactor,
        decoration: BoxDecoration(
          color: isHighlighted ? KineticVaultTheme.tertiary : KineticVaultTheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isHighlighted ? [
            BoxShadow(
              color: KineticVaultTheme.tertiary.withValues(alpha: 0.3),
              blurRadius: 10,
            )
          ] : null,
        ),
      ),
    );
  }
}
