import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/core/theme/app_typography.dart';
import 'package:alumni_connect/features/chat/data/models/chat_model.dart';
import 'package:alumni_connect/features/chat/presentation/cubit/chat_cubit.dart';

class DirectMessagesScreen extends StatefulWidget {
  final String conversationId;

  const DirectMessagesScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<DirectMessagesScreen> createState() => _DirectMessagesScreenState();
}

class _DirectMessagesScreenState extends State<DirectMessagesScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().markAsRead(widget.conversationId);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatCubit>().sendMessage(widget.conversationId, text);
    _textController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state is! ChatLoaded) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final conv = state.conversations.firstWhere(
          (c) => c.id == widget.conversationId,
          orElse: () => state.conversations.first,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => context.pop(),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(conv.peerAvatar),
                    ),
                    if (conv.isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              conv.peerName,
                              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conv.isMentor) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
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
                      Text(
                        conv.isOnline ? 'Đang hoạt động' : 'Offline',
                        style: AppTypography.labelSmall.copyWith(
                          color: conv.isOnline ? AppColors.accent : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.videocam_outlined, color: AppColors.secondary),
                tooltip: 'Google Meet',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Khởi tạo phòng họp Google Meet 1-1...')),
                  );
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'mute', child: Text('Tắt thông báo (CH-09)')),
                  PopupMenuItem(value: 'search', child: Text('Tìm tin nhắn (CH-08)')),
                  PopupMenuItem(value: 'block', child: Text('Chặn người dùng (US-10)')),
                ],
                onSelected: (val) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã thực hiện: $val')),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Message bubbles list (CH-02, CH-04, CH-05)
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: conv.messages.length,
                  itemBuilder: (context, index) {
                    final msg = conv.messages[index];
                    final isMe = msg.senderId == 'user_an';
                    return _buildMessageBubble(msg, isMe);
                  },
                ),
              ),

              // Typing indicator simulation (CH-06)
              if (_isTyping)
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 8),
                  child: Row(
                    children: [
                      Text(
                        '${conv.peerName} đang soạn tin nhắn...',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),

              // Bottom Input Bar with attachment buttons (CH-07)
              _buildInputBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(DirectMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe ? null : Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.content,
              style: AppTypography.bodyMedium.copyWith(
                color: isMe ? Colors.white : AppColors.textPrimary,
                height: 1.4,
              ),
            ),

            // Google Meet Attached Card (Mentoring booking)
            if (msg.meetLink != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isMe ? Colors.white.withOpacity(0.15) : AppColors.secondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.video_call, color: isMe ? Colors.white : AppColors.secondary, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tham gia Google Meet',
                        style: TextStyle(
                          color: isMe ? Colors.white : AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.isSeen ? Icons.done_all : Icons.done,
                    size: 14,
                    color: msg.isSeen ? Colors.white : Colors.white60,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image_outlined, color: AppColors.textSecondary),
            tooltip: 'Gửi ảnh (CH-07)',
            onPressed: () {
              context.read<ChatCubit>().sendMessage(
                    widget.conversationId,
                    'Đã gửi 1 hình ảnh đính kèm (CV preview)',
                    imageUrl: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=600',
                  );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined, color: AppColors.textSecondary),
            tooltip: 'Gửi lịch hẹn',
            onPressed: () {
              _textController.text = 'Em xin gửi link Google Meet lịch hẹn trao đổi: https://meet.google.com/fpt-123';
            },
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
