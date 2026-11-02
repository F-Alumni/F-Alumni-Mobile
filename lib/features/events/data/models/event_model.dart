class EventModel {
  final String id;
  final String creatorId;
  final String creatorName;
  final String creatorAvatarUrl;
  final String title;
  final String description;
  final String bannerUrl;
  final String location;
  final String campus;
  final DateTime startTime;
  final DateTime endTime;
  final int? maxAttendees;
  final int goingCount;
  final int interestedCount;
  final DateTime createdAt;
  final String? myStatus; // 'Going', 'Interested', 'NotGoing', or null

  const EventModel({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.creatorAvatarUrl,
    required this.title,
    required this.description,
    required this.bannerUrl,
    required this.location,
    required this.campus,
    required this.startTime,
    required this.endTime,
    this.maxAttendees,
    this.goingCount = 0,
    this.interestedCount = 0,
    required this.createdAt,
    this.myStatus,
  });

  bool get isFull => maxAttendees != null && goingCount >= maxAttendees!;
  bool get isUpcoming => startTime.isAfter(DateTime.now());

  EventModel copyWith({
    String? id,
    String? creatorId,
    String? creatorName,
    String? creatorAvatarUrl,
    String? title,
    String? description,
    String? bannerUrl,
    String? location,
    String? campus,
    DateTime? startTime,
    DateTime? endTime,
    int? maxAttendees,
    int? goingCount,
    int? interestedCount,
    DateTime? createdAt,
    String? myStatus,
  }) {
    return EventModel(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorAvatarUrl: creatorAvatarUrl ?? this.creatorAvatarUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      location: location ?? this.location,
      campus: campus ?? this.campus,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      goingCount: goingCount ?? this.goingCount,
      interestedCount: interestedCount ?? this.interestedCount,
      createdAt: createdAt ?? this.createdAt,
      myStatus: myStatus ?? this.myStatus,
    );
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String? ?? '',
      creatorId: json['creatorId'] as String? ?? '',
      creatorName: json['creatorName'] as String? ?? 'FPT Alumni',
      creatorAvatarUrl: json['creatorAvatarUrl'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      bannerUrl: json['bannerUrl'] as String? ?? '',
      location: json['location'] as String? ?? '',
      campus: switch (json['campus'] as String? ?? 'All') {
        'FU-HL' => 'Hòa Lạc',
        'FU-HCM' => 'TP. Hồ Chí Minh',
        'FU-DN' => 'Đà Nẵng',
        'FU-CT' => 'Cần Thơ',
        'FU-QN' => 'Quy Nhơn',
        _ => 'Tất cả cơ sở',
      },
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      maxAttendees: json['maxAttendees'] as int?,
      goingCount: json['goingCount'] as int? ?? 0,
      interestedCount: json['interestedCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      myStatus: json['myStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorAvatarUrl': creatorAvatarUrl,
      'title': title,
      'description': description,
      'bannerUrl': bannerUrl,
      'location': location,
      'campus': campus,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'maxAttendees': maxAttendees,
      'goingCount': goingCount,
      'interestedCount': interestedCount,
      'createdAt': createdAt.toIso8601String(),
      'myStatus': myStatus,
    };
  }
}
