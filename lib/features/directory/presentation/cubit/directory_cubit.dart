import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/features/directory/data/models/alumni_model.dart';
import 'package:alumni_connect/features/directory/data/mock/directory_mock_data.dart';

abstract class DirectoryState {}

class DirectoryInitial extends DirectoryState {}

class DirectoryLoading extends DirectoryState {}

class DirectoryLoaded extends DirectoryState {
  final List<AlumniModel> alumni;
  final bool filterOnlyMentors;
  final String searchQuery;

  DirectoryLoaded({
    required this.alumni,
    this.filterOnlyMentors = true,
    this.searchQuery = '',
  });

  DirectoryLoaded copyWith({
    List<AlumniModel>? alumni,
    bool? filterOnlyMentors,
    String? searchQuery,
  }) {
    return DirectoryLoaded(
      alumni: alumni ?? this.alumni,
      filterOnlyMentors: filterOnlyMentors ?? this.filterOnlyMentors,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class DirectoryCubit extends Cubit<DirectoryState> {
  DirectoryCubit() : super(DirectoryInitial());

  void loadDirectory() {
    emit(DirectoryLoading());
    emit(DirectoryLoaded(
      alumni: DirectoryMockData.alumniList,
      filterOnlyMentors: true,
    ));
  }

  void toggleMentorFilter() {
    if (state is DirectoryLoaded) {
      final current = state as DirectoryLoaded;
      final newFilter = !current.filterOnlyMentors;
      final filteredList = newFilter
          ? DirectoryMockData.alumniList.where((a) => a.isAvailableForMentoring).toList()
          : DirectoryMockData.alumniList;

      emit(current.copyWith(
        filterOnlyMentors: newFilter,
        alumni: filteredList,
      ));
    }
  }

  void search(String query) {
    if (state is DirectoryLoaded) {
      final current = state as DirectoryLoaded;
      final list = DirectoryMockData.alumniList.where((a) {
        final matchesQuery = a.name.toLowerCase().contains(query.toLowerCase()) ||
            a.company.toLowerCase().contains(query.toLowerCase()) ||
            a.currentRole.toLowerCase().contains(query.toLowerCase()) ||
            a.skills.any((s) => s.toLowerCase().contains(query.toLowerCase()));
        return current.filterOnlyMentors ? (matchesQuery && a.isAvailableForMentoring) : matchesQuery;
      }).toList();

      emit(current.copyWith(
        searchQuery: query,
        alumni: list,
      ));
    }
  }
}
