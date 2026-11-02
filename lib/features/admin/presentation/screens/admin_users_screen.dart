import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/core/theme/app_typography.dart';
import 'package:alumni_connect/features/admin/presentation/cubit/admin_cubit.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _roleFilters = [
    'Tất cả',
    'Mentor',
    'Bị khóa',
    'Chờ duyệt',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLockConfirmDialog(BuildContext context, String userId, String userName, bool isCurrentlyLocked) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isCurrentlyLocked ? 'Mở khóa tài khoản?' : 'Khóa tài khoản vi phạm?'),
        content: Text(
          isCurrentlyLocked
              ? 'Xác nhận mở khóa hoạt động trở lại cho người dùng $userName?'
              : 'Xác nhận tạm khóa tài khoản của $userName do có hành vi vi phạm quy định diễn đàn?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrentlyLocked ? AppColors.accent : AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AdminCubit>().toggleLockUser(userId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isCurrentlyLocked ? 'Đã mở khóa $userName' : 'Đã khóa tài khoản $userName'),
                  backgroundColor: isCurrentlyLocked ? AppColors.accent : AppColors.error,
                ),
              );
            },
            child: Text(isCurrentlyLocked ? 'Mở khóa' : 'Khóa tài khoản'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is! AdminLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = state.filteredUsers;

        return Column(
          children: [
            // Search Input (AD-02)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => context.read<AdminCubit>().searchUsers(val),
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên, email @fpt.edu.vn, MSSV...',
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

            // Role Filters
            SizedBox(
              height: 38,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _roleFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _roleFilters[index];
                  final isSelected = filter == state.userRoleFilter;
                  return ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) => context.read<AdminCubit>().filterUsersByRole(filter),
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
            ),
            const SizedBox(height: 10),

            // Users List
            Expanded(
              child: users.isEmpty
                  ? Center(
                      child: Text(
                        'Không tìm thấy người dùng phù hợp',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: user.isLocked ? AppColors.error.withOpacity(0.04) : AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: user.isLocked ? AppColors.error.withOpacity(0.4) : AppColors.border,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundImage: NetworkImage(user.avatarUrl),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                user.name,
                                                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: user.isLocked
                                                    ? AppColors.error.withOpacity(0.12)
                                                    : AppColors.secondary.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                user.isLocked ? 'Bị khóa' : user.role,
                                                style: TextStyle(
                                                  color: user.isLocked ? AppColors.error : AppColors.secondary,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '${user.email} • ${user.studentId}',
                                          style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                                        ),
                                        Text(
                                          user.campus,
                                          style: AppTypography.labelSmall.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // If Pending Alumni Verification
                              if (user.isPendingVerification) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          user.diplomaCode ?? 'Chứng chỉ/Bằng tốt nghiệp chờ duyệt',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.accent,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          minimumSize: Size.zero,
                                        ),
                                        onPressed: () => context.read<AdminCubit>().approveAlumni(user.id),
                                        child: const Text('Phê duyệt', style: TextStyle(fontSize: 11)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // Lock Reason
                              if (user.isLocked && user.lockReason != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  user.lockReason!,
                                  style: const TextStyle(color: AppColors.error, fontSize: 11, fontStyle: FontStyle.italic),
                                ),
                              ],

                              const SizedBox(height: 10),
                              const Divider(height: 1),
                              const SizedBox(height: 6),

                              // Actions Row (AD-03)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    icon: Icon(
                                      user.isLocked ? Icons.lock_open : Icons.lock_outline,
                                      size: 16,
                                      color: user.isLocked ? AppColors.accent : AppColors.error,
                                    ),
                                    label: Text(
                                      user.isLocked ? 'Mở khóa' : 'Khóa tài khoản',
                                      style: TextStyle(
                                        color: user.isLocked ? AppColors.accent : AppColors.error,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () => _showLockConfirmDialog(context, user.id, user.name, user.isLocked),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
