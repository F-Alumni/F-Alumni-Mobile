import 'dart:async';
import 'dart:ui' as ui;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseCrashlyticsService {
  FirebaseCrashlyticsService(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  Future<void> recordHandledError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
  }) =>
      _crashlytics.recordError(error, stackTrace, reason: reason, fatal: false);

  Future<void> setUserIdentifier(String? identifier) =>
      _crashlytics.setUserIdentifier(identifier ?? '');

  Future<void> setCustomKey(String key, Object value) =>
      _crashlytics.setCustomKey(key, value);

  void crashForDemo() => _crashlytics.crash();

  Future<void> recordFatalError(Object error, StackTrace stackTrace) =>
      _crashlytics.recordError(error, stackTrace, fatal: true);

  static void installGlobalErrorHandlers(FirebaseCrashlyticsService service) {
    final previousFlutterHandler = FlutterError.onError;
    final previousPlatformHandler = ui.PlatformDispatcher.instance.onError;
    FlutterError.onError = (details) {
      previousFlutterHandler?.call(details);
      unawaited(service._crashlytics.recordFlutterFatalError(details));
    };
    ui.PlatformDispatcher.instance.onError = (error, stackTrace) {
      unawaited(service.recordFatalError(error, stackTrace));
      return previousPlatformHandler?.call(error, stackTrace) ?? true;
    };
  }
}
