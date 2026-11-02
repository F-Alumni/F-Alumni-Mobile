import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:alumni_connect/features/notifications/data/models/notification_model.dart';
import 'package:alumni_connect/firebase_options.dart';

class FcmMessagingService {
  FcmMessagingService._();

  static final FcmMessagingService instance = FcmMessagingService._();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final List<NotificationItem> _notifications = [];
  final StreamController<NotificationItem> _incoming =
      StreamController<NotificationItem>.broadcast();
  final StreamController<String> _installationIds =
      StreamController<String>.broadcast();
  bool _initialized = false;
  String? _latestInstallationId;

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  Stream<NotificationItem> get incomingNotifications => _incoming.stream;
  Stream<String> get installationIds => _installationIds.stream;
  String? get latestInstallationId => _latestInstallationId;

  static bool get isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<bool> initialize({VoidCallback? onNotificationOpened}) async {
    if (!isSupportedPlatform || _initialized) return false;
    _initialized = true;

    final messaging = FirebaseMessaging.instance;
    messaging.onRegistered.listen((installationId) {
      _latestInstallationId = installationId;
      _installationIds.add(installationId);
    });
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _remember(message);
      onNotificationOpened?.call();
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) _remember(initialMessage);
    return initialMessage != null;
  }

  Future<void> requestPermission() async {
    if (!isSupportedPlatform || Firebase.apps.isEmpty) return;
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = _remember(message);
    if (notification == null) return;
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('${notification.title}: ${notification.body}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  NotificationItem? _remember(RemoteMessage message) {
    final data = message.data;
    final id = message.messageId ?? '${data['id'] ?? ''}';
    if (id.isNotEmpty && _notifications.any((item) => item.id == id)) {
      return null;
    }

    final item = NotificationItem(
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
    _notifications.insert(0, item);
    _incoming.add(item);
    return item;
  }

  NotificationType _typeFrom(Object? value) => switch ('$value'.toLowerCase()) {
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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Notification payloads are displayed by the platform while the app is in
  // the background. A backend notification history API is still required for
  // persistent in-app history.
  if (message.messageId == null && message.data.isEmpty) return;
}
