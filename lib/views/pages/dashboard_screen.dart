import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/service_locator.dart';
import '../components/organisms/app_balance_card.dart';
import '../components/organisms/app_header.dart';
import '../components/organisms/app_weekly_pulse_chart.dart';
import '../components/molecules/app_icon_button.dart';
import '../components/molecules/app_section_header.dart';
import '../components/molecules/app_transaction_item.dart';
import '../components/molecules/app_greeting_header.dart';
import 'notifications_page.dart';
import 'all_transactions_page.dart';
import 'transaction_detail_page.dart';
import 'ocr_scan_page.dart';
import 'add_transaction_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    if (sl.financeController.dashboardData == null) {
      sl.financeController.loadInitialData();
    }
  }

  void _navigateToAddTransaction({required String type, String? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionPage(
          initialType: type,
          initialCategory: category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sl.financeController,
      builder: (context, _) {
        final provider = sl.financeController;
        
        if (provider.isLoading && provider.dashboardData == null) {
          return const Scaffold(
            backgroundColor: KineticVaultTheme.background,
            body: Center(child: CircularProgressIndicator(color: KineticVaultTheme.primary)),
          );
        }

        final data = provider.dashboardData;
        final profile = provider.userProfile;
        
        return Scaffold(
          backgroundColor: KineticVaultTheme.background,
          appBar: AppHeader(
            avatarUrl: profile?['avatar'],
            onNotificationTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
          body: RefreshIndicator(
            onRefresh: () => provider.loadInitialData(),
            color: KineticVaultTheme.primary,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section (Molecule)
                  AppGreetingHeader(
                    userName: profile?['name']?.split(' ').first ?? 'User',
                  ),
                  const SizedBox(height: 24),

                  // Hero Balance Card (Organism)
                  if (data != null)
                    AppBalanceCard(
                      balance: data.balance,
                      income: data.totalIncome,
                      expense: data.totalExpense,
                      onIncomeTap: () => _navigateToAddTransaction(type: 'Income'),
                      onExpenseTap: () => _navigateToAddTransaction(type: 'Expense'),
                    )
                  else
                    const AppBalanceCard(
                      balance: 0,
                      income: 0,
                      expense: 0,
                      isLoading: true,
                    ),
                  const SizedBox(height: 32),

                  // Quick Actions (Molecules)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AppIconButton(
                        icon: Icons.add_rounded,
                        label: 'Pemasukan',
                        color: KineticVaultTheme.tertiary,
                        onTap: () => _navigateToAddTransaction(type: 'Income'),
                      ),
                      AppIconButton(
                        icon: Icons.receipt_long,
                        label: 'Scan Struk',
                        variant: AppIconButtonVariant.gradient,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OcrScanPage()),
                        ),
                      ),
                      AppIconButton(
                        icon: Icons.remove_rounded,
                        label: 'Pengeluaran',
                        color: KineticVaultTheme.error,
                        onTap: () => _navigateToAddTransaction(type: 'Expense'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Recent History (Molecule + Molecule)
                  AppSectionHeader(
                    title: 'Riwayat Terbaru',
                    actionLabel: 'Lihat Semua',
                    onActionTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AllTransactionsPage(
                          initialTransactions: data?.recentTransactions ?? [],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (data != null && data.recentTransactions.isNotEmpty)
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.recentTransactions.length > 5 ? 5 : data.recentTransactions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tx = data.recentTransactions[index];
                        return AppTransactionItem(
                          transaction: tx,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => TransactionDetailPage(transaction: tx)),
                          ),
                        );
                      },
                    )
                  else if (data != null && data.recentTransactions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('Belum ada transaksi', style: TextStyle(color: KineticVaultTheme.onSurfaceVariant)),
                      ),
                    )
                  else
                    // Skeleton for transactions
                    Column(
                      children: List.generate(3, (index) => Container(
                        height: 70,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: KineticVaultTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      )),
                    ),

                  const SizedBox(height: 32),

                  // Weekly Pulse (Organism)
                  const AppSectionHeader(title: 'Wawasan Mingguan'),
                  const SizedBox(height: 16),
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
