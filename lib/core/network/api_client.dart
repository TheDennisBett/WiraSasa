import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wirasasa/core/config/app_env.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    Duration timeout = const Duration(seconds: 20),
  }) : _http = httpClient ?? http.Client(),
       _timeout = timeout;

  final http.Client _http;
  final Duration _timeout;

  Uri _uri(String path, [Map<String, String>? query]) {
    final baseUrl = AppEnv.apiBaseUrl.trim();
    final baseUri = Uri.tryParse(baseUrl);
    if (baseUri == null || !baseUri.hasScheme || baseUri.host.isEmpty) {
      throw ApiException('API base URL is not valid.', statusCode: 0);
    }
    return baseUri.resolve(path).replace(queryParameters: query);
  }

  Future<dynamic> getJson(
    String path, {
    String? bearerToken,
    Map<String, String>? query,
  }) async {
    final response = await _send(
      () => _http.get(
        _uri(path, query),
        headers: _headers(bearerToken: bearerToken),
      ),
    );
    return _decode(response);
  }

  Future<dynamic> postJson(
    String path, {
    Object? body,
    String? bearerToken,
  }) async {
    final response = await _send(
      () => _http.post(
        _uri(path),
        headers: _headers(
          bearerToken: bearerToken,
          includeJsonContentType: true,
        ),
        body: jsonEncode(body),
      ),
    );
    return _decode(response);
  }

  Future<dynamic> patchJson(
    String path, {
    Object? body,
    String? bearerToken,
  }) async {
    final response = await _send(
      () => _http.patch(
        _uri(path),
        headers: _headers(
          bearerToken: bearerToken,
          includeJsonContentType: true,
        ),
        body: jsonEncode(body),
      ),
    );
    return _decode(response);
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_timeout);
    } on ApiException {
      rethrow;
    } on FormatException {
      rethrow;
    } catch (error) {
      if (error is TimeoutException || error is http.ClientException) {
        throw ApiException(
          'Unable to reach the Wirasasa API. Check your connection and API base URL.',
          statusCode: 0,
        );
      }
      rethrow;
    }
  }

  Map<String, String> _headers({
    String? bearerToken,
    bool includeJsonContentType = false,
  }) {
    return {
      'Accept': 'application/json',
      if (includeJsonContentType) 'Content-Type': 'application/json',
      if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
    };
  }

  dynamic _decode(http.Response response) {
    final body = response.body.trim();
    final payload = body.isEmpty ? null : _decodeBody(body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return payload;
    }
    if (payload is Map<String, dynamic>) {
      throw ApiException(
        payload['message'] as String? ??
            payload['title'] as String? ??
            'Request failed with status ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    }
    throw ApiException(
      'Request failed with status ${response.statusCode}.',
      statusCode: response.statusCode,
    );
  }

  dynamic _decodeBody(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      throw ApiException(
        'API returned an invalid JSON response.',
        statusCode: 0,
      );
    }
  }
}

class ApiException implements Exception {
  ApiException(this.message, {required this.statusCode});

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}
