import 'package:alumni_connect/core/network/alumni_api.dart';
import 'package:alumni_connect/features/auth/data/models/auth_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  AuthRepository(this.api);
  final AlumniApi api;
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
    return _saveSession(data);
  }

  Future<AuthUser> login(String email, String password) async {
    final data = await api.user.post(
      '/api/v1/auth/login',
      body: {'email': email, 'password': password},
    );
    return _saveSession(data);
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await api.user.post(
      '/api/v1/auth/register',
      body: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'campus': 'HCM',
        'accountType': 'Student',
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
      return _toUser(data);
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
      return _toUser(renewed['user'] as Map<String, dynamic>);
    }
  }

  Future<void> logout() async {
    final refresh = await api.tokens.refreshToken;
    try {
      await api.user.post(
        '/api/v1/auth/logout',
        body: {'refreshToken': refresh},
      );
    } finally {
      await api.tokens.clear();
    }
  }

  Future<AuthUser> _saveSession(Map<String, dynamic> data) async {
    final user = _toUser(data['user'] as Map<String, dynamic>);
    await api.tokens.save(
      access: data['accessToken'] as String,
      refresh: data['refreshToken'] as String,
    );
    return user;
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
