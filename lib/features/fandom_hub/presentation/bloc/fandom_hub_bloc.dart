import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import '../../../../core/repositories/i_fandom_hub_repository.dart';
import '../../../../core/repositories/fandom_hub_repository_impl.dart';
import 'fandom_hub_event.dart';
import 'fandom_hub_state.dart';

class FandomHubBloc extends Bloc<FandomHubEvent, FandomHubState> {
  final IFandomHubRepository _repository;

  FandomHubBloc({IFandomHubRepository? repository})
      : _repository = repository ?? FandomHubRepositoryImpl(),
        super(const FandomHubLoading()) {
    on<LoadFandomHubContentEvent>(_onLoadContent);
    on<FilterContentByCategoryEvent>(_onFilterCategory);
    on<SearchFandomContentEvent>(
      _onSearchContent,
      transformer: (events, mapper) => events
          .debounce(const Duration(milliseconds: 300))
          .switchMap(mapper),
    );
    on<ToggleBookmarkPostEvent>(_onToggleBookmarkPost);
    on<ToggleBookmarkGlossaryEvent>(_onToggleBookmarkGlossary);
  }

  Future<void> _onLoadContent(
    LoadFandomHubContentEvent event,
    Emitter<FandomHubState> emit,
  ) async {
    emit(const FandomHubLoading());
    try {
      final trending = await _repository.getTrendingPosts();
      final latest = await _repository.getLatestNews();
      final glossary = await _repository.getGlossary();

      emit(
        FandomHubLoaded(
          trendingPosts: trending,
          latestNews: latest,
          glossary: glossary,
        ),
      );
    } catch (_) {
      // Fallback
      emit(
        const FandomHubLoaded(
          trendingPosts: [],
          latestNews: [],
          glossary: [],
        ),
      );
    }
  }

  void _onFilterCategory(
    FilterContentByCategoryEvent event,
    Emitter<FandomHubState> emit,
  ) {
    if (state is FandomHubLoaded) {
      final current = state as FandomHubLoaded;
      emit(current.copyWith(activeCategory: event.category));
    }
  }

  void _onSearchContent(
    SearchFandomContentEvent event,
    Emitter<FandomHubState> emit,
  ) {
    if (state is FandomHubLoaded) {
      final current = state as FandomHubLoaded;
      emit(current.copyWith(searchQuery: event.query));
    }
  }

  Future<void> _onToggleBookmarkPost(
    ToggleBookmarkPostEvent event,
    Emitter<FandomHubState> emit,
  ) async {
    if (state is FandomHubLoaded) {
      final current = state as FandomHubLoaded;
      bool targetNewBookmarkState = true;

      final updatedNews = current.latestNews.map((post) {
        if (post.id == event.postId) {
          targetNewBookmarkState = !post.isBookmarked;
          return post.copyWith(isBookmarked: targetNewBookmarkState);
        }
        return post;
      }).toList();

      final updatedTrending = current.trendingPosts.map((post) {
        if (post.id == event.postId) {
          targetNewBookmarkState = !post.isBookmarked;
          return post.copyWith(isBookmarked: targetNewBookmarkState);
        }
        return post;
      }).toList();

      emit(current.copyWith(latestNews: updatedNews, trendingPosts: updatedTrending));

      // Persist to SQLite posts table
      await _repository.togglePostBookmark(event.postId, targetNewBookmarkState);
    }
  }

  Future<void> _onToggleBookmarkGlossary(
    ToggleBookmarkGlossaryEvent event,
    Emitter<FandomHubState> emit,
  ) async {
    if (state is FandomHubLoaded) {
      final current = state as FandomHubLoaded;
      bool newBookmark = true;
      final updatedGlossary = current.glossary.map((term) {
        if (term.id == event.termId) {
          newBookmark = !term.isBookmarked;
          return term.copyWith(isBookmarked: newBookmark);
        }
        return term;
      }).toList();

      emit(current.copyWith(glossary: updatedGlossary));
      await _repository.toggleGlossaryBookmark(event.termId, newBookmark);
    }
  }
}
