import 'dart:async' as async;
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:savaio/controllers/auth_controller.dart';
import 'exceptions.dart';

class ApiClient {
  final AuthController _authController;
  final http.Client _client;
  static const Duration _defaultTimeout = Duration(seconds: 10);
  static const int _maxRetries = 1;

  ApiClient({
    required AuthController authController,
    http.Client? client,
  })  : _authController = authController,
        _client = client ?? http.Client();

  Map<String, String> get _baseHeaders => {
        'Accept': 'application/json',
        if (_authController.token != null)
          'Authorization': 'Bearer ${_authController.token}',
      };

  Future<String?> getStoredToken() async {
    return _authController.token;
  }

  Future<dynamic> get(String url, {Map<String, String>? queryParameters}) async {
    final uri = Uri.parse(url).replace(queryParameters: queryParameters);
    return _requestWithRetry(() => _client.get(uri, headers: _baseHeaders));
  }

  Future<dynamic> post(String url, {dynamic body}) async {
    return _requestWithRetry(() => _client.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json', ..._baseHeaders},
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> put(String url, {dynamic body}) async {
    return _requestWithRetry(() => _client.put(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json', ..._baseHeaders},
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> patch(String url, {dynamic body}) async {
    return _requestWithRetry(() => _client.patch(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json', ..._baseHeaders},
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> delete(String url) async {
    return _requestWithRetry(() => _client.delete(Uri.parse(url), headers: _baseHeaders));
  }

  /// Upload a file using multipart/form-data.
  /// Returns the unwrapped data after the server responds.
  Future<dynamic> uploadFile(
    String url,
    File file, {
    String fieldName = 'file',
    Map<String, String>? fields,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final uri = Uri.parse(url);
    final extension = file.path.split('.').last.toLowerCase();
    String mimeType = 'image/jpeg';
    if (extension == 'png') mimeType = 'image/png';
    if (extension == 'webp') mimeType = 'image/webp';

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_baseHeaders);
    request.files.add(await http.MultipartFile.fromPath(
      fieldName,
      file.path,
      contentType: MediaType.parse(mimeType),
    ));
    if (fields != null) request.fields.addAll(fields);

    final streamedResponse = await request.send().timeout(timeout);
    final response = await http.Response.fromStream(streamedResponse);
    return _processResponse(response);
  }

  Future<dynamic> _requestWithRetry(Future<http.Response> Function() requestFn) async {
    int attempts = 0;
    bool didRefreshOnce = false;
    while (attempts <= _maxRetries) {
      try {
        final response = await requestFn().timeout(_defaultTimeout);
        return _processResponse(response);
      } on SocketException {
        if (attempts == _maxRetries) throw NetworkException();
      } on async.TimeoutException {
        if (attempts == _maxRetries) throw RequestTimeoutException();
      } on UnauthorizedException {
        if (!didRefreshOnce && _authController.isAuthenticated) {
          didRefreshOnce = true;
          final refreshed = await _authController.refreshAccessToken();
          if (refreshed) {
            continue;
          }
        }
        await _authController.forceLogout();
        rethrow;
      } on Exception catch (e) {
        if (attempts == _maxRetries) rethrow;
        log('Request failed, retrying ($attempts): $e');
      }
      attempts++;
      await Future.delayed(Duration(milliseconds: 500 * attempts));
    }
    throw ServerException('Request failed after retries');
  }

  /// Unwraps FastAPI standard response: {success: true, data: ...} or {success: false, message: ...}
  dynamic _processResponse(http.Response response) {
    log('API Response [${response.statusCode}]: ${response.request?.url}');

    if (response.statusCode == 204) return null;

    dynamic raw;
    bool isJson = false;
    try {
      if (response.body.isNotEmpty) {
        raw = jsonDecode(response.body);
        isJson = true;
      }
    } catch (e) {
      log('Failed to decode response body as JSON: ${response.body}');
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return _unwrap(raw);
      case 400:
        throw BadRequestException(isJson ? _errorMessage(raw) : 'Request error', response.statusCode);
      case 401:
      case 403:
        throw UnauthorizedException(isJson ? _errorMessage(raw) : 'Unauthorized');
      case 404:
        throw NotFoundException(isJson ? _errorMessage(raw) : 'Resource not found', response.statusCode);
      case 409:
        throw ApiErrorException(isJson ? _errorMessage(raw) : 'Conflict occurred');
      case 422:
        log('Validation error details: $raw');
        throw BadRequestException(isJson ? _errorMessage(raw) : 'Validation failed', response.statusCode);
      case 500:
        throw ServerException(
          'Internal Server Error (500). Please try again later.',
          response.statusCode,
        );
      default:
        throw ServerException(
          'Error occurred with status code: ${response.statusCode}',
          response.statusCode,
        );
    }
  }

  /// Unwrap {success: true, data: ...} → return data directly.
  /// Throw ApiErrorException for {success: false, message: ...}.
  dynamic _unwrap(dynamic raw) {
    if (raw == null) return null;
    if (raw is! Map) return raw;
    final map = raw as Map<String, dynamic>;

    if (map.containsKey('success')) {
      if (map['success'] == false) {
        throw ApiErrorException(map['message']?.toString() ?? 'Request failed');
      }
      return map['data'];
    }
    // Legacy: no success wrapper — return raw
    return raw;
  }

  String _errorMessage(dynamic raw) {
    if (raw == null) return 'Unknown error';
    if (raw is Map) {
      if (raw.containsKey('message')) return raw['message'].toString();
      if (raw.containsKey('detail')) {
        final detail = raw['detail'];
        if (detail is List) {
          try {
            return detail.map((e) {
              if (e is Map && e.containsKey('msg')) return e['msg'];
              return e.toString();
            }).join(', ');
          } catch (_) {
            return detail.toString();
          }
        }
        return detail.toString();
      }
    }
    return 'Unknown error';
  }
}