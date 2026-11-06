enum NotificationType { chat, mentorship, social, job, system }

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? actorName;
  final String? actorAvatar;
  final String? actionUrl;
  final String? actionLabel;
  final String? secondaryActionLabel;
  final String? tag;
  final String? evidenceThumbnail;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.actorName,
    this.actorAvatar,
    this.actionUrl,
    this.actionLabel,
    this.secondaryActionLabel,
    this.tag,
    this.evidenceThumbnail,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      actorName: actorName,
      actorAvatar: actorAvatar,
      actionUrl: actionUrl,
      actionLabel: actionLabel,
      secondaryActionLabel: secondaryActionLabel,
      tag: tag,
      evidenceThumbnail: evidenceThumbnail,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type.name,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
    'actorName': actorName,
    'actorAvatar': actorAvatar,
    'actionUrl': actionUrl,
    'actionLabel': actionLabel,
    'secondaryActionLabel': secondaryActionLabel,
    'tag': tag,
    'evidenceThumbnail': evidenceThumbnail,
  };

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String?;
    return NotificationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: NotificationType.values.firstWhere(
        (value) => value.name == typeName,
        orElse: () => NotificationType.system,
      ),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      actorName: json['actorName'] as String?,
      actorAvatar: json['actorAvatar'] as String?,
      actionUrl: json['actionUrl'] as String?,
      actionLabel: json['actionLabel'] as String?,
      secondaryActionLabel: json['secondaryActionLabel'] as String?,
      tag: json['tag'] as String?,
      evidenceThumbnail: json['evidenceThumbnail'] as String?,
    );
  }
}
