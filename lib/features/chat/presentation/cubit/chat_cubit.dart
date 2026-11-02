import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/features/chat/data/models/chat_model.dart';
import 'package:alumni_connect/features/chat/data/mock/chat_mock_data.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatConversation> conversations;
  final String selectedFilter;
  final String searchQuery;

  ChatLoaded({
    required this.conversations,
    this.selectedFilter = 'Tất cả',
    this.searchQuery = '',
  });

  int get totalUnreadCount {
    return conversations.fold(0, (sum, item) => sum + item.unreadCount);
  }

  List<ChatConversation> get filteredConversations {
    return conversations.where((conv) {
      final matchesFilter = selectedFilter == 'Tất cả' ||
          (selectedFilter == 'Mentor & Cố vấn' && conv.isMentor) ||
          (selectedFilter == 'Chưa đọc' && conv.unreadCount > 0);

      final matchesQuery = searchQuery.isEmpty ||
          conv.peerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          conv.peerRole.toLowerCase().contains(searchQuery.toLowerCase()) ||
          conv.lastMessage.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesFilter && matchesQuery;
    }).toList();
  }

  ChatLoaded copyWith({
    List<ChatConversation>? conversations,
    String? selectedFilter,
    String? searchQuery,
  }) {
    return ChatLoaded(
      conversations: conversations ?? this.conversations,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  void loadChats() {
    emit(ChatLoaded(conversations: List.from(ChatMockData.mockConversations)));
  }

  void filterChats(String filter) {
    if (state is ChatLoaded) {
      emit((state as ChatLoaded).copyWith(selectedFilter: filter));
    }
  }

  void searchChats(String query) {
    if (state is ChatLoaded) {
      emit((state as ChatLoaded).copyWith(searchQuery: query));
    }
  }

  void markAsRead(String conversationId) {
    if (state is ChatLoaded) {
      final current = state as ChatLoaded;
      final updated = current.conversations.map((c) {
        if (c.id == conversationId) {
          return c.copyWith(unreadCount: 0, lastMessageIsSeen: true);
        }
        return c;
      }).toList();
      emit(current.copyWith(conversations: updated));
    }
  }

  void sendMessage(String conversationId, String text, {String? imageUrl}) {
    if (state is ChatLoaded) {
      final current = state as ChatLoaded;
      final newMsg = DirectMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'user_an',
        content: text,
        timestamp: DateTime.now(),
        isSeen: true,
        imageUrl: imageUrl,
      );

      final updated = current.conversations.map((c) {
        if (c.id == conversationId) {
          return c.copyWith(
            lastMessage: text,
            lastMessageTime: 'Vừa xong',
            lastMessageIsSeen: true,
            messages: [...c.messages, newMsg],
          );
        }
        return c;
      }).toList();

      emit(current.copyWith(conversations: updated));
    }
  }
}
