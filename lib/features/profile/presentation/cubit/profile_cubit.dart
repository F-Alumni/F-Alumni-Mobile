import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/features/profile/data/models/user_profile_model.dart';
import 'package:alumni_connect/features/profile/data/mock/profile_mock_data.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  ProfileLoaded({required this.profile});

  ProfileLoaded copyWith({UserProfile? profile}) {
    return ProfileLoaded(profile: profile ?? this.profile);
  }
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  void loadProfile() {
    emit(ProfileLoading());
    emit(ProfileLoaded(profile: ProfileMockData.currentUser));
  }

  void updateProfile({
    String? name,
    String? bio,
    String? campus,
    String? major,
    String? cohort,
    String? calendarUrl,
    List<String>? skills,
    bool? isAlumni,
  }) {
    if (state is ProfileLoaded) {
      final current = (state as ProfileLoaded).profile;
      final updated = current.copyWith(
        name: name,
        bio: bio,
        campus: campus,
        major: major,
        cohort: cohort,
        calendarUrl: calendarUrl,
        skills: skills,
        isAlumni: isAlumni,
      );
      emit(ProfileLoaded(profile: updated));
    }
  }

  void updatePrivacySettings({
    bool? isPublicToRecruiters,
    bool? showContactInfo,
    bool? allowMessagesFromStrangers,
  }) {
    if (state is ProfileLoaded) {
      final current = (state as ProfileLoaded).profile;
      final updated = current.copyWith(
        isPublicToRecruiters: isPublicToRecruiters,
        showContactInfo: showContactInfo,
        allowMessagesFromStrangers: allowMessagesFromStrangers,
      );
      emit(ProfileLoaded(profile: updated));
    }
  }
}
