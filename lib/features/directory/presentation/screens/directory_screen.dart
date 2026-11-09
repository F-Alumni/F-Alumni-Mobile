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

  static const _campusChips = <String, String>{
    '': 'Tất cả Campus',
    'HCM': 'TP.HCM',
    'HN': 'Hòa Lạc (HN)',
    'DN': 'Đà Nẵng',
    'CT': 'Cần Thơ',
    'QN': 'Quy Nhơn',
  };

  static const _majorChips = <String, String>{
    '': 'Tất cả Ngành',
    'SE': 'Kỹ thuật phần mềm (SE)',
    'AI': 'Trí tuệ nhân tạo (AI)',
    'IA': 'An toàn thông tin (IA)',
    'MKT': 'Marketing (MKT)',
    'IB': 'Kinh doanh quốc tế (IB)',
    'GD': 'Thiết kế đồ họa (GD)',
  };

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
              'Kết nối thành viên & Mentor FPTU (US-05, US-06)',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Lọc theo Campus & Ngành (US-06)',
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
                      onSubmitted: (_) =>
                          context.read<DirectoryCubit>().trackSearchResults(),
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
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.filter_list,
                            color: AppColors.fptBlue,
                          ),
                          onPressed: () => _showFilters(context),
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
                        if (state.campus.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          InputChip(
                            label: Text(
                              'Campus: ${_campusChips[state.campus] ?? state.campus}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            onDeleted: () => context
                                .read<DirectoryCubit>()
                                .setFilters(campus: '', major: state.major),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                        if (state.major.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          InputChip(
                            label: Text(
                              'Ngành: ${_majorChips[state.major] ?? state.major}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            onDeleted: () => context
                                .read<DirectoryCubit>()
                                .setFilters(campus: state.campus, major: ''),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 3. Mentor matching banner
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
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
                                'Kết nối 1-1 qua Chat hoặc xem link lịch hẹn Google Calendar trên hồ sơ.',
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

                  // 4. Alumni Card List or Empty State
                  if (state.alumni.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: const [
                            Icon(
                              Icons.people_outline,
                              size: 48,
                              color: AppColors.textMuted,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Không tìm thấy cựu sinh viên phù hợp với bộ lọc.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...state.alumni.map(
                      (a) => AlumniCardWidget(
                        alumni: a,
                        onViewProfile: context
                            .read<DirectoryCubit>()
                            .trackAlumniOpened,
                      ),
                    ),
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
    final cubit = context.read<DirectoryCubit>();
    final current = cubit.state;
    var selectedCampus = current is DirectoryLoaded ? current.campus : '';
    var selectedMajor = current is DirectoryLoaded ? current.major : '';

    final filters = await showModalBottomSheet<(String, String)>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lọc danh bạ Cựu sinh viên (US-06)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setSheetState(() {
                          selectedCampus = '';
                          selectedMajor = '';
                        });
                      },
                      child: const Text('Xóa lọc'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cơ sở FPTU (Campus)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final entry in _campusChips.entries)
                      ChoiceChip(
                        label: Text(entry.value),
                        selected: selectedCampus == entry.key,
                        onSelected: (_) =>
                            setSheetState(() => selectedCampus = entry.key),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Chuyên ngành (Major)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final entry in _majorChips.entries)
                      ChoiceChip(
                        label: Text(entry.value),
                        selected: selectedMajor == entry.key,
                        onSelected: (_) =>
                            setSheetState(() => selectedMajor = entry.key),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(sheetContext, (
                      selectedCampus,
                      selectedMajor,
                    )),
                    child: const Text('Áp dụng bộ lọc'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (filters != null && context.mounted) {
      await cubit.setFilters(campus: filters.$1, major: filters.$2);
    }
  }
}
