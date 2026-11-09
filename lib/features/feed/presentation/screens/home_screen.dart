import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:alumni_connect/features/feed/presentation/widgets/stories_carousel_widget.dart';
import 'package:alumni_connect/features/feed/presentation/widgets/post_card_widget.dart';
import 'package:alumni_connect/features/lab3/presentation/viewmodels/remote_config_view_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  static const _campusOptions = <String?, String>{
    null: 'Mọi campus',
    'FU-HL': 'Hòa Lạc',
    'FU-DN': 'Đà Nẵng',
    'FU-HCM': 'TP.HCM',
    'FU-CT': 'Cần Thơ',
    'FU-QN': 'Quy Nhơn',
  };

  static const _answeredOptions = <(bool?, String)>[
    (null, 'Tất cả câu hỏi'),
    (false, 'Chưa có câu trả lời'),
    (true, 'Đã giải đáp'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAdvancedFilters(BuildContext context) async {
    final cubit = context.read<FeedCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          'Bộ lọc & Sắp xếp bảng tin',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          cubit.selectCampus(null);
                          cubit.selectAnswered(null);
                          cubit.selectSort('latest');
                          setSheetState(() {});
                        },
                        child: const Text('Đặt lại'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cơ sở FPTU (FO-12)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final entry in _campusOptions.entries)
                        ChoiceChip(
                          label: Text(entry.value),
                          selected: cubit.selectedCampus == entry.key,
                          onSelected: (_) {
                            cubit.selectCampus(entry.key);
                            setSheetState(() {});
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Trạng thái câu hỏi (FO-15, FO-16)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final option in _answeredOptions)
                        ChoiceChip(
                          label: Text(option.$2),
                          selected: cubit.answeredFilter == option.$1,
                          onSelected: (_) {
                            cubit.selectAnswered(option.$1);
                            setSheetState(() {});
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sắp xếp (FO-14)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ChoiceChip(
                        label: const Text('Mới nhất'),
                        selected: cubit.selectedSort == 'latest',
                        onSelected: (_) {
                          cubit.selectSort('latest');
                          setSheetState(() {});
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Phổ biến nhất'),
                        selected: cubit.selectedSort == 'popular',
                        onSelected: (_) {
                          cubit.selectSort('popular');
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Áp dụng'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remoteSettings =
        ref.watch(remoteConfigViewModelProvider).asData?.value ??
        RemoteConfigUiSettings.defaults;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 12,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Tìm bài viết, hashtag, tác giả (FO-13)...',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
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
                onSubmitted: (_) =>
                    context.read<FeedCubit>().trackSearchResults(),
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.fptOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: AppColors.fptOrange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'FPT Alumni Connect',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.fptBlue,
                          ),
                        ),
                        Text(
                          'Đại học FPT',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        actions: [
          if (kDebugMode)
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.sync, size: 20),
              tooltip: 'Tải lại cấu hình Remote Config',
              onPressed: () =>
                  ref.read(remoteConfigViewModelProvider.notifier).refresh(),
            ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(_isSearching ? Icons.close : Icons.search, size: 21),
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
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.notifications_outlined, size: 21),
                  tooltip: 'Thông báo',
                  onPressed: () => context.push('/notifications'),
                ),
                Positioned(
                  top: 10,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.fptOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.chat_outlined, size: 21),
              tooltip: 'Tin nhắn (CH-03)',
              onPressed: () => context.push('/chats'),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.auto_awesome,
                color: AppColors.fptOrange,
                size: 21,
              ),
              tooltip: 'AI Trợ lý',
              onPressed: () => context.go('/ai-assistant'),
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

          if (state is FeedFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 42,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Không tải được diễn đàn: ${state.message}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context.read<FeedCubit>().loadFeed(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is FeedLoaded) {
            final cubit = context.read<FeedCubit>();
            final categories = state.categories;
            final displayPosts = state.filteredPosts
                .take(remoteSettings.maxItemsDisplay)
                .toList();
            final activeFilterCount =
                (cubit.selectedCampus != null ? 1 : 0) +
                (cubit.answeredFilter != null ? 1 : 0) +
                (cubit.selectedSort != 'latest' ? 1 : 0);

            return RefreshIndicator(
              color: AppColors.fptOrange,
              onRefresh: () async {
                context.read<FeedCubit>().loadFeed();
              },
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 12, bottom: 80),
                children: [
                  // 1. Stories Carousel (Ẩn khi đang search để tập trung kết quả)
                  if (!_isSearching) ...[
                    StoriesCarouselWidget(stories: state.stories),
                    const SizedBox(height: 8),

                    // 1.5 Community Events Banner
                    if (remoteSettings.isPromoBannerEnabled)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => context.push('/events'),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF27024), Color(0xFFFF8C42)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF27024)
                                      .withValues(alpha: 0.28),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.campaign,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sự kiện & Workshop FPTU mới nhất',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        'Khám phá Tech Talk, Workshop CV & Họp mặt Alumni',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

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
                                  child: Icon(Icons.person_outline, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Chia sẻ kinh nghiệm hoặc tin tuyển dụng...',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 16,
                              runSpacing: 6,
                              alignment: WrapAlignment.spaceAround,
                              children: [
                                _buildQuickAction(
                                  Icons.photo_camera_outlined,
                                  'Ảnh/Video',
                                  Colors.green,
                                ),
                                _buildQuickAction(
                                  Icons.work_outline,
                                  'Referral',
                                  AppColors.fptBlue,
                                ),
                                _buildQuickAction(
                                  Icons.help_outline,
                                  'Hỏi Mentor',
                                  AppColors.fptOrange,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3. Compact Filter Button + Category Chips Row (Auto-sizing height for 1.3x - 2.0x text scales)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Builder(
                            builder: (context) {
                              final hasFilter = activeFilterCount > 0;
                              return GestureDetector(
                                onTap: () => _showAdvancedFilters(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: hasFilter
                                        ? AppColors.fptBlue
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: hasFilter
                                          ? AppColors.fptBlue
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.tune,
                                        size: 15,
                                        color: hasFilter
                                            ? Colors.white
                                            : AppColors.fptBlue,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        hasFilter
                                            ? 'Bộ lọc ($activeFilterCount)'
                                            : 'Bộ lọc',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: hasFilter
                                              ? Colors.white
                                              : AppColors.fptBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          for (final cat in categories) ...[
                            const SizedBox(width: 8),
                            Builder(
                              builder: (context) {
                                final isActive = state.selectedCategory == cat;
                                return GestureDetector(
                                  onTap: () => context
                                      .read<FeedCubit>()
                                      .selectCategory(cat),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? AppColors.fptOrange
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isActive
                                            ? AppColors.fptOrange
                                            : AppColors.border,
                                      ),
                                    ),
                                    child: Text(
                                      cat,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isActive
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isActive
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (activeFilterCount > 0) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (cubit.selectedCampus != null)
                              InputChip(
                                label: Text(
                                  _campusOptions[cubit.selectedCampus] ??
                                      cubit.selectedCampus!,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                onDeleted: () => cubit.selectCampus(null),
                                visualDensity: VisualDensity.compact,
                              ),
                            if (cubit.answeredFilter != null)
                              InputChip(
                                label: Text(
                                  cubit.answeredFilter!
                                      ? 'Đã giải đáp'
                                      : 'Chưa có câu trả lời',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                onDeleted: () => cubit.selectAnswered(null),
                                visualDensity: VisualDensity.compact,
                              ),
                            if (cubit.selectedSort == 'popular')
                              InputChip(
                                label: const Text(
                                  'Phổ biến nhất',
                                  style: TextStyle(fontSize: 11),
                                ),
                                onDeleted: () => cubit.selectSort('latest'),
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: AppColors.textMuted,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Chưa có bài viết phù hợp.',
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
                        onLike: () =>
                            context.read<FeedCubit>().toggleLike(post.id),
                        onBookmark: () {
                          context.read<FeedCubit>().toggleBookmark(post.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                post.isSaved
                                    ? 'Đã bỏ lưu bài viết.'
                                    : 'Đã lưu bài viết vào danh sách (FO-09).',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        onTap: () {
                          context.read<FeedCubit>().trackPostOpened();
                          context.push('/post-detail/${post.id}');
                        },
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
