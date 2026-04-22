import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/service_locator.dart';
import '../organisms/app_balance_card.dart';
import '../organisms/app_header.dart';
import '../organisms/app_weekly_pulse_chart.dart';
import '../molecules/app_icon_button.dart';
import '../molecules/app_section_header.dart';
import '../molecules/app_transaction_item.dart';
import '../molecules/app_greeting_header.dart';
import 'placeholder_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    if (sl.financeProvider.dashboardData == null) {
      sl.financeProvider.fetchAllData();
    }
  }

  void _navigateToPlaceholder(String feature) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlaceholderPage(featureName: feature)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sl.financeProvider,
      builder: (context, _) {
        final provider = sl.financeProvider;
        
        if (provider.isLoading || provider.dashboardData == null) {
          return const Scaffold(
            backgroundColor: KineticVaultTheme.background,
            body: Center(child: CircularProgressIndicator(color: KineticVaultTheme.primary)),
          );
        }

        final data = provider.dashboardData!;
        
        return Scaffold(
          backgroundColor: KineticVaultTheme.background,
          appBar: AppHeader(
            avatarUrl: provider.userProfile?['avatar'],
          ),
          body: RefreshIndicator(
            onRefresh: () => provider.fetchAllData(),
            color: KineticVaultTheme.primary,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section (Molecule)
                  AppGreetingHeader(
                    userName: provider.userProfile?['name']?.split(' ').first ?? 'User',
                    avatarUrl: provider.userProfile?['avatar'],
                  ),
                  const SizedBox(height: 24),

                  // Hero Balance Card (Organism)
                  AppBalanceCard(balance: data.balance),
                  const SizedBox(height: 32),

                  // Quick Actions (Molecules)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AppIconButton(
                        icon: Icons.call_made,
                        label: 'Pengeluaran',
                        color: KineticVaultTheme.error,
                        onTap: () => _navigateToPlaceholder('Detail Pengeluaran'),
                      ),
                      AppIconButton(
                        icon: Icons.receipt_long,
                        label: 'Scan Struk',
                        variant: AppIconButtonVariant.gradient,
                        onTap: () => _navigateToPlaceholder('Scan Struk AI'),
                      ),
                      AppIconButton(
                        icon: Icons.call_received,
                        label: 'Pemasukan',
                        color: KineticVaultTheme.tertiary,
                        onTap: () => _navigateToPlaceholder('Detail Pemasukan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Recent History (Molecule + Molecule)
                  AppSectionHeader(
                    title: 'Riwayat Hari ini',
                    actionLabel: 'Semua Riwayat',
                    onActionTap: () => _navigateToPlaceholder('Semua Riwayat'),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.recentTransactions.length > 2 ? 2 : data.recentTransactions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final tx = data.recentTransactions[index];
                      return AppTransactionItem(
                        transaction: tx,
                        onTap: () => _navigateToPlaceholder('Detail Transaksi'),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Weekly Pulse (Organism)
                  AppWeeklyPulseChart(
                    growth: 12.0,
                    values: const [0.5, 0.8, 0.4, 1.0, 0.7, 0.5, 0.8],
                  ),
                  
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
