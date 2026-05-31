with open("lib/repositories/data_sources/remote/dashboard_remote_data_source.dart", "r") as f: code = f.read()
code = code.replace("jsonDecode(response.body)", "data")
code = code.replace("final data = await _client.get('${ApiConfig.baseUrl}/checkins/streak') as List? ?? [];\n    return CheckInStatus.fromStreakJson(data);", "final data = await _client.get('${ApiConfig.baseUrl}/checkins/streak') as List? ?? [];\n    return CheckInStatus(isCheckedInToday: false, streakCount: data.length);")
with open("lib/repositories/data_sources/remote/dashboard_remote_data_source.dart", "w") as f: f.write(code)

with open("lib/repositories/data_sources/ocr_data_source.dart", "r") as f: code = f.read()
code = code.replace("_getStoredToken()", "_client.getStoredToken()")
with open("lib/repositories/data_sources/ocr_data_source.dart", "w") as f: f.write(code)

