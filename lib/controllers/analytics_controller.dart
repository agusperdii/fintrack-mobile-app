import 'package:flutter/material.dart';
import 'package:savaio/models/weekly_pulse_model.dart';
import 'package:savaio/models/monthly_summary_model.dart';
import 'package:savaio/repositories/analytics_repository.dart';

class AnalyticsController extends ChangeNotifier {
  final AnalyticsRepository _repository;

  AnalyticsController(this._repository);

  WeeklyPulseModel? _weeklyPulse;
  List<MonthlySummaryModel>? _monthlySummary;
  bool _isLoading = false;
  String? _error;

  WeeklyPulseModel? get weeklyPulse => _weeklyPulse;
  List<MonthlySummaryModel>? get monthlySummary => _monthlySummary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getWeeklyPulse(),
        _repository.getMonthlySummary(),
      ]);
      _weeklyPulse = results[0] as WeeklyPulseModel;
      _monthlySummary = results[1] as List<MonthlySummaryModel>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWeeklyPulse() async {
    try {
      _weeklyPulse = await _repository.getWeeklyPulse();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching weekly pulse: $e');
    }
  }

  Future<void> fetchMonthlySummary() async {
    _isLoading = true;
    notifyListeners();
    try {
      _monthlySummary = await _repository.getMonthlySummary();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
