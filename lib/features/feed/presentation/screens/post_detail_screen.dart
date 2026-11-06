import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  late Future<(PostItem, List<CommentItem>)> _data;
  final _commentController = TextEditingController();
  bool _sending = false;
  String? _replyTo;
  @override
  void initState() {
    super.initState();
    _repository = context.read<FeedCubit>().repository;
    _data = _load();
  }

  Future<(PostItem, List<CommentItem>)> _load() async => (
    await _repository.getPost(widget.postId),
    await _repository.getComments(widget.postId),
  );
  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    setState(() => _sending = true);
    try {
      await _repository.addComment(
        widget.postId,
        content,
        parentCommentId: _replyTo,
      );
      _commentController.clear();
      _replyTo = null;
      setState(() {
        _data = _load();
      });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không gửi được bình luận: $e')));
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
        title: const Text('Báo cáo bài viết'),
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
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi báo cáo đến Ban quản trị.')),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không gửi được báo cáo: $e')));
    }
  }

  Future<void> _toggleAnswered() async {
    try {
      final (post, _) = await _data;
      await _repository.markAnswered(post.id, !post.isAnswered);
      if (mounted) {
        setState(() {
          _data = _load();
        });
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không cập nhật được trạng thái câu hỏi: $e')),
        );
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
      if (mounted) {
        setState(() {
          _data = _load();
        });
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không sửa được bình luận: $e')));
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
      if (mounted) {
        setState(() {
          _data = _load();
        });
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không xóa được bình luận: $e')));
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Bài viết'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          tooltip: 'Đánh dấu câu hỏi đã giải đáp',
          onPressed: _toggleAnswered,
          icon: const Icon(Icons.check_circle_outline),
        ),
        IconButton(
          tooltip: 'Báo cáo',
          onPressed: _reportPost,
          icon: const Icon(Icons.flag_outlined),
        ),
      ],
    ),
    body: FutureBuilder<(PostItem, List<CommentItem>)>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return Center(
            child: Text('Không tải được bài viết: ${snapshot.error}'),
          );
        final (post, comments) = snapshot.data!;
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    post.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('${post.authorName} • ${post.timeAgo}'),
                  const SizedBox(height: 16),
                  Text(post.content),
                  if (post.attachmentImageUrl != null) ...[
                    const SizedBox(height: 12),
                    Image.network(
                      post.attachmentImageUrl!,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          try {
                            await _repository.toggleLike(post.id);
                            setState(() {
                              _data = _load();
                            });
                          } catch (e) {
                            if (mounted)
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text('$e')));
                          }
                        },
                        icon: Icon(
                          post.isLiked ? Icons.favorite : Icons.favorite_border,
                        ),
                        label: Text('${post.likes}'),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          try {
                            await _repository.toggleBookmark(post.id);
                            if (mounted)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã cập nhật bài viết đã lưu.'),
                                ),
                              );
                          } catch (e) {
                            if (mounted)
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text('$e')));
                          }
                        },
                        icon: Icon(
                          post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                        ),
                        label: const Text('Lưu'),
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(
                    'Bình luận (${comments.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  ...comments.map(
                    (c) => _CommentTile(
                      comment: c,
                      currentUserId: _currentUserId,
                      onReply: (comment) =>
                          setState(() => _replyTo = comment.id),
                      onReport: (comment) => _reportPost(
                        targetType: 'Comment',
                        targetId: comment.id,
                      ),
                      onEdit: _editComment,
                      onDelete: _deleteComment,
                      onAccept: (comment) async {
                        try {
                          await _repository.acceptAnswer(comment.id);
                          if (mounted) {
                            setState(() {
                              _data = _load();
                            });
                          }
                        } catch (e) {
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Không thể chọn câu trả lời: $e'),
                              ),
                            );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: _replyTo == null
                              ? 'Viết bình luận…'
                              : 'Đang trả lời bình luận…',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _sending ? null : _sendComment,
                      icon: _sending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
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
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          comment.authorName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(comment.content),
        if (comment.isAcceptedAnswer)
          const Text(
            '✓ Câu trả lời được chấp nhận',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
          ),
        Wrap(
          spacing: 4,
          children: [
            TextButton(
              onPressed: () => onReply(comment),
              child: const Text('Trả lời'),
            ),
            TextButton(
              onPressed: () => onReport(comment),
              child: const Text('Báo cáo'),
            ),
            if (currentUserId != null && currentUserId == comment.authorId) ...[
              TextButton(
                onPressed: () => onEdit(comment),
                child: const Text('Sửa'),
              ),
              TextButton(
                onPressed: () => onDelete(comment),
                child: const Text('Xóa'),
              ),
            ],
            if (!comment.isAcceptedAnswer)
              TextButton(
                onPressed: () => onAccept(comment),
                child: const Text('Chọn làm câu trả lời'),
              ),
          ],
        ),
        ...comment.replies.map(
          (reply) => Padding(
            padding: const EdgeInsets.only(left: 20, top: 8),
            child: _CommentTile(
              comment: reply,
              currentUserId: currentUserId,
              onReply: onReply,
              onAccept: onAccept,
              onReport: onReport,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ),
        ),
      ],
    ),
  );
}
