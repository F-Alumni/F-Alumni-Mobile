import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:alumni_connect/features/feed/data/feed_repository.dart';
import 'package:alumni_connect/features/feed/data/models/feed_models.dart';
import 'package:alumni_connect/features/auth/presentation/cubit/auth_cubit.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.postId});
  final String postId;
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late final FeedRepository _repository;
  final _commentController = TextEditingController();
  PostItem? _post;
  List<CommentItem> _comments = const [];
  Object? _error;
  bool _loading = true;
  bool _sending = false;
  CommentItem? _replyTo;

  @override
  void initState() {
    super.initState();
    _repository = context.read<FeedCubit>().repository;
    _initialLoad();
    unawaited(
      _repository.watchPost(
        widget.postId,
        onNewComment: (_) => _refreshSilently(),
        onReaction: (postId, _) {
          if (postId == widget.postId) _refreshSilently();
        },
      ),
    );
  }

  Future<void> _initialLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait<Object>([
        _repository.getPost(widget.postId),
        _repository.getComments(widget.postId),
      ]);
      if (!mounted) return;
      setState(() {
        _post = results[0] as PostItem;
        _comments = results[1] as List<CommentItem>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _refreshSilently() async {
    try {
      final results = await Future.wait<Object>([
        _repository.getPost(widget.postId),
        _repository.getComments(widget.postId),
      ]);
      if (!mounted) return;
      setState(() {
        _post = results[0] as PostItem;
        _comments = results[1] as List<CommentItem>;
      });
    } catch (_) {}
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    setState(() => _sending = true);
    try {
      await _repository.addComment(
        widget.postId,
        content,
        parentCommentId: _replyTo?.id,
      );
      _commentController.clear();
      setState(() => _replyTo = null);
      await _refreshSilently();
      if (mounted) {
        unawaited(context.read<FeedCubit>().loadFeed());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không gửi được bình luận: $e')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _reportPost({
    String targetType = 'Post',
    String? targetId,
  }) async {
    final reasons = [
      'Spam hoặc quảng cáo',
      'Nội dung sai sự thật',
      'Quấy rối hoặc công kích',
      'Khác',
    ];
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Báo cáo vi phạm (FO-11)'),
        children: reasons
            .map(
              (r) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, r),
                child: Text(r),
              ),
            )
            .toList(),
      ),
    );
    if (reason == null) return;
    try {
      await _repository.report(
        targetType: targetType,
        targetId: targetId ?? widget.postId,
        reason: reason,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi báo cáo đến Ban quản trị.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không gửi được báo cáo: $e')));
      }
    }
  }

  Future<void> _toggleAnswered() async {
    final post = _post;
    if (post == null) return;
    try {
      await _repository.markAnswered(post.id, !post.isAnswered);
      await _refreshSilently();
      if (mounted) {
        unawaited(context.read<FeedCubit>().loadFeed());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không cập nhật được trạng thái câu hỏi: $e')),
        );
      }
    }
  }

  String? get _currentUserId {
    final auth = context.read<AuthCubit>().state;
    return auth is AuthAuthenticated ? auth.user.id : null;
  }

  Future<void> _editComment(CommentItem comment) async {
    final controller = TextEditingController(text: comment.content);
    final content = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa bình luận'),
        content: TextField(controller: controller, minLines: 2, maxLines: 5),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (content == null || content.isEmpty) return;
    try {
      await _repository.updateComment(comment.id, content);
      await _refreshSilently();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không sửa được bình luận: $e')));
      }
    }
  }

  Future<void> _deleteComment(CommentItem comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa bình luận?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _repository.deleteComment(comment.id);
      await _refreshSilently();
      if (mounted) {
        unawaited(context.read<FeedCubit>().loadFeed());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không xóa được bình luận: $e')));
      }
    }
  }

  @override
  void dispose() {
    unawaited(_repository.unwatchPost(widget.postId));
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = _post;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chi tiết bài viết'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (post != null) ...[
            IconButton(
              tooltip: 'Đánh dấu câu hỏi đã giải đáp (FO-16)',
              onPressed: _toggleAnswered,
              icon: Icon(
                post.isAnswered
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color: post.isAnswered
                    ? AppColors.fptGreen
                    : AppColors.textSecondary,
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'edit') {
                  context.push('/edit-post/${post.id}');
                } else if (value == 'delete') {
                  try {
                    await _repository.deletePost(post.id);
                    if (context.mounted) {
                      unawaited(context.read<FeedCubit>().loadFeed());
                      context.pop();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Không xóa được: $e')),
                      );
                    }
                  }
                } else if (value == 'report') {
                  _reportPost();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Chỉnh sửa bài viết (FO-04)'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Xóa bài viết (FO-04)'),
                ),
                PopupMenuItem(
                  value: 'report',
                  child: Text('Báo cáo bài viết (FO-11)'),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.fptOrange),
            )
          : _error != null || post == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Không tải được bài viết: $_error',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _initialLoad,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.fptOrange,
                    onRefresh: _refreshSilently,
                    child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Post Card Container
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Author Header
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.fptOrange
                                        .withValues(alpha: 0.14),
                                    backgroundImage: post.authorAvatar.isEmpty
                                        ? null
                                        : NetworkImage(post.authorAvatar),
                                    child: post.authorAvatar.isEmpty
                                        ? Text(
                                            post.authorName.isNotEmpty
                                                ? post.authorName[0]
                                                : 'U',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.fptOrange,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.authorName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${post.category} • ${post.timeAgo}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.fptBlue.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      post.campus,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.fptBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              if (post.isAnswered) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFA7F3D0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.verified_outlined,
                                        size: 14,
                                        color: Color(0xFF065F46),
                                      ),
                                      SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Câu hỏi đã được giải đáp',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF065F46),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 14),
                              Text(
                                post.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                post.content,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.55,
                                  color: Color(0xFF334155),
                                ),
                              ),

                              if (post.attachmentImageUrls.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                ...post.attachmentImageUrls.map(
                                  (url) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        url,
                                        errorBuilder: (_, _, _) =>
                                            const SizedBox.shrink(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              if (post.tags.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: post.tags
                                      .map(
                                        (tag) => Text(
                                          tag.startsWith('#') ? tag : '#$tag',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.fptBlue,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],

                              const SizedBox(height: 12),
                              const Divider(height: 1, color: AppColors.border),
                              const SizedBox(height: 6),

                              // Action Bar
                              Row(
                                children: [
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: () async {
                                      final feedCubit =
                                          context.read<FeedCubit>();
                                      setState(() {
                                        final desired = !post.isLiked;
                                        _post = post.copyWith(
                                          isLiked: desired,
                                          likes:
                                              (post.likes + (desired ? 1 : -1))
                                                  .clamp(0, 1 << 30)
                                                  .toInt(),
                                        );
                                      });
                                      try {
                                        await feedCubit.toggleLike(post.id);
                                        await _refreshSilently();
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Không thể thích: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    icon: Icon(
                                      post.isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 18,
                                      color: post.isLiked
                                          ? AppColors.fptOrange
                                          : AppColors.textSecondary,
                                    ),
                                    label: Text(
                                      '${post.likes} Thích',
                                      style: TextStyle(
                                        color: post.isLiked
                                            ? AppColors.fptOrange
                                            : AppColors.textSecondary,
                                        fontWeight: post.isLiked
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: null,
                                    icon: const Icon(
                                      Icons.chat_bubble_outline,
                                      size: 18,
                                      color: AppColors.textSecondary,
                                    ),
                                    label: Text(
                                      '${_comments.length} Bình luận',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    tooltip: 'Lưu bài viết (FO-09)',
                                    onPressed: () async {
                                      final feedCubit =
                                          context.read<FeedCubit>();
                                      setState(() {
                                        _post = post.copyWith(
                                          isSaved: !post.isSaved,
                                        );
                                      });
                                      try {
                                        await feedCubit.toggleBookmark(post.id);
                                        await _refreshSilently();
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Không thể lưu: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    icon: Icon(
                                      post.isSaved
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: post.isSaved
                                          ? AppColors.fptOrange
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        Text(
                          'Thảo luận (${_comments.length})',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),

                        if (_comments.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Center(
                              child: Text(
                                'Chưa có bình luận nào. Hãy là người đầu tiên chia sẻ!',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        else
                          ..._comments.map(
                            (c) => _CommentTile(
                              comment: c,
                              currentUserId: _currentUserId,
                              onReply: (comment) =>
                                  setState(() => _replyTo = comment),
                              onReport: (comment) => _reportPost(
                                targetType: 'Comment',
                                targetId: comment.id,
                              ),
                              onEdit: _editComment,
                              onDelete: _deleteComment,
                              onAccept: (comment) async {
                                final feedCubit = context.read<FeedCubit>();
                                try {
                                  await _repository.acceptAnswer(comment.id);
                                  await _refreshSilently();
                                  unawaited(feedCubit.loadFeed());
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Không thể đánh dấu câu trả lời: $e',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Reply Banner
                if (_replyTo != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: AppColors.fptBlue.withValues(alpha: 0.08),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.reply,
                          size: 16,
                          color: AppColors.fptBlue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Đang trả lời ${_replyTo!.authorName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.fptBlue,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(() => _replyTo = null),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Modern Comment Input Bar
                Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 12,
                    top: 10,
                    bottom: MediaQuery.of(context).padding.bottom + 10,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: _replyTo == null
                                ? 'Viết bình luận chia sẻ (FO-06)...'
                                : 'Viết phản hồi cho ${_replyTo!.authorName} (FO-07)...',
                            hintStyle: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _sendComment(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.fptOrange,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _sending ? null : _sendComment,
                          icon: _sending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 18,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.currentUserId,
    required this.onReply,
    required this.onAccept,
    required this.onReport,
    required this.onEdit,
    required this.onDelete,
  });
  final CommentItem comment;
  final String? currentUserId;
  final ValueChanged<CommentItem> onReply;
  final Future<void> Function(CommentItem) onAccept;
  final ValueChanged<CommentItem> onReport;
  final ValueChanged<CommentItem> onEdit;
  final ValueChanged<CommentItem> onDelete;

  bool get _isOwner =>
      currentUserId != null &&
      currentUserId!.isNotEmpty &&
      comment.authorId == currentUserId;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: comment.isAcceptedAnswer ? const Color(0xFFECFDF5) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: comment.isAcceptedAnswer
            ? AppColors.fptGreen
            : AppColors.border,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (comment.isAcceptedAnswer)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: const [
                Icon(Icons.check_circle, size: 15, color: AppColors.fptGreen),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Câu trả lời được chấp nhận (FO-16)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF065F46),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.fptBlue.withValues(alpha: 0.12),
              backgroundImage: comment.authorAvatar.isEmpty
                  ? null
                  : NetworkImage(comment.authorAvatar),
              child: comment.authorAvatar.isEmpty
                  ? Text(
                      comment.authorName.isNotEmpty
                          ? comment.authorName[0]
                          : 'U',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.fptBlue,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${comment.authorName} • ${comment.timeAgo}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          comment.content,
          style: const TextStyle(
            fontSize: 13.5,
            height: 1.45,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            InkWell(
              onTap: () => onReply(comment),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Trả lời',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.fptBlue,
                  ),
                ),
              ),
            ),
            if (!comment.isAcceptedAnswer)
              InkWell(
                onTap: () => onAccept(comment),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Chấp nhận câu trả lời',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.fptGreen,
                    ),
                  ),
                ),
              ),
            if (_isOwner) ...[
              InkWell(
                onTap: () => onEdit(comment),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Sửa',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => onDelete(comment),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Xóa',
                    style: TextStyle(fontSize: 12, color: Colors.redAccent),
                  ),
                ),
              ),
            ],
            InkWell(
              onTap: () => onReport(comment),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Báo cáo',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (comment.replies.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Column(
              children: comment.replies
                  .map(
                    (r) => _CommentTile(
                      comment: r,
                      currentUserId: currentUserId,
                      onReply: onReply,
                      onAccept: onAccept,
                      onReport: onReport,
                      onEdit: onEdit,
                      onDelete: onDelete,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    ),
  );
}
