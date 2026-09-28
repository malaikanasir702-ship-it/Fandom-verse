import '../../domain/entities/advanced_lore_entity.dart';
import '../../domain/entities/behind_scenes_entity.dart';
import '../../domain/entities/fandom_post.dart';
import '../../domain/entities/glossary_term.dart';
import '../../domain/entities/interview_entity.dart';
import '../widgets/trivia_question_card.dart';

abstract class FandomHubState {
  const FandomHubState();
}

class FandomHubInitial extends FandomHubState {
  const FandomHubInitial();
}

class FandomHubLoading extends FandomHubState {
  const FandomHubLoading();
}

class FandomHubLoaded extends FandomHubState {
  final List<FandomPost> trendingPosts;
  final List<FandomPost> latestNews;
  final List<GlossaryTerm> glossary;
  final String activeCategory;
  final String searchQuery;
  final List<AdvancedLoreEntity> advancedLore;
  final List<BehindScenesEntity> behindScenes;
  final List<InterviewEntity> interviews;
  final List<TriviaQuestion> triviaQuestions;

  const FandomHubLoaded({
    required this.trendingPosts,
    required this.latestNews,
    required this.glossary,
    this.activeCategory = 'All',
    this.searchQuery = '',
    this.advancedLore = const [],
    this.behindScenes = const [],
    this.interviews = const [],
    this.triviaQuestions = const [],
  });

  List<FandomPost> get filteredNews {
    return latestNews.where((item) {
      final matchesCat = activeCategory == 'All' || item.category == activeCategory;
      final matchesQuery = searchQuery.isEmpty ||
          item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.contentBody.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCat && matchesQuery;
    }).toList();
  }

  List<FandomPost> get bookmarkedPosts {
    return latestNews.where((post) => post.isBookmarked).toList();
  }

  List<GlossaryTerm> get bookmarkedGlossary {
    return glossary.where((term) => term.isBookmarked).toList();
  }

  FandomHubLoaded copyWith({
    List<FandomPost>? trendingPosts,
    List<FandomPost>? latestNews,
    List<GlossaryTerm>? glossary,
    String? activeCategory,
    String? searchQuery,
    List<AdvancedLoreEntity>? advancedLore,
    List<BehindScenesEntity>? behindScenes,
    List<InterviewEntity>? interviews,
    List<TriviaQuestion>? triviaQuestions,
  }) {
    return FandomHubLoaded(
      trendingPosts: trendingPosts ?? this.trendingPosts,
      latestNews: latestNews ?? this.latestNews,
      glossary: glossary ?? this.glossary,
      activeCategory: activeCategory ?? this.activeCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      advancedLore: advancedLore ?? this.advancedLore,
      behindScenes: behindScenes ?? this.behindScenes,
      interviews: interviews ?? this.interviews,
      triviaQuestions: triviaQuestions ?? this.triviaQuestions,
    );
  }
}

class FandomHubError extends FandomHubState {
  final String message;
  const FandomHubError(this.message);
}
