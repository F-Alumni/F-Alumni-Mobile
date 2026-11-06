import 'package:alumni_connect/core/network/alumni_api.dart';
import 'package:alumni_connect/features/ai/data/models/ai_chat_model.dart';
import 'package:alumni_connect/features/directory/data/models/alumni_model.dart';

class AiRepository {
  AiRepository(this.api);
  final AlumniApi api;

  Future<List<Map<String, dynamic>>> loadConversations() async =>
      (await api.ai.getList('/api/v1/ai/conversations'))
          .map((row) => row as Map<String, dynamic>)
          .toList();

  Future<Map<String, dynamic>> loadConversation(String id) =>
      api.ai.get('/api/v1/ai/conversations/$id');

  ChatMessage _messageFromHistory(Map<String, dynamic> value) {
    final citations = (value['citations'] as List<dynamic>? ?? const [])
        .map((row) => row as Map<String, dynamic>)
        .map(
          (row) => CitationSource(
            title: '${row['sourceTitle'] ?? ''}',
            author: '${row['section'] ?? row['programCode'] ?? ''}',
            postId: '',
            timeAgo: '',
          ),
        )
        .toList();
    return ChatMessage(
      id: '${value['id'] ?? ''}',
      content: '${value['content'] ?? ''}',
      isUser: '${value['role'] ?? ''}'.toLowerCase() == 'user',
      timestamp:
          DateTime.tryParse('${value['createdAt'] ?? ''}') ?? DateTime.now(),
      sources: citations,
    );
  }

  List<ChatMessage> parseHistory(Map<String, dynamic> data) =>
      (data['messages'] as List<dynamic>? ?? const [])
          .map((row) => _messageFromHistory(row as Map<String, dynamic>))
          .toList();

  Future<({String conversationId, ChatMessage message})> ask(
    String question, {
    String? conversationId,
  }) async {
    final result = await api.ai.post(
      '/api/v1/ai/chat',
      body: {
        'question': question,
        if (conversationId != null) 'conversationId': conversationId,
        'campus': 'All',
        'major': 'All',
      },
    );
    final citations = (result['citations'] as List<dynamic>? ?? const [])
        .map((value) => value as Map<String, dynamic>)
        .map(
          (value) => CitationSource(
            title: '${value['sourceTitle'] ?? ''}',
            author: '${value['section'] ?? value['programCode'] ?? ''}',
            postId: '',
            timeAgo: '',
          ),
        )
        .toList();
    return (
      conversationId: '${result['conversationId'] ?? ''}',
      message: ChatMessage(
        id: '${result['conversationId'] ?? DateTime.now().microsecondsSinceEpoch}',
        content: '${result['answer'] ?? ''}',
        isUser: false,
        timestamp:
            DateTime.tryParse('${result['createdAt'] ?? ''}') ?? DateTime.now(),
        sources: citations,
      ),
    );
  }

  Future<List<AlumniModel>> recommendMentors({String major = 'SE'}) async {
    final rows = await api.ai.postList(
      '/api/v1/ai/mentors/recommend',
      body: {'major': major, 'targetSkills': <String>[], 'careerGoal': null},
    );
    return rows.map((row) {
      final mentor = row as Map<String, dynamic>;
      final skills = '${mentor['skills'] ?? ''}'
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList();
      return AlumniModel(
        id: '${mentor['userId'] ?? mentor['id'] ?? ''}',
        name: '${mentor['fullName'] ?? ''}',
        mssv: '',
        cohort: '',
        major: '${mentor['major'] ?? major}',
        campus: '',
        currentRole: '${mentor['jobTitle'] ?? ''}',
        company: '${mentor['currentCompany'] ?? ''}',
        avatarUrl: '${mentor['avatarUrl'] ?? ''}',
        isVerified: true,
        isAvailableForMentoring: true,
        rating: (mentor['matchScore'] as num?)?.toDouble() ?? 0,
        reviewsCount: 0,
        completedSessions: 0,
        skills: skills,
        bio: '${mentor['bio'] ?? ''}',
      );
    }).toList();
  }
}
