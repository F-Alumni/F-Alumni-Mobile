import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static String get _defaultHost =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? 'http://10.0.2.2'
      : 'http://localhost';

  static const _userOverride = String.fromEnvironment('USER_API_BASE_URL');
  static const _chatOverride = String.fromEnvironment('CHAT_API_BASE_URL');
  static const _aiOverride = String.fromEnvironment('AI_API_BASE_URL');
  static const _forumOverride = String.fromEnvironment('FORUM_API_BASE_URL');
  static const _adminOverride = String.fromEnvironment('ADMIN_API_BASE_URL');

  static String get userBaseUrl =>
      _userOverride.isNotEmpty ? _userOverride : '$_defaultHost:5001';
  static String get chatBaseUrl =>
      _chatOverride.isNotEmpty ? _chatOverride : '$_defaultHost:5002';
  static String get aiBaseUrl =>
      _aiOverride.isNotEmpty ? _aiOverride : '$_defaultHost:5004';
  static String get forumBaseUrl =>
      _forumOverride.isNotEmpty ? _forumOverride : '$_defaultHost:5003';
  static String get adminBaseUrl =>
      _adminOverride.isNotEmpty ? _adminOverride : '$_defaultHost:5005';
}
