import '../../features/fandom_hub/domain/entities/fandom_post.dart';
import '../../features/fandom_hub/domain/entities/glossary_term.dart';

abstract class IFandomHubRepository {
  Future<List<FandomPost>> getTrendingPosts();
  Future<List<FandomPost>> getLatestNews();
  Future<List<GlossaryTerm>> getGlossary();
  Future<void> togglePostBookmark(String postId, bool isBookmarked);
  Future<void> toggleGlossaryBookmark(String termId, bool isBookmarked);
}
