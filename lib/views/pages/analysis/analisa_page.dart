import 'package:flutter/material.dart';
import 'package:savaio/others.dart';
import 'package:savaio/models/analysis_view_data.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/components/organisms/app_smart_insight_card.dart';
import 'package:savaio/views/components/organisms/app_trend_line_chart.dart';
import 'package:savaio/views/pages/budget/spending_target_page.dart';
import 'package:savaio/views/pages/analysis/sections/analisa_hero_section.dart';
import 'package:savaio/views/pages/analysis/sections/analisa_category_breakdown_section.dart';
import 'package:savaio/views/pages/analysis/sections/analisa_month_filter_section.dart';
import 'package:savaio/views/pages/analysis/sections/analisa_status_views.dart';

class AnalisaPage extends StatefulWidget {
  const AnalisaPage({super.key});

  @override
  State<AnalisaPage> createState() => _AnalisaPageState();
}

class _AnalisaPageState extends State<AnalisaPage> {
  String _selectedMonth = _nowMonthStr();
  bool _isWeeklyTrend = true;
  Future<AnalysisViewData>? _analysisFuture;

  static String _nowMonthStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _refreshFuture();
  }

  void _refreshFuture() {
    _analysisFuture = sl.financeController.getAnalysisViewData(_selectedMonth);
  }

  void _onMonthChanged(String month) {
    if (month == _selectedMonth) return;
    setState(() {
      _selectedMonth = month;
      _refreshFuture();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppHeader(
        title: 'Analisa Pengeluaran',
        showNotification: false,
        unreadCount: sl.financeController.unreadNotificationsCount,
      ),
      body: FutureBuilder<AnalysisViewData>(
        future: _analysisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AnalisaLoadingView();
          }

          if (snapshot.hasError) {
            return AnalisaErrorView(
              error: snapshot.error.toString(),
              onRetry: () => setState(() => _refreshFuture()),
            );
          }

          final data = snapshot.data;
          if (data == null || data.categoryBreakdown.isEmpty) {
            return const AnalisaEmptyView();
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _refreshFuture());
            },
            color: theme.colorScheme.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnalisaMonthFilterSection(
                    selectedMonth: _selectedMonth,
                    onMonthChanged: _onMonthChanged,
                  ),
                  const SizedBox(height: 20),
                  
                  AnalisaHeroSection(data: data),
                  const SizedBox(height: 20),
                  
                  _buildSmartInsight(data.categoryBreakdown),
                  const SizedBox(height: 32),
                  
                  AnalisaCategoryBreakdownSection(
                    categoryBreakdown: data.categoryBreakdown,
                  ),
                  const SizedBox(height: 32),
                  
                  AppTrendLineChart(
                    title: 'Tren Ledger',
                    isWeekly: _isWeeklyTrend,
                    spots: data.getTrendSpots(_isWeeklyTrend),
                    days: data.getTrendDays(_isWeeklyTrend),
                    onPeriodChanged: (val) => setState(() => _isWeeklyTrend = val),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSmartInsight(List<AnalysisCategoryData> breakdown) {
    final description = breakdown.isNotEmpty
        ? 'Pengeluaran terbesar di ${breakdown.first.label}. Pastikan tetap hemat!'
        : 'Belum ada data pengeluaran.';
    return AppSmartInsightCard(
      title: 'Wawasan Pintar',
      description: description,
      buttonLabel: 'DETAIL PENGHEMATAN',
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpendingTargetPage())),
    );
  }
}
