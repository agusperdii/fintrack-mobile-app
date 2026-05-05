import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class PieChartItem {
  final String label;
  final double value;
  final Color color;

  const PieChartItem({
    required this.label,
    required this.value,
    required this.color,
  });
}

class AppCategoryPieChart extends StatefulWidget {
  final List<PieChartItem> data;
  final String title;

  const AppCategoryPieChart({
    super.key, 
    required this.data,
    this.title = 'DISTRIBUSI PENGELUARAN',
  });

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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      container: true,
      label: 'Category Distribution Chart',
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            AppHeading(
              widget.title,
              size: AppHeadingSize.caption,
              color: colorScheme.onSurfaceVariant,
              isBold: true,
              textAlign: TextAlign.center,
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
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _showingSections() {
    final total = widget.data.fold<double>(0, (sum, item) => sum + item.value);
    
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      final percentage = (item.value / total * 100).toStringAsFixed(1);

      return PieChartSectionData(
        color: item.color,
        value: item.value,
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

  Widget _buildLegend(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: widget.data.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
