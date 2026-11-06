import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:alumni_connect/core/network/api_client.dart';
import 'package:alumni_connect/core/network/api_config.dart';
import 'package:alumni_connect/core/network/token_storage.dart';

class AlumniApi {
  AlumniApi({TokenStorage? tokens}) : tokens = tokens ?? TokenStorage() {
    user = ApiClient(
      baseUrl: ApiConfig.userBaseUrl,
      tokens: this.tokens,
      refreshSession: _refreshSession,
    );
    chat = ApiClient(
      baseUrl: ApiConfig.chatBaseUrl,
      tokens: this.tokens,
      refreshSession: _refreshSession,
    );
    ai = ApiClient(
      baseUrl: ApiConfig.aiBaseUrl,
      tokens: this.tokens,
      refreshSession: _refreshSession,
    );
    forum = ApiClient(
      baseUrl: ApiConfig.forumBaseUrl,
      tokens: this.tokens,
      refreshSession: _refreshSession,
    );
    admin = ApiClient(
      baseUrl: ApiConfig.adminBaseUrl,
      tokens: this.tokens,
      refreshSession: _refreshSession,
    );
  }

  final TokenStorage tokens;
  late final ApiClient user;
  late final ApiClient chat;
  late final ApiClient ai;
  late final ApiClient forum;
  late final ApiClient admin;

  Future<bool>? _refreshing;

  Future<bool> _refreshSession() {
    final activeRefresh = _refreshing;
    if (activeRefresh != null) return activeRefresh;
    final refresh = _refreshTokens();
    _refreshing = refresh;
    return refresh.whenComplete(() => _refreshing = null);
  }

  Future<bool> _refreshTokens() async {
    final refreshToken = await tokens.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.userBaseUrl}/api/v1/auth/refresh-token'),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) return false;
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final access = data['accessToken'] as String?;
      final renewedRefresh = data['refreshToken'] as String?;
      if (access == null || renewedRefresh == null) return false;
      await tokens.save(access: access, refresh: renewedRefresh);
      return true;
    } catch (_) {
      return false;
    }
  }
}
