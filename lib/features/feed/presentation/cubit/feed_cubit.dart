import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/features/feed/data/models/feed_models.dart';
import 'package:alumni_connect/features/feed/data/mock/feed_mock_data.dart';

// States
abstract class FeedState {}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

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
      final matchesCategory = selectedCategory == 'Tất cả' ||
          p.category.toLowerCase().contains(selectedCategory.toLowerCase()) ||
          p.tags.any((t) => t.toLowerCase().contains(selectedCategory.toLowerCase()));
      final matchesSearch = searchQuery.isEmpty ||
          p.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.content.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.tags.any((t) => t.toLowerCase().contains(searchQuery.toLowerCase())) ||
          p.authorName.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
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
  FeedCubit() : super(FeedInitial());

  void loadFeed() {
    emit(FeedLoading());
    emit(FeedLoaded(
      stories: FeedMockData.mockStories,
      posts: FeedMockData.mockPosts,
      selectedCategory: 'Tất cả',
    ));
  }

  void selectCategory(String category) {
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      emit(currentState.copyWith(selectedCategory: category));
    }
  }

  void toggleLike(String postId) {
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == postId) {
          final isLiked = !post.isLiked;
          return post.copyWith(
            isLiked: isLiked,
            likes: isLiked ? post.likes + 1 : (post.likes > 0 ? post.likes - 1 : 0),
          );
        }
        return post;
      }).toList();

      emit(currentState.copyWith(posts: updatedPosts));
    }
  }

  void toggleSave(String postId) {
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(isSaved: !post.isSaved);
        }
        return post;
      }).toList();

      emit(currentState.copyWith(posts: updatedPosts));
    }
  }

  void addComment(String postId, String commentText, {String? parentCommentId}) {
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == postId) {
          final newComment = CommentItem(
            id: 'cmt_${DateTime.now().millisecondsSinceEpoch}',
            authorName: 'Nguyễn Văn An',
            authorRole: 'Sinh viên K16 • FPT University',
            authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
            timeAgo: 'Vừa xong',
            content: commentText,
          );

          List<CommentItem> updatedComments = List.from(post.commentList);
          if (parentCommentId == null) {
            updatedComments.insert(0, newComment);
          } else {
            updatedComments = updatedComments.map((c) {
              if (c.id == parentCommentId) {
                return c.copyWith(
                  replies: [...c.replies, newComment],
                );
              }
              return c;
            }).toList();
          }

          return post.copyWith(
            commentList: updatedComments,
            comments: post.comments + 1,
          );
        }
        return post;
      }).toList();

      emit(currentState.copyWith(posts: updatedPosts));
    }
  }

  void searchPosts(String query) {
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      emit(currentState.copyWith(searchQuery: query));
    }
  }

  void deletePost(String postId) {
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      final updatedPosts = currentState.posts.where((p) => p.id != postId).toList();
      emit(currentState.copyWith(posts: updatedPosts));
    }
  }

  void editPost(String postId, String newTitle, String newContent) {
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(title: newTitle, content: newContent);
        }
        return post;
      }).toList();
      emit(currentState.copyWith(posts: updatedPosts));
    }
  }
}
