import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/core/theme/app_typography.dart';
import 'package:alumni_connect/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:alumni_connect/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:alumni_connect/features/admin/presentation/screens/admin_moderation_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trung tâm Quản trị Admin',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Hệ thống điều hành Alumni Connect (AD-01 → AD-08)',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Tổng quan KPI (AD-08)'),
            Tab(text: 'Người dùng (AD-01)'),
            Tab(text: 'Kiểm duyệt (AD-04)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKpiOverviewTab(),
          const AdminUsersScreen(),
          const AdminModerationScreen(),
        ],
      ),
    );
  }

  Widget _buildKpiOverviewTab() {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is! AdminLoaded) {
          return Center(
            child: state is AdminError
                ? Text(state.message)
                : const CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chỉ số tổng quan hệ thống (AD-08)',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // 2x2 Metric Cards Grid (Stitch Screen 14 & Screen 20)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Tổng người dùng',
                      value: '${state.totalUsers}',
                      subtitle: 'Tổng số từ User Service',
                      icon: Icons.people,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Alumni xác thực',
                      value: state.verifiedAlumniCount < 0
                          ? '—'
                          : '${state.verifiedAlumniCount}',
                      subtitle: 'Chưa có API thống kê xác thực',
                      icon: Icons.verified,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Sinh viên FPT',
                      value: state.activeStudentsCount < 0
                          ? '—'
                          : '${state.activeStudentsCount}',
                      subtitle: 'Chưa có API thống kê sinh viên',
                      icon: Icons.school,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Báo cáo cần xử lý',
                      value: state.unresolvedReportsCount < 0
                          ? '—'
                          : '${state.unresolvedReportsCount}',
                      subtitle: 'Chưa có API báo cáo kiểm duyệt',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                'Phân bố theo campus chưa có API thống kê',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Tác vụ quản trị nhanh',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(
                        Icons.manage_accounts,
                        color: AppColors.secondary,
                      ),
                      label: const Text(
                        'Xem User',
                        style: TextStyle(color: AppColors.secondary),
                      ),
                      onPressed: () => _tabController.animateTo(1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.security, color: AppColors.error),
                      label: const Text(
                        'Xử lý vi phạm',
                        style: TextStyle(color: AppColors.error),
                      ),
                      onPressed: () => _tabController.animateTo(2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
