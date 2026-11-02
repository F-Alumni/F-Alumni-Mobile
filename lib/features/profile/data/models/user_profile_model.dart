class UserProfile {
  final String id;
  final String name;
  final String email;
  final String studentId; // MSSV
  final String cohort; // K16
  final String major; // Kỹ thuật phần mềm (SE)
  final String campus; // FPT Đà Nẵng
  final String avatarUrl;
  final String bio;
  final bool isAlumni;
  final bool isVerified;
  final List<String> skills;
  final List<String> interests;
  final String? calendarUrl; // US-11 (Google Calendar link)
  final bool isPublicToRecruiters; // US-09
  final bool showContactInfo; // US-09
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
    required this.avatarUrl,
    required this.bio,
    this.isAlumni = false,
    this.isVerified = true,
    required this.skills,
    required this.interests,
    this.calendarUrl,
    this.isPublicToRecruiters = true,
    this.showContactInfo = false,
    this.allowMessagesFromStrangers = true,
    this.totalPosts = 12,
    this.totalConnections = 86,
    this.mentoringSessions = 5,
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
      avatarUrl: json['avatarUrl'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      isAlumni: json['isAlumni'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? true,
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      interests: (json['interests'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      calendarUrl: json['calendarUrl'] as String?,
      isPublicToRecruiters: json['isPublicToRecruiters'] as bool? ?? true,
      showContactInfo: json['showContactInfo'] as bool? ?? false,
      allowMessagesFromStrangers: json['allowMessagesFromStrangers'] as bool? ?? true,
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
        'avatarUrl': avatarUrl,
        'bio': bio,
        'isAlumni': isAlumni,
        'isVerified': isVerified,
        'skills': skills,
        'interests': interests,
        'calendarUrl': calendarUrl,
        'isPublicToRecruiters': isPublicToRecruiters,
        'showContactInfo': showContactInfo,
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
    String? avatarUrl,
    String? bio,
    bool? isAlumni,
    bool? isVerified,
    List<String>? skills,
    List<String>? interests,
    String? calendarUrl,
    bool? isPublicToRecruiters,
    bool? showContactInfo,
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
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      isAlumni: isAlumni ?? this.isAlumni,
      isVerified: isVerified ?? this.isVerified,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      calendarUrl: calendarUrl ?? this.calendarUrl,
      isPublicToRecruiters: isPublicToRecruiters ?? this.isPublicToRecruiters,
      showContactInfo: showContactInfo ?? this.showContactInfo,
      allowMessagesFromStrangers: allowMessagesFromStrangers ?? this.allowMessagesFromStrangers,
      totalPosts: totalPosts ?? this.totalPosts,
      totalConnections: totalConnections ?? this.totalConnections,
      mentoringSessions: mentoringSessions ?? this.mentoringSessions,
    );
  }
}
