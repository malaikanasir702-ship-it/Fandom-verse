import '../../domain/entities/fandom_post.dart';
import '../../domain/entities/glossary_term.dart';

abstract class FandomHubState {
  const FandomHubState();
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

  const FandomHubLoaded({
    required this.trendingPosts,
    required this.latestNews,
    required this.glossary,
    this.activeCategory = 'All',
    this.searchQuery = '',
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
  }) {
    return FandomHubLoaded(
      trendingPosts: trendingPosts ?? this.trendingPosts,
      latestNews: latestNews ?? this.latestNews,
      glossary: glossary ?? this.glossary,
      activeCategory: activeCategory ?? this.activeCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class FandomHubError extends FandomHubState {
  final String message;
  const FandomHubError(this.message);
}
