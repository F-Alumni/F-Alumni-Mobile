class EventAttendeeModel {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String status; // 'Going', 'Interested', 'NotGoing'
  final DateTime registeredAt;

  const EventAttendeeModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.status,
    required this.registeredAt,
  });

  factory EventAttendeeModel.fromJson(Map<String, dynamic> json) {
    return EventAttendeeModel(
      id: json['id'] as String? ?? '',
      eventId: json['eventId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Thành viên FPT',
      userAvatarUrl: json['userAvatarUrl'] as String? ?? '',
      status: json['status'] as String? ?? 'Going',
      registeredAt: json['registeredAt'] != null
          ? DateTime.tryParse(json['registeredAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'status': status,
      'registeredAt': registeredAt.toIso8601String(),
    };
  }
}
