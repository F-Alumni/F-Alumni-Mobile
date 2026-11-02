import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/core/theme/app_typography.dart';
import 'package:alumni_connect/features/jobs/data/models/job_model.dart';
import 'package:alumni_connect/features/jobs/presentation/cubit/jobs_cubit.dart';

class JobDetailScreen extends StatelessWidget {
  final String jobId;

  const JobDetailScreen({
    super.key,
    required this.jobId,
  });

  void _showReferralModal(BuildContext context, JobModel job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ứng tuyển & Nhận Referral',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Hồ sơ của bạn sẽ được gửi trực tiếp tới ${job.referralAlumniName} để bảo chứng tới bộ phận HR của ${job.companyName}.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            // CV attached card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: AppColors.primary, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('CV_NguyenVanAn_SoftwareEngineer.pdf', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Đã cập nhật từ Hồ sơ cá nhân • 1.8 MB', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Thay đổi', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Lời nhắn gửi tới Mentor / Cựu SV bảo chứng (Điểm mạnh, mục tiêu, lý do phù hợp)...',
                hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã gửi yêu cầu Referral tới ${job.referralAlumniName} thành công!'),
                      backgroundColor: AppColors.accent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Gửi hồ sơ bảo chứng', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobsCubit, JobsState>(
      builder: (context, state) {
        if (state is! JobsLoaded) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final job = state.jobs.firstWhere(
          (j) => j.id == jobId,
          orElse: () => state.jobs.first,
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
            title: Text(
              'Chi tiết công việc',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  job.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: job.isSaved ? AppColors.primary : AppColors.textSecondary,
                ),
                onPressed: () => context.read<JobsCubit>().toggleSaveJob(job.id),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: AppColors.textSecondary),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Company & Title Card
                Container(
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
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(job.companyLogo, width: 56, height: 56, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.title,
                                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  job.companyName,
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mức lương', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text(job.salary, style: AppTypography.titleSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Hình thức', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text('${job.jobType} • ${job.experienceLevel}', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(job.location, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Referral Alumni Highlight Box (Screen 10)
                if (job.hasReferral) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified, color: AppColors.accent, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Được bảo chứng bởi Cựu sinh viên FPT',
                              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.secondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(job.referralAlumniAvatar),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(job.referralAlumniName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(job.referralAlumniRole, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Ưu đãi đặc biệt: CV gửi qua kênh Alumni Connect sẽ được chuyển thẳng tới Hiring Manager trong 24h và ưu tiên xếp lịch phỏng vấn.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Job Description
                _buildSectionContainer(
                  title: 'Mô tả công việc',
                  content: Text(job.description, style: AppTypography.bodyMedium.copyWith(height: 1.5)),
                ),
                const SizedBox(height: 16),

                // Requirements
                _buildSectionContainer(
                  title: 'Yêu cầu ứng viên',
                  content: Column(
                    children: job.requirements.map((req) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppColors.accent, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(req, style: AppTypography.bodyMedium.copyWith(height: 1.4))),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Benefits
                _buildSectionContainer(
                  title: 'Quyền lợi & Đãi ngộ',
                  content: Column(
                    children: job.benefits.map((b) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.star_outline, color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(b, style: AppTypography.bodyMedium.copyWith(height: 1.4))),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomSheet: Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: const Border(top: BorderSide(color: AppColors.border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: IconButton(
                    icon: Icon(
                      job.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: job.isSaved ? AppColors.primary : AppColors.textSecondary,
                    ),
                    onPressed: () => context.read<JobsCubit>().toggleSaveJob(job.id),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showReferralModal(context, job),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      job.hasReferral ? 'Ứng tuyển & Nhận Referral' : 'Nộp đơn ứng tuyển',
                      style: AppTypography.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionContainer({required String title, required Widget content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}
