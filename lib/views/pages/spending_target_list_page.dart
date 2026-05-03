import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_progress_bar.dart';
import 'package:savaio/views/components/atoms/app_icon_container.dart';
import 'package:savaio/views/components/molecules/app_date_time_picker.dart';
import 'package:savaio/views/pages/spending_target_page.dart';

class SpendingTargetListPage extends StatefulWidget {
  const SpendingTargetListPage({super.key});

  @override
  State<SpendingTargetListPage> createState() => _SpendingTargetListPageState();
}

class _SpendingTargetListPageState extends State<SpendingTargetListPage> {
  late String _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    sl.financeController.fetchTransactions(month: _selectedMonth);
  }

  String _formatMonth(String month) {
    final parts = month.split('-');
    if (parts.length != 2) return month;
    const months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    final m = int.tryParse(parts[1]) ?? 0;
    return '${months[m]} ${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sl.financeController,
      builder: (context, _) {
        final provider = sl.financeController;
        final categories = [
          {'name': 'All', 'icon': Icons.all_inclusive, 'isEmoji': false},
          ...provider.categories
        ];

        return Scaffold(
          backgroundColor: SavaioTheme.background,
          appBar: AppBar(
            backgroundColor: SavaioTheme.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: SavaioTheme.primary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: AppHeading(_formatMonth(_selectedMonth), size: AppHeadingSize.h3),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month_rounded, color: SavaioTheme.primary),
                onPressed: () => _showMonthPicker(),
              ),
            ],
          ),
          body: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final name = cat['name'] as String;
              final displayName = name == 'All' ? 'Total Pengeluaran' : name;
              
              final currentSpent = provider.getSpentAmountFor(name, _selectedMonth);
              final budget = provider.allBudgets.firstWhere(
                (b) => b['category'] == name && b['period'] == _selectedMonth,
                orElse: () => provider.allBudgets.firstWhere(
                  (b) => b['category'] == name,
                  orElse: () => {'amount': 0.0},
                ),
              );
              final targetAmount = (budget['amount'] as num).toDouble();
              final progress = targetAmount > 0 ? (currentSpent / targetAmount).clamp(0.0, 1.0) : 0.0;
              final isOver = currentSpent > targetAmount && targetAmount > 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpendingTargetPage(initialCategory: name),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: GlassCard(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 20,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            AppIconContainer(
                              icon: cat['icon'],
                              size: 40,
                              color: SavaioTheme.primary,
                              opacity: 0.1,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppHeading(displayName, size: AppHeadingSize.subtitle),
                                  const SizedBox(height: 4),
                                  Text(
                                    targetAmount > 0 
                                        ? 'Target: ${SavaioTheme.formatCurrency(targetAmount)}'
                                        : 'Target belum diatur',
                                    style: TextStyle(
                                      fontSize: 12, 
                                      color: targetAmount > 0 ? SavaioTheme.onSurfaceVariant : SavaioTheme.onSurfaceVariant.withValues(alpha: 0.5)
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: SavaioTheme.onSurfaceVariant),
                          ],
                        ),
                        if (targetAmount > 0) ...[
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${SavaioTheme.formatCurrency(currentSpent)} terpakai',
                                style: const TextStyle(fontSize: 11, color: SavaioTheme.onSurfaceVariant),
                              ),
                              Text(
                                isOver ? 'Over Budget!' : '${(progress * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 11, 
                                  fontWeight: FontWeight.bold,
                                  color: isOver ? SavaioTheme.error : SavaioTheme.tertiary
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          AppProgressBar(
                            value: progress,
                            color: isOver ? SavaioTheme.error : (progress > 0.8 ? Colors.orange : SavaioTheme.tertiary),
                            height: 6,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showMonthPicker() async {
    final picked = await AppDateTimePicker.showMonthPicker(
      context: context,
      initialMonth: _selectedMonth,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
        sl.financeController.fetchTransactions(month: _selectedMonth);
      });
    }
  }
}
