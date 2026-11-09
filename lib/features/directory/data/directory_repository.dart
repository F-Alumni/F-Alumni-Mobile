import 'package:alumni_connect/core/network/alumni_api.dart';
import 'package:alumni_connect/features/directory/data/models/alumni_model.dart';

class DirectoryRepository {
  DirectoryRepository(this.api);
  final AlumniApi api;

  Future<List<AlumniModel>> search({
    String query = '',
    String? campus,
    String? major,
  }) async {
    final result = await api.user.get(
      '/api/v1/users/directory',
      query: {
        if (query.isNotEmpty) 'search': query,
        if (campus != null && campus.isNotEmpty) 'campus': campus,
        if (major != null && major.isNotEmpty) 'major': major,
        'pageNumber': '1',
        'pageSize': '50',
      },
    );
    final items = result['items'] as List<dynamic>? ?? const [];
    return items
        .map((item) => _toAlumni(item as Map<String, dynamic>))
        .toList();
  }

  Future<AlumniModel> getProfile(String id) async =>
      _toAlumni(await api.user.get('/api/v1/users/$id'));

  AlumniModel _toAlumni(Map<String, dynamic> user) {
    final skills = '${user['skills'] ?? ''}'
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    return AlumniModel(
      id: '${user['id'] ?? ''}',
      name: '${user['displayName'] ?? user['fullName'] ?? ''}',
      mssv: '${user['studentCode'] ?? ''}',
      cohort: '${user['graduationYear'] ?? ''}',
      major: '${user['major'] ?? ''}',
      campus: '${user['campus'] ?? ''}',
      currentRole: '${user['jobTitle'] ?? ''}',
      company: '${user['currentCompany'] ?? ''}',
      avatarUrl: '${user['avatarUrl'] ?? ''}',
      isVerified: user['emailVerified'] as bool? ?? false,
      isAvailableForMentoring:
          ('${user['googleCalendarUrl'] ?? ''}').trim().isNotEmpty,
      rating: 0,
      reviewsCount: 0,
      completedSessions: 0,
      skills: skills,
      bio: '${user['bio'] ?? ''}',
      email: '${user['email'] ?? ''}',
      phoneNumber: '${user['phoneNumber'] ?? ''}',
      linkedInUrl: '${user['linkedInUrl'] ?? ''}',
      gitHubUrl: '${user['gitHubUrl'] ?? ''}',
      calendarUrl: '${user['googleCalendarUrl'] ?? ''}',
    );
  }
}
