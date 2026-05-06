import '../core/utils/parser_utils.dart';

class WeeklyPulseModel {
  final List<double> values;
  final double growth;

  WeeklyPulseModel({
    required this.values,
    required this.growth,
  });

  factory WeeklyPulseModel.fromJson(Map<String, dynamic> json) {
    return WeeklyPulseModel(
      values: (json['values'] as List? ?? [])
          .map((v) => ParserUtils.toDouble(v))
          .toList(),
      growth: ParserUtils.toDouble(json['growth']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'values': values,
      'growth': growth,
    };
  }
}
