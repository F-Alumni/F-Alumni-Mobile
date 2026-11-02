import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/features/jobs/data/models/job_model.dart';
import 'package:alumni_connect/features/jobs/data/mock/jobs_mock_data.dart';

abstract class JobsState {}

class JobsInitial extends JobsState {}

class JobsLoading extends JobsState {}

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
      final matchesFilter = selectedFilter == 'Tất cả' ||
          (selectedFilter == 'OJT / Thực tập' && (job.jobType.contains('OJT') || job.jobType.contains('Thực tập'))) ||
          (selectedFilter == 'Có Referral' && job.hasReferral) ||
          (selectedFilter == 'Full-time' && job.jobType.contains('Full-time'));

      final matchesQuery = searchQuery.isEmpty ||
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
  JobsCubit() : super(JobsInitial());

  void loadJobs() {
    emit(JobsLoading());
    emit(JobsLoaded(jobs: JobsMockData.mockJobs));
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

  void toggleSaveJob(String jobId) {
    if (state is JobsLoaded) {
      final current = state as JobsLoaded;
      final updated = current.jobs.map((job) {
        if (job.id == jobId) {
          return job.copyWith(isSaved: !job.isSaved);
        }
        return job;
      }).toList();
      emit(current.copyWith(jobs: updated));
    }
  }

  void addJob(JobModel newJob) {
    if (state is JobsLoaded) {
      final current = state as JobsLoaded;
      emit(current.copyWith(jobs: [newJob, ...current.jobs]));
    }
  }
}
