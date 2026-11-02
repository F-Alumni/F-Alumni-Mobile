import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/features/auth/data/models/auth_model.dart';

// ─── States ───────────────────────────────────────────────────────────────────

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthUser user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthUnauthenticated());

  /// US-01: Login with FPT Google account (mock — accept any @fpt.edu.vn email)
  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1500));

    // Mock: simulate successful Google SSO with FPT account
    emit(AuthAuthenticated(_mockUser));
  }

  /// US-01: Login with email + password (mock)
  Future<void> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!email.endsWith('@fpt.edu.vn') && !email.endsWith('@fe.edu.vn')) {
      emit(AuthError('Chỉ hỗ trợ tài khoản FPT Mail (@fpt.edu.vn hoặc @fe.edu.vn)'));
      return;
    }
    if (password.length < 6) {
      emit(AuthError('Mật khẩu phải có ít nhất 6 ký tự'));
      return;
    }

    emit(AuthAuthenticated(_mockUser));
  }

  /// US-08: Logout
  void logout() {
    emit(AuthUnauthenticated());
  }

  // Mock authenticated user (Student An K16 FPT Đà Nẵng)
  static const _mockUser = AuthUser(
    id: 'user_001',
    name: 'Nguyễn Thị An',
    email: 'anhnt.k16@fpt.edu.vn',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
    isAlumni: false,
    isVerified: true,
    campus: 'FPT Đà Nẵng',
    cohort: 'K16',
  );
}
