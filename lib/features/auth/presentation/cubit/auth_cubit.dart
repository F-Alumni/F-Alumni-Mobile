import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/features/auth/data/auth_repository.dart';
import 'package:alumni_connect/features/auth/data/models/auth_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  AuthAuthenticated(this.user);
  final AuthUser user;
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  AuthError(this.message);
  final String message;
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(AuthInitial());
  final AuthRepository _repository;

  Future<void> restoreSession() async {
    try {
      emit(AuthAuthenticated(await _repository.restoreSession()));
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      emit(AuthAuthenticated(await _repository.login(email.trim(), password)));
    } catch (error) {
      emit(AuthError(error.toString()));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    try {
      emit(AuthAuthenticated(await _repository.loginWithGoogle()));
    } catch (error) {
      emit(AuthError(error.toString()));
    }
  }

  Future<String?> register({
    required String email,
    required String password,
    required String fullName,
    String accountType = 'Alumni',
  }) async {
    emit(AuthLoading());
    try {
      await _repository.register(
        email: email.trim(),
        password: password,
        fullName: fullName.trim(),
        accountType: accountType,
      );
      emit(AuthUnauthenticated());
      return null;
    } catch (error) {
      emit(AuthUnauthenticated());
      return error.toString();
    }
  }

  Future<String?> verifyEmail({
    required String email,
    required String otpCode,
  }) async {
    emit(AuthLoading());
    try {
      emit(
        AuthAuthenticated(
          await _repository.verifyEmail(
            email: email.trim(),
            otpCode: otpCode.trim(),
          ),
        ),
      );
      return null;
    } catch (error) {
      emit(AuthUnauthenticated());
      return error.toString();
    }
  }

  Future<String?> requestPasswordReset(String email) async {
    emit(AuthLoading());
    try {
      await _repository.requestPasswordReset(email.trim());
      emit(AuthUnauthenticated());
      return null;
    } catch (error) {
      emit(AuthUnauthenticated());
      return error.toString();
    }
  }

  Future<String?> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    emit(AuthLoading());
    try {
      await _repository.resetPassword(
        email: email.trim(),
        otpCode: otpCode.trim(),
        newPassword: newPassword,
      );
      emit(AuthUnauthenticated());
      return null;
    } catch (error) {
      emit(AuthUnauthenticated());
      return error.toString();
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final previousState = state;
    emit(AuthLoading());
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      emit(
        previousState is AuthAuthenticated
            ? previousState
            : AuthUnauthenticated(),
      );
      return null;
    } catch (error) {
      emit(AuthError(error.toString()));
      return error.toString();
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _repository.logout();
    } finally {
      emit(AuthUnauthenticated());
    }
  }
}
