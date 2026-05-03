import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/pages/dashboard_page.dart';
import 'package:savaio/views/pages/analisa_page.dart';
import 'package:savaio/views/pages/profile_page.dart';
import 'package:savaio/views/pages/summary_page.dart';
import 'package:savaio/views/pages/add_transaction_page.dart';
import 'package:savaio/core/utils/service_locator.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch data only if not already present or loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = sl.financeController;
      if (controller.dashboardData == null && !controller.isLoading) {
        controller.loadInitialData();
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
    // final bottomPadding = 16;
    // Use a consistent margin for all sides to ensure symmetry. 
    // On iOS notched devices, bottomPadding is typically 34, so we use that for side symmetry too.
    // On Android/older devices, we default to 24.
    final horizontalMargin = 22.0;
    final bottomMargin = horizontalMargin;
    
    return Scaffold(
      backgroundColor: SavaioTheme.background,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          Positioned(
            left: horizontalMargin,
            right: horizontalMargin,
            bottom: bottomMargin,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: SavaioTheme.surfaceContainerHighest.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: SavaioTheme.outlineVariant.withValues(alpha: 0.2)),
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
              SavaioTheme.primary.withValues(alpha: 0.1),
              SavaioTheme.secondary.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ) : null,
        child: Icon(
          icon,
          color: isSelected ? SavaioTheme.primary : SavaioTheme.onSurfaceVariant,
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
          gradient: SavaioTheme.primaryGradient,
        ),
        child: const Icon(
          Icons.add_rounded,
          color: SavaioTheme.onPrimaryFixed,
          size: 32,
        ),
      ),
    );
  }
}
