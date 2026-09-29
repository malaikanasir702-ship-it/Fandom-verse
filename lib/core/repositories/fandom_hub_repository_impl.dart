import '../constants/db_constants.dart';
import '../database/sqlite_helper.dart';
import '../database/seed_deep_dive.dart';
import '../services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
    // ── Try SQLite first ──
    List<Map<String, dynamic>> rows = categoryFilter != null
        ? await _dbHelper.query(DbConstants.tableAdvancedLore, where: 'fandom_category = ?', whereArgs: [categoryFilter], orderBy: 'created_at DESC')
        : await _dbHelper.query(DbConstants.tableAdvancedLore, orderBy: 'created_at DESC');

    if (rows.isNotEmpty) return rows.map((m) => AdvancedLoreEntity.fromDbMap(m)).toList();

    // ── Try Firestore ──
    if (FirebaseService.isInitialized) {
      try {
        final snap = await FirebaseFirestore.instance.collection('advanced_lore').orderBy('created_at', descending: true).get().timeout(const Duration(seconds: 8));
        if (snap.docs.isNotEmpty) {
          final result = snap.docs.map((d) => d.data()).toList();
          for (final r in result) { _dbHelper.insert(DbConstants.tableAdvancedLore, r).catchError((_) => 0); }
          return result.map((m) => AdvancedLoreEntity.fromDbMap(m)).toList();
        }
      } catch (e) { debugPrint('[FandomHubRepo] Firestore advanced_lore error: $e'); }
    }

    // ── Fallback: seed defaults ──
    for (final l in SeedDeepDive.defaultAdvancedLore) {
      await _dbHelper.insert(DbConstants.tableAdvancedLore, l).catchError((_) => 0);
    }
    final seeded = await _dbHelper.query(DbConstants.tableAdvancedLore, orderBy: 'created_at DESC');
    return seeded.map((m) => AdvancedLoreEntity.fromDbMap(m)).toList();
  }

  @override
  Future<List<BehindScenesEntity>> getBehindScenes({String? categoryFilter}) async {
    List<Map<String, dynamic>> rows = categoryFilter != null
        ? await _dbHelper.query(DbConstants.tableBehindScenes, where: 'fandom_category = ?', whereArgs: [categoryFilter], orderBy: 'created_at DESC')
        : await _dbHelper.query(DbConstants.tableBehindScenes, orderBy: 'created_at DESC');

    if (rows.isNotEmpty) return rows.map((m) => BehindScenesEntity.fromDbMap(m)).toList();

    if (FirebaseService.isInitialized) {
      try {
        final snap = await FirebaseFirestore.instance.collection('behind_scenes').orderBy('created_at', descending: true).get().timeout(const Duration(seconds: 8));
        if (snap.docs.isNotEmpty) {
          final result = snap.docs.map((d) => d.data()).toList();
          for (final r in result) { _dbHelper.insert(DbConstants.tableBehindScenes, r).catchError((_) => 0); }
          return result.map((m) => BehindScenesEntity.fromDbMap(m)).toList();
        }
      } catch (e) { debugPrint('[FandomHubRepo] Firestore behind_scenes error: $e'); }
    }

    for (final s in SeedDeepDive.defaultBehindScenes) {
      await _dbHelper.insert(DbConstants.tableBehindScenes, s).catchError((_) => 0);
    }
    final seeded = await _dbHelper.query(DbConstants.tableBehindScenes, orderBy: 'created_at DESC');
    return seeded.map((m) => BehindScenesEntity.fromDbMap(m)).toList();
  }

  @override
  Future<List<InterviewEntity>> getInterviews({String? categoryFilter}) async {
    List<Map<String, dynamic>> rows = categoryFilter != null
        ? await _dbHelper.query(DbConstants.tableInterviews, where: 'fandom_category = ?', whereArgs: [categoryFilter], orderBy: 'interview_date DESC')
        : await _dbHelper.query(DbConstants.tableInterviews, orderBy: 'interview_date DESC');

    if (rows.isNotEmpty) return rows.map((m) => InterviewEntity.fromDbMap(m)).toList();

    if (FirebaseService.isInitialized) {
      try {
        final snap = await FirebaseFirestore.instance.collection('interviews').orderBy('created_at', descending: true).get().timeout(const Duration(seconds: 8));
        if (snap.docs.isNotEmpty) {
          final result = snap.docs.map((d) => d.data()).toList();
          for (final r in result) { _dbHelper.insert(DbConstants.tableInterviews, r).catchError((_) => 0); }
          return result.map((m) => InterviewEntity.fromDbMap(m)).toList();
        }
      } catch (e) { debugPrint('[FandomHubRepo] Firestore interviews error: $e'); }
    }

    for (final i in SeedDeepDive.defaultInterviews) {
      await _dbHelper.insert(DbConstants.tableInterviews, i).catchError((_) => 0);
    }
    final seeded = await _dbHelper.query(DbConstants.tableInterviews, orderBy: 'interview_date DESC');
    return seeded.map((m) => InterviewEntity.fromDbMap(m)).toList();
  }

  @override
  Future<List<TriviaQuestion>> getTriviaQuestions({String? categoryFilter}) async {
    List<Map<String, dynamic>> rows = (categoryFilter != null && categoryFilter != 'All')
        ? await _dbHelper.query(DbConstants.tableDeepDiveTrivia, where: 'fandom_category = ?', whereArgs: [categoryFilter], orderBy: 'created_at ASC')
        : await _dbHelper.query(DbConstants.tableDeepDiveTrivia, orderBy: 'created_at ASC');

    if (rows.isNotEmpty) return rows.map((m) => TriviaQuestion.fromDbMap(m)).toList();

    if (FirebaseService.isInitialized) {
      try {
        final snap = await FirebaseFirestore.instance.collection('deep_dive_trivia').orderBy('created_at', descending: false).get().timeout(const Duration(seconds: 8));
        if (snap.docs.isNotEmpty) {
          final result = snap.docs.map((d) => d.data()).toList();
          for (final r in result) { _dbHelper.insert(DbConstants.tableDeepDiveTrivia, r).catchError((_) => 0); }
          return result.map((m) => TriviaQuestion.fromDbMap(m)).toList();
        }
      } catch (e) { debugPrint('[FandomHubRepo] Firestore trivia error: $e'); }
    }

    // ── Seed defaults into SQLite (force re-seed) ──
    for (final t in SeedDeepDive.defaultTrivia) {
      await _dbHelper.insert(DbConstants.tableDeepDiveTrivia, t).catchError((_) => 0);
    }
    final seeded = await _dbHelper.query(DbConstants.tableDeepDiveTrivia, orderBy: 'created_at ASC');
    return seeded.map((m) => TriviaQuestion.fromDbMap(m)).toList();
  }
}
