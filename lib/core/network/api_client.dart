import 'dart:async' as async;
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:savaio/controllers/auth_controller.dart';
import 'exceptions.dart';

class ApiClient {
  final AuthController _authController;
  final http.Client _client;

  // Keep UX responsive: avoid 45s+ hangs on flaky networks.
  static const Duration _defaultTimeout = Duration(seconds: 10);
  static const int _maxRetries = 1;

  ApiClient({
    required AuthController authController,
    http.Client? client,
  })  : _authController = authController,
        _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authController.token != null)
          'Authorization': 'Bearer ${_authController.token}',
      };

  Future<dynamic> get(String url, {Map<String, String>? queryParameters}) async {
    final uri = Uri.parse(url).replace(queryParameters: queryParameters);
    return _requestWithRetry(() => _client.get(uri, headers: _headers));
  }

  Future<dynamic> post(String url, {dynamic body}) async {
    return _requestWithRetry(() => _client.post(
          Uri.parse(url),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> put(String url, {dynamic body}) async {
    return _requestWithRetry(() => _client.put(
          Uri.parse(url),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> patch(String url, {dynamic body}) async {
    return _requestWithRetry(() => _client.patch(
          Uri.parse(url),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> delete(String url) async {
    return _requestWithRetry(() => _client.delete(Uri.parse(url), headers: _headers));
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
        // Try refreshing Supabase session once, then retry the request with new token.
        if (!didRefreshOnce && _authController.isAuthenticated) {
          didRefreshOnce = true;
          final refreshed = await _authController.refreshSession();
          if (refreshed) {
            continue;
          }
        }
        // If refresh fails, proceed with logout to avoid a broken state loop.
        await _authController.logout();
        rethrow;
      } on Exception catch (e) {
        if (attempts == _maxRetries) rethrow;
        log('Request failed, retrying ($attempts): $e');
      }
      attempts++;
      await Future.delayed(Duration(milliseconds: 500 * attempts));
    }

    // Should be unreachable, but keep the type system happy.
    throw ServerException('Request failed after retries');
  }

  dynamic _processResponse(http.Response response) {
    log('API Response [${response.statusCode}]: ${response.request?.url}');
    
    final responseJson = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    switch (response.statusCode) {
      case 200:
      case 201:
        return responseJson;
      case 400:
        throw BadRequestException(responseJson?['detail'] ?? 'Bad Request', response.statusCode);
      case 401:
        throw UnauthorizedException(responseJson?['detail'] ?? 'Unauthorized');
      case 403:
        throw UnauthorizedException(responseJson?['detail'] ?? 'Forbidden');
      case 404:
        throw NotFoundException(responseJson?['detail'] ?? 'Not Found', response.statusCode);
      case 500:
      default:
        throw ServerException(
          'Error occurred while communicating with server with status code: ${response.statusCode}',
          response.statusCode,
        );
    }
  }
}
