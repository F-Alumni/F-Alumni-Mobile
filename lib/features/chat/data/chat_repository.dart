import 'dart:convert';

import 'package:alumni_connect/core/network/alumni_api.dart';
import 'package:alumni_connect/features/chat/data/models/chat_model.dart';
import 'package:signalr_netcore/signalr_client.dart';

class ChatRepository {
  ChatRepository(this.api);
  final AlumniApi api;
  HubConnection? _hub;
  String? _activeConversation;

  Future<String> _userId() async {
    final token = await api.tokens.accessToken;
    if (token == null) return '';
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(token.split('.')[1]))),
      ) as Map<String, dynamic>;
      return '${payload['sub'] ?? payload['nameid'] ?? payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ?? ''}';
    } catch (_) {
      return '';
    }
  }

  Future<List<ChatConversation>> loadConversations({
    bool includeHidden = true,
  }) async {
    final data = await api.chat.get(
      '/api/v1/chats/conversations',
      query: {
        'page': '1',
        'pageSize': '100',
        'includeHidden': '$includeHidden',
      },
    );
    final rows = data['items'] as List<dynamic>? ?? const [];
    final currentId = await _userId();
    return rows
        .map((row) => _conversation(row as Map<String, dynamic>, currentId))
        .toList();
  }

  Future<String> createConversation(String targetUserId) async {
    final data = await api.chat.post(
      '/api/v1/chats/conversations',
      body: {
        'targetUserId': targetUserId,
        'isGroup': false,
        'participantUserIds': <String>[],
      },
    );
    return '${data['id'] ?? ''}';
  }

  Future<String> get currentUserId => _userId();

  Future<List<DirectMessage>> loadMessages(
    String conversationId, {
    String? search,
  }) async {
    final data = await api.chat.get(
      '/api/v1/chats/conversations/$conversationId/messages',
      query: {
        'page': '1',
        'pageSize': '100',
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    final rows = data['items'] as List<dynamic>? ?? const [];
    return rows.map((row) => _message(row as Map<String, dynamic>)).toList();
  }

  Future<DirectMessage> sendMessage(
    String conversationId,
    String text, {
    String? attachmentUrl,
  }) async {
    final data = await api.chat.post(
      '/api/v1/chats/conversations/$conversationId/messages',
      body: {
        'content': text,
        if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
        if (attachmentUrl != null) 'attachmentType': 'Image',
      },
    );
    return _message(data);
  }

  Future<void> markRead(String conversationId) async {
    await api.chat.post('/api/v1/chats/conversations/$conversationId/read');
  }

  Future<void> updateSettings(
    String conversationId, {
    bool? muted,
    bool? hidden,
  }) async {
    await api.chat.put(
      '/api/v1/chats/conversations/$conversationId/settings',
      body: {
        if (muted != null) 'isMuted': muted,
        if (hidden != null) 'isHidden': hidden,
      },
    );
  }

  Future<void> connect(
    String conversationId, {
    required void Function(DirectMessage) onMessage,
    required void Function(String, bool) onTyping,
    required void Function(String readerUserId) onMessagesRead,
  }) async {
    await disconnect();
    _activeConversation = conversationId;
    final hubUrl = '${api.chat.baseUrl}/hubs/chat';
    final options = HttpConnectionOptions(
      accessTokenFactory: () async => await api.tokens.accessToken ?? '',
    );
    final hub = HubConnectionBuilder()
        .withUrl(hubUrl, options: options)
        .withAutomaticReconnect()
        .build();
    _hub = hub;
    hub.on('ReceiveMessage', (args) {
      if (args == null || args.isEmpty || args.first is! Map) return;
      onMessage(_message(Map<String, dynamic>.from(args.first as Map)));
    });
    hub.on('UserTyping', (args) {
      if (args == null || args.isEmpty || args.first is! Map) return;
      final value = Map<String, dynamic>.from(args.first as Map);
      onTyping('${value['userId'] ?? ''}', value['isTyping'] as bool? ?? false);
    });
    hub.on('MessagesRead', (args) {
      if (args == null || args.isEmpty || args.first is! Map) return;
      final value = Map<String, dynamic>.from(args.first as Map);
      onMessagesRead('${value['readerUserId'] ?? value['ReaderUserId'] ?? ''}');
    });
    await hub.start();
    await hub.invoke('JoinConversation', args: <Object>[conversationId]);
  }

  Future<void> sendTyping(bool isTyping) async {
    final hub = _hub;
    final id = _activeConversation;
    if (hub != null && id != null) {
      await hub.invoke('SendTypingIndicator', args: <Object>[id, isTyping]);
    }
  }

  Future<void> disconnect() async {
    final hub = _hub;
    _hub = null;
    _activeConversation = null;
    if (hub != null) await hub.stop();
  }

  ChatConversation _conversation(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    final id = '${json['id'] ?? ''}';
    final participants = json['participants'] as List<dynamic>? ?? const [];
    final users = participants
        .map((value) => value as Map<String, dynamic>)
        .toList();
    final peer =
        users
            .where((value) => '${value['userId']}' != currentUserId)
            .firstOrNull ??
        users.firstOrNull ??
        const <String, dynamic>{};
    final me =
        users
            .where((value) => '${value['userId']}' == currentUserId)
            .firstOrNull ??
        const <String, dynamic>{};
    final last = json['lastMessage'] as Map<String, dynamic>?;
    final sentAt = last?['sentAt'] ?? json['lastMessageAt'];
    final readAt = DateTime.tryParse('${me['lastReadAt'] ?? ''}');
    final lastSentAt = DateTime.tryParse('${sentAt ?? ''}');
    final hasUnreadPeerMessage =
        last != null &&
        '${last['senderUserId'] ?? ''}' != currentUserId &&
        lastSentAt != null &&
        (readAt == null || lastSentAt.isAfter(readAt));
    return ChatConversation(
      id: id,
      peerUserId: '${peer['userId'] ?? ''}',
      peerName: '${peer['displayName'] ?? json['title'] ?? ''}',
      peerRole: '${peer['status'] ?? ''}',
      peerAvatar: '${peer['avatarUrl'] ?? ''}',
      isOnline: false,
      isMentor: false,
      isMuted: me['isMuted'] as bool? ?? false,
      isHidden: me['isHidden'] as bool? ?? false,
      unreadCount: hasUnreadPeerMessage ? 1 : 0,
      lastMessage: '${last?['content'] ?? ''}'.isNotEmpty
          ? '${last?['content']}'
          : (last?['attachmentUrl'] != null ? '📷 Ảnh' : ''),
      lastMessageSenderId: '${last?['senderUserId'] ?? ''}',
      lastMessageTime: sentAt == null ? '' : _time(sentAt.toString()),
      lastMessageIsSeen: '${last?['status'] ?? ''}'.toLowerCase() == 'read',
      messages: const [],
    );
  }

  DirectMessage _message(Map<String, dynamic> json) => DirectMessage(
    id: '${json['id'] ?? ''}',
    senderId: '${json['senderUserId'] ?? ''}',
    content: '${json['content'] ?? ''}',
    timestamp: DateTime.tryParse('${json['sentAt'] ?? ''}') ?? DateTime.now(),
    isSeen: '${json['status'] ?? ''}'.toLowerCase() == 'read',
    imageUrl: json['attachmentUrl'] as String?,
  );

  String _time(String value) {
    final time = DateTime.tryParse(value)?.toLocal();
    if (time == null) return value;
    final diff = DateTime.now().difference(time);
    if (diff.inDays == 0)
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 1) return 'Hôm qua';
    return '${time.day}/${time.month}';
  }
}
