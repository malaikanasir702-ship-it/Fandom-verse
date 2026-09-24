import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/fandom_mock_data.dart';
import 'fandom_hub_event.dart';
import 'fandom_hub_state.dart';

class FandomHubBloc extends Bloc<FandomHubEvent, FandomHubState> {
  FandomHubBloc() : super(const FandomHubLoading()) {
    on<LoadFandomHubContentEvent>(_onLoadContent);
    on<FilterContentByCategoryEvent>(_onFilterCategory);
    on<SearchFandomContentEvent>(_onSearchContent);
    on<ToggleBookmarkPostEvent>(_onToggleBookmarkPost);
    on<ToggleBookmarkGlossaryEvent>(_onToggleBookmarkGlossary);
  }

  void _onLoadContent(
    LoadFandomHubContentEvent event,
    Emitter<FandomHubState> emit,
  ) {
    emit(
      FandomHubLoaded(
        trendingPosts: FandomMockData.trendingBanners,
        latestNews: FandomMockData.latestNews,
        glossary: FandomMockData.glossaryList,
      ),
    );
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

  void _onToggleBookmarkPost(
    ToggleBookmarkPostEvent event,
    Emitter<FandomHubState> emit,
  ) {
    if (state is FandomHubLoaded) {
      final current = state as FandomHubLoaded;
      final updatedNews = current.latestNews.map((post) {
        if (post.id == event.postId) {
          return post.copyWith(isBookmarked: !post.isBookmarked);
        }
        return post;
      }).toList();

      final updatedTrending = current.trendingPosts.map((post) {
        if (post.id == event.postId) {
          return post.copyWith(isBookmarked: !post.isBookmarked);
        }
        return post;
      }).toList();

      emit(current.copyWith(latestNews: updatedNews, trendingPosts: updatedTrending));
    }
  }

  void _onToggleBookmarkGlossary(
    ToggleBookmarkGlossaryEvent event,
    Emitter<FandomHubState> emit,
  ) {
    if (state is FandomHubLoaded) {
      final current = state as FandomHubLoaded;
      final updatedGlossary = current.glossary.map((term) {
        if (term.id == event.termId) {
          return term.copyWith(isBookmarked: !term.isBookmarked);
        }
        return term;
      }).toList();

      emit(current.copyWith(glossary: updatedGlossary));
    }
  }
}
