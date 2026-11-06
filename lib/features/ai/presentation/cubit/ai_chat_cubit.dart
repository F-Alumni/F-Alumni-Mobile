import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/features/ai/data/ai_repository.dart';
import 'package:alumni_connect/features/ai/data/models/ai_chat_model.dart';

abstract class AiChatState {}

class AiChatInitial extends AiChatState {}

class AiChatLoaded extends AiChatState {
  AiChatLoaded({required this.messages, this.isGenerating = false});
  final List<ChatMessage> messages;
  final bool isGenerating;
  AiChatLoaded copyWith({List<ChatMessage>? messages, bool? isGenerating}) =>
      AiChatLoaded(
        messages: messages ?? this.messages,
        isGenerating: isGenerating ?? this.isGenerating,
      );
}

class AiChatCubit extends Cubit<AiChatState> {
  AiChatCubit(this._repository) : super(AiChatLoaded(messages: const []));
  final AiRepository _repository;
  String? _conversationId;

  void loadChat() => emit(AiChatLoaded(messages: const []));

  Future<List<Map<String, dynamic>>> loadConversations() =>
      _repository.loadConversations();

  Future<void> openConversation(String id) async {
    final history = await _repository.loadConversation(id);
    _conversationId = id;
    emit(AiChatLoaded(messages: _repository.parseHistory(history)));
  }

  Future<void> sendMessage(String query) async {
    final current = state;
    if (current is! AiChatLoaded ||
        query.trim().isEmpty ||
        current.isGenerating)
      return;
    final userMessage = ChatMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      content: query.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    emit(
      current.copyWith(
        messages: [...current.messages, userMessage],
        isGenerating: true,
      ),
    );
    try {
      final result = await _repository.ask(
        query.trim(),
        conversationId: _conversationId,
      );
      _conversationId = result.conversationId;
      final latest = state as AiChatLoaded;
      emit(
        latest.copyWith(
          messages: [...latest.messages, result.message],
          isGenerating: false,
        ),
      );
    } catch (error) {
      final latest = state as AiChatLoaded;
      emit(
        latest.copyWith(
          messages: [
            ...latest.messages,
            ChatMessage(
              id: 'error-${DateTime.now().microsecondsSinceEpoch}',
              content: 'Không thể kết nối AI service: $error',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          ],
          isGenerating: false,
        ),
      );
    }
  }

  void clearChat() {
    _conversationId = null;
    emit(AiChatLoaded(messages: const []));
  }
}
