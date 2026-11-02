import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/features/directory/presentation/cubit/directory_cubit.dart';
import 'package:alumni_connect/features/directory/presentation/widgets/alumni_card_widget.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DirectoryContent();
  }
}

class _DirectoryContent extends StatelessWidget {
  const _DirectoryContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Danh bạ Cựu sinh viên FPT',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Danh sách thành viên từ User Service',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, size: 22),
            onPressed: () => _showFilters(context),
          ),
        ],
      ),
      body: BlocBuilder<DirectoryCubit, DirectoryState>(
        builder: (context, state) {
          if (state is DirectoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.fptOrange),
            );
          }

          if (state is DirectoryError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<DirectoryCubit>().loadDirectory(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is DirectoryLoaded) {
            return RefreshIndicator(
              color: AppColors.fptOrange,
              onRefresh: () => context.read<DirectoryCubit>().loadDirectory(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                children: [
                  // 1. Search Box
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: TextField(
                      onChanged: (val) =>
                          context.read<DirectoryCubit>().search(val),
                      decoration: InputDecoration(
                        hintText: 'Tìm theo tên, vị trí, công ty, kỹ năng...',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textMuted,
                        ),
                        suffixIcon: const Icon(
                          Icons.filter_list,
                          color: AppColors.fptBlue,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),

                  // 2. Quick Filter Chips Bar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context
                              .read<DirectoryCubit>()
                              .toggleMentorFilter(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: state.filterOnlyMentors
                                  ? const Color(0xFFECFDF5)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: state.filterOnlyMentors
                                    ? const Color(0xFFA7F3D0)
                                    : AppColors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: state.filterOnlyMentors
                                      ? AppColors.fptGreen
                                      : AppColors.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Sẵn sàng Mentoring',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: state.filterOnlyMentors
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: state.filterOnlyMentors
                                        ? const Color(0xFF065F46)
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Mentor matching is provided by the AI service.
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.fptOrange.withValues(alpha: 0.12),
                          AppColors.fptBlue.withValues(alpha: 0.08),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: AppColors.fptOrange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Tìm mentor phù hợp với mục tiêu của bạn',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Gợi ý mentor dùng API AI; lịch hẹn chưa có API.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. Alumni Card List
                  ...state.alumni.map((a) => AlumniCardWidget(alumni: a)),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _showFilters(BuildContext context) async {
    final campusController = TextEditingController();
    final majorController = TextEditingController();
    final filters = await showDialog<(String, String)>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Lọc danh bạ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: campusController,
              decoration: const InputDecoration(labelText: 'Campus'),
            ),
            TextField(
              controller: majorController,
              decoration: const InputDecoration(labelText: 'Ngành học'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, ('', '')),
            child: const Text('Xóa lọc'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, (
              campusController.text.trim(),
              majorController.text.trim(),
            )),
            child: const Text('Áp dụng'),
          ),
        ],
      ),
    );
    campusController.dispose();
    majorController.dispose();
    if (filters != null && context.mounted) {
      await context.read<DirectoryCubit>().setFilters(
        campus: filters.$1,
        major: filters.$2,
      );
    }
  }
}
