class MentorStory {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final bool isOnline;
  final bool isUser;

  const MentorStory({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    this.isOnline = true,
    this.isUser = false,
  });
}

class CommentItem {
  final String id;
  final String authorName;
  final String authorRole;
  final String authorAvatar;
  final String timeAgo;
  final String content;
  final int likes;
  final bool isLiked;
  final bool isAuthor;
  final List<CommentItem> replies;

  const CommentItem({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.authorAvatar,
    required this.timeAgo,
    required this.content,
    this.likes = 0,
    this.isLiked = false,
    this.isAuthor = false,
    this.replies = const [],
  });

  factory CommentItem.fromJson(Map<String, dynamic> json) {
    return CommentItem(
      id: json['id'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '',
      authorRole: json['authorRole'] as String? ?? '',
      authorAvatar: json['authorAvatar'] as String? ?? '',
      timeAgo: json['timeAgo'] as String? ?? '',
      content: json['content'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isAuthor: json['isAuthor'] as bool? ?? false,
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => CommentItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorName': authorName,
        'authorRole': authorRole,
        'authorAvatar': authorAvatar,
        'timeAgo': timeAgo,
        'content': content,
        'likes': likes,
        'isLiked': isLiked,
        'isAuthor': isAuthor,
        'replies': replies.map((e) => e.toJson()).toList(),
      };

    String? id,
    String? authorName,
    String? authorRole,
    String? authorAvatar,
    String? timeAgo,
    String? content,
    int? likes,
    bool? isLiked,
    bool? isAuthor,
    List<CommentItem>? replies,
  }) {
    return CommentItem(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      timeAgo: timeAgo ?? this.timeAgo,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      isAuthor: isAuthor ?? this.isAuthor,
      replies: replies ?? this.replies,
    );
  }
}

class PostItem {
  final String id;
  final String authorName;
  final String authorRole;
  final String authorAvatar;
  final String timeAgo;
  final bool isVerified;
  final String title;
  final String content;
  final String? attachmentTitle;
  final String? attachmentSubtitle;
  final String? attachmentImageUrl;
  final String campus;
  final String category;
  final List<String> tags;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final bool isSaved;
  final bool isJobPost;
  final String? jobTitle;
  final String? jobSalary;
  final String? jobPerks;
  final String? companyName;
  final List<CommentItem> commentList;

  const PostItem({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.authorAvatar,
    required this.timeAgo,
    this.isVerified = true,
    this.title = '',
    required this.content,
    this.attachmentTitle,
    this.attachmentSubtitle,
    this.attachmentImageUrl,
    this.campus = 'Toàn quốc',
    this.category = 'Chia sẻ kinh nghiệm',
    required this.tags,
    required this.likes,
    required this.comments,
    required this.shares,
    this.isLiked = false,
    this.isSaved = false,
    this.isJobPost = false,
    this.jobTitle,
    this.jobSalary,
    this.jobPerks,
    this.companyName,
    this.commentList = const [],
  });

  factory PostItem.fromJson(Map<String, dynamic> json) {
    return PostItem(
      id: json['id'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '',
      authorRole: json['authorRole'] as String? ?? '',
      authorAvatar: json['authorAvatar'] as String? ?? '',
      timeAgo: json['timeAgo'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? true,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      attachmentTitle: json['attachmentTitle'] as String?,
      attachmentSubtitle: json['attachmentSubtitle'] as String?,
      attachmentImageUrl: json['attachmentImageUrl'] as String?,
      campus: json['campus'] as String? ?? 'Toàn quốc',
      category: json['category'] as String? ?? 'Chia sẻ kinh nghiệm',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
      isJobPost: json['isJobPost'] as bool? ?? false,
      jobTitle: json['jobTitle'] as String?,
      jobSalary: json['jobSalary'] as String?,
      jobPerks: json['jobPerks'] as String?,
      companyName: json['companyName'] as String?,
      commentList: (json['commentList'] as List<dynamic>?)
              ?.map((e) => CommentItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorName': authorName,
        'authorRole': authorRole,
        'authorAvatar': authorAvatar,
        'timeAgo': timeAgo,
        'isVerified': isVerified,
        'title': title,
        'content': content,
        'attachmentTitle': attachmentTitle,
        'attachmentSubtitle': attachmentSubtitle,
        'attachmentImageUrl': attachmentImageUrl,
        'campus': campus,
        'category': category,
        'tags': tags,
        'likes': likes,
        'comments': comments,
        'shares': shares,
        'isLiked': isLiked,
        'isSaved': isSaved,
        'isJobPost': isJobPost,
        'jobTitle': jobTitle,
        'jobSalary': jobSalary,
        'jobPerks': jobPerks,
        'companyName': companyName,
        'commentList': commentList.map((e) => e.toJson()).toList(),
      };

  PostItem copyWith({
    String? id,
    String? authorName,
    String? authorRole,
    String? authorAvatar,
    String? timeAgo,
    bool? isVerified,
    String? title,
    String? content,
    String? attachmentTitle,
    String? attachmentSubtitle,
    String? attachmentImageUrl,
    String? campus,
    String? category,
    List<String>? tags,
    int? likes,
    int? comments,
    int? shares,
    bool? isLiked,
    bool? isSaved,
    bool? isJobPost,
    String? jobTitle,
    String? jobSalary,
    String? jobPerks,
    String? companyName,
    List<CommentItem>? commentList,
  }) {
    return PostItem(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      timeAgo: timeAgo ?? this.timeAgo,
      isVerified: isVerified ?? this.isVerified,
      title: title ?? this.title,
      content: content ?? this.content,
      attachmentTitle: attachmentTitle ?? this.attachmentTitle,
      attachmentSubtitle: attachmentSubtitle ?? this.attachmentSubtitle,
      attachmentImageUrl: attachmentImageUrl ?? this.attachmentImageUrl,
      campus: campus ?? this.campus,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      isJobPost: isJobPost ?? this.isJobPost,
      jobTitle: jobTitle ?? this.jobTitle,
      jobSalary: jobSalary ?? this.jobSalary,
      jobPerks: jobPerks ?? this.jobPerks,
      companyName: companyName ?? this.companyName,
      commentList: commentList ?? this.commentList,
    );
  }
}
