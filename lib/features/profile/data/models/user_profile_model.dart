class UserProfile {
  final String id;
  final String name;
  final String email;
  final String studentId; // MSSV
  final String cohort; // K16
  final String major; // Kỹ thuật phần mềm (SE)
  final String campus; // FPT Đà Nẵng
  final String currentCompany;
  final String jobTitle;
  final String linkedInUrl;
  final String gitHubUrl;
  final String phoneNumber;
  final String avatarUrl;
  final String bio;
  final bool isAlumni;
  final bool isVerified;
  final List<String> skills;
  final List<String> interests;
  final String? calendarUrl; // US-11 (Google Calendar link)
  final bool isPublicToRecruiters; // US-09
  final bool showEmailPublicly; // US-09
  final bool showPhonePublicly; // US-09
  final bool showCalendarPublicly;
  final bool allowMessagesFromStrangers;
  final int totalPosts;
  final int totalConnections;
  final int mentoringSessions;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.studentId,
    required this.cohort,
    required this.major,
    required this.campus,
    this.currentCompany = '',
    this.jobTitle = '',
    this.linkedInUrl = '',
    this.gitHubUrl = '',
    this.phoneNumber = '',
    required this.avatarUrl,
    required this.bio,
    this.isAlumni = false,
    this.isVerified = false,
    required this.skills,
    required this.interests,
    this.calendarUrl,
    this.isPublicToRecruiters = true,
    this.showEmailPublicly = false,
    this.showPhonePublicly = false,
    this.showCalendarPublicly = true,
    this.allowMessagesFromStrangers = false,
    this.totalPosts = 0,
    this.totalConnections = 0,
    this.mentoringSessions = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      cohort: json['cohort'] as String? ?? '',
      major: json['major'] as String? ?? '',
      campus: json['campus'] as String? ?? 'Toàn quốc',
      currentCompany: json['currentCompany'] as String? ?? '',
      jobTitle: json['jobTitle'] as String? ?? '',
      linkedInUrl: json['linkedInUrl'] as String? ?? '',
      gitHubUrl: json['gitHubUrl'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      isAlumni: json['isAlumni'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? true,
      skills:
          (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      calendarUrl: json['calendarUrl'] as String?,
      isPublicToRecruiters: json['isPublicToRecruiters'] as bool? ?? true,
      showEmailPublicly: json['showEmailPublicly'] as bool? ?? false,
      showPhonePublicly: json['showPhonePublicly'] as bool? ?? false,
      showCalendarPublicly: json['showCalendarPublicly'] as bool? ?? true,
      allowMessagesFromStrangers:
          json['allowMessagesFromStrangers'] as bool? ?? true,
      totalPosts: json['totalPosts'] as int? ?? 0,
      totalConnections: json['totalConnections'] as int? ?? 0,
      mentoringSessions: json['mentoringSessions'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'studentId': studentId,
    'cohort': cohort,
    'major': major,
    'campus': campus,
    'currentCompany': currentCompany,
    'jobTitle': jobTitle,
    'linkedInUrl': linkedInUrl,
    'gitHubUrl': gitHubUrl,
    'phoneNumber': phoneNumber,
    'avatarUrl': avatarUrl,
    'bio': bio,
    'isAlumni': isAlumni,
    'isVerified': isVerified,
    'skills': skills,
    'interests': interests,
    'calendarUrl': calendarUrl,
    'isPublicToRecruiters': isPublicToRecruiters,
    'showEmailPublicly': showEmailPublicly,
    'showPhonePublicly': showPhonePublicly,
    'showCalendarPublicly': showCalendarPublicly,
    'allowMessagesFromStrangers': allowMessagesFromStrangers,
    'totalPosts': totalPosts,
    'totalConnections': totalConnections,
    'mentoringSessions': mentoringSessions,
  };

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? studentId,
    String? cohort,
    String? major,
    String? campus,
    String? currentCompany,
    String? jobTitle,
    String? linkedInUrl,
    String? gitHubUrl,
    String? phoneNumber,
    String? avatarUrl,
    String? bio,
    bool? isAlumni,
    bool? isVerified,
    List<String>? skills,
    List<String>? interests,
    String? calendarUrl,
    bool? isPublicToRecruiters,
    bool? showEmailPublicly,
    bool? showPhonePublicly,
    bool? showCalendarPublicly,
    bool? allowMessagesFromStrangers,
    int? totalPosts,
    int? totalConnections,
    int? mentoringSessions,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      cohort: cohort ?? this.cohort,
      major: major ?? this.major,
      campus: campus ?? this.campus,
      currentCompany: currentCompany ?? this.currentCompany,
      jobTitle: jobTitle ?? this.jobTitle,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      gitHubUrl: gitHubUrl ?? this.gitHubUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      isAlumni: isAlumni ?? this.isAlumni,
      isVerified: isVerified ?? this.isVerified,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      calendarUrl: calendarUrl ?? this.calendarUrl,
      isPublicToRecruiters: isPublicToRecruiters ?? this.isPublicToRecruiters,
      showEmailPublicly: showEmailPublicly ?? this.showEmailPublicly,
      showPhonePublicly: showPhonePublicly ?? this.showPhonePublicly,
      showCalendarPublicly: showCalendarPublicly ?? this.showCalendarPublicly,
      allowMessagesFromStrangers:
          allowMessagesFromStrangers ?? this.allowMessagesFromStrangers,
      totalPosts: totalPosts ?? this.totalPosts,
      totalConnections: totalConnections ?? this.totalConnections,
      mentoringSessions: mentoringSessions ?? this.mentoringSessions,
    );
  }
}
