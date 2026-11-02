import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/features/directory/presentation/cubit/directory_cubit.dart';
import 'package:alumni_connect/features/directory/presentation/widgets/alumni_card_widget.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DirectoryCubit()..loadDirectory(),
      child: const _DirectoryContent(),
    );
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
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            Text(
              '2,450+ thành viên đã xác thực',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.tune, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<DirectoryCubit, DirectoryState>(
        builder: (context, state) {
          if (state is DirectoryLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.fptOrange));
          }

          if (state is DirectoryLoaded) {
            return RefreshIndicator(
              color: AppColors.fptOrange,
              onRefresh: () async {
                context.read<DirectoryCubit>().loadDirectory();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                children: [
                  // 1. Search Box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: TextField(
                      onChanged: (val) => context.read<DirectoryCubit>().search(val),
                      decoration: InputDecoration(
                        hintText: 'Tìm theo tên, vị trí, công ty, kỹ năng...',
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                        suffixIcon: const Icon(Icons.filter_list, color: AppColors.fptBlue),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.read<DirectoryCubit>().toggleMentorFilter(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: state.filterOnlyMentors ? const Color(0xFFECFDF5) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: state.filterOnlyMentors ? const Color(0xFFA7F3D0) : AppColors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: state.filterOnlyMentors ? AppColors.fptGreen : AppColors.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Sẵn sàng Mentoring',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: state.filterOnlyMentors ? FontWeight.bold : FontWeight.w500,
                                    color: state.filterOnlyMentors ? const Color(0xFF065F46) : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip('Ngành học ▾'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Khóa K10-K15 ▾'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Campus ▾'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Công ty ▾'),
                      ],
                    ),
                  ),

                  // 3. Spotlight Banner
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          child: const Icon(Icons.auto_awesome, color: AppColors.fptOrange, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                '120+ Cựu SV sẵn sàng cố vấn OJT kỳ này!',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Đặt lịch 1-1 miễn phí để được review CV & Mock interview.',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
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

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
      ),
    );
  }
}
