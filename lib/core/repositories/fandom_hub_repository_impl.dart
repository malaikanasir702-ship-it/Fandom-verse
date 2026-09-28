import '../constants/db_constants.dart';
import '../database/sqlite_helper.dart';
import '../../features/fandom_hub/domain/entities/advanced_lore_entity.dart';
import '../../features/fandom_hub/domain/entities/behind_scenes_entity.dart';
import '../../features/fandom_hub/domain/entities/fandom_post.dart';
import '../../features/fandom_hub/domain/entities/glossary_term.dart';
import '../../features/fandom_hub/domain/entities/interview_entity.dart';
import '../../features/fandom_hub/presentation/widgets/trivia_question_card.dart';
import 'i_fandom_hub_repository.dart';

class FandomHubRepositoryImpl implements IFandomHubRepository {
  final SqliteHelper _dbHelper;

  FandomHubRepositoryImpl({SqliteHelper? dbHelper})
      : _dbHelper = dbHelper ?? SqliteHelper.instance;

  @override
  Future<List<FandomPost>> getTrendingPosts({List<String>? selectedFandoms}) async {
    String? whereClause = 'is_trending = 1';
    List<dynamic>? whereArgs;

    if (selectedFandoms != null && selectedFandoms.isNotEmpty) {
      final placeholders = List.filled(selectedFandoms.length, '?').join(',');
      whereClause =
          'is_trending = 1 AND (category_id IN ($placeholders) OR category_id IN (SELECT category_id FROM ${DbConstants.tableCategories} WHERE name IN ($placeholders)))';
      whereArgs = [...selectedFandoms, ...selectedFandoms];
    }

    final rows = await _dbHelper.query(
      DbConstants.tablePosts,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
    );
    return rows.map((m) => FandomPost.fromDbMap(m)).toList();
  }

  @override
  Future<List<FandomPost>> getLatestNews({List<String>? selectedFandoms}) async {
    String? whereClause;
    List<dynamic>? whereArgs;

    if (selectedFandoms != null && selectedFandoms.isNotEmpty) {
      final placeholders = List.filled(selectedFandoms.length, '?').join(',');
      whereClause =
          'category_id IN ($placeholders) OR category_id IN (SELECT category_id FROM ${DbConstants.tableCategories} WHERE name IN ($placeholders))';
      whereArgs = [...selectedFandoms, ...selectedFandoms];
    }

    final rows = await _dbHelper.query(
      DbConstants.tablePosts,
      where: whereClause,
      whereArgs: whereArgs,
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

  @override
  Future<List<AdvancedLoreEntity>> getAdvancedLore({String? categoryFilter}) async {
    final rows = categoryFilter != null
        ? await _dbHelper.query(
            DbConstants.tableAdvancedLore,
            where: 'fandom_category = ?',
            whereArgs: [categoryFilter],
            orderBy: 'created_at DESC',
          )
        : await _dbHelper.query(
            DbConstants.tableAdvancedLore,
            orderBy: 'created_at DESC',
          );
    return rows.map((m) => AdvancedLoreEntity.fromDbMap(m)).toList();
  }

  @override
  Future<List<BehindScenesEntity>> getBehindScenes({String? categoryFilter}) async {
    final rows = categoryFilter != null
        ? await _dbHelper.query(
            DbConstants.tableBehindScenes,
            where: 'fandom_category = ?',
            whereArgs: [categoryFilter],
            orderBy: 'created_at DESC',
          )
        : await _dbHelper.query(
            DbConstants.tableBehindScenes,
            orderBy: 'created_at DESC',
          );
    return rows.map((m) => BehindScenesEntity.fromDbMap(m)).toList();
  }

  @override
  Future<List<InterviewEntity>> getInterviews({String? categoryFilter}) async {
    final rows = categoryFilter != null
        ? await _dbHelper.query(
            DbConstants.tableInterviews,
            where: 'fandom_category = ?',
            whereArgs: [categoryFilter],
            orderBy: 'interview_date DESC',
          )
        : await _dbHelper.query(
            DbConstants.tableInterviews,
            orderBy: 'interview_date DESC',
          );
    return rows.map((m) => InterviewEntity.fromDbMap(m)).toList();
  }

  @override
  Future<List<TriviaQuestion>> getTriviaQuestions({String? categoryFilter}) async {
    final rows = categoryFilter != null && categoryFilter != 'All'
        ? await _dbHelper.query(
            DbConstants.tableDeepDiveTrivia,
            where: 'fandom_category = ?',
            whereArgs: [categoryFilter],
            orderBy: 'created_at ASC',
          )
        : await _dbHelper.query(
            DbConstants.tableDeepDiveTrivia,
            orderBy: 'created_at ASC',
          );
    return rows.map((m) => TriviaQuestion.fromDbMap(m)).toList();
  }
}
