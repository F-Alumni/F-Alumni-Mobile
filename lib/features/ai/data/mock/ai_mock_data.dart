import 'package:alumni_connect/features/ai/data/models/ai_chat_model.dart';

class AiMockData {
  static const List<String> initialPrompts = [
    'Kinh nghiệm phỏng vấn OJT FPT Software?',
    'Lộ trình học Backend Golang cho sinh viên SE?',
    'Cách chọn đề tài Capstone đạt điểm cao?',
    'Làm thế nào để xin được Mentor Cựu SV?',
  ];

  static final List<ChatMessage> initialMessages = [
    ChatMessage(
      id: 'msg_welcome',
      content:
          'Xin chào Nguyễn Văn An! 👋\n\nMình là **Trợ lý AI Cựu sinh viên FPT** (Alumni AI). Mình được huấn luyện trên toàn bộ kho tri thức, bài chia sẻ kinh nghiệm học tập, phỏng vấn OJT và đồ án tốt nghiệp từ các anh chị cựu sinh viên FPTU qua các thời kỳ.\n\nBạn đang quan tâm đến chủ đề gì hôm nay?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      followUpQuestions: [
        'Kinh nghiệm chuẩn bị CV OJT kỳ Fall 2026',
        'Cách kết nối 1-1 với Mentor Tech Lead',
        'Top kỹ năng doanh nghiệp yêu cầu ở Fresher',
      ],
    ),
    ChatMessage(
      id: 'msg_sample_user',
      content: 'Chưa có chứng chỉ quốc tế AWS thì cơ hội pass OJT bên FPT Software thế nào?',
      isUser: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    ChatMessage(
      id: 'msg_sample_ai',
      content:
          'Theo đúc kết từ kinh nghiệm của các anh chị Alumni FPT Software:\n\n'
          '1. **Không bắt buộc:** Chứng chỉ AWS không phải là điều kiện tiên quyết đối với vòng tuyển chọn OJT/Fresher.\n\n'
          '2. **Điểm mấu chốt được đánh giá cao:** Nền tảng OOP vững chắc, tư duy cấu trúc dữ liệu, khả năng giải quyết vấn đề và đặc biệt là các dự án thực tế trong đồ án môn học (Capstone/Lab project).\n\n'
          '3. **Lợi thế sau khi vào dự án:** Chứng chỉ AWS sẽ là điểm cộng cực lớn giúp bạn được ưu tiên xếp vào các BU Cloud Engineering trọng điểm.',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      sources: const [
        CitationSource(
          title: 'Kinh nghiệm chuẩn bị CV & phỏng vấn xin việc OJT kỳ Fall 2026',
          author: 'Lê Thị Thu Thảo (Alumni K13 • Senior PM)',
          postId: 'post_thao',
          timeAgo: '2 giờ trước',
        ),
        CitationSource(
          title: 'Chia sẻ kinh nghiệm phỏng vấn Backend Developer',
          author: 'Trần Hoàng Long (Alumni K14 • Tech Lead)',
          postId: 'post_1',
          timeAgo: '4 giờ trước',
        ),
      ],
      followUpQuestions: [
        'Các câu hỏi phỏng vấn OOP thường gặp là gì?',
        'Làm sao để trình bày dự án môn học ấn tượng trên CV?',
        'Có nên thi chứng chỉ AWS Cloud Practitioner trước khi ra trường?',
      ],
    ),
  ];
}
