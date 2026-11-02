import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:alumni_connect/core/network/alumni_api.dart';
import 'package:alumni_connect/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:alumni_connect/features/events/data/event_repository.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/features/events/data/models/event_model.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  String _selectedCampus = 'Tất cả';
  String _searchQuery = '';
  List<EventModel> _events = [];
  late final EventRepository _repository;
  String? _currentUserId;
  bool _isLoading = true;
  String? _loadError;

  final List<String> _campuses = [
    'Tất cả',
    'Hòa Lạc',
    'TP. Hồ Chí Minh',
    'Đà Nẵng',
    'Cần Thơ',
    'Quy Nhơn',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _repository = EventRepository(AlumniApi());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthCubit>().state;
      if (auth is AuthAuthenticated) _currentUserId = auth.user.id;
      _loadEvents();
    });
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final page = await _repository.getEvents(
        campus: EventRepository.campusCode(_selectedCampus),
        upcomingOnly: false,
      );
      if (!mounted) return;
      setState(() {
        _events = page.items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<EventModel> _getFilteredEvents(int tabIndex) {
    return _events.where((event) {
      // 1. Campus filter
      final matchCampus =
          _selectedCampus == 'Tất cả' ||
          event.campus.toLowerCase().contains(_selectedCampus.toLowerCase()) ||
          _selectedCampus.toLowerCase().contains(event.campus.toLowerCase());

      // 2. Search query filter
      final matchSearch =
          _searchQuery.isEmpty ||
          event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.creatorName.toLowerCase().contains(_searchQuery.toLowerCase());

      // 3. Tab filter
      bool matchTab = true;
      if (tabIndex == 1) {
        // Đã đăng ký (Going or Interested)
        matchTab = event.myStatus == 'Going' || event.myStatus == 'Interested';
      } else if (tabIndex == 2) {
        // Sự kiện của tôi (Host)
        matchTab = event.creatorId == _currentUserId;
      } else {
        matchTab = event.isUpcoming;
      }

      return matchCampus && matchSearch && matchTab;
    }).toList();
  }

  Future<void> _handleQuickRsvp(EventModel event, String newStatus) async {
    try {
      await _repository.rsvp(event.id, newStatus);
      await _loadEvents();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'Going'
                ? 'Đã xác nhận tham gia sự kiện!'
                : 'Đã lưu sự kiện vào danh sách quan tâm.',
          ),
          backgroundColor: newStatus == 'Going'
              ? AppColors.fptOrange
              : AppColors.fptBlue,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không cập nhật RSVP được: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Sự kiện & Workshop',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push<EventModel>('/create-event');
          if (mounted) await _loadEvents();
        },
        backgroundColor: AppColors.fptOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tạo sự kiện',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Không tải được sự kiện: $_loadError',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _loadEvents,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // ── Search & Filter Section ─────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    children: [
                      // Search Input
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val.trim();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Tìm workshop, talkshow, offline FPTU...',
                            hintStyle: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Campus Filter Chips (Horizontal scroll)
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _campuses.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final campus = _campuses[index];
                            final isSelected = _selectedCampus == campus;
                            return ChoiceChip(
                              label: Text(
                                campus,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.fptOrange,
                              backgroundColor: AppColors.surfaceVariant,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.fptOrange
                                      : AppColors.border,
                                ),
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedCampus = campus;
                                  });
                                  _loadEvents();
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Tabs Bar ────────────────────────────────────────────────────
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.fptOrange,
                    unselectedLabelColor: AppColors.textMuted,
                    indicatorColor: AppColors.fptOrange,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                    tabs: const [
                      Tab(text: 'Sắp diễn ra'),
                      Tab(text: 'Đã đăng ký'),
                      Tab(text: 'Sự kiện của tôi'),
                    ],
                  ),
                ),

                // ── Events List ─────────────────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildEventsListView(0),
                      _buildEventsListView(1),
                      _buildEventsListView(2),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEventsListView(int tabIndex) {
    final filtered = _getFilteredEvents(tabIndex);

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy,
                size: 56,
                color: AppColors.textMuted.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              const Text(
                'Không tìm thấy sự kiện phù hợp',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Hãy thử thay đổi từ khóa tìm kiếm hoặc chọn cơ sở FPTU khác nhé.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final event = filtered[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(EventModel event) {
    final isGoing = event.myStatus == 'Going';
    final isInterested = event.myStatus == 'Interested';
    final dateFormat = DateFormat('dd/MM · HH:mm');
    final dayNum = DateFormat('dd').format(event.startTime);
    final monthStr = 'TH${DateFormat('MM').format(event.startTime)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await context.push('/event-detail/${event.id}');
          if (mounted) await _loadEvents();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner Image with Badges ─────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    event.bannerUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: AppColors.fptBlue.withOpacity(0.1),
                      child: const Center(
                        child: Icon(
                          Icons.event,
                          size: 48,
                          color: AppColors.fptBlue,
                        ),
                      ),
                    ),
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                ),
                // Top Left Date Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dayNum,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.fptOrange,
                            height: 1,
                          ),
                        ),
                        Text(
                          monthStr,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Top Right Campus Chip
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.fptBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.school, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          event.campus,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom Info overlay on banner
                Positioned(
                  bottom: 10,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: event.creatorAvatarUrl.isEmpty
                            ? null
                            : NetworkImage(event.creatorAvatarUrl),
                        child: event.creatorAvatarUrl.isEmpty
                            ? const Icon(Icons.person_outline, size: 14)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.creatorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Event Card Content ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Time
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 15,
                        color: AppColors.fptOrange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${dateFormat.format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: AppColors.fptBlue,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Attendees Count & Progress
                  Row(
                    children: [
                      const Icon(
                        Icons.people_alt_outlined,
                        size: 15,
                        color: AppColors.fptGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${event.goingCount} người sẽ tham gia · ${event.interestedCount} quan tâm',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (event.maxAttendees != null)
                        Text(
                          '${event.goingCount}/${event.maxAttendees}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: event.isFull
                                ? AppColors.error
                                : AppColors.fptGreen,
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 20),

                  // ── Action Buttons ──────────────────────────────────────
                  Row(
                    children: [
                      // "Going" Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleQuickRsvp(event, 'Going'),
                          icon: Icon(
                            isGoing
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            size: 16,
                            color: isGoing ? Colors.white : AppColors.fptOrange,
                          ),
                          label: Text(
                            isGoing ? 'Đã tham gia' : 'Sẽ tham gia',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isGoing
                                  ? Colors.white
                                  : AppColors.fptOrange,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isGoing
                                ? AppColors.fptOrange
                                : AppColors.fptOrange.withOpacity(0.08),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isGoing
                                    ? AppColors.fptOrange
                                    : AppColors.fptOrange.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // "Interested" Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _handleQuickRsvp(event, 'Interested'),
                          icon: Icon(
                            isInterested ? Icons.star : Icons.star_border,
                            size: 16,
                            color: isInterested
                                ? AppColors.fptBlue
                                : AppColors.textSecondary,
                          ),
                          label: Text(
                            isInterested ? 'Đang quan tâm' : 'Quan tâm',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isInterested
                                  ? AppColors.fptBlue
                                  : AppColors.textSecondary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isInterested
                                ? AppColors.fptBlue.withOpacity(0.08)
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(
                              color: isInterested
                                  ? AppColors.fptBlue
                                  : AppColors.border,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
