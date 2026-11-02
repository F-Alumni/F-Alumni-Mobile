import 'package:alumni_connect/core/network/alumni_api.dart';
import 'package:alumni_connect/features/feed/data/models/feed_models.dart';

class FeedPage {
  const FeedPage(this.items, this.totalCount, this.pageNumber, this.pageSize);
  final List<PostItem> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
}

class FeedRepository {
  FeedRepository(this.api);
  final AlumniApi api;

  Future<FeedPage> getFeed({
    int page = 1,
    String? search,
    String? campus,
    String? major,
    String? postType,
    bool? isAnswered,
    String sort = 'latest',
  }) async {
    final query = <String, String>{
      'page': '$page',
      'pageSize': '20',
      'sort': sort,
    };
    if (search?.trim().isNotEmpty == true) query['search'] = search!.trim();
    if (campus != null && campus != 'All') query['campus'] = campus;
    if (major != null && major != 'All') query['major'] = major;
    if (postType != null) query['postType'] = postType;
    if (isAnswered != null) query['isAnswered'] = '$isAnswered';
    return _page(await api.forum.get('/api/v1/posts', query: query));
  }

  Future<FeedPage> getMyPosts({int page = 1}) async => _page(
    await api.forum.get(
      '/api/v1/posts/me',
      query: {'page': '$page', 'pageSize': '20'},
    ),
  );

  Future<FeedPage> getBookmarks({int page = 1}) async => _page(
    await api.forum.get(
      '/api/v1/bookmarks/me',
      query: {'page': '$page', 'pageSize': '20'},
    ),
  );

  Future<PostItem> getPost(String id) async =>
      _post(await api.forum.get('/api/v1/posts/$id'));

  Future<PostItem> createPost({
    required String title,
    required String content,
    required String postType,
    required String campus,
    required String major,
    List<String> tags = const [],
    List<String> imageUrls = const [],
  }) async => _post(
    await api.forum.post(
      '/api/v1/posts',
      body: {
        'title': title,
        'content': content,
        'postType': postType,
        'campus': campus,
        'major': major,
        'tags': tags,
        'imageUrls': imageUrls,
      },
    ),
  );

  Future<PostItem> updatePost({
    required String id,
    required String title,
    required String content,
    required String postType,
    required String campus,
    required String major,
    List<String> tags = const [],
    List<String> imageUrls = const [],
  }) async => _post(
    await api.forum.put(
      '/api/v1/posts/$id',
      body: {
        'title': title,
        'content': content,
        'postType': postType,
        'campus': campus,
        'major': major,
        'tags': tags,
        'imageUrls': imageUrls,
      },
    ),
  );

  Future<void> markAnswered(String postId, bool answered) async {
    await api.forum.patch(
      '/api/v1/posts/$postId/answered',
      query: {'isAnswered': '$answered'},
    );
  }

  Future<void> acceptAnswer(String commentId) async {
    await api.forum.post('/api/v1/comments/$commentId/accept');
  }

  Future<void> deletePost(String id) => api.forum.delete('/api/v1/posts/$id');

  Future<bool> toggleLike(String id) async =>
      (await api.forum.post('/api/v1/posts/$id/react'))['isLiked'] as bool? ??
      false;

  Future<bool> toggleBookmark(String id) async =>
      (await api.forum.post('/api/v1/posts/$id/bookmark'))['isBookmarked']
          as bool? ??
      false;

  Future<List<CommentItem>> getComments(String postId) async =>
      (await api.forum.getList('/api/v1/posts/$postId/comments'))
          .whereType<Map<String, dynamic>>()
          .map(_comment)
          .toList();

  Future<CommentItem> addComment(
    String postId,
    String content, {
    String? parentCommentId,
  }) async => _comment(
    await api.forum.post(
      '/api/v1/posts/$postId/comments',
      body: {
        'content': content,
        if (parentCommentId != null) 'parentCommentId': parentCommentId,
      },
    ),
  );

  Future<void> updateComment(String id, String content) async {
    await api.forum.put('/api/v1/comments/$id', body: {'content': content});
  }

  Future<void> deleteComment(String id) =>
      api.forum.delete('/api/v1/comments/$id');

  Future<void> report({
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
  }) async {
    await api.forum.post(
      '/api/v1/reports',
      body: {
        'targetType': targetType,
        'targetId': targetId,
        'reason': reason,
        'details': details,
      },
    );
  }

  FeedPage _page(Map<String, dynamic> json) {
    final rows = (json['items'] as List<dynamic>? ?? const []);
    return FeedPage(
      rows.whereType<Map<String, dynamic>>().map(_post).toList(),
      json['totalCount'] as int? ?? rows.length,
      json['pageNumber'] as int? ?? 1,
      json['pageSize'] as int? ?? rows.length,
    );
  }

  PostItem _post(Map<String, dynamic> j) {
    final images = (j['images'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();
    final type = (j['postType'] as String? ?? 'Sharing');
    final campus = (j['campus'] as String? ?? 'All');
    return PostItem(
      id: '${j['id'] ?? ''}',
      authorName: j['authorName'] as String? ?? 'FPT Alumni',
      authorRole: '',
      authorAvatar: j['authorAvatarUrl'] as String? ?? '',
      timeAgo: _time(j['createdAt'] as String?),
      title: j['title'] as String? ?? '',
      content: j['content'] as String? ?? '',
      attachmentImageUrl: images.isEmpty ? null : images.first,
      attachmentImageUrls: images,
      campus: _campusLabel(campus),
      major: j['major'] as String? ?? 'All',
      category: _typeLabel(type),
      tags: (j['tags'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      likes: j['likeCount'] as int? ?? 0,
      comments: j['commentCount'] as int? ?? 0,
      shares: 0,
      isLiked: j['hasLiked'] as bool? ?? false,
      isSaved: j['isBookmarked'] as bool? ?? false,
      isAnswered: j['isAnswered'] as bool? ?? false,
      commentList: (j['comments'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_comment)
          .toList(),
    );
  }

  CommentItem _comment(Map<String, dynamic> j) => CommentItem(
    id: '${j['id'] ?? ''}',
    authorId: '${j['authorId'] ?? ''}',
    authorName: j['authorName'] as String? ?? '',
    authorRole: '',
    authorAvatar: j['authorAvatarUrl'] as String? ?? '',
    timeAgo: _time(j['createdAt'] as String?),
    content: j['content'] as String? ?? '',
    isAcceptedAnswer: j['isAcceptedAnswer'] as bool? ?? false,
    replies: (j['replies'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_comment)
        .toList(),
  );

  String _typeLabel(String value) => switch (value.toLowerCase()) {
    'question' => 'Hỏi đáp & Thảo luận',
    'recruitment' => 'Cơ hội việc làm / Thực tập',
    _ => 'Chia sẻ kinh nghiệm',
  };
  String _campusLabel(String value) => switch (value) {
    'FU-HCM' => 'FPT TP.HCM',
    'FU-HL' => 'FPT Hòa Lạc',
    'FU-DN' => 'FPT Đà Nẵng',
    'FU-CT' => 'FPT Cần Thơ',
    'FU-QN' => 'FPT Quy Nhơn',
    _ => 'Toàn quốc',
  };
  String _time(String? value) {
    final date = DateTime.tryParse(value ?? '')?.toLocal();
    if (date == null) return '';
    final elapsed = DateTime.now().difference(date);
    if (elapsed.inMinutes < 1) return 'Vừa xong';
    if (elapsed.inHours < 1) return '${elapsed.inMinutes} phút trước';
    if (elapsed.inDays < 1) return '${elapsed.inHours} giờ trước';
    return '${elapsed.inDays} ngày trước';
  }
}
