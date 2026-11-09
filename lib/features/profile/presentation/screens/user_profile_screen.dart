import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/core/theme/app_typography.dart';
import 'package:alumni_connect/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:alumni_connect/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:alumni_connect/features/feed/data/models/feed_models.dart';
import 'package:alumni_connect/features/feed/presentation/widgets/post_card_widget.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Future<List<PostItem>>? _myPostsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileCubit>().loadProfile();
      _loadMyPosts();
    });
  }

  void _loadMyPosts() {
    setState(() {
      _myPostsFuture = context.read<FeedCubit>().loadMyPosts().then(
        (page) => page.items,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<ProfileCubit>().loadProfile(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (state is! ProfileLoaded) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final profile = state.profile;
        final isNarrowOrLargeFont =
            MediaQuery.sizeOf(context).width < 380 ||
            MediaQuery.textScalerOf(context).scale(14) > 18;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Text(
              'Hồ sơ của tôi',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.bookmark_border,
                  color: AppColors.textPrimary,
                ),
                tooltip: 'Bài viết đã lưu (FO-09)',
                onPressed: () => context.push('/saved-posts'),
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.textPrimary,
                ),
                tooltip: 'Chỉnh sửa hồ sơ & Cài đặt',
                onPressed: () => context.push('/edit-profile'),
              ),
            ],
          ),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        // Avatar & Badges
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 46,
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.15,
                              ),
                              backgroundImage: profile.avatarUrl.isEmpty
                                  ? null
                                  : NetworkImage(profile.avatarUrl),
                              child: profile.avatarUrl.isEmpty
                                  ? const Icon(Icons.person_outline)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Name & Verification Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                profile.name,
                                textAlign: TextAlign.center,
                                style: AppTypography.headlineSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (profile.isVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified,
                                size: 20,
                                color: AppColors.accent,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),

                        // MSSV & Cohort & Campus
                        Text(
                          'MSSV: ${profile.studentId} • ${profile.cohort} • ${profile.campus}',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            profile.major,
                            textAlign: TextAlign.center,
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Bio text
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            profile.bio,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => context.push('/edit-profile'),
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text(
                                  'Chỉnh sửa hồ sơ',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.calendar_month,
                                  color: AppColors.secondary,
                                ),
                                tooltip: 'Google Calendar (US-11)',
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Lịch hẹn cá nhân: ${profile.calendarUrl}',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Stats Row
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  '${profile.totalPosts}',
                                  'Bài viết',
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  '${profile.totalConnections}',
                                  'Kết nối',
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  '${profile.mentoringSessions}',
                                  'Buổi Mentoring',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      isScrollable: isNarrowOrLargeFont,
                      tabAlignment: isNarrowOrLargeFont
                          ? TabAlignment.start
                          : TabAlignment.fill,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(text: 'Bài viết (FO-10)'),
                        Tab(text: 'Kỹ năng & OJT'),
                        Tab(text: 'Thông tin'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Bài viết của tôi (FO-10)
                FutureBuilder<List<PostItem>>(
                  future: _myPostsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Không tải được bài viết: ${snapshot.error}',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _loadMyPosts,
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final myPosts = snapshot.data ?? const <PostItem>[];
                    if (myPosts.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('Bạn chưa có bài viết nào.'),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: myPosts.length,
                      itemBuilder: (context, idx) {
                        final post = myPosts[idx];
                        return PostCardWidget(
                          post: post,
                          onLike: () =>
                              context.read<FeedCubit>().toggleLike(post.id),
                          onBookmark: () =>
                              context.read<FeedCubit>().toggleBookmark(post.id),
                          onTap: () => context.push('/post-detail/${post.id}'),
                        );
                      },
                    );
                  },
                ),

                // Tab 2: Kỹ năng & Mục tiêu OJT
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kỹ năng chuyên môn',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: profile.skills.map((skill) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                skill,
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Mục tiêu & Quan tâm',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: profile.interests.map((interest) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                interest,
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab 3: Thông tin cá nhân
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          Icons.school_outlined,
                          'Chuyên ngành',
                          profile.major,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.location_on_outlined,
                          'Cơ sở',
                          profile.campus,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.badge_outlined,
                          'Mã số sinh viên',
                          profile.studentId,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.calendar_today_outlined,
                          'Khóa đào tạo',
                          profile.cohort,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.verified_outlined,
                          'Trạng thái tài khoản',
                          'Đã xác thực FPT Mail',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.surface, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}
