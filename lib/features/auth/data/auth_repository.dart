import 'package:alumni_connect/core/network/alumni_api.dart';
import 'package:alumni_connect/features/auth/data/models/auth_model.dart';
import 'package:alumni_connect/features/lab3/data/services/firebase_analytics_service.dart';
import 'package:alumni_connect/features/lab3/data/services/firebase_auth_service.dart';
import 'package:alumni_connect/features/lab3/data/services/firebase_crashlytics_service.dart';
import 'package:alumni_connect/features/notifications/data/fcm_messaging_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  AuthRepository(
    this.api, {
    this.firebaseAuthService,
    this.analyticsService,
    this.crashlyticsService,
  });

  final AlumniApi api;
  final FirebaseAuthService? firebaseAuthService;
  final FirebaseAnalyticsService? analyticsService;
  final FirebaseCrashlyticsService? crashlyticsService;
  static const _googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
  static const _googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );
  static Future<void>? _googleInitialization;

  Future<AuthUser> loginWithGoogle() async {
    if (_googleClientId.isEmpty && _googleServerClientId.isEmpty) {
      throw StateError(
        'Thiếu GOOGLE_CLIENT_ID hoặc GOOGLE_SERVER_CLIENT_ID để cấu hình Google Sign-In.',
      );
    }
    final firebaseAuth = firebaseAuthService;
    if (firebaseAuth == null) return await _loginWithGoogleBackendOnly();

    final result = await firebaseAuth.signInWithGoogle(
      clientId: _googleClientId.isEmpty ? null : _googleClientId,
      serverClientId: _googleServerClientId.isEmpty
          ? null
          : _googleServerClientId,
    );
    try {
      final firebaseUser = result.firebaseUser;
      final data = await api.user.post(
        '/api/v1/auth/google',
        body: {
          'idToken': result.googleIdToken,
          'email': firebaseUser.email ?? '',
          'fullName': firebaseUser.displayName ?? '',
          'avatarUrl': firebaseUser.photoURL ?? '',
        },
      );
      final authUser = await _saveSession(data);
      await _recordLogin(AnalyticsLoginMethod.google);
      return authUser;
    } catch (_) {
      await firebaseAuth.signOut();
      await _setAnalyticsUserId(null);
      rethrow;
    }
  }

  Future<AuthUser> _loginWithGoogleBackendOnly() async {
    final signIn = GoogleSignIn.instance;
    _googleInitialization ??= signIn.initialize(
      clientId: _googleClientId.isEmpty ? null : _googleClientId,
      serverClientId: _googleServerClientId.isEmpty
          ? null
          : _googleServerClientId,
    );
    await _googleInitialization;
    final account = await signIn.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Google Sign-In không trả về ID token.');
    }
    final data = await api.user.post(
      '/api/v1/auth/google',
      body: {
        'idToken': idToken,
        'email': account.email,
        'fullName': account.displayName ?? '',
        'avatarUrl': account.photoUrl ?? '',
      },
    );
    final user = await _saveSession(data);
    await _recordLogin(AnalyticsLoginMethod.google);
    return user;
  }

  Future<AuthUser> login(String email, String password) async {
    await firebaseAuthService?.signOut();
    final data = await api.user.post(
      '/api/v1/auth/login',
      body: {'email': email, 'password': password},
    );
    final user = await _saveSession(data);
    await _recordLogin(AnalyticsLoginMethod.email);
    return user;
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String accountType = 'Alumni',
  }) async {
    await api.user.post(
      '/api/v1/auth/register',
      body: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'campus': 'HCM',
        'accountType': accountType,
        'role': accountType.toUpperCase(),
      },
    );
  }

  Future<AuthUser> verifyEmail({
    required String email,
    required String otpCode,
  }) async {
    final data = await api.user.post(
      '/api/v1/auth/verify-email',
      body: {'email': email, 'otpCode': otpCode},
    );
    return _saveSession(data);
  }

  Future<void> requestPasswordReset(String email) async {
    await api.user.post('/api/v1/auth/forgot-password', body: {'email': email});
  }

  Future<void> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    await api.user.post(
      '/api/v1/auth/reset-password',
      body: {'email': email, 'otpCode': otpCode, 'newPassword': newPassword},
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await api.user.post(
      '/api/v1/auth/change-password',
      body: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  Future<AuthUser> restoreSession() async {
    final access = await api.tokens.accessToken;
    if (access == null || access.isEmpty) {
      throw StateError('No saved session');
    }
    try {
      final data = await api.user.get('/api/v1/users/me');
      final user = _toUser(data);
      await _syncAnalyticsIdentity(user);
      return user;
    } catch (_) {
      final refresh = await api.tokens.refreshToken;
      if (refresh == null || refresh.isEmpty) rethrow;
      final renewed = await api.user.post(
        '/api/v1/auth/refresh-token',
        body: {'refreshToken': refresh},
      );
      await api.tokens.save(
        access: renewed['accessToken'] as String,
        refresh: renewed['refreshToken'] as String,
      );
      final user = _toUser(renewed['user'] as Map<String, dynamic>);
      await _syncAnalyticsIdentity(user);
      return user;
    }
  }

  Future<void> logout() async {
    await _analyticsCall((analytics) => analytics.logLogout());
    await _setAnalyticsUserId(null);
    await _crashlyticsCall(
      (crashlytics) => crashlytics.setUserIdentifier(null),
    );
    final refresh = await api.tokens.refreshToken;
    try {
      await api.user.post(
        '/api/v1/auth/logout',
        body: {'refreshToken': refresh},
      );
    } finally {
      try {
        await api.tokens.clear();
      } finally {
        try {
          await firebaseAuthService?.signOut();
        } finally {
          await FcmMessagingService.instance.clearHistory();
        }
      }
    }
  }

  Future<AuthUser> _saveSession(Map<String, dynamic> data) async {
    final user = _toUser(data['user'] as Map<String, dynamic>);
    await api.tokens.save(
      access: data['accessToken'] as String,
      refresh: data['refreshToken'] as String,
    );
    await FcmMessagingService.instance.setUserScope(user.id);
    await _syncAnalyticsIdentity(user);
    return user;
  }

  Future<void> _recordLogin(AnalyticsLoginMethod method) async {
    await _analyticsCall((analytics) => analytics.logLogin(method));
    await _setCrashlyticsLoginMethod(method.name);
  }

  Future<void> _syncAnalyticsIdentity(AuthUser user) async {
    final firebaseUser = firebaseAuthService?.currentUser;
    final isMatchingFirebaseUser =
        firebaseUser?.email?.trim().toLowerCase() ==
        user.email.trim().toLowerCase();
    final userId = isMatchingFirebaseUser ? firebaseUser?.uid : null;
    await _setAnalyticsUserId(userId);
    final crashlyticsUserId = isMatchingFirebaseUser ? firebaseUser?.uid : null;
    await _crashlyticsCall(
      (crashlytics) => crashlytics.setUserIdentifier(crashlyticsUserId),
    );
  }

  Future<void> _setCrashlyticsLoginMethod(String method) => _crashlyticsCall(
    (crashlytics) => crashlytics.setCustomKey('auth_method', method),
  );

  Future<void> _crashlyticsCall(
    Future<void> Function(FirebaseCrashlyticsService crashlytics) call,
  ) async {
    final crashlytics = crashlyticsService;
    if (crashlytics == null) return;
    try {
      await call(crashlytics);
    } on Object {
      // Diagnostics must not change the outcome of an app operation.
    }
  }

  Future<void> _setAnalyticsUserId(String? userId) =>
      _analyticsCall((analytics) => analytics.setUserId(userId));

  Future<void> _analyticsCall(
    Future<void> Function(FirebaseAnalyticsService analytics) call,
  ) async {
    final analytics = analyticsService;
    if (analytics == null) return;
    try {
      await call(analytics);
    } on Object {
      // Analytics failure must never block sign-in, sign-out, or app actions.
    }
  }

  AuthUser _toUser(Map<String, dynamic> json) => AuthUser(
    id: '${json['id'] ?? ''}',
    name: '${json['displayName'] ?? json['fullName'] ?? ''}',
    email: '${json['email'] ?? ''}',
    avatarUrl: json['avatarUrl'] as String?,
    isAlumni: '${json['accountType']}'.toLowerCase() == 'alumni',
    isVerified: json['emailVerified'] as bool? ?? false,
    campus: '${json['campus'] ?? ''}',
    cohort: '${json['graduationYear'] ?? ''}',
  );
}
