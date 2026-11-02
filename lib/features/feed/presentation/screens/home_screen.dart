import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:alumni_connect/features/feed/presentation/widgets/stories_carousel_widget.dart';
import 'package:alumni_connect/features/feed/presentation/widgets/post_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  static const List<String> categories = [
    'Tất cả',
    'CNTT & Phần mềm',
    'Việc làm & Referral',
    'Kinh tế & Marketing',
    'Hỏi đáp Mentor',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 16,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Tìm bài viết, hashtag, tác giả (FO-13)...',
                  hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      context.read<FeedCubit>().searchPosts('');
                    },
                  ),
                ),
                style: const TextStyle(fontSize: 14),
                onChanged: (val) {
                  context.read<FeedCubit>().searchPosts(val);
                },
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.fptOrange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.school, color: AppColors.fptOrange, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'FPT Alumni Connect',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.fptBlue,
                        ),
                      ),
                      Text(
                        'Đại học FPT',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, size: 22),
            tooltip: 'Tìm kiếm bài viết (FO-13)',
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  context.read<FeedCubit>().searchPosts('');
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          if (!_isSearching) ...[
            IconButton(
              icon: const Icon(Icons.chat_outlined, size: 22),
              tooltip: 'Tin nhắn (CH-03)',
              onPressed: () => context.push('/chats'),
            ),
            IconButton(
              icon: const Icon(Icons.auto_awesome, color: AppColors.fptOrange, size: 22),
              tooltip: 'AI Trợ lý',
              onPressed: () => context.go('/ai-assistant'),
            ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, size: 22),
                  onPressed: () {},
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.fptOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
      body: BlocBuilder<FeedCubit, FeedState>(
        builder: (context, state) {
          if (state is FeedLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.fptOrange),
            );
          }

          if (state is FeedLoaded) {
            final displayPosts = state.filteredPosts;

            return RefreshIndicator(
              color: AppColors.fptOrange,
              onRefresh: () async {
                context.read<FeedCubit>().loadFeed();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 12, bottom: 80),
                children: [
                  // 1. Stories Carousel (Ẩn khi đang search để tập trung kết quả)
                  if (!_isSearching) ...[
                    StoriesCarouselWidget(stories: state.stories),
                    const SizedBox(height: 8),

                    // 2. Quick Create Post Box
                    GestureDetector(
                      onTap: () => context.push('/create-post'),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(
                                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Chia sẻ kinh nghiệm hoặc tin tuyển dụng...',
                                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildQuickAction(Icons.photo_camera_outlined, 'Ảnh/Video', Colors.green),
                                _buildQuickAction(Icons.work_outline, 'Referral', AppColors.fptBlue),
                                _buildQuickAction(Icons.help_outline, 'Hỏi Mentor', AppColors.fptOrange),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3. Category Filter Chips
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isActive = state.selectedCategory == cat;
                          return GestureDetector(
                            onTap: () => context.read<FeedCubit>().selectCategory(cat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.fptOrange : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isActive ? AppColors.fptOrange : AppColors.border,
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                  color: isActive ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Kết quả tìm kiếm cho "${state.searchQuery}" (${displayPosts.length})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],

                  // 4. Feed Posts List
                  if (displayPosts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: const [
                            Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                            SizedBox(height: 12),
                            Text(
                              'Không tìm thấy bài viết nào phù hợp',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...displayPosts.map(
                      (post) => PostCardWidget(
                        post: post,
                        onLike: () => context.read<FeedCubit>().toggleLike(post.id),
                        onTap: () => context.push('/post-detail/${post.id}'),
                      ),
                    ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-post'),
        backgroundColor: AppColors.fptOrange,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
