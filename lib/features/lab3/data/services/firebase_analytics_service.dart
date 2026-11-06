import 'package:firebase_analytics/firebase_analytics.dart';

enum AnalyticsLoginMethod { google, email }

enum AnalyticsContentType { post, alumni, job }

enum AnalyticsSearchType { feed, alumni, jobs }

enum AnalyticsNotificationType { chat, mentorship, social, job, system }

class FirebaseAnalyticsService {
  FirebaseAnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  Future<void> logLogin(AnalyticsLoginMethod method) =>
      _logEvent('login', {'method': method.name});

  Future<void> logLogout() => _logEvent('logout');

  Future<void> logSelectContent(AnalyticsContentType contentType) =>
      _logEvent('select_content', {'content_type': contentType.name});

  Future<void> logViewItem(AnalyticsContentType contentType) =>
      _logEvent('view_item', {'item_category': contentType.name});

  Future<void> logSearch(AnalyticsSearchType searchType, {int? resultCount}) =>
      _logEvent('search', {
        'search_type': searchType.name,
        if (resultCount != null && resultCount >= 0)
          'result_count': resultCount,
      });

  Future<void> logAvatarUploadComplete() =>
      _logEvent('avatar_upload_complete', const {'file_type': 'image'});

  Future<void> logNotificationOpen(AnalyticsNotificationType type) =>
      _logEvent('notification_open', {'notification_type': type.name});

  Future<void> setUserId(String? id) => _analytics.setUserId(id: id);

  Future<void> _logEvent(String name, [Map<String, Object>? parameters]) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } on Object {
      // Measurement failures must not interrupt an app flow.
    }
  }
}
