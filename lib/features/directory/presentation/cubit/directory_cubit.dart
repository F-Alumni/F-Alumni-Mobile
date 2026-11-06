import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/features/directory/data/directory_repository.dart';
import 'package:alumni_connect/features/directory/data/models/alumni_model.dart';
import 'package:alumni_connect/features/ai/data/ai_repository.dart';
import 'package:alumni_connect/features/lab3/data/services/firebase_analytics_service.dart';

abstract class DirectoryState {}

class DirectoryInitial extends DirectoryState {}

class DirectoryLoading extends DirectoryState {}

class DirectoryError extends DirectoryState {
  DirectoryError(this.message);
  final String message;
}

class DirectoryLoaded extends DirectoryState {
  DirectoryLoaded({
    required this.alumni,
    this.filterOnlyMentors = false,
    this.searchQuery = '',
    this.campus = '',
    this.major = '',
  });
  final List<AlumniModel> alumni;
  final bool filterOnlyMentors;
  final String searchQuery;
  final String campus;
  final String major;

  DirectoryLoaded copyWith({
    List<AlumniModel>? alumni,
    bool? filterOnlyMentors,
    String? searchQuery,
    String? campus,
    String? major,
  }) => DirectoryLoaded(
    alumni: alumni ?? this.alumni,
    filterOnlyMentors: filterOnlyMentors ?? this.filterOnlyMentors,
    searchQuery: searchQuery ?? this.searchQuery,
    campus: campus ?? this.campus,
    major: major ?? this.major,
  );
}

class DirectoryCubit extends Cubit<DirectoryState> {
  DirectoryCubit(this._repository, this._aiRepository, {this.analyticsService})
    : super(DirectoryInitial());
  final DirectoryRepository _repository;
  final AiRepository _aiRepository;
  final FirebaseAnalyticsService? analyticsService;
  bool _mentorFilter = false;
  String _query = '';
  String _campus = '';
  String _major = '';

  void trackAlumniOpened() {
    final analytics = analyticsService;
    if (analytics == null) return;
    unawaited(analytics.logSelectContent(AnalyticsContentType.alumni));
    unawaited(analytics.logViewItem(AnalyticsContentType.alumni));
  }

  void trackSearchResults() {
    if (_query.trim().isEmpty) return;
    final analytics = analyticsService;
    if (analytics == null) return;
    final count = state is DirectoryLoaded
        ? (state as DirectoryLoaded).alumni.length
        : null;
    unawaited(
      analytics.logSearch(AnalyticsSearchType.alumni, resultCount: count),
    );
  }

  Future<void> loadDirectory() => _load();

  Future<void> toggleMentorFilter() async {
    _mentorFilter = !_mentorFilter;
    await _load();
  }

  Future<void> search(String query) async {
    _query = query;
    await _load();
  }

  Future<void> setFilters({String? campus, String? major}) async {
    _campus = campus ?? _campus;
    _major = major ?? _major;
    await _load();
  }

  Future<void> _load() async {
    emit(DirectoryLoading());
    try {
      final rows = _mentorFilter
          ? await _aiRepository.recommendMentors()
          : await _repository.search(
              query: _query,
              campus: _campus,
              major: _major,
            );
      final filtered = _mentorFilter && _query.isNotEmpty
          ? rows
                .where(
                  (mentor) =>
                      mentor.name.toLowerCase().contains(
                        _query.toLowerCase(),
                      ) ||
                      mentor.company.toLowerCase().contains(
                        _query.toLowerCase(),
                      ) ||
                      mentor.currentRole.toLowerCase().contains(
                        _query.toLowerCase(),
                      ) ||
                      mentor.skills.any(
                        (skill) =>
                            skill.toLowerCase().contains(_query.toLowerCase()),
                      ),
                )
                .toList()
          : rows;
      emit(
        DirectoryLoaded(
          alumni: filtered,
          filterOnlyMentors: _mentorFilter,
          searchQuery: _query,
          campus: _campus,
          major: _major,
        ),
      );
    } catch (error) {
      emit(DirectoryError(error.toString()));
    }
  }
}
