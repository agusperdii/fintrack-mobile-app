import 'package:flutter/material.dart';
import 'package:savaio/others.dart';
import 'package:savaio/views/components/molecules/app_section_header.dart';
import 'package:savaio/views/components/organisms/app_weekly_pulse_chart.dart';

class DashboardWeeklyPulseSection extends StatelessWidget {
  final Map<String, dynamic>? weeklyPulse;

  const DashboardWeeklyPulseSection({
    super.key,
    this.weeklyPulse,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Wawasan Mingguan'),
        const SizedBox(height: 16),
        if (weeklyPulse != null)
          AppWeeklyPulseChart(
            growth: ParserUtils.toDouble(weeklyPulse!['growth']),
            values: ParserUtils.toList(
              weeklyPulse!['values'],
              (v) => ParserUtils.toDouble(v),
            ),
          )
        else
          const AppWeeklyPulseChart(
            growth: 0,
            values: [0, 0, 0, 0, 0, 0, 0],
          ),
      ],
    );
  }
}
