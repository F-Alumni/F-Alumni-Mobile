import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alumni_connect/features/notifications/data/fcm_messaging_service.dart';
import 'package:alumni_connect/features/lab3/data/services/firebase_analytics_service.dart';
import 'package:alumni_connect/features/lab3/data/services/firebase_auth_service.dart';
import 'package:alumni_connect/features/lab3/data/services/firebase_crashlytics_service.dart';
import 'package:alumni_connect/features/lab3/data/services/firebase_remote_config_service.dart';
import 'package:alumni_connect/features/lab3/data/services/firebase_storage_service.dart';

bool get firebaseServicesAvailable => Firebase.apps.isNotEmpty;

final firebaseAuthServiceProvider = Provider<FirebaseAuthService?>((ref) {
  if (!firebaseServicesAvailable) return null;
  return FirebaseAuthService(FirebaseAuth.instance);
});

final firebaseAnalyticsServiceProvider = Provider<FirebaseAnalyticsService?>((
  ref,
) {
  if (!firebaseServicesAvailable) return null;
  return FirebaseAnalyticsService(FirebaseAnalytics.instance);
});

final firebaseCrashlyticsServiceProvider =
    Provider<FirebaseCrashlyticsService?>((ref) {
      if (!firebaseServicesAvailable ||
          !FcmMessagingService.isSupportedPlatform) {
        return null;
      }
      return FirebaseCrashlyticsService(FirebaseCrashlytics.instance);
    });

final firebaseRemoteConfigServiceProvider =
    Provider<FirebaseRemoteConfigService?>((ref) {
      if (!firebaseServicesAvailable) return null;
      return FirebaseRemoteConfigService(FirebaseRemoteConfig.instance);
    });

final firebaseStorageServiceProvider = Provider<FirebaseStorageService?>((ref) {
  if (!firebaseServicesAvailable) return null;
  return FirebaseStorageService(FirebaseStorage.instance);
});
