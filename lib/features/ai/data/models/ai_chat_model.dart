class CitationSource {
  final String title;
  final String author;
  final String postId;
  final String timeAgo;
  final String snippet;

  const CitationSource({
    required this.title,
    required this.author,
    required this.postId,
    required this.timeAgo,
    this.snippet = '',
  });
}

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<CitationSource> sources; // AI-03 (Nguồn bài viết trích dẫn)
  final List<String> followUpQuestions; // AI-04 (Gợi ý câu hỏi tiếp theo)

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.sources = const [],
    this.followUpQuestions = const [],
  });
}
