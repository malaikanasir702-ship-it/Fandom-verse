import '../../features/fandom_hub/domain/entities/advanced_lore_entity.dart';
import '../../features/fandom_hub/domain/entities/behind_scenes_entity.dart';
import '../../features/fandom_hub/domain/entities/fandom_post.dart';
import '../../features/fandom_hub/domain/entities/glossary_term.dart';
import '../../features/fandom_hub/domain/entities/interview_entity.dart';

abstract class IFandomHubRepository {
  Future<List<FandomPost>> getTrendingPosts({List<String>? selectedFandoms});
  Future<List<FandomPost>> getLatestNews({List<String>? selectedFandoms});
  Future<List<GlossaryTerm>> getGlossary();
  Future<void> togglePostBookmark(String postId, bool isBookmarked);
  Future<void> toggleGlossaryBookmark(String termId, bool isBookmarked);
  Future<List<AdvancedLoreEntity>> getAdvancedLore({String? categoryFilter});
  Future<List<BehindScenesEntity>> getBehindScenes({String? categoryFilter});
  Future<List<InterviewEntity>> getInterviews({String? categoryFilter});
}
