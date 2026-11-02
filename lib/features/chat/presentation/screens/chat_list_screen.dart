import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/core/theme/app_typography.dart';
import 'package:alumni_connect/features/chat/data/models/chat_model.dart';
import 'package:alumni_connect/features/chat/presentation/cubit/chat_cubit.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'Tất cả',
    'Mentor & Cố vấn',
    'Chưa đọc',
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
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            final unread = (state is ChatLoaded) ? state.totalUnreadCount : 0;
            return Row(
              children: [
                Text(
                  'Tin nhắn',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                if (unread > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unread tin mới',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square, color: AppColors.primary),
            tooltip: 'Soạn tin nhắn mới (CH-01)',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chọn Mentor hoặc Sinh viên từ danh bạ để nhắn tin')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => context.read<ChatCubit>().searchChats(val),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm tin nhắn, mentor, cựu sinh viên...',
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
          ),

          // Filter Chips
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              final activeFilter = (state is ChatLoaded) ? state.selectedFilter : 'Tất cả';
              return SizedBox(
                height: 38,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final f = _filters[index];
                    final isSelected = f == activeFilter;
                    return ChoiceChip(
                      label: Text(f),
                      selected: isSelected,
                      onSelected: (_) => context.read<ChatCubit>().filterChats(f),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // Conversations List View
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state is! ChatLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                final convs = state.filteredConversations;

                if (convs.isEmpty) {
                  return Center(
                    child: Text(
                      'Không tìm thấy cuộc trò chuyện nào',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: convs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 76, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final conv = convs[index];
                    return _buildConversationItem(context, conv);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.chat),
        onPressed: () {
          // Quick navigate to first conversation
          context.push('/chat/chat_thao');
        },
      ),
    );
  }

  Widget _buildConversationItem(BuildContext context, ChatConversation conv) {
    return InkWell(
      onTap: () => context.push('/chat/${conv.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar with Online dot
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(conv.peerAvatar),
                ),
                if (conv.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Middle info (Name, role, message preview)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          conv.peerName,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: conv.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conv.isMentor) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Mentor',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    conv.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: conv.unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: conv.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right side (Time, Pinned icon, Unread badge)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  conv.lastMessageTime,
                  style: AppTypography.labelSmall.copyWith(
                    color: conv.unreadCount > 0 ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: conv.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (conv.isPinned)
                      const Icon(Icons.push_pin, size: 14, color: AppColors.textSecondary),
                    if (conv.unreadCount > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${conv.unreadCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
