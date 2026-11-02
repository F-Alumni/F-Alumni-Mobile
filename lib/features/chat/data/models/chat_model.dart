class DirectMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isSeen; // CH-05 (Seen checkmark)
  final String? imageUrl; // CH-07 (Image attachment)
  final String? meetLink; // Lịch hẹn Google Meet

  const DirectMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isSeen = true,
    this.imageUrl,
    this.meetLink,
  factory DirectMessage.fromJson(Map<String, dynamic> json) {
    return DirectMessage(
      id: json['id'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isSeen: json['isSeen'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
      meetLink: json['meetLink'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'isSeen': isSeen,
        'imageUrl': imageUrl,
        'meetLink': meetLink,
      };
}


class ChatConversation {
  final String id;
  final String peerName;
  final String peerRole;
  final String peerAvatar;
  final bool isOnline; // Online green dot
  final bool isMentor;
  final bool isPinned;
  final bool isMuted; // CH-09 (Mute notifications)
  final int unreadCount; // CH-10 & Unread badge
  final String lastMessage;
  final String lastMessageTime;
  final bool lastMessageIsSeen;
  final List<DirectMessage> messages;

  const ChatConversation({
    required this.id,
    required this.peerName,
    required this.peerRole,
    required this.peerAvatar,
    this.isOnline = true,
    this.isMentor = false,
    this.isPinned = false,
    this.isMuted = false,
    this.unreadCount = 0,
    required this.lastMessage,
    required this.lastMessageTime,
    this.lastMessageIsSeen = true,
    this.messages = const [],
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] as String? ?? '',
      peerName: json['peerName'] as String? ?? '',
      peerRole: json['peerRole'] as String? ?? '',
      peerAvatar: json['peerAvatar'] as String? ?? '',
      isOnline: json['isOnline'] as bool? ?? true,
      isMentor: json['isMentor'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      isMuted: json['isMuted'] as bool? ?? false,
      unreadCount: json['unreadCount'] as int? ?? 0,
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: json['lastMessageTime'] as String? ?? '',
      lastMessageIsSeen: json['lastMessageIsSeen'] as bool? ?? true,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => DirectMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'peerName': peerName,
        'peerRole': peerRole,
        'peerAvatar': peerAvatar,
        'isOnline': isOnline,
        'isMentor': isMentor,
        'isPinned': isPinned,
        'isMuted': isMuted,
        'unreadCount': unreadCount,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime,
        'lastMessageIsSeen': lastMessageIsSeen,
        'messages': messages.map((e) => e.toJson()).toList(),
      };

  ChatConversation copyWith({
    String? id,
    String? peerName,
    String? peerRole,
    String? peerAvatar,
    bool? isOnline,
    bool? isMentor,
    bool? isPinned,
    bool? isMuted,
    int? unreadCount,
    String? lastMessage,
    String? lastMessageTime,
    bool? lastMessageIsSeen,
    List<DirectMessage>? messages,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      peerName: peerName ?? this.peerName,
      peerRole: peerRole ?? this.peerRole,
      peerAvatar: peerAvatar ?? this.peerAvatar,
      isOnline: isOnline ?? this.isOnline,
      isMentor: isMentor ?? this.isMentor,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageIsSeen: lastMessageIsSeen ?? this.lastMessageIsSeen,
      messages: messages ?? this.messages,
    );
  }
}
