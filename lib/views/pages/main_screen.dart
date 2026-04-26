import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'analisa_page.dart';
import 'profile_page.dart';
import 'summary_page.dart';
import 'add_transaction_page.dart';
import '../../core/utils/service_locator.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch all initial data once when the main screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (sl.financeController.dashboardData == null) {
        sl.financeController.loadInitialData();
      }
    });
  }

  final List<Widget> _pages = [
    const DashboardPage(),
    const AnalisaPage(),
    const SummaryPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KineticVaultTheme.background,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: KineticVaultTheme.surfaceContainerHighest.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: KineticVaultTheme.outlineVariant.withValues(alpha: 0.2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0, Icons.grid_view_rounded, 'Home'),
                    _buildNavItem(1, Icons.bar_chart_rounded, 'Analisa'),
                    _buildFloatingActionButton(),
                    _buildNavItem(2, Icons.history_edu_rounded, 'Laporan'),
                    _buildNavItem(3, Icons.person_rounded, 'Profil'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: isSelected ? BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              KineticVaultTheme.primary.withValues(alpha: 0.1),
              KineticVaultTheme.secondary.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ) : null,
        child: Icon(
          icon,
          color: isSelected ? KineticVaultTheme.primary : KineticVaultTheme.onSurfaceVariant,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddTransactionPage()),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: KineticVaultTheme.primaryGradient,
        ),
        child: const Icon(
          Icons.add_rounded,
          color: KineticVaultTheme.onPrimaryFixed,
          size: 32,
        ),
      ),
    );
  }
}
