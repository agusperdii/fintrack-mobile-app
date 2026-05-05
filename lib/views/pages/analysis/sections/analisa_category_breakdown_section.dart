import 'package:flutter/material.dart';
import 'package:savaio/others.dart';
import 'package:savaio/models/analysis_view_data.dart';
import 'package:savaio/views/components/molecules/app_section_header.dart';
import 'package:savaio/views/components/organisms/app_category_card.dart';
import 'package:savaio/views/components/organisms/app_category_pie_chart.dart';

class AnalisaCategoryBreakdownSection extends StatelessWidget {
  final List<AnalysisCategoryData> categoryBreakdown;

  const AnalisaCategoryBreakdownSection({
    super.key,
    required this.categoryBreakdown,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryBreakdown.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCategoryPieChart(
          data: categoryBreakdown.map((e) => PieChartItem(
            label: e.label,
            value: e.amount,
            color: Color(int.parse('FF${e.colorHex}', radix: 16)),
          )).toList(),
        ),
        const SizedBox(height: 32),
        const AppSectionHeader(title: 'Breakdown Kategori'),
        const SizedBox(height: 20),
        ...List.generate(categoryBreakdown.length, (i) {
          final item = categoryBreakdown[i];
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AppCategoryCard(
              icon: sl.financeController.getCategoryIcon(item.label),
              title: item.label,
              amount: SavaioTheme.formatCurrency(item.amount),
              progress: item.progress,
              limit: item.budgetLimit > 0 ? 'Batas: ${SavaioTheme.formatCurrency(item.budgetLimit)}' : 'Tanpa Batas',
              status: item.status,
              accentColor: Color(int.parse('FF${item.colorHex}', radix: 16)),
              onTap: () {},
            ),
          );
        }),
      ],
    );
  }
}
