import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/features/feed/data/models/feed_models.dart';
import 'package:alumni_connect/features/feed/data/feed_repository.dart';
import 'package:alumni_connect/features/lab3/data/services/firebase_analytics_service.dart';

// States
abstract class FeedState {}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedFailure extends FeedState {
  FeedFailure(this.message);
  final String message;
}

class FeedLoaded extends FeedState {
  final List<MentorStory> stories;
  final List<PostItem> posts;
  final String selectedCategory;
  final String searchQuery;

  FeedLoaded({
    required this.stories,
    required this.posts,
    required this.selectedCategory,
    this.searchQuery = '',
  });

  List<PostItem> get filteredPosts {
    return posts.where((p) {
      final matchesSearch =
          searchQuery.isEmpty ||
          p.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.content.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.tags.any(
            (t) => t.toLowerCase().contains(searchQuery.toLowerCase()),
          ) ||
          p.authorName.toLowerCase().contains(searchQuery.toLowerCase());
      // Category, campus, sort, and answered filters are applied by Forum API.
      return matchesSearch;
    }).toList();
  }

  FeedLoaded copyWith({
    List<MentorStory>? stories,
    List<PostItem>? posts,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return FeedLoaded(
      stories: stories ?? this.stories,
      posts: posts ?? this.posts,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Cubit
class FeedCubit extends Cubit<FeedState> {
  FeedCubit(this.repository, {this.analyticsService}) : super(FeedInitial());
  final FeedRepository repository;
  final FirebaseAnalyticsService? analyticsService;
  String? get selectedCampus => _campus;
  String _search = '';
  String _category = 'Tất cả';
  String? _campus;
  String _sort = 'latest';
  bool? _answered;

  void trackPostOpened() {
    final analytics = analyticsService;
    if (analytics == null) return;
    unawaited(analytics.logSelectContent(AnalyticsContentType.post));
    unawaited(analytics.logViewItem(AnalyticsContentType.post));
  }

  void trackSearchResults() {
    if (_search.trim().isEmpty) return;
    final analytics = analyticsService;
    if (analytics == null) return;
    final count = state is FeedLoaded
        ? (state as FeedLoaded).filteredPosts.length
        : null;
    unawaited(
      analytics.logSearch(AnalyticsSearchType.feed, resultCount: count),
    );
  }

  Future<void> loadFeed() async {
    emit(FeedLoading());
    try {
      final page = await repository.getFeed(
        search: _search,
        postType: _postType(_category),
        major: _major(_category),
        campus: _campus,
        sort: _sort,
        isAnswered: _answered,
      );
      emit(
        FeedLoaded(
          stories: const [],
          posts: page.items,
          selectedCategory: _category,
          searchQuery: _search,
        ),
      );
    } catch (e) {
      emit(FeedFailure(e.toString()));
    }
  }

  Future<FeedPage> loadMyPosts() => repository.getMyPosts();

  void selectCategory(String category) {
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      _category = category;
      emit(currentState.copyWith(selectedCategory: category));
      loadFeed();
    }
  }

  void selectCampus(String? campus) {
    _campus = campus;
    loadFeed();
  }

  String get selectedSort => _sort;
  bool? get answeredFilter => _answered;
  void selectSort(String sort) {
    _sort = sort;
    loadFeed();
  }

  void selectAnswered(bool? answered) {
    _answered = answered;
    loadFeed();
  }

  Future<void> toggleLike(String postId) async {
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      final matches = currentState.posts.where((p) => p.id == postId);
      final existing = matches.isEmpty ? null : matches.first;
      if (existing == null) return;
      final desired = !existing.isLiked;
      final optimistic = currentState.posts
          .map(
            (post) => post.id == postId
                ? post.copyWith(
                    isLiked: desired,
                    likes: (post.likes + (desired ? 1 : -1))
                        .clamp(0, 1 << 30)
                        .toInt(),
                  )
                : post,
          )
          .toList();
      emit(currentState.copyWith(posts: optimistic));
      try {
        final actual = await repository.toggleLike(postId);
        final latest = state;
        if (latest is FeedLoaded) {
          emit(
            latest.copyWith(
              posts: latest.posts
                  .map((p) => p.id == postId ? p.copyWith(isLiked: actual) : p)
                  .toList(),
            ),
          );
        }
      } catch (_) {
        emit(currentState);
      }
      return;
    }
  }

  void searchPosts(String query) {
    _search = query;
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      emit(currentState.copyWith(searchQuery: query));
    }
    loadFeed();
  }

  Future<void> createPost({
    required String title,
    required String content,
    required String postType,
    required String campus,
    required String major,
    List<String> tags = const [],
    List<String> imageUrls = const [],
  }) async {
    await repository.createPost(
      title: title,
      content: content,
      postType: postType,
      campus: campus,
      major: major,
      tags: tags,
      imageUrls: imageUrls,
    );
    await loadFeed();
  }

  Future<void> updatePost({
    required String id,
    required String title,
    required String content,
    required String postType,
    required String campus,
    required String major,
    List<String> tags = const [],
    List<String> imageUrls = const [],
  }) async {
    await repository.updatePost(
      id: id,
      title: title,
      content: content,
      postType: postType,
      campus: campus,
      major: major,
      tags: tags,
      imageUrls: imageUrls,
    );
    await loadFeed();
  }

  String? _postType(String category) => switch (category) {
    'Hỏi đáp Mentor' || 'Hỏi đáp & Thảo luận' => 'Question',
    'Việc làm & Referral' || 'Cơ hội việc làm / Thực tập' => 'Recruitment',
    _ => null,
  };

  String? _major(String category) => switch (category) {
    'CNTT & Phần mềm' => 'SE',
    'Kinh tế & Marketing' => 'MKT',
    _ => null,
  };
}
