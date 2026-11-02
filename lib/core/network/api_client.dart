import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:alumni_connect/core/network/token_storage.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.tokens,
    this.refreshSession,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final TokenStorage tokens;
  final Future<bool> Function()? refreshSession;
  final http.Client _client;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final response = await _send('GET', path, query: query);
    return _decode(response);
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, String>? query,
  }) async {
    final response = await _send('GET', path, query: query);
    return _decodeList(response);
  }

  Future<List<dynamic>> postList(String path, {Object? body}) async {
    final response = await _send('POST', path, body: body);
    return _decodeList(response);
  }

  List<dynamic> _decodeList(http.Response response) {
    final text = utf8.decode(response.bodyBytes);
    dynamic decoded;
    try {
      decoded = text.isEmpty ? const [] : jsonDecode(text);
    } on FormatException {
      throw const ApiException('Unexpected API response format.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final map = decoded is Map<String, dynamic> ? decoded : const {};
      throw ApiException(
        '${map['detail'] ?? map['message'] ?? map['title'] ?? 'Request failed (${response.statusCode})'}',
        statusCode: response.statusCode,
      );
    }
    if (decoded is List<dynamic>) return decoded;
    throw const ApiException('Expected a list from API.');
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
    Map<String, String>? query,
  }) async {
    final response = await _send('POST', path, query: query, body: body);
    return _decode(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Object? body,
    Map<String, String>? query,
  }) async {
    final response = await _send('PUT', path, query: query, body: body);
    return _decode(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Object? body,
    Map<String, String>? query,
  }) async {
    final response = await _send('PATCH', path, query: query, body: body);
    return _decode(response);
  }

  Future<void> delete(String path) async {
    final response = await _send('DELETE', path);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _decode(response);
    }
  }

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    bool allowRefresh = true,
  }) async {
    final uri = _uri(path, query);
    final requestToken = await tokens.accessToken;
    final headers = await _headers();
    final encodedBody = body == null ? null : jsonEncode(body);
    final response = await _dispatch(method, uri, headers, encodedBody);
    if (response.statusCode == 401 && allowRefresh) {
      final currentToken = await tokens.accessToken;
      if (currentToken != null && currentToken != requestToken) {
        return _send(
          method,
          path,
          query: query,
          body: body,
          allowRefresh: false,
        );
      }
      if (refreshSession != null && await refreshSession!()) {
        return _send(
          method,
          path,
          query: query,
          body: body,
          allowRefresh: false,
        );
      }
    }
    return response;
  }

  Future<http.Response> _dispatch(
    String method,
    Uri uri,
    Map<String, String> headers,
    String? body,
  ) => switch (method) {
    'GET' => _client.get(uri, headers: headers),
    'POST' => _client.post(uri, headers: headers, body: body ?? '{}'),
    'PUT' => _client.put(uri, headers: headers, body: body ?? '{}'),
    'PATCH' => _client.patch(uri, headers: headers, body: body ?? '{}'),
    'DELETE' => _client.delete(uri, headers: headers),
    _ => throw ArgumentError.value(method, 'method', 'Unsupported HTTP method'),
  };

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final token = await tokens.accessToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _decode(http.Response response) {
    final text = utf8.decode(response.bodyBytes);
    dynamic decoded;
    if (text.isNotEmpty) {
      try {
        decoded = jsonDecode(text);
      } on FormatException {
        decoded = null;
      }
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final map = decoded is Map<String, dynamic> ? decoded : const {};
      final message =
          map['detail'] ??
          map['message'] ??
          map['title'] ??
          'Request failed (${response.statusCode})';
      throw ApiException(message.toString(), statusCode: response.statusCode);
    }
    if (decoded == null) return <String, dynamic>{};
    if (decoded is Map<String, dynamic>) return decoded;
    throw const ApiException('Unexpected API response format.');
  }
}
