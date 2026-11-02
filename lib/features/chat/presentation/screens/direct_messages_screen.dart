import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/core/theme/app_typography.dart';
import 'package:alumni_connect/features/chat/data/models/chat_model.dart';
import 'package:alumni_connect/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:alumni_connect/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:alumni_connect/features/profile/presentation/cubit/profile_cubit.dart';

class DirectMessagesScreen extends StatefulWidget {
  final String conversationId;

  const DirectMessagesScreen({super.key, required this.conversationId});

  @override
  State<DirectMessagesScreen> createState() => _DirectMessagesScreenState();
}

class _DirectMessagesScreenState extends State<DirectMessagesScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatCubit _chatCubit;

  @override
  void initState() {
    super.initState();
    _chatCubit = context.read<ChatCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _chatCubit.loadChats();
      await _chatCubit.loadMessages(widget.conversationId);
      await _chatCubit.markAsRead(widget.conversationId);
      await _chatCubit.connectToConversation(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _chatCubit.disconnectFromConversation();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _chatCubit.sendMessage(widget.conversationId, text);
    _chatCubit.sendTyping(false);
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

  Future<void> _sendImageByUrl() async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Gửi ảnh bằng đường dẫn'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: 'https://example.com/image.jpg',
          ),
          onSubmitted: (value) => Navigator.pop(dialogContext, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Gửi ảnh'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (url == null || !mounted) return;
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đường dẫn ảnh không hợp lệ.')),
      );
      return;
    }
    await _chatCubit.sendMessage(
      widget.conversationId,
      '',
      imageUrl: uri.toString(),
    );
  }

  Future<void> _searchMessages() async {
    final controller = TextEditingController();
    final query = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tìm tin nhắn'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nhập từ khóa'),
          onSubmitted: (value) => Navigator.pop(dialogContext, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Tìm'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (query == null || query.trim().isEmpty || !mounted) return;
    await _chatCubit.loadMessages(widget.conversationId, search: query);
  }

  Future<void> _blockPeer(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Chặn người dùng?'),
        content: const Text('Bạn sẽ hạn chế tương tác với tài khoản này.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Chặn'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final error = await context.read<ProfileCubit>().blockUser(userId);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state is! ChatLoaded) {
          return Scaffold(
            body: Center(
              child: state is ChatError
                  ? Text(state.message)
                  : const CircularProgressIndicator(),
            ),
          );
        }

        final matches = state.conversations.where(
          (c) => c.id == widget.conversationId,
        );
        if (matches.isEmpty)
          return const Scaffold(
            body: Center(child: Text('Không tìm thấy cuộc trò chuyện.')),
          );
        final conv = matches.first;
        final authState = context.read<AuthCubit>().state;
        final currentUserId = authState is AuthAuthenticated
            ? authState.user.id
            : '';

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
                      backgroundImage: conv.peerAvatar.isEmpty
                          ? null
                          : NetworkImage(conv.peerAvatar),
                      child: conv.peerAvatar.isEmpty
                          ? const Icon(Icons.person_outline)
                          : null,
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
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conv.isMentor) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
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
                        conv.peerRole.isEmpty
                            ? 'Cuộc trò chuyện'
                            : conv.peerRole,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'hide',
                    child: Text(
                      conv.isHidden
                          ? 'Bỏ ẩn cuộc trò chuyện'
                          : 'Ẩn cuộc trò chuyện',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'mute',
                    child: Text(
                      conv.isMuted ? 'Bật lại thông báo' : 'Tắt thông báo',
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'search',
                    child: Text('Tìm tin nhắn'),
                  ),
                  if ((conv.peerUserId ?? '').isNotEmpty)
                    const PopupMenuItem(
                      value: 'block',
                      child: Text('Chặn người dùng'),
                    ),
                ],
                onSelected: (val) async {
                  if (val == 'hide') {
                    final changed = await context
                        .read<ChatCubit>()
                        .toggleHidden(conv.id);
                    if (changed && context.mounted) context.pop();
                  }
                  if (val == 'mute')
                    context.read<ChatCubit>().toggleMute(conv.id);
                  if (val == 'search') _searchMessages();
                  if (val == 'block' && conv.peerUserId != null)
                    _blockPeer(conv.peerUserId!);
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
                    final isMe = msg.senderId == currentUserId;
                    return _buildMessageBubble(msg, isMe);
                  },
                ),
              ),

              // Realtime typing indicator (CH-06)
              if (state.isPeerTyping)
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 8),
                  child: Row(
                    children: [
                      Text(
                        '${conv.peerName} đang soạn tin nhắn...',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

              // Message input and image URL attachment (CH-07)
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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
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
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (msg.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  msg.imageUrl!,
                  width: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Text('Không tải được ảnh'),
                ),
              ),
              if (msg.content.isNotEmpty) const SizedBox(height: 6),
            ],
            if (msg.content.isNotEmpty)
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
                  color: isMe
                      ? Colors.white.withOpacity(0.15)
                      : AppColors.secondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.video_call,
                      color: isMe ? Colors.white : AppColors.secondary,
                      size: 22,
                    ),
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
            tooltip: 'Gửi ảnh bằng URL',
            onPressed: _sendImageByUrl,
            icon: const Icon(Icons.image_outlined, color: AppColors.primary),
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              onChanged: (value) => _chatCubit.sendTyping(value.isNotEmpty),
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
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
