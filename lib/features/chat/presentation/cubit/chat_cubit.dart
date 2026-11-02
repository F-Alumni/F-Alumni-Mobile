import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/features/chat/data/chat_repository.dart';
import 'package:alumni_connect/features/chat/data/models/chat_model.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatError extends ChatState {
  ChatError(this.message);
  final String message;
}

class ChatLoaded extends ChatState {
  ChatLoaded({
    required this.conversations,
    this.selectedFilter = 'Tất cả',
    this.searchQuery = '',
    this.isPeerTyping = false,
  });
  final List<ChatConversation> conversations;
  final String selectedFilter;
  final String searchQuery;
  final bool isPeerTyping;

  int get totalUnreadCount =>
      conversations.fold(0, (sum, item) => sum + item.unreadCount);
  List<ChatConversation> get filteredConversations =>
      conversations.where((conv) {
        final matchesFilter = selectedFilter == 'Đã ẩn'
            ? conv.isHidden
            : !conv.isHidden &&
                  (selectedFilter == 'Tất cả' ||
                      (selectedFilter == 'Mentor & Cố vấn' && conv.isMentor) ||
                      (selectedFilter == 'Chưa đọc' && conv.unreadCount > 0));
        final matchesQuery =
            searchQuery.isEmpty ||
            conv.peerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            conv.peerRole.toLowerCase().contains(searchQuery.toLowerCase()) ||
            conv.lastMessage.toLowerCase().contains(searchQuery.toLowerCase());
        return matchesFilter && matchesQuery;
      }).toList();

  ChatLoaded copyWith({
    List<ChatConversation>? conversations,
    String? selectedFilter,
    String? searchQuery,
    bool? isPeerTyping,
  }) => ChatLoaded(
    conversations: conversations ?? this.conversations,
    selectedFilter: selectedFilter ?? this.selectedFilter,
    searchQuery: searchQuery ?? this.searchQuery,
    isPeerTyping: isPeerTyping ?? this.isPeerTyping,
  );
}

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._repository) : super(ChatInitial());
  final ChatRepository _repository;

  Future<void> loadChats() async {
    emit(ChatLoading());
    try {
      emit(
        ChatLoaded(
          conversations: await _repository.loadConversations(
            includeHidden: true,
          ),
        ),
      );
    } catch (error) {
      emit(ChatError(error.toString()));
    }
  }

  Future<String> createConversation(String targetUserId) async {
    final id = await _repository.createConversation(targetUserId);
    await loadChats();
    return id;
  }

  Future<void> loadMessages(String conversationId, {String? search}) async {
    try {
      final messages = await _repository.loadMessages(
        conversationId,
        search: search,
      );
      _updateConversation(
        conversationId,
        (conversation) => conversation.copyWith(messages: messages),
      );
    } catch (error) {
      emit(ChatError(error.toString()));
    }
  }

  Future<void> connectToConversation(String conversationId) async {
    try {
      final currentUserId = await _repository.currentUserId;
      await _repository.connect(
        conversationId,
        onMessage: (message) {
          final current = state;
          if (current is! ChatLoaded) return;
          _updateConversation(
            conversationId,
            (conversation) => conversation.copyWith(
              messages: [
                ...conversation.messages.where((item) => item.id != message.id),
                message,
              ],
              lastMessage: message.content.isNotEmpty
                  ? message.content
                  : (message.imageUrl != null ? '📷 Ảnh' : ''),
              lastMessageSenderId: message.senderId,
              lastMessageTime: 'Vừa xong',
            ),
          );
        },
        onTyping: (userId, isTyping) {
          if (userId ==
              (state is ChatLoaded ? _findPeerUserId(conversationId) : null)) {
            _setTyping(isTyping);
          }
        },
        onMessagesRead: (readerUserId) {
          if (readerUserId.isEmpty || readerUserId == currentUserId) return;
          _updateConversation(conversationId, (conversation) {
            final messages = conversation.messages
                .map(
                  (message) => message.senderId == currentUserId
                      ? message.copyWith(isSeen: true)
                      : message,
                )
                .toList();
            return conversation.copyWith(
              messages: messages,
              lastMessageIsSeen:
                  conversation.lastMessageSenderId == currentUserId
                  ? true
                  : conversation.lastMessageIsSeen,
            );
          });
        },
      );
    } catch (error) {
      // Keep REST chat usable when SignalR is unavailable.
    }
  }

  Future<void> disconnectFromConversation() async {
    await _repository.disconnect();
    _setTyping(false);
  }

  Future<void> sendTyping(bool value) => _repository.sendTyping(value);

  Future<void> filterChats(String filter) async {
    final current = state;
    if (current is ChatLoaded) emit(current.copyWith(selectedFilter: filter));
  }

  Future<void> searchChats(String query) async {
    final current = state;
    if (current is ChatLoaded) emit(current.copyWith(searchQuery: query));
  }

  Future<void> markAsRead(String conversationId) async {
    try {
      await _repository.markRead(conversationId);
    } catch (_) {}
    _updateConversation(
      conversationId,
      (conversation) => conversation.copyWith(unreadCount: 0),
    );
  }

  Future<bool> toggleHidden(String conversationId) async {
    final current = state;
    if (current is! ChatLoaded) return false;
    ChatConversation? conversation;
    for (final item in current.conversations) {
      if (item.id == conversationId) conversation = item;
    }
    if (conversation == null) return false;
    final wasHidden = conversation.isHidden;
    final hidden = !wasHidden;
    _updateConversation(
      conversationId,
      (item) => item.copyWith(isHidden: hidden),
    );
    try {
      await _repository.updateSettings(conversationId, hidden: hidden);
      return true;
    } catch (error) {
      _updateConversation(
        conversationId,
        (item) => item.copyWith(isHidden: wasHidden),
      );
      emit(ChatError(error.toString()));
      return false;
    }
  }

  Future<void> toggleMute(String conversationId) async {
    final current = state;
    if (current is! ChatLoaded) return;
    ChatConversation? conversation;
    for (final item in current.conversations) {
      if (item.id == conversationId) conversation = item;
    }
    if (conversation == null) return;
    final muted = !conversation.isMuted;
    try {
      await _repository.updateSettings(conversationId, muted: muted);
      _updateConversation(
        conversationId,
        (item) => item.copyWith(isMuted: muted),
      );
    } catch (error) {
      emit(ChatError(error.toString()));
    }
  }

  Future<void> sendMessage(
    String conversationId,
    String text, {
    String? imageUrl,
  }) async {
    final current = state;
    if (current is! ChatLoaded) return;
    try {
      final message = await _repository.sendMessage(
        conversationId,
        text,
        attachmentUrl: imageUrl,
      );
      _updateConversation(
        conversationId,
        (conversation) => conversation.copyWith(
          lastMessage: text.isNotEmpty ? text : '📷 Ảnh',
          lastMessageSenderId: message.senderId,
          lastMessageTime: 'Vừa xong',
          lastMessageIsSeen: false,
          messages: [
            ...conversation.messages.where((item) => item.id != message.id),
            message,
          ],
        ),
      );
    } catch (error) {
      emit(ChatError(error.toString()));
    }
  }

  String? _findPeerUserId(String id) {
    final current = state;
    if (current is! ChatLoaded) return null;
    for (final conv in current.conversations) {
      if (conv.id == id) return conv.peerUserId;
    }
    return null;
  }

  void _setTyping(bool value) {
    final current = state;
    if (current is ChatLoaded) emit(current.copyWith(isPeerTyping: value));
  }

  void _updateConversation(
    String id,
    ChatConversation Function(ChatConversation) update,
  ) {
    final current = state;
    if (current is! ChatLoaded) return;
    emit(
      current.copyWith(
        conversations: current.conversations
            .map((conv) => conv.id == id ? update(conv) : conv)
            .toList(),
      ),
    );
  }
}
