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
}
