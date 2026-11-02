import 'package:alumni_connect/core/network/alumni_api.dart';
import 'package:alumni_connect/features/profile/data/models/user_profile_model.dart';

class ProfileRepository {
  ProfileRepository(this.api);
  final AlumniApi api;

  Future<UserProfile> loadMe() async =>
      _profile(await api.user.get('/api/v1/users/me'));

  Future<UserProfile> update(UserProfile profile) async {
    final data = await api.user.put(
      '/api/v1/users/me',
      body: {
        'fullName': profile.name,
        'displayName': profile.name,
        'avatarUrl': profile.avatarUrl,
        'studentCode': profile.studentId,
        'campus': profile.campus,
        'graduationYear': int.tryParse(profile.cohort),
        'major': profile.major,
        'currentCompany': profile.currentCompany,
        'jobTitle': profile.jobTitle,
        'bio': profile.bio,
        'skills': profile.skills.join(', '),
        'linkedInUrl': profile.linkedInUrl,
        'gitHubUrl': profile.gitHubUrl,
        'phoneNumber': profile.phoneNumber,
        'googleCalendarUrl': profile.calendarUrl ?? '',
      },
    );
    var updated = data;
    if (profile.avatarUrl.isNotEmpty) {
      updated = await api.user.put(
        '/api/v1/users/me/avatar',
        body: {'avatarUrl': profile.avatarUrl},
      );
    }
    updated = await api.user.put(
      '/api/v1/users/me/calendar',
      body: {'googleCalendarUrl': profile.calendarUrl ?? ''},
    );
    return _profile(updated);
  }

  Future<UserProfile> updatePrivacy(UserProfile profile) async {
    final data = await api.user.put(
      '/api/v1/users/me/privacy',
      body: {
        'showEmailPublicly': profile.showEmailPublicly,
        'showPhonePublicly': profile.showPhonePublicly,
        'showCompanyPublicly': profile.isPublicToRecruiters,
        'showCalendarPublicly': profile.showCalendarPublicly,
      },
    );
    return _profile(data);
  }

  Future<void> blockUser(String userId, {String reason = ''}) async {
    await api.user.post(
      '/api/v1/users/$userId/block',
      body: {'reason': reason},
    );
  }

  Future<List<Map<String, dynamic>>> loadBlockedUsers() async =>
      (await api.user.getList('/api/v1/users/me/blocks'))
          .map((row) => row as Map<String, dynamic>)
          .toList();

  Future<void> unblockUser(String userId) async =>
      api.user.delete('/api/v1/users/$userId/block');

  UserProfile _profile(Map<String, dynamic> json) {
    final skills = '${json['skills'] ?? ''}'
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    return UserProfile(
      id: '${json['id'] ?? ''}',
      name: '${json['displayName'] ?? json['fullName'] ?? ''}',
      email: '${json['email'] ?? ''}',
      studentId: '${json['studentCode'] ?? ''}',
      cohort: '${json['graduationYear'] ?? ''}',
      major: '${json['major'] ?? ''}',
      campus: '${json['campus'] ?? ''}',
      currentCompany: '${json['currentCompany'] ?? ''}',
      jobTitle: '${json['jobTitle'] ?? ''}',
      linkedInUrl: '${json['linkedInUrl'] ?? ''}',
      gitHubUrl: '${json['gitHubUrl'] ?? ''}',
      phoneNumber: '${json['phoneNumber'] ?? ''}',
      avatarUrl: '${json['avatarUrl'] ?? ''}',
      bio: '${json['bio'] ?? ''}',
      isAlumni: '${json['accountType']}'.toLowerCase() == 'alumni',
      isVerified: json['emailVerified'] as bool? ?? false,
      skills: skills,
      interests: const [],
      calendarUrl: json['googleCalendarUrl'] as String?,
      isPublicToRecruiters: json['showCompanyPublicly'] as bool? ?? true,
      showEmailPublicly: json['showEmailPublicly'] as bool? ?? false,
      showPhonePublicly: json['showPhonePublicly'] as bool? ?? false,
      showCalendarPublicly: json['showCalendarPublicly'] as bool? ?? true,
      allowMessagesFromStrangers: false,
      totalPosts: 0,
      totalConnections: 0,
      mentoringSessions: 0,
    );
  }
}
