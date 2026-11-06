import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/core/theme/app_typography.dart';
import 'package:alumni_connect/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:alumni_connect/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:alumni_connect/features/lab3/presentation/providers/firebase_service_providers.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key, this.postId});
  final String? postId;

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String _selectedCategory = 'Hỏi đáp & Thảo luận';
  String _selectedCampus = 'FPT Đà Nẵng';
  String _selectedMajor = 'All';
  String _privacyScope = 'Công khai';

  final List<String> _categories = [
    'Hỏi đáp & Thảo luận',
    'Chia sẻ kinh nghiệm',
    'Cơ hội việc làm / Thực tập',
    'Sự kiện Alumni',
    'Review môn học & OJT',
  ];

  final List<String> _campuses = [
    'Toàn quốc',
    'FPT Đà Nẵng',
    'FPT Hòa Lạc',
    'FPT TP.HCM',
    'FPT Quy Nhơn',
    'FPT Cần Thơ',
  ];

  final List<String> _quickHashtags = [
    '#OJT',
    '#K16',
    '#DoAnCapstone',
    '#KinhNghiemPhongVan',
    '#FPTSoftware',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _addHashtag(String tag) {
    setState(() {
      _contentController.text = '${_contentController.text.trim()} $tag ';
    });
  }

  bool _submitting = false;
  bool _uploadingImage = false;
  double _imageUploadProgress = 0;
  final List<String> _imageUrls = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _loadingExisting = false;
  bool _didLoadExisting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadExisting && widget.postId != null) {
      _didLoadExisting = true;
      _loadExistingPost();
    }
  }

  Future<void> _loadExistingPost() async {
    setState(() => _loadingExisting = true);
    try {
      final post = await context.read<FeedCubit>().repository.getPost(
        widget.postId!,
      );
      if (!mounted) return;
      _titleController.text = post.title;
      _contentController.text = post.content;
      _imageUrls.addAll(post.attachmentImageUrls);
      _selectedCategory = post.category;
      _selectedCampus = post.campus;
      _selectedMajor = post.major;
      setState(() {});
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tải được bài để sửa: $e')),
        );
    } finally {
      if (mounted) setState(() => _loadingExisting = false);
    }
  }

  Future<void> _addImageUrl() async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm ảnh vào bài viết'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(hintText: 'https://...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Thêm URL'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (url == null || url.isEmpty || !mounted) return;
    setState(() => _imageUrls.add(url));
  }

  Future<void> _showImageOptions() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Chọn ảnh từ điện thoại'),
              onTap: () => Navigator.pop(context, 'device'),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Thêm ảnh bằng URL'),
              onTap: () => Navigator.pop(context, 'url'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (choice == 'device') await _pickAndUploadPostImage();
    if (choice == 'url') await _addImageUrl();
  }

  Future<void> _pickAndUploadPostImage() async {
    if (_uploadingImage) return;
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 1800,
      );
      if (picked == null || !mounted) return;

      final file = File(picked.path);
      final size = await file.length();
      if (!mounted) return;
      if (size > 10 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ảnh phải nhỏ hơn 10 MB.')),
        );
        return;
      }

      final firebaseUser = ref.read(firebaseAuthServiceProvider)?.currentUser;
      final storage = ref.read(firebaseStorageServiceProvider);
      if (firebaseUser == null || storage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn cần đăng nhập Google để tải ảnh lên.'),
          ),
        );
        return;
      }

      setState(() {
        _uploadingImage = true;
        _imageUploadProgress = 0;
      });
      String? downloadUrl;
      final fileName =
          '${DateTime.now().microsecondsSinceEpoch}_${picked.name}';
      await for (final progress in storage.uploadPostImage(
        uid: firebaseUser.uid,
        file: file,
        fileName: fileName,
      )) {
        downloadUrl = progress.downloadUrl ?? downloadUrl;
        if (mounted) {
          setState(() => _imageUploadProgress = progress.fraction);
        }
      }
      if (downloadUrl == null) {
        throw StateError('Firebase Storage không trả về URL ảnh.');
      }
      if (!mounted) return;
      setState(() => _imageUrls.add(downloadUrl!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã tải ảnh lên, ảnh sẽ được gửi cùng bài viết.'),
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Không tải được ảnh: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _uploadingImage = false;
          _imageUploadProgress = 0;
        });
      }
    }
  }

  Future<void> _submitPost() async {
    if (_titleController.text.trim().length < 5 ||
        _contentController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tiêu đề tối thiểu 5 ký tự, nội dung tối thiểu 10 ký tự.',
          ),
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final postType = _selectedCategory == 'Hỏi đáp & Thảo luận'
          ? 'Question'
          : _selectedCategory == 'Cơ hội việc làm / Thực tập'
          ? 'Recruitment'
          : 'Sharing';
      final campus = switch (_selectedCampus) {
        'FPT Đà Nẵng' => 'FU-DN',
        'FPT Hòa Lạc' => 'FU-HL',
        'FPT TP.HCM' => 'FU-HCM',
        'FPT Quy Nhơn' => 'FU-QN',
        'FPT Cần Thơ' => 'FU-CT',
        _ => 'All',
      };
      final tags = RegExp(r'#([\wÀ-ỹ]+)')
          .allMatches(_contentController.text)
          .map((m) => m.group(1)!)
          .toList();
      if (widget.postId == null) {
        await context.read<FeedCubit>().createPost(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          postType: postType,
          campus: campus,
          major: _selectedMajor,
          tags: tags,
          imageUrls: _imageUrls,
        );
      } else {
        await context.read<FeedCubit>().updatePost(
          id: widget.postId!,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          postType: postType,
          campus: campus,
          major: _selectedMajor,
          tags: tags,
          imageUrls: _imageUrls,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đăng bài thành công.')));
      context.pop();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Không đăng được bài: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.postId == null ? 'Tạo bài viết' : 'Chỉnh sửa bài viết',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ElevatedButton(
              onPressed: _submitting ? null : _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                elevation: 0,
              ),
              child: Text(
                _loadingExisting
                    ? 'Đang tải…'
                    : _submitting
                    ? 'Đang lưu…'
                    : widget.postId == null
                    ? 'Đăng bài'
                    : 'Lưu thay đổi',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info row (Avatar, Name, Privacy selector)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: (user?.avatarUrl?.isNotEmpty ?? false)
                            ? NetworkImage(user!.avatarUrl!)
                            : null,
                        child: (user?.avatarUrl?.isNotEmpty ?? false)
                            ? null
                            : const Icon(Icons.person_outline),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user?.name ?? '',
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if (user?.isVerified == true)
                                  const Icon(
                                    Icons.verified,
                                    size: 14,
                                    color: AppColors.accent,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${user?.cohort ?? ''} • ${user?.campus ?? ''}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Privacy selector dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _privacyScope,
                            isDense: true,
                            icon: const Icon(Icons.arrow_drop_down, size: 18),
                            items: const [
                              DropdownMenuItem(
                                value: 'Công khai',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.public,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Công khai',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Nội bộ FPT',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.school,
                                      size: 14,
                                      color: AppColors.secondary,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Nội bộ FPT',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null)
                                setState(() => _privacyScope = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category Selector (Horizontal Scroll Chips - FO-02)
                  Text(
                    'Chọn danh mục bài viết',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = cat == _selectedCategory;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => _selectedCategory = cat),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceVariant,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campus selector (FO-03)
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Cơ sở FPT liên quan:',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedCampus,
                          isDense: true,
                          isExpanded: true,
                          underline: Container(
                            height: 1,
                            color: AppColors.secondary,
                          ),
                          items: _campuses.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.secondary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null)
                              setState(() => _selectedCampus = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.border),

                  Row(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Chuyên ngành:',
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedMajor,
                          isExpanded: true,
                          selectedItemBuilder: (context) => const [
                            Text(
                              'Tất cả',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Kỹ thuật phần mềm',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Trí tuệ nhân tạo',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'An toàn thông tin',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Thiết kế đồ họa',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Kinh doanh quốc tế',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Truyền thông đa phương tiện',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Marketing',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          items: const [
                            DropdownMenuItem(
                              value: 'All',
                              child: Text('Tất cả'),
                            ),
                            DropdownMenuItem(
                              value: 'SE',
                              child: Text('Kỹ thuật phần mềm'),
                            ),
                            DropdownMenuItem(
                              value: 'AI',
                              child: Text('Trí tuệ nhân tạo'),
                            ),
                            DropdownMenuItem(
                              value: 'IA',
                              child: Text('An toàn thông tin'),
                            ),
                            DropdownMenuItem(
                              value: 'GD',
                              child: Text('Thiết kế đồ họa'),
                            ),
                            DropdownMenuItem(
                              value: 'IB',
                              child: Text('Kinh doanh quốc tế'),
                            ),
                            DropdownMenuItem(
                              value: 'MC',
                              child: Text('Truyền thông đa phương tiện'),
                            ),
                            DropdownMenuItem(
                              value: 'MKT',
                              child: Text('Marketing'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null)
                              setState(() => _selectedMajor = value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.border),

                  // Title Input Field
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Tiêu đề bài viết (tuỳ chọn)',
                      hintStyle: AppTypography.titleMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                    ),
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Divider(height: 16, color: AppColors.border),

                  // Content Area (Large expandable TextField)
                  TextField(
                    controller: _contentController,
                    maxLines: null,
                    minLines: 8,
                    decoration: InputDecoration(
                      hintText: 'Bạn muốn chia sẻ điều gì với cộng đồng FPT Alumni hôm nay? Thêm #hashtag hoặc hỏi ý kiến các anh chị cựu SV...',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      border: InputBorder.none,
                    ),
                    style: AppTypography.bodyLarge.copyWith(height: 1.5),
                  ),

                  const SizedBox(height: 16),

                  // Quick Hashtag Suggestions
                  Text(
                    'Gợi ý hashtag nhanh:',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickHashtags.map((tag) {
                      return ActionChip(
                        label: Text(tag),
                        onPressed: () => _addHashtag(tag),
                        backgroundColor: AppColors.background,
                        labelStyle: AppTypography.labelSmall.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppColors.border),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_imageUrls.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Ảnh đính kèm (${_imageUrls.length})',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: List.generate(
                        _imageUrls.length,
                        (index) => InputChip(
                          avatar: const Icon(Icons.image_outlined, size: 18),
                          label: Text('Ảnh ${index + 1}'),
                          onDeleted: () => setState(() {
                            _imageUrls.removeAt(index);
                          }),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Attachment Toolbar (Sticky Bottom above keyboard)
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: MediaQuery.of(context).padding.bottom + 10,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.image_outlined,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'Đính kèm hình ảnh',
                  onPressed: _uploadingImage ? null : _showImageOptions,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.picture_as_pdf_outlined,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'Đính kèm tài liệu',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'BE chưa có API upload file. Ảnh hiện được đính kèm bằng URL qua nút hình ảnh.',
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.link, color: AppColors.textSecondary),
                  tooltip: 'Chèn liên kết',
                  onPressed: () {
                    _contentController.text =
                        '${_contentController.text} https://github.com/';
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.alternate_email,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'Tag Mentor',
                  onPressed: () {
                    _contentController.text =
                        '${_contentController.text} @Mentor ';
                  },
                ),
                if (_uploadingImage)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        value: _imageUploadProgress > 0
                            ? _imageUploadProgress
                            : null,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _submitting || _uploadingImage
                      ? null
                      : _submitPost,
                  icon: _submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.publish_outlined, size: 18),
                  label: Text(
                    _submitting
                        ? 'Đang đăng'
                        : widget.postId == null
                        ? 'Đăng bài'
                        : 'Lưu sửa',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
