import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/features/feed/data/feed_repository.dart';
import 'package:alumni_connect/features/feed/data/models/feed_models.dart';
import 'package:alumni_connect/features/jobs/data/models/job_model.dart';
import 'package:alumni_connect/features/lab3/data/services/firebase_analytics_service.dart';

abstract class JobsState {}

class JobsInitial extends JobsState {}

class JobsLoading extends JobsState {}

class JobsFailure extends JobsState {
  JobsFailure(this.message);
  final String message;
}

class JobsLoaded extends JobsState {
  final List<JobModel> jobs;
  final String selectedFilter;
  final String searchQuery;

  JobsLoaded({
    required this.jobs,
    this.selectedFilter = 'Tất cả',
    this.searchQuery = '',
  });

  List<JobModel> get filteredJobs {
    return jobs.where((job) {
      final matchesFilter =
          selectedFilter == 'Tất cả' ||
          (selectedFilter == 'OJT / Thực tập' &&
              (job.jobType.contains('OJT') ||
                  job.jobType.contains('Thực tập'))) ||
          (selectedFilter == 'Có Referral' && job.hasReferral) ||
          (selectedFilter == 'Full-time' &&
              (job.jobType.contains('Full-time') || job.jobType == 'Việc làm'));

      final matchesQuery =
          searchQuery.isEmpty ||
          job.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          job.companyName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          job.location.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesFilter && matchesQuery;
    }).toList();
  }

  JobsLoaded copyWith({
    List<JobModel>? jobs,
    String? selectedFilter,
    String? searchQuery,
  }) {
    return JobsLoaded(
      jobs: jobs ?? this.jobs,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class JobsCubit extends Cubit<JobsState> {
  JobsCubit(this._feedRepository, {this.analyticsService})
    : super(JobsInitial());
  final FeedRepository _feedRepository;
  final FirebaseAnalyticsService? analyticsService;

  JobModel? findJob(String id) {
    final current = state;
    if (current is! JobsLoaded) return null;
    for (final job in current.jobs) {
      if (job.id == id) return job;
    }
    return null;
  }

  void trackJobOpened() {
    final analytics = analyticsService;
    if (analytics == null) return;
    unawaited(analytics.logSelectContent(AnalyticsContentType.job));
    unawaited(analytics.logViewItem(AnalyticsContentType.job));
  }

  void trackSearchResults() {
    final query = state is JobsLoaded ? (state as JobsLoaded).searchQuery : '';
    if (query.trim().isEmpty) return;
    final analytics = analyticsService;
    if (analytics == null) return;
    final count = state is JobsLoaded
        ? (state as JobsLoaded).filteredJobs.length
        : null;
    unawaited(
      analytics.logSearch(AnalyticsSearchType.jobs, resultCount: count),
    );
  }

  Future<void> loadJobs() async {
    emit(JobsLoading());
    try {
      final page = await _feedRepository.getFeed(postType: 'Recruitment');
      emit(JobsLoaded(jobs: page.items.map(_jobFromPost).toList()));
    } catch (error) {
      emit(JobsFailure(error.toString()));
    }
  }

  void filterJobs(String filter) {
    if (state is JobsLoaded) {
      emit((state as JobsLoaded).copyWith(selectedFilter: filter));
    }
  }

  void searchJobs(String query) {
    if (state is JobsLoaded) {
      emit((state as JobsLoaded).copyWith(searchQuery: query));
    }
  }

  Future<void> toggleSaveJob(String jobId) async {
    final current = state;
    if (current is! JobsLoaded) return;

    JobModel? job;
    for (final item in current.jobs) {
      if (item.id == jobId) {
        job = item;
        break;
      }
    }
    if (job == null) return;

    try {
      final isSaved = await _feedRepository.toggleBookmark(jobId);
      final latest = state;
      if (latest is JobsLoaded) {
        emit(
          latest.copyWith(
            jobs: latest.jobs
                .map(
                  (item) =>
                      item.id == jobId ? item.copyWith(isSaved: isSaved) : item,
                )
                .toList(),
          ),
        );
      }
    } catch (_) {
      // Keep the server value when the bookmark request fails.
    }
  }

  void addJob(JobModel newJob) {
    if (state is JobsLoaded) {
      final current = state as JobsLoaded;
      emit(current.copyWith(jobs: [newJob, ...current.jobs]));
    }
  }

  JobModel _jobFromPost(PostItem post) {
    final text = '${post.title} ${post.content} ${post.tags.join(' ')}'
        .toLowerCase();
    final isInternship =
        text.contains('intern') ||
        text.contains('ojt') ||
        text.contains('thực tập');
    final hasReferral =
        text.contains('referral') ||
        text.contains('giới thiệu') ||
        text.contains('refer');
    final referralTag = post.tags.any(
      (tag) => tag.toLowerCase().contains('referral'),
    );

    return JobModel(
      id: post.id,
      title: post.title,
      companyName: 'Tin tuyển dụng từ cộng đồng FPT',
      companyLogo: '',
      location: post.campus,
      salary: 'Trao đổi với người đăng',
      jobType: isInternship ? 'OJT / Thực tập' : 'Việc làm',
      experienceLevel: 'Xem mô tả',
      hasReferral: hasReferral || referralTag,
      referralAlumniName: post.authorName,
      referralAlumniRole: 'Người đăng tin',
      referralAlumniAvatar: post.authorAvatar,
      postedTime: post.timeAgo,
      description: post.content,
      requirements: const [],
      benefits: const [],
      tags: post.tags,
      isSaved: post.isSaved,
    );
  }
}
