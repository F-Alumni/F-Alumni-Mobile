import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/features/profile/data/models/user_profile_model.dart';
import 'package:alumni_connect/features/profile/data/profile_repository.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileError extends ProfileState {
  ProfileError(this.message);
  final String message;
}

class ProfileLoaded extends ProfileState {
  ProfileLoaded({required this.profile});
  final UserProfile profile;
  ProfileLoaded copyWith({UserProfile? profile}) =>
      ProfileLoaded(profile: profile ?? this.profile);
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(ProfileInitial());
  final ProfileRepository _repository;

  Future<String?> blockUser(String userId) async {
    try {
      await _repository.blockUser(userId, reason: 'Blocked from mobile app');
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Future<List<Map<String, dynamic>>> loadBlockedUsers() async {
    final rows = await _repository.loadBlockedUsers();
    return rows;
  }

  Future<String?> unblockUser(String userId) async {
    try {
      await _repository.unblockUser(userId);
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      emit(ProfileLoaded(profile: await _repository.loadMe()));
    } catch (error) {
      emit(ProfileError(error.toString()));
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? bio,
    String? campus,
    String? major,
    String? cohort,
    String? calendarUrl,
    String? avatarUrl,
    List<String>? skills,
  }) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return false;
    final current = currentState.profile;
    emit(ProfileLoading());
    try {
      final updated = current.copyWith(
        name: name,
        bio: bio,
        campus: campus,
        major: major,
        cohort: cohort,
        calendarUrl: calendarUrl,
        avatarUrl: avatarUrl,
        skills: skills,
      );
      emit(ProfileLoaded(profile: await _repository.update(updated)));
      return true;
    } catch (error) {
      emit(ProfileError(error.toString()));
      return false;
    }
  }

  Future<bool> updatePrivacySettings({
    bool? isPublicToRecruiters,
    bool? showEmailPublicly,
    bool? showPhonePublicly,
    bool? showCalendarPublicly,
  }) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return false;
    final current = currentState.profile;
    emit(ProfileLoading());
    try {
      final updated = current.copyWith(
        isPublicToRecruiters: isPublicToRecruiters,
        showEmailPublicly: showEmailPublicly,
        showPhonePublicly: showPhonePublicly,
        showCalendarPublicly: showCalendarPublicly,
      );
      emit(ProfileLoaded(profile: await _repository.updatePrivacy(updated)));
      return true;
    } catch (error) {
      emit(ProfileError(error.toString()));
      return false;
    }
  }
}
