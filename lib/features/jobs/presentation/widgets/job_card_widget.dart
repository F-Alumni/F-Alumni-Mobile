import 'package:flutter/material.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/core/theme/app_typography.dart';
import 'package:alumni_connect/features/jobs/data/models/job_model.dart';

class JobCardWidget extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;
  final VoidCallback onSave;

  const JobCardWidget({
    super.key,
    required this.job,
    required this.onTap,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company info & Bookmark
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: job.companyLogo.isEmpty
                          ? Container(
                              width: 44,
                              height: 44,
                              color: AppColors.surfaceVariant,
                              child: const Icon(Icons.work_outline),
                            )
                          : Image.network(
                              job.companyLogo,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 44,
                                height: 44,
                                color: AppColors.surfaceVariant,
                                child: const Icon(Icons.work_outline),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.companyName,
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            job.title,
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        job.isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: job.isSaved
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                      onPressed: onSave,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Salary & Location pills
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        job.salary,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          job.location,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Referral Alumni Badge (Screen 9 highlight)
                if (job.hasReferral)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.secondary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundImage: NetworkImage(
                            job.referralAlumniAvatar,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Referral từ: ',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextSpan(
                                  text: job.referralAlumniName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                TextSpan(
                                  text: ' (${job.referralAlumniRole})',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'BẢO CHỨNG',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Tags & Posted time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        children: job.tags.take(3).map((tag) {
                          return Text(
                            tag,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Text(
                      job.postedTime,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
