import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/features/jobs/presentation/cubit/jobs_cubit.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key, required this.jobId});
  final String jobId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: const Text('Chi tiết cơ hội'),
    ),
    body: BlocBuilder<JobsCubit, JobsState>(
      builder: (context, state) {
        if (state is JobsLoading || state is JobsInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is JobsFailure) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<JobsCubit>().loadJobs(),
                    child: const Text('Tải lại'),
                  ),
                ],
              ),
            ),
          );
        }

        final job = context.read<JobsCubit>().findJob(jobId);
        if (job == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Không tìm thấy cơ hội tuyển dụng này.'),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              job.title,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              job.companyName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DetailChip(
                  icon: Icons.location_on_outlined,
                  text: job.location,
                ),
                _DetailChip(icon: Icons.work_outline, text: job.jobType),
                _DetailChip(icon: Icons.payments_outlined, text: job.salary),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundImage: job.referralAlumniAvatar.isEmpty
                    ? null
                    : NetworkImage(job.referralAlumniAvatar),
                child: job.referralAlumniAvatar.isEmpty
                    ? const Icon(Icons.person_outline)
                    : null,
              ),
              title: Text(job.referralAlumniName),
              subtitle: Text('${job.referralAlumniRole} • ${job.postedTime}'),
            ),
            const SizedBox(height: 16),
            Text('Mô tả', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SelectableText(job.description),
            if (job.tags.isNotEmpty) ...[
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                children: job.tags
                    .map((tag) => Chip(label: Text('#$tag')))
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/post-detail/${job.id}'),
              icon: const Icon(Icons.forum_outlined),
              label: const Text('Mở bài đăng để bình luận hoặc liên hệ'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 18),
    label: Text(text.isEmpty ? 'Không nêu' : text),
  );
}
