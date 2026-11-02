import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/core/theme/app_typography.dart';
import 'package:alumni_connect/features/admin/presentation/cubit/admin_cubit.dart';

class AdminModerationScreen extends StatelessWidget {
  const AdminModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is! AdminLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = state.reports;

        if (reports.isEmpty) {
          return Center(
            child: Text(
              'Không có bài viết nào bị báo cáo vi phạm',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: report.isHidden ? Colors.grey.shade100 : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: report.isHidden ? Colors.grey.shade300 : AppColors.error.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: report.isHidden ? Colors.grey : AppColors.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          report.isHidden ? 'Đã gỡ bài' : (report.isResolved ? 'Đã bỏ qua' : 'Cần xử lý'),
                          style: TextStyle(
                            color: report.isHidden ? Colors.white : (report.isResolved ? AppColors.textSecondary : AppColors.error),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        report.reportTime,
                        style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    report.postTitle,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: report.isHidden ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tác giả: ${report.postAuthor} • Báo cáo bởi: ${report.reporterName}',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.error),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Lý do vi phạm: ${report.reason}',
                            style: const TextStyle(fontSize: 12, color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!report.isResolved) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => context.read<AdminCubit>().dismissReport(report.id),
                          child: const Text('Bỏ qua báo cáo (AD-07)', style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Gỡ & Ẩn bài (AD-05)', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            context.read<AdminCubit>().removeReportedPost(report.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã gỡ bài viết vi phạm khỏi Diễn đàn FPT!'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
