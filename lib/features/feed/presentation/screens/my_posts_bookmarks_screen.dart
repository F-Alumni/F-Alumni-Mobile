import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:alumni_connect/features/feed/data/feed_repository.dart';
import 'package:alumni_connect/features/feed/data/models/feed_models.dart';
import 'package:alumni_connect/features/feed/presentation/cubit/feed_cubit.dart';

class MyPostsBookmarksScreen extends StatefulWidget {
  const MyPostsBookmarksScreen({super.key, this.initialTabIndex = 0});
  final int initialTabIndex;
  @override
  State<MyPostsBookmarksScreen> createState() => _MyPostsBookmarksScreenState();
}

class _MyPostsBookmarksScreenState extends State<MyPostsBookmarksScreen>
    with SingleTickerProviderStateMixin {
  late final FeedRepository _repo;
  late final TabController _tabs;
  late Future<FeedPage> _myPosts;
  late Future<FeedPage> _bookmarks;
  @override
  void initState() {
    super.initState();
    _repo = context.read<FeedCubit>().repository;
    _tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
    _refresh();
  }

  void _refresh() {
    _myPosts = _repo.getMyPosts();
    _bookmarks = _repo.getBookmarks();
  }

  Future<void> _delete(PostItem post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa bài viết?'),
        content: Text('Xóa “${post.title}”?'),
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
      await _repo.deletePost(post.id);
      setState(_refresh);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Không xóa được: $e')));
    }
  }

  Future<void> _unbookmark(PostItem post) async {
    try {
      await _repo.toggleBookmark(post.id);
      setState(_refresh);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Không bỏ lưu được: $e')));
    }
  }

  Future<void> _edit(PostItem post) async {
    await context.push('/edit-post/${post.id}');
    if (mounted) setState(_refresh);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: const Text('Kho bài viết cá nhân'),
      bottom: TabBar(
        controller: _tabs,
        tabs: const [
          Tab(text: 'Bài viết của tôi'),
          Tab(text: 'Đã lưu'),
        ],
      ),
    ),
    body: TabBarView(
      controller: _tabs,
      children: [
        _PostList(
          future: _myPosts,
          onRefresh: () async => setState(_refresh),
          onAction: _delete,
          onEdit: _edit,
          actionIcon: Icons.delete_outline,
          actionLabel: 'Xóa',
        ),
        _PostList(
          future: _bookmarks,
          onRefresh: () async => setState(_refresh),
          onAction: _unbookmark,
          actionIcon: Icons.bookmark_remove_outlined,
          actionLabel: 'Bỏ lưu',
        ),
      ],
    ),
  );
}

class _PostList extends StatelessWidget {
  const _PostList({
    required this.future,
    required this.onRefresh,
    required this.onAction,
    required this.actionIcon,
    required this.actionLabel,
    this.onEdit,
  });
  final Future<FeedPage> future;
  final Future<void> Function() onRefresh;
  final Future<void> Function(PostItem) onAction;
  final IconData actionIcon;
  final String actionLabel;
  final Future<void> Function(PostItem)? onEdit;
  @override
  Widget build(BuildContext context) => FutureBuilder<FeedPage>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done)
        return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError)
        return Center(child: Text('Không tải được dữ liệu: ${snapshot.error}'));
      final posts = snapshot.data!.items;
      if (posts.isEmpty)
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            children: const [
              SizedBox(height: 220),
              Center(child: Text('Chưa có bài viết.')),
            ],
          ),
        );
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: posts.length,
          itemBuilder: (context, i) {
            final post = posts[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(
                  post.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${post.category} • ${post.timeAgo}\n${post.likes} lượt thích • ${post.comments} bình luận',
                ),
                isThreeLine: true,
                onTap: () => context.push('/post-detail/${post.id}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        tooltip: 'Chỉnh sửa',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => onEdit!(post),
                      ),
                    IconButton(
                      tooltip: actionLabel,
                      icon: Icon(actionIcon),
                      onPressed: () => onAction(post),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
