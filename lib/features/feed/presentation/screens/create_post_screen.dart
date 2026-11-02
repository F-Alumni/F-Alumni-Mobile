import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/core/theme/app_typography.dart';
import 'package:alumni_connect/features/feed/data/models/feed_models.dart';
import 'package:alumni_connect/features/feed/presentation/cubit/feed_cubit.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String _selectedCategory = 'Hỏi đáp & Thảo luận';
  String _selectedCampus = 'FPT Đà Nẵng';
  String _privacyScope = 'Công khai';
  bool _hasImageAttached = false;

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

  void _submitPost() {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung bài viết trước khi đăng!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final newPost = PostItem(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      authorName: 'Nguyễn Văn An',
      authorRole: 'Sinh viên K16 • Kỹ thuật phần mềm',
      authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      timeAgo: 'Vừa xong',
      isVerified: true,
      title: _titleController.text.trim(),
      content: content,
      campus: _selectedCampus,
      category: _selectedCategory,
      attachmentTitle: _hasImageAttached ? 'Ảnh đính kèm từ thư viện' : null,
      attachmentImageUrl: _hasImageAttached
          ? 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=600'
          : null,
      tags: _quickHashtags.take(3).toList(),
      likes: 1,
      comments: 0,
      shares: 0,
      isLiked: true,
    );

    context.read<FeedCubit>().addNewPost(newPost);
    context.pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đăng bài viết thành công lên Diễn đàn FPT!'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Tạo bài viết',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ElevatedButton(
              onPressed: _submitPost,
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
                'Đăng bài',
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
                      const CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Nguyễn Văn An',
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, size: 14, color: AppColors.accent),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'K16 • Kỹ thuật phần mềm',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Privacy selector dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                                    Icon(Icons.public, size: 14, color: AppColors.textSecondary),
                                    SizedBox(width: 4),
                                    Text('Công khai', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Nội bộ FPT',
                                child: Row(
                                  children: [
                                    Icon(Icons.school, size: 14, color: AppColors.secondary),
                                    SizedBox(width: 4),
                                    Text('Nội bộ FPT', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _privacyScope = val);
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
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
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
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceVariant,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.border,
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
                      const Icon(Icons.location_on_outlined, size: 18, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      Text(
                        'Cơ sở FPT liên quan:',
                        style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: _selectedCampus,
                        isDense: true,
                        underline: Container(height: 1, color: AppColors.secondary),
                        items: _campuses.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(
                              c,
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.secondary),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCampus = val);
                        },
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
                      hintText:
                          'Bạn muốn chia sẻ điều gì với cộng đồng FPT Alumni hôm nay? Thêm #hashtag hoặc hỏi ý kiến các anh chị cựu SV...',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      border: InputBorder.none,
                    ),
                    style: AppTypography.bodyLarge.copyWith(height: 1.5),
                  ),

                  // Attached Image Mockup Preview
                  if (_hasImageAttached) ...[
                    const SizedBox(height: 12),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=600',
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _hasImageAttached = false),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Quick Hashtag Suggestions
                  Text(
                    'Gợi ý hashtag nhanh:',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
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
                    color: _hasImageAttached ? AppColors.primary : AppColors.textSecondary,
                  ),
                  tooltip: 'Đính kèm hình ảnh',
                  onPressed: () {
                    setState(() => _hasImageAttached = !_hasImageAttached);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.textSecondary),
                  tooltip: 'Đính kèm tài liệu',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã chọn file PDF tài liệu')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.link, color: AppColors.textSecondary),
                  tooltip: 'Chèn liên kết',
                  onPressed: () {
                    _contentController.text = '${_contentController.text} https://github.com/';
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.alternate_email, color: AppColors.textSecondary),
                  tooltip: 'Tag Mentor',
                  onPressed: () {
                    _contentController.text = '${_contentController.text} @Mentor ';
                  },
                ),
                const Spacer(),
                Text(
                  'Đã lưu nháp',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
