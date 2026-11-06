import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alumni_connect/features/notifications/data/models/notification_model.dart';
import 'package:alumni_connect/firebase_options.dart';

class FcmMessagingService {
  FcmMessagingService._();

  static final FcmMessagingService instance = FcmMessagingService._();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static const _notificationsKeyPrefix = 'lab3_notifications_v1';
  static const _activeUserScopeKey = 'lab3_notifications_active_user';
  static const _anonymousScope = 'anonymous';
  static const _maxStoredNotifications = 200;

  final List<NotificationItem> _notifications = [];
  final StreamController<NotificationItem> _incoming =
      StreamController<NotificationItem>.broadcast();
  final StreamController<String> _installationIds =
      StreamController<String>.broadcast();
  final StreamController<String> _fcmTokens =
      StreamController<String>.broadcast();
  bool _initialized = false;
  String? _latestInstallationId;
  String? _latestFcmToken;
  String _userScope = _anonymousScope;
  Future<void> _persistenceQueue = Future<void>.value();

  String get _notificationsStorageKey =>
      '${_notificationsKeyPrefix}_$_userScope';

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  Stream<NotificationItem> get incomingNotifications => _incoming.stream;
  Stream<String> get installationIds => _installationIds.stream;
  String? get latestInstallationId => _latestInstallationId;
  Stream<String> get fcmTokens => _fcmTokens.stream;
  String? get latestFcmToken => _latestFcmToken;

  static bool get isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<NotificationItem?> initialize({
    ValueChanged<NotificationItem>? onNotificationOpened,
  }) async {
    if (!isSupportedPlatform || _initialized) return null;
    _initialized = true;
    await _loadUserScope();
    await _loadNotifications();

    final messaging = FirebaseMessaging.instance;
    messaging.onRegistered.listen((installationId) {
      _latestInstallationId = installationId;
      _installationIds.add(installationId);
    });
    // FCM registration tokens are needed for Firebase Console test messages;
    // onRegistered separately exposes the Firebase Installation ID.
    // ignore: deprecated_member_use
    messaging.onTokenRefresh.listen(_recordFcmToken);
    unawaited(_refreshFcmToken(messaging));
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final item = _remember(message);
      onNotificationOpened?.call(item);
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage == null) return null;
    return _remember(initialMessage);
  }

  static Future<void> persistBackgroundMessage(RemoteMessage message) async {
    final preferences = await SharedPreferences.getInstance();
    final userScope =
        preferences.getString(_activeUserScopeKey) ?? _anonymousScope;
    final storageKey = '${_notificationsKeyPrefix}_$userScope';
    final raw = preferences.getString(storageKey);
    final decoded = raw == null ? null : jsonDecode(raw);
    final items = decoded is List<dynamic>
        ? decoded
              .whereType<Map<String, dynamic>>()
              .map(NotificationItem.fromJson)
              .toList()
        : <NotificationItem>[];
    final item = _itemFromMessage(message);
    if (items.any((existing) => existing.id == item.id)) return;
    items.insert(0, item);
    if (items.length > _maxStoredNotifications) {
      items.removeRange(_maxStoredNotifications, items.length);
    }
    if ((preferences.getString(_activeUserScopeKey) ?? _anonymousScope) !=
        userScope) {
      return;
    }
    await preferences.setString(
      storageKey,
      jsonEncode(items.map((notification) => notification.toJson()).toList()),
    );
  }

  static String destinationFor(NotificationItem item) {
    final actionUrl = item.actionUrl;
    if (actionUrl == null) return '/notifications';
    final uri = Uri.tryParse(actionUrl);
    if (uri == null || uri.hasScheme || uri.hasAuthority) {
      return '/notifications';
    }
    const detailPath =
        r'^/(chat|job-detail|post-detail|event-detail|alumni-profile|booking)/[^/]+$';
    if (RegExp(detailPath).hasMatch(uri.path)) return uri.toString();
    return '/notifications';
  }

  void markAllAsRead() {
    for (var index = 0; index < _notifications.length; index++) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
    _schedulePersistence();
  }

  Future<void> setUserScope(String? userId) async {
    final nextScope = userId?.isNotEmpty == true ? userId! : _anonymousScope;
    if (_userScope == nextScope) return;
    try {
      await _persistenceQueue;
      final preferences = await SharedPreferences.getInstance();
      _userScope = nextScope;
      await preferences.setString(_activeUserScopeKey, _userScope);
      _notifications.clear();
      await _loadNotifications();
    } on Object catch (error) {
      debugPrint('Could not switch notification history scope: $error');
    }
  }

  Future<void> clearHistory() async {
    try {
      await _persistenceQueue;
      final preferences = await SharedPreferences.getInstance();
      final previousStorageKey = _notificationsStorageKey;
      _notifications.clear();
      _userScope = _anonymousScope;
      await preferences.remove(previousStorageKey);
      await preferences.setString(_activeUserScopeKey, _anonymousScope);
      await preferences.setString(_notificationsStorageKey, '[]');
    } on Object catch (error) {
      debugPrint('Could not clear notification history: $error');
    }
  }

  Future<bool?> requestPermission() async {
    if (!isSupportedPlatform || Firebase.apps.isEmpty) return null;
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    if (granted) await _refreshFcmToken(FirebaseMessaging.instance);
    return granted;
  }

  Future<void> _refreshFcmToken(FirebaseMessaging messaging) async {
    try {
      // ignore: deprecated_member_use
      final token = await messaging.getToken();
      if (token != null) _recordFcmToken(token);
    } on Object catch (error) {
      debugPrint('Could not retrieve FCM registration token: $error');
    }
  }

  void _recordFcmToken(String token) {
    if (token == _latestFcmToken) return;
    _latestFcmToken = token;
    _fcmTokens.add(token);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = _remember(message);
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('${notification.title}: ${notification.body}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  NotificationItem _remember(RemoteMessage message) {
    final item = _itemFromMessage(message);
    for (final existing in _notifications) {
      if (existing.id == item.id) return existing;
    }
    _notifications.insert(0, item);
    if (_notifications.length > _maxStoredNotifications) {
      _notifications.removeRange(
        _maxStoredNotifications,
        _notifications.length,
      );
    }
    _incoming.add(item);
    _schedulePersistence();
    return item;
  }

  Future<void> _loadNotifications() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final raw = preferences.getString(_notificationsStorageKey);
      if (raw == null) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) return;
      _notifications
        ..clear()
        ..addAll(
          decoded
              .whereType<Map<String, dynamic>>()
              .map(NotificationItem.fromJson)
              .take(_maxStoredNotifications),
        );
    } on Object catch (error) {
      debugPrint('Could not restore notification history: $error');
    }
  }

  Future<void> _loadUserScope() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      _userScope =
          preferences.getString(_activeUserScopeKey) ?? _anonymousScope;
    } on Object catch (error) {
      debugPrint('Could not restore notification account scope: $error');
    }
  }

  void _schedulePersistence() {
    final snapshot = _notifications.map((item) => item.toJson()).toList();
    final storageKey = _notificationsStorageKey;
    _persistenceQueue = _persistenceQueue.then((_) async {
      try {
        final preferences = await SharedPreferences.getInstance();
        await preferences.setString(storageKey, jsonEncode(snapshot));
      } on Object catch (error) {
        debugPrint('Could not persist notification history: $error');
      }
    });
  }

  static NotificationItem _itemFromMessage(RemoteMessage message) {
    final data = message.data;
    final id = message.messageId ?? '${data['id'] ?? ''}';
    return NotificationItem(
      id: id.isEmpty ? DateTime.now().microsecondsSinceEpoch.toString() : id,
      title: message.notification?.title ?? '${data['title'] ?? 'Thông báo'}',
      body: message.notification?.body ?? '${data['body'] ?? ''}',
      type: _typeFrom(data['type']),
      createdAt: message.sentTime ?? DateTime.now(),
      actorName: data['actorName'] as String?,
      actorAvatar: data['actorAvatar'] as String?,
      actionUrl: data['actionUrl'] as String?,
      actionLabel: data['actionLabel'] as String?,
      tag: data['tag'] as String?,
    );
  }

  static NotificationType _typeFrom(Object? value) =>
      switch ('$value'.toLowerCase()) {
        'chat' || 'message' => NotificationType.chat,
        'mentorship' => NotificationType.mentorship,
        'social' => NotificationType.social,
        'job' => NotificationType.job,
        _ => NotificationType.system,
      };
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!DefaultFirebaseOptions.isConfigured) return;
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    await FcmMessagingService.persistBackgroundMessage(message);
  } on Object catch (error) {
    debugPrint('Could not persist background notification: $error');
  }
}
