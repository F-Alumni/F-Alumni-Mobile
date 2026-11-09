import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static String get _defaultHost =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? 'http://10.0.2.2'
      : 'http://localhost';

  static const _useGateway = bool.fromEnvironment('USE_API_GATEWAY');
  static const _gatewayOverride = String.fromEnvironment('GATEWAY_BASE_URL');
  static const _userOverride = String.fromEnvironment('USER_API_BASE_URL');
  static const _chatOverride = String.fromEnvironment('CHAT_API_BASE_URL');
  static const _aiOverride = String.fromEnvironment('AI_API_BASE_URL');
  static const _forumOverride = String.fromEnvironment('FORUM_API_BASE_URL');
  static const _adminOverride = String.fromEnvironment('ADMIN_API_BASE_URL');

  static String get gatewayBaseUrl =>
      _gatewayOverride.isNotEmpty ? _gatewayOverride : '$_defaultHost:5000';

  static String get userBaseUrl => _userOverride.isNotEmpty
      ? _userOverride
      : (_useGateway || _gatewayOverride.isNotEmpty
            ? gatewayBaseUrl
            : '$_defaultHost:5001');
  static String get chatBaseUrl => _chatOverride.isNotEmpty
      ? _chatOverride
      : (_useGateway || _gatewayOverride.isNotEmpty
            ? gatewayBaseUrl
            : '$_defaultHost:5002');
  static String get aiBaseUrl => _aiOverride.isNotEmpty
      ? _aiOverride
      : (_useGateway || _gatewayOverride.isNotEmpty
            ? gatewayBaseUrl
            : '$_defaultHost:5004');
  static String get forumBaseUrl => _forumOverride.isNotEmpty
      ? _forumOverride
      : (_useGateway || _gatewayOverride.isNotEmpty
            ? gatewayBaseUrl
            : '$_defaultHost:5003');
  static String get adminBaseUrl => _adminOverride.isNotEmpty
      ? _adminOverride
      : (_useGateway || _gatewayOverride.isNotEmpty
            ? gatewayBaseUrl
            : '$_defaultHost:5005');
}
