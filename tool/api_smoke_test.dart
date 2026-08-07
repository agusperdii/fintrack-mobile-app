import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class _Result {
  final String name;
  final Uri uri;
  final int status;
  final int ms;
  final String bodyPreview;

  _Result({
    required this.name,
    required this.uri,
    required this.status,
    required this.ms,
    required this.bodyPreview,
  });
}

Future<_Result> _get(
  http.Client client, {
  required String name,
  required Uri uri,
  required Map<String, String> headers,
}) async {
  final sw = Stopwatch()..start();
  final resp = await client.get(uri, headers: headers);
  sw.stop();

  final preview = resp.body.length > 400 ? '${resp.body.substring(0, 400)}…' : resp.body;
  return _Result(
    name: name,
    uri: uri,
    status: resp.statusCode,
    ms: sw.elapsedMilliseconds,
    bodyPreview: preview,
  );
}

void _printResult(_Result r) {
  stdout.writeln('== ${r.name}');
  stdout.writeln('GET ${r.uri}');
  stdout.writeln('status=${r.status} time=${r.ms}ms');
  if (r.bodyPreview.isNotEmpty) {
    stdout.writeln(r.bodyPreview);
  }
  stdout.writeln('');
}

Map<String, String> _parseArgs(List<String> args) {
  final out = <String, String>{};
  for (final a in args) {
    final idx = a.indexOf('=');
    if (idx <= 0) continue;
    out[a.substring(0, idx).trim()] = a.substring(idx + 1).trim();
  }
  return out;
}

void _validateDashboardShape(dynamic json) {
  if (json is! Map) return;

  final keys = json.keys.map((k) => k.toString()).toSet();
  final hasTargetPeriod = keys.contains('targetPeriod') || keys.contains('target_period');
  if (!hasTargetPeriod) {
    stdout.writeln(
      '[warn] dashboard response missing targetPeriod/target_period. Keys: ${keys.take(30).toList()}',
    );
  }
}

Future<void> main(List<String> args) async {
  final parsed = _parseArgs(args);

  final baseUrl = (parsed['--base-url'] ?? parsed['baseUrl'] ?? '').trim();
  if (baseUrl.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/api_smoke_test.dart --base-url=https://.../api/v1 --token=YOUR_JWT',
    );
    exitCode = 2;
    return;
  }

  final token = (parsed['--token'] ?? parsed['token'] ?? '').trim();

  final headers = <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  final client = http.Client();
  try {
    final endpoints = <String, Uri>{
      'dashboard': Uri.parse('$baseUrl/dashboard/'),
      'checkin_status': Uri.parse('$baseUrl/check-in/status'),
      'analytics_weekly_pulse': Uri.parse('$baseUrl/analytics/weekly-pulse'),
      'dashboard_monthly_summary': Uri.parse('$baseUrl/dashboard/monthly-summary'),
      'transactions_default': Uri.parse('$baseUrl/transactions/?limit=20'),
      'analytics_summary': Uri.parse('$baseUrl/analytics/summary'),
    };

    for (final entry in endpoints.entries) {
      final r = await _get(client, name: entry.key, uri: entry.value, headers: headers);
      _printResult(r);

      if (entry.key == 'dashboard' && r.status >= 200 && r.status < 300) {
        try {
          final decoded = jsonDecode(r.bodyPreview.endsWith('…')
              ? r.bodyPreview.substring(0, r.bodyPreview.length - 1)
              : r.bodyPreview);
          _validateDashboardShape(decoded);
        } catch (_) {
          // ignore preview parse errors
        }
      }
    }
  } finally {
    client.close();
  }
}

