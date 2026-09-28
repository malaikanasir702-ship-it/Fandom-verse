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
    on<LoadAdvancedLoreEvent>(_onLoadAdvancedLore);
    on<LoadBehindScenesEvent>(_onLoadBehindScenes);
    on<LoadInterviewsEvent>(_onLoadInterviews);
    on<LoadTriviaQuestionsEvent>(_onLoadTriviaQuestions);
  }

  Future<void> _onLoadContent(
    LoadFandomHubContentEvent event,
    Emitter<FandomHubState> emit,
  ) async {
    final prevLoaded = state is FandomHubLoaded ? state as FandomHubLoaded : null;
    emit(const FandomHubLoading());
    try {
      final trending = await _repository.getTrendingPosts(
        selectedFandoms: event.selectedFandoms,
      );
      final latest = await _repository.getLatestNews(
        selectedFandoms: event.selectedFandoms,
      );
      final glossary = await _repository.getGlossary();

      emit(
        FandomHubLoaded(
          trendingPosts: trending,
          latestNews: latest,
          glossary: glossary,
          advancedLore: prevLoaded?.advancedLore ?? const [],
          behindScenes: prevLoaded?.behindScenes ?? const [],
          interviews: prevLoaded?.interviews ?? const [],
          triviaQuestions: prevLoaded?.triviaQuestions ?? const [],
        ),
      );
    } catch (_) {
      // Fallback
      emit(
        FandomHubLoaded(
          trendingPosts: const [],
          latestNews: const [],
          glossary: const [],
          advancedLore: prevLoaded?.advancedLore ?? const [],
          behindScenes: prevLoaded?.behindScenes ?? const [],
          interviews: prevLoaded?.interviews ?? const [],
          triviaQuestions: prevLoaded?.triviaQuestions ?? const [],
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

  Future<void> _onLoadAdvancedLore(
    LoadAdvancedLoreEvent event,
    Emitter<FandomHubState> emit,
  ) async {
    try {
      final lore = await _repository.getAdvancedLore(categoryFilter: event.categoryFilter);
      if (state is FandomHubLoaded) {
        final current = state as FandomHubLoaded;
        emit(current.copyWith(advancedLore: lore));
      } else {
        emit(FandomHubLoaded(
          trendingPosts: const [],
          latestNews: const [],
          glossary: const [],
          advancedLore: lore,
        ));
      }
    } catch (_) {
      // Maintain current state on error
    }
  }

  Future<void> _onLoadBehindScenes(
    LoadBehindScenesEvent event,
    Emitter<FandomHubState> emit,
  ) async {
    try {
      final scenes = await _repository.getBehindScenes(categoryFilter: event.categoryFilter);
      if (state is FandomHubLoaded) {
        final current = state as FandomHubLoaded;
        emit(current.copyWith(behindScenes: scenes));
      } else {
        emit(FandomHubLoaded(
          trendingPosts: const [],
          latestNews: const [],
          glossary: const [],
          behindScenes: scenes,
        ));
      }
    } catch (_) {
      // Maintain current state on error
    }
  }

  Future<void> _onLoadInterviews(
    LoadInterviewsEvent event,
    Emitter<FandomHubState> emit,
  ) async {
    try {
      final interviews = await _repository.getInterviews(categoryFilter: event.categoryFilter);
      if (state is FandomHubLoaded) {
        final current = state as FandomHubLoaded;
        emit(current.copyWith(interviews: interviews));
      } else {
        emit(FandomHubLoaded(
          trendingPosts: const [],
          latestNews: const [],
          glossary: const [],
          interviews: interviews,
        ));
      }
    } catch (_) {
      // Maintain current state on error
    }
  }

  Future<void> _onLoadTriviaQuestions(
    LoadTriviaQuestionsEvent event,
    Emitter<FandomHubState> emit,
  ) async {
    try {
      final trivia = await _repository.getTriviaQuestions(categoryFilter: event.categoryFilter);
      if (state is FandomHubLoaded) {
        final current = state as FandomHubLoaded;
        emit(current.copyWith(triviaQuestions: trivia));
      } else {
        emit(FandomHubLoaded(
          trendingPosts: const [],
          latestNews: const [],
          glossary: const [],
          triviaQuestions: trivia,
        ));
      }
    } catch (_) {
      // Maintain current state on error
    }
  }
}
