import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/entities/app_data.dart';
import '../atoms/app_heading.dart';

class AppCategoryPieChart extends StatefulWidget {
  final List<AnalysisData> data;

  const AppCategoryPieChart({super.key, required this.data});

  @override
  State<AppCategoryPieChart> createState() => _AppCategoryPieChartState();
}

class _AppCategoryPieChartState extends State<AppCategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: KineticVaultTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const AppHeading(
            'DISTRIBUSI PENGELUARAN',
            size: AppHeadingSize.caption,
            color: KineticVaultTheme.onSurfaceVariant,
            isBold: true,
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 4,
                centerSpaceRadius: 50,
                sections: _showingSections(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildLegend(),
        ],
      ),
    );
  }

  List<PieChartSectionData> _showingSections() {
    final total = widget.data.fold<double>(0, (sum, item) => sum + item.amount);
    
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      final percentage = (item.amount / total * 100).toStringAsFixed(1);
      final color = Color(int.parse('FF${item.colorHex}', radix: 16));

      return PieChartSectionData(
        color: color,
        value: item.amount,
        title: isTouched ? '$percentage%' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: widget.data.map((item) {
        final color = Color(int.parse('FF${item.colorHex}', radix: 16));
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 12,
                color: KineticVaultTheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
