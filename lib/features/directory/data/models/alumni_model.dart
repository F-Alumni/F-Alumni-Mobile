class AlumniModel {
  final String id;
  final String name;
  final String mssv;
  final String cohort; // K14, K13...
  final String major; // Kỹ thuật phần mềm...
  final String campus; // Hòa Lạc, TP.HCM...
  final String currentRole; // Tech Lead...
  final String company; // TechCorp, Grab...
  final String avatarUrl;
  final bool isVerified;
  final bool isAvailableForMentoring;
  final double rating;
  final int reviewsCount;
  final int completedSessions;
  final List<String> skills;
  final String bio;

  const AlumniModel({
    required this.id,
    required this.name,
    required this.mssv,
    required this.cohort,
    required this.major,
    required this.campus,
    required this.currentRole,
    required this.company,
    required this.avatarUrl,
    this.isVerified = true,
    this.isAvailableForMentoring = true,
    required this.rating,
    required this.reviewsCount,
    required this.completedSessions,
    required this.skills,
    required this.bio,
  });

  factory AlumniModel.fromJson(Map<String, dynamic> json) {
    return AlumniModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      mssv: json['mssv'] as String? ?? '',
      cohort: json['cohort'] as String? ?? '',
      major: json['major'] as String? ?? '',
      campus: json['campus'] as String? ?? 'Toàn quốc',
      currentRole: json['currentRole'] as String? ?? '',
      company: json['company'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? true,
      isAvailableForMentoring: json['isAvailableForMentoring'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewsCount: json['reviewsCount'] as int? ?? 0,
      completedSessions: json['completedSessions'] as int? ?? 0,
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      bio: json['bio'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mssv': mssv,
        'cohort': cohort,
        'major': major,
        'campus': campus,
        'currentRole': currentRole,
        'company': company,
        'avatarUrl': avatarUrl,
        'isVerified': isVerified,
        'isAvailableForMentoring': isAvailableForMentoring,
        'rating': rating,
        'reviewsCount': reviewsCount,
        'completedSessions': completedSessions,
        'skills': skills,
        'bio': bio,
      };
}

