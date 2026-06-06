import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/view_models/analysis_view_model.dart';

class AppCategoryPieChart extends StatefulWidget {
  final List<PieSegment> segments;

  const AppCategoryPieChart({
    super.key,
    required this.segments,
  });

  @override
  State<AppCategoryPieChart> createState() => _AppCategoryPieChartState();
}

class _AppCategoryPieChartState extends State<AppCategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.segments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainerOf(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          AppHeading(
            'DISTRIBUSI PENGELUARAN',
            size: AppHeadingSize.caption,
            color: SavaioTheme.onSurfaceVariantOf(context),
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
                sections: _buildSections(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildLegend(),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return widget.segments.asMap().entries.map((entry) {
      final idx = entry.key;
      final segment = entry.value;
      final isTouched = idx == touchedIndex;

      final color = _parseColor(segment.colorHex);

      return PieChartSectionData(
        color: color,
        value: segment.value,
        radius: isTouched ? 60.0 : 50.0,
        titleStyle: TextStyle(
          fontSize: isTouched ? 16.0 : 12.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        title: isTouched ? '${_calculatePercentage(segment.value)}%' : '',
        showTitle: isTouched,
      );
    }).toList();
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Theme.of(context).colorScheme.primary;
    }
  }

  String _calculatePercentage(double value) {
    final total = widget.segments.fold<double>(0, (sum, item) => sum + item.value);
    if (total == 0) return '0';
    return (value / total * 100).toStringAsFixed(1);
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: widget.segments.map((segment) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _parseColor(segment.colorHex),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              segment.label,
              style: TextStyle(
                fontSize: 12,
                color: SavaioTheme.onSurfaceVariantOf(context),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}