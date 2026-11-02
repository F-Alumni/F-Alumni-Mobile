import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:alumni_connect/core/network/alumni_api.dart';
import 'package:alumni_connect/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:alumni_connect/features/events/data/event_repository.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/features/events/data/models/event_model.dart';
import 'package:alumni_connect/features/events/data/models/event_attendee_model.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late EventModel _event;
  late List<EventAttendeeModel> _attendees;
  late final EventRepository _repository;
  bool _isCreator = false;
  bool _isLoading = true;
  bool _isRsvpLoading = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _repository = EventRepository(AlumniApi());
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEvent());
  }

  Future<void> _loadEvent() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final event = await _repository.getEvent(widget.eventId);
      final attendees = await _repository.getAttendees(widget.eventId);
      final auth = context.read<AuthCubit>().state;
      if (!mounted) return;
      setState(() {
        _event = event;
        _attendees = attendees;
        _isCreator =
            auth is AuthAuthenticated && event.creatorId == auth.user.id;
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

  Future<void> _handleRsvp(String status) async {
    setState(() => _isRsvpLoading = true);
    try {
      await _repository.rsvp(widget.eventId, status);
      await _loadEvent();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'Going'
                ? 'Tuyệt vời! Bạn đã xác nhận Sẽ tham gia sự kiện.'
                : status == 'Interested'
                ? 'Đã lưu vào danh sách Sự kiện quan tâm của bạn.'
                : 'Đã cập nhật: Bạn không tham gia sự kiện này.',
          ),
          backgroundColor: status == 'Going'
              ? AppColors.fptOrange
              : status == 'Interested'
              ? AppColors.fptBlue
              : AppColors.textSecondary,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không cập nhật RSVP được: $e')));
    } finally {
      if (mounted) setState(() => _isRsvpLoading = false);
    }
  }

  void _showAttendees() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(ctx).height * 0.65,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Người tham dự (${_attendees.length})',
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _attendees.length,
                  itemBuilder: (context, index) {
                    final attendee = _attendees[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: attendee.userAvatarUrl.isEmpty
                            ? null
                            : NetworkImage(attendee.userAvatarUrl),
                        child: attendee.userAvatarUrl.isEmpty
                            ? const Icon(Icons.person_outline)
                            : null,
                      ),
                      title: Text(attendee.userName),
                      subtitle: Text(attendee.status),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy / Xóa sự kiện này?'),
        content: const Text(
          'Bạn có chắc chắn muốn hủy sự kiện này không? Tất cả người tham gia sẽ nhận được thông báo hủy sự kiện.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Không'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _repository.deleteEvent(_event.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa sự kiện.')),
                );
                context.pop();
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Không xóa được sự kiện: $e')),
                  );
              }
            },
            child: const Text(
              'Xác nhận xóa',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sự kiện')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Không tải được sự kiện: $_loadError',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: _loadEvent, child: const Text('Thử lại')),
            ],
          ),
        ),
      );
    }
    final isGoing = _event.myStatus == 'Going';
    final isInterested = _event.myStatus == 'Interested';
    final isNotGoing = _event.myStatus == 'NotGoing';

    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    final progressRatio =
        _event.maxAttendees != null && _event.maxAttendees! > 0
        ? (_event.goingCount / _event.maxAttendees!).clamp(0.0, 1.0)
        : 0.5;

    return WillPopScope(
      onWillPop: () async {
        context.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(top: BorderSide(color: AppColors.border)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isRsvpLoading
                        ? null
                        : () => _handleRsvp('Interested'),
                    icon: Icon(
                      isInterested ? Icons.star : Icons.star_border,
                      size: 18,
                      color: isInterested
                          ? AppColors.fptBlue
                          : AppColors.textSecondary,
                    ),
                    label: Text(
                      isInterested ? 'Đang quan tâm' : 'Quan tâm',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isInterested
                            ? AppColors.fptBlue
                            : AppColors.textSecondary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isInterested
                            ? AppColors.fptBlue
                            : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isRsvpLoading
                        ? null
                        : isGoing
                        ? () => _handleRsvp('NotGoing')
                        : () => _handleRsvp('Going'),
                    icon: Icon(
                      isGoing ? Icons.cancel_outlined : Icons.check_circle,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      isGoing ? 'Hủy tham gia' : 'Đăng ký tham gia ngay',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.fptOrange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            // ── Sliver App Bar with Banner ────────────────────────────────
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              backgroundColor: AppColors.fptBlue,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã sao chép liên kết sự kiện!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
                if (_isCreator)
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (val) {
                        if (val == 'delete') _showDeleteConfirmDialog();
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Hủy sự kiện',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 4),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      _event.bannerUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.fptBlue,
                        child: const Icon(
                          Icons.event,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            Colors.black.withOpacity(0.75),
                          ],
                        ),
                      ),
                    ),
                    // Date & Campus Chips overlay
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.fptOrange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              DateFormat('dd THÁNG MM, yyyy')
                                  .format(_event.startTime)
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.school,
                                  size: 13,
                                  color: AppColors.fptBlue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _event.campus,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.fptBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Event Content Body ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      _event.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Organizer Card ────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundImage: _event.creatorAvatarUrl.isEmpty
                                ? null
                                : NetworkImage(_event.creatorAvatarUrl),
                            child: _event.creatorAvatarUrl.isEmpty
                                ? const Icon(Icons.person_outline)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tổ chức bởi:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _event.creatorName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.verified,
                                      size: 15,
                                      color: AppColors.fptGreen,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => context.push('/chats'),
                            icon: const Icon(
                              Icons.chat_outlined,
                              size: 14,
                              color: AppColors.fptOrange,
                            ),
                            label: const Text(
                              'Nhắn tin',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.fptOrange,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              side: const BorderSide(
                                color: AppColors.fptOrange,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Key Information Box ───────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          // Time Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.fptOrange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.calendar_month,
                                  color: AppColors.fptOrange,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${dateFormat.format(_event.startTime)} (${timeFormat.format(_event.startTime)} - ${timeFormat.format(_event.endTime)})',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    InkWell(
                                      onTap: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Đã tạo liên kết thêm vào Google Calendar!',
                                            ),
                                            backgroundColor: AppColors.fptBlue,
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        '+ Thêm vào Google Calendar',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.fptBlue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),

                          // Location Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.fptBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: AppColors.fptBlue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _event.location,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Xem bản đồ & Hướng dẫn vào cổng',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.fptBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),

                          // Capacity & Progress Bar
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.fptGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.group,
                                  color: AppColors.fptGreen,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Đã đăng ký: ${_event.goingCount} ${_event.maxAttendees != null ? '/ ${_event.maxAttendees} chỗ' : 'người'}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        if (_event.maxAttendees != null)
                                          Text(
                                            'Còn ${_event.maxAttendees! - _event.goingCount} chỗ',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: _event.isFull
                                                  ? AppColors.error
                                                  : AppColors.fptGreen,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progressRatio,
                                        minHeight: 6,
                                        backgroundColor:
                                            AppColors.surfaceVariant,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              AppColors.fptGreen,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── RSVP Interactive Card ─────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.fptOrange.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.fptOrange.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bạn sẽ tham gia sự kiện này chứ?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Xác nhận trước ngày sự kiện để ban tổ chức chuẩn bị teabreak và quà tặng kỷ niệm FPTU chu đáo nhất.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              // Going button
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _handleRsvp('Going'),
                                  icon: Icon(
                                    isGoing
                                        ? Icons.check_circle
                                        : Icons.check_circle_outline,
                                    size: 15,
                                    color: isGoing
                                        ? Colors.white
                                        : AppColors.fptOrange,
                                  ),
                                  label: Text(
                                    'Sẽ đi',
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
                                        : Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: isGoing
                                            ? AppColors.fptOrange
                                            : AppColors.border,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Interested button
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _handleRsvp('Interested'),
                                  icon: Icon(
                                    isInterested
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 15,
                                    color: isInterested
                                        ? AppColors.fptBlue
                                        : AppColors.textSecondary,
                                  ),
                                  label: Text(
                                    'Quan tâm',
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
                                        ? AppColors.fptBlue.withOpacity(0.1)
                                        : Colors.white,
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
                              const SizedBox(width: 8),
                              // Not Going button
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _handleRsvp('NotGoing'),
                                  icon: Icon(
                                    Icons.cancel_outlined,
                                    size: 15,
                                    color: isNotGoing
                                        ? AppColors.error
                                        : AppColors.textMuted,
                                  ),
                                  label: Text(
                                    'Bận',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isNotGoing
                                          ? AppColors.error
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: isNotGoing
                                        ? AppColors.error.withOpacity(0.08)
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    side: BorderSide(
                                      color: isNotGoing
                                          ? AppColors.error
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
                    const SizedBox(height: 20),

                    // ── Attendees Section ─────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Người tham dự (${_event.goingCount})',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        InkWell(
                          onTap: _showAttendees,
                          child: const Text(
                            'Xem tất cả >',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.fptOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 52,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _attendees.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final att = _attendees[index];
                          return Tooltip(
                            message: att.userName,
                            child: CircleAvatar(
                              radius: 22,
                              backgroundImage: att.userAvatarUrl.isEmpty
                                  ? null
                                  : NetworkImage(att.userAvatarUrl),
                              child: att.userAvatarUrl.isEmpty
                                  ? const Icon(Icons.person_outline, size: 18)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Detailed Event Description ────────────────────────
                    const Text(
                      'Giới thiệu sự kiện',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        _event.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Lịch trình chương trình',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Text(
                        'Ban tổ chức chưa cập nhật lịch trình chi tiết.',
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
