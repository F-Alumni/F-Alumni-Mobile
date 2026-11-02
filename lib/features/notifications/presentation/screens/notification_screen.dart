import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alumni_connect/features/notifications/data/fcm_messaging_service.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/core/theme/app_typography.dart';
import 'package:alumni_connect/features/notifications/data/models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = [
    'Tất cả',
    'Tin nhắn',
    'Mentorship',
    'Tương tác & Bài viết',
    'Việc làm & Tuyển dụng',
    'Hệ thống',
  ];

  late List<NotificationItem> _notifications;
  StreamSubscription<NotificationItem>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    final messaging = FcmMessagingService.instance;
    _notifications = messaging.notifications;
    _notificationSubscription = messaging.incomingNotifications.listen((item) {
      if (!mounted) return;
      setState(() => _notifications.insert(0, item));
    });
    unawaited(messaging.requestPermission());
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationItem> get _filteredNotifications {
    if (_selectedFilterIndex == 0) return _notifications;
    final filter = _filters[_selectedFilterIndex];
    if (filter == 'Mentorship') {
      return _notifications
          .where((n) => n.type == NotificationType.mentorship)
          .toList();
    }
    if (filter == 'Tin nhắn') {
      return _notifications
          .where((n) => n.type == NotificationType.chat)
          .toList();
    }
    if (filter == 'Tương tác & Bài viết') {
      return _notifications
          .where((n) => n.type == NotificationType.social)
          .toList();
    }
    if (filter == 'Việc làm & Tuyển dụng') {
      return _notifications
          .where((n) => n.type == NotificationType.job)
          .toList();
    }
    if (filter == 'Hệ thống') {
      return _notifications
          .where((n) => n.type == NotificationType.system)
          .toList();
    }
    return _notifications;
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đánh dấu tất cả thông báo là đã đọc'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleAction(NotificationItem item, String action) {
    final destination = item.actionUrl;
    if (destination != null && destination.startsWith('/')) {
      context.push(destination);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thông báo “$action” chưa có liên kết đích từ backend.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotifications;
    final todayList = filtered
        .where((n) => DateTime.now().difference(n.createdAt).inDays < 1)
        .toList();
    final thisWeekList = filtered
        .where(
          (n) =>
              DateTime.now().difference(n.createdAt).inDays >= 1 &&
              DateTime.now().difference(n.createdAt).inDays < 7,
        )
        .toList();
    final olderList = filtered
        .where((n) => DateTime.now().difference(n.createdAt).inDays >= 7)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Text(
              'Thông báo',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.fptOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount mới',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _unreadCount > 0 ? _markAllAsRead : null,
            icon: const Icon(Icons.done_all, size: 16),
            label: const Text('Đã đọc hết', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(foregroundColor: AppColors.fptBlue),
          ),
          IconButton(
            icon: const Icon(
              Icons.tune,
              color: AppColors.textSecondary,
              size: 20,
            ),
            tooltip: 'Tùy chỉnh thông báo',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Tính năng cài đặt thông báo đang được cập nhật',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilterIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filters[index]),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedFilterIndex = index);
                        }
                      },
                      selectedColor: AppColors.fptOrange,
                      backgroundColor: AppColors.surfaceVariant,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.fptOrange
                              : AppColors.border,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          // Notification List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: AppColors.textMuted.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Không có thông báo nào trong mục này',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    children: [
                      if (todayList.isNotEmpty) ...[
                        _buildSectionHeader('HÔM NAY'),
                        ...todayList.map(_buildNotificationCard),
                        const SizedBox(height: 16),
                      ],
                      if (thisWeekList.isNotEmpty) ...[
                        _buildSectionHeader('TUẦN NÀY'),
                        ...thisWeekList.map(_buildNotificationCard),
                        const SizedBox(height: 16),
                      ],
                      if (olderList.isNotEmpty) ...[
                        _buildSectionHeader('CŨ HƠN'),
                        ...olderList.map(_buildNotificationCard),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item) {
    final isUnread = !item.isRead;

    IconData typeIcon;
    Color typeColor;
    switch (item.type) {
      case NotificationType.chat:
        typeIcon = Icons.chat_bubble_outline;
        typeColor = AppColors.fptBlue;
        break;
      case NotificationType.mentorship:
        typeIcon = Icons.calendar_today;
        typeColor = AppColors.fptOrange;
        break;
      case NotificationType.social:
        typeIcon = Icons.favorite_border;
        typeColor = Colors.pinkAccent;
        break;
      case NotificationType.job:
        typeIcon = Icons.work_outline;
        typeColor = AppColors.fptBlue;
        break;
      case NotificationType.system:
        typeIcon = Icons.verified;
        typeColor = AppColors.fptGreen;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnread
            ? AppColors.surface
            : AppColors.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread
              ? AppColors.fptOrange.withOpacity(0.35)
              : AppColors.border,
          width: isUnread ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnread
                ? AppColors.fptOrange.withOpacity(0.06)
                : Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar or Icon
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: typeColor.withOpacity(0.12),
                    backgroundImage: item.actorAvatar != null
                        ? NetworkImage(item.actorAvatar!)
                        : null,
                    child: item.actorAvatar == null
                        ? Icon(typeIcon, color: typeColor, size: 20)
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 1),
                      ),
                      child: Icon(typeIcon, size: 10, color: typeColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (item.tag != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.tag!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: typeColor,
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            Text(
                              _formatTimeAgo(item.createdAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                            if (isUnread) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.fptOrange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: isUnread
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.body,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Action Buttons
          if (item.actionLabel != null) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 8),
            Row(
              children: [
                if (item.secondaryActionLabel != null) ...[
                  OutlinedButton(
                    onPressed: () =>
                        _handleAction(item, item.secondaryActionLabel!),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Text(
                      item.secondaryActionLabel!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                ElevatedButton.icon(
                  onPressed: () => _handleAction(item, item.actionLabel!),
                  icon: Icon(
                    item.actionLabel!.contains('Calendar')
                        ? Icons.event_available
                        : Icons.arrow_forward,
                    size: 14,
                  ),
                  label: Text(item.actionLabel!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.actionLabel!.contains('Calendar')
                        ? AppColors.fptBlue
                        : AppColors.fptOrange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else {
      return '${diff.inDays} ngày trước';
    }
  }
}
