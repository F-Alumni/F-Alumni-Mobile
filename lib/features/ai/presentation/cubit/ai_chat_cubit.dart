import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/features/ai/data/models/ai_chat_model.dart';
import 'package:alumni_connect/features/ai/data/mock/ai_mock_data.dart';

abstract class AiChatState {}

class AiChatInitial extends AiChatState {}

class AiChatLoaded extends AiChatState {
  final List<ChatMessage> messages;
  final bool isGenerating;

  AiChatLoaded({
    required this.messages,
    this.isGenerating = false,
  });

  AiChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isGenerating,
  }) {
    return AiChatLoaded(
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }
}

class AiChatCubit extends Cubit<AiChatState> {
  AiChatCubit() : super(AiChatInitial());

  void loadChat() {
    emit(AiChatLoaded(messages: List.from(AiMockData.initialMessages)));
  }

  void sendMessage(String query) async {
    if (state is! AiChatLoaded) return;
    final currentState = state as AiChatLoaded;

    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      content: query,
      isUser: true,
      timestamp: DateTime.now(),
    );

    emit(currentState.copyWith(
      messages: [...currentState.messages, userMsg],
      isGenerating: true,
    ));

    // Simulate AI inference and RAG retrieval
    await Future.delayed(const Duration(milliseconds: 1200));

    final aiReply = ChatMessage(
      id: 'msg_ai_${DateTime.now().millisecondsSinceEpoch}',
      content:
          'Dựa trên thông tin tổng hợp từ các bài viết thảo luận của Cựu sinh viên FPT về "$query":\n\n'
          '• **Lời khuyên thực tiễn:** Bạn nên chủ động rèn luyện tư duy tự giải quyết vấn đề, chuẩn bị sẵn portfolio/GitHub rõ ràng và thể hiện thái độ cầu thị, tích cực trong buổi phỏng vấn.\n\n'
          '• **Gợi ý kết nối:** Bạn có thể tham khảo thêm các buổi Mentoring 1-1 tại mục "Kết nối" để được các anh chị Tech Leads trực tiếp mock interview.',
      isUser: false,
      timestamp: DateTime.now(),
      sources: const [
        CitationSource(
          title: 'Kinh nghiệm chuẩn bị CV & phỏng vấn xin việc OJT kỳ Fall 2026',
          author: 'Lê Thị Thu Thảo (Alumni K13)',
          postId: 'post_thao',
          timeAgo: '2 giờ trước',
        ),
      ],
      followUpQuestions: [
        'Làm thế nào để đặt lịch Mock Interview với Mentor?',
        'Có những câu hỏi phỏng vấn kỹ thuật phổ biến nào?',
      ],
    );

    if (state is AiChatLoaded) {
      final updatedState = state as AiChatLoaded;
      emit(updatedState.copyWith(
        messages: [...updatedState.messages, aiReply],
        isGenerating: false,
      ));
    }
  }

  void clearChat() {
    emit(AiChatLoaded(messages: [AiMockData.initialMessages.first]));
  }
}
