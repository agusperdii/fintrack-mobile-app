import 'package:flutter/material.dart';
import 'dart:ui';
import 'theme/kinetic_vault_theme.dart';
import 'dashboard_screen.dart';
import 'analisa_page.dart';
import 'add_transaction_page.dart';
import 'summary_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Replaced ChatPage with SummaryPage
  final List<Widget> _pages = [
    const DashboardPage(),
    const AnalisaPage(),
    const SummaryPage(),
    const ProfilePage(),
  ];

  void _showAddTransaction() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        pageBuilder: (context, animation, secondaryAnimation) => const AddTransactionPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 100,
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: KineticVaultTheme.background.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home, Icons.home_outlined),
                _buildNavItem(1, Icons.analytics, Icons.analytics_outlined),
                _buildAddButton(),
                _buildNavItem(2, Icons.history_edu, Icons.history_edu_outlined), // History icon for Summary
                _buildNavItem(3, Icons.person, Icons.person_outlined),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: isSelected
            ? BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [KineticVaultTheme.primary, KineticVaultTheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: KineticVaultTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                  ),
                ],
              )
            : null,
        child: Icon(
          isSelected ? activeIcon : inactiveIcon,
          color: isSelected ? KineticVaultTheme.background : KineticVaultTheme.onSurface.withValues(alpha: 0.4),
          size: isSelected ? 24 : 20,
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showAddTransaction,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          Icons.add_circle_outline,
          color: KineticVaultTheme.onSurface.withValues(alpha: 0.4),
          size: 24,
        ),
      ),
    );
  }
}
