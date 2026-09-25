import '../constants/db_constants.dart';
import '../database/sqlite_helper.dart';
import '../../features/fandom_hub/domain/entities/fandom_post.dart';
import '../../features/fandom_hub/domain/entities/glossary_term.dart';
import 'i_fandom_hub_repository.dart';

class FandomHubRepositoryImpl implements IFandomHubRepository {
  final SqliteHelper _dbHelper;

  FandomHubRepositoryImpl({SqliteHelper? dbHelper})
      : _dbHelper = dbHelper ?? SqliteHelper.instance;

  @override
  Future<List<FandomPost>> getTrendingPosts() async {
    final rows = await _dbHelper.query(
      DbConstants.tablePosts,
      where: 'is_trending = 1',
      orderBy: 'timestamp DESC',
    );
    return rows.map((m) => FandomPost.fromDbMap(m)).toList();
  }

  @override
  Future<List<FandomPost>> getLatestNews() async {
    final rows = await _dbHelper.query(
      DbConstants.tablePosts,
      orderBy: 'timestamp DESC',
    );
    return rows.map((m) => FandomPost.fromDbMap(m)).toList();
  }

  @override
  Future<List<GlossaryTerm>> getGlossary() async {
    final rows = await _dbHelper.query(
      DbConstants.tableGlossary,
      orderBy: 'term ASC',
    );
    return rows.map((m) => GlossaryTerm.fromDbMap(m)).toList();
  }

  @override
  Future<void> togglePostBookmark(String postId, bool isBookmarked) async {
    await _dbHelper.update(
      DbConstants.tablePosts,
      'post_id',
      postId,
      {'is_bookmarked': isBookmarked ? 1 : 0},
    );
  }

  @override
  Future<void> toggleGlossaryBookmark(String termId, bool isBookmarked) async {
    await _dbHelper.update(
      DbConstants.tableGlossary,
      'term_id',
      termId,
      {'is_bookmarked': isBookmarked ? 1 : 0},
    );
  }
}
