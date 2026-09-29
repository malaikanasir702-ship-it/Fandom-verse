import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/db_constants.dart';
import '../database/sqlite_helper.dart';
import '../../features/community/domain/entities/discussion_thread.dart';
import '../../features/community/domain/entities/star_profile.dart';
import 'i_community_repository.dart';

class CommunityRepositoryImpl implements ICommunityRepository {
  final SqliteHelper _dbHelper;
  final FirebaseFirestore _firestore;

  CommunityRepositoryImpl({SqliteHelper? dbHelper, FirebaseFirestore? firestore})
      : _dbHelper = dbHelper ?? SqliteHelper.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Discussions ──────────────────────────────────────────────────────────────

  @override
  Future<List<DiscussionThread>> getThreads() async {
    final threadRows = await _dbHelper.query(
      DbConstants.tableDiscussions,
      orderBy: 'created_at DESC',
    );
    final replyRows = await _dbHelper.query(
      DbConstants.tableDiscussionReplies,
      orderBy: 'created_at ASC',
    );

    final Map<String, List<DiscussionReply>> repliesByThread = {};
    for (final r in replyRows) {
      final threadId = (r['thread_id'] ?? '').toString();
      repliesByThread.putIfAbsent(threadId, () => []).add(DiscussionReply.fromDbMap(r));
    }

    return threadRows.map((t) {
      final tid = (t['thread_id'] ?? '').toString();
      return DiscussionThread.fromDbMap(t, replies: repliesByThread[tid] ?? []);
    }).toList();
  }

  // ── Star Profiles — Firestore-first with SQLite cache ───────────────────────

  @override
  Future<List<StarProfile>> getStarProfiles() async {
    try {
      // 1. Fetch from Firestore (source of truth)
      final snapshot = await _firestore
          .collection('star_profiles')
          .orderBy('seededAt', descending: false)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final firestoreStars = snapshot.docs
            .map((doc) => StarProfile.fromFirestore(doc))
            .toList();

        // 2. Sync into SQLite cache (preserve bookmarks)
        await _syncStarsToSQLite(firestoreStars);

        // 3. Re-read from SQLite to get bookmark state
        return await _getStarsFromSQLite();
      }
    } catch (e) {
      // Firestore failed — fall through to SQLite cache
    }

    // Fallback: SQLite cache
    return await _getStarsFromSQLite();
  }

  Future<List<StarProfile>> _getStarsFromSQLite() async {
    final rows = await _dbHelper.query(DbConstants.tableStarProfiles);
    return rows.map((s) => StarProfile.fromDbMap(s)).toList();
  }

  Future<void> _syncStarsToSQLite(List<StarProfile> firestoreStars) async {
    for (final star in firestoreStars) {
      // Check if already exists in SQLite to preserve bookmark state
      final existing = await _dbHelper.query(
        DbConstants.tableStarProfiles,
        where: 'star_id = ?',
        whereArgs: [star.id],
      );

      if (existing.isEmpty) {
        // Insert new star
        try {
          await _dbHelper.insert(DbConstants.tableStarProfiles, star.toDbMap());
        } catch (_) {}
      } else {
        // Update fields but keep bookmark
        final isBookmarked = (existing.first['is_bookmarked'] as num?)?.toInt() == 1;
        try {
          await _dbHelper.update(
            DbConstants.tableStarProfiles,
            'star_id',
            star.id,
            {
              'name': star.name,
              'fandom_category': star.category,
              'role_title': star.roleTitle,
              'bio': star.bio,
              'image_url': star.imageUrl,
              'social_handle': star.socialHandle,
              'is_bookmarked': isBookmarked ? 1 : 0,
            },
          );
        } catch (_) {}
      }
    }
  }

  // ── Bookmark ─────────────────────────────────────────────────────────────────

  @override
  Future<void> toggleStarBookmark(String starId, bool isBookmarked) async {
    await _dbHelper.update(
      DbConstants.tableStarProfiles,
      'star_id',
      starId,
      {'is_bookmarked': isBookmarked ? 1 : 0},
    );
  }

  // ── Upvote ───────────────────────────────────────────────────────────────────

  @override
  Future<void> upvoteThread(String threadId, int upvotes, bool isUpvoted) async {
    await _dbHelper.update(
      DbConstants.tableDiscussions,
      'thread_id',
      threadId,
      {
        'upvotes': upvotes,
        'is_upvoted': isUpvoted ? 1 : 0,
      },
    );
  }

  // ── Replies ──────────────────────────────────────────────────────────────────

  @override
  Future<void> addReply(String threadId, DiscussionReply reply) async {
    await _dbHelper.insert(
      DbConstants.tableDiscussionReplies,
      reply.toDbMap(threadId),
    );
  }

  // ── Create Thread ─────────────────────────────────────────────────────────────

  @override
  Future<void> createThread(DiscussionThread thread) async {
    await _dbHelper.insert(
      DbConstants.tableDiscussions,
      thread.toDbMap(),
    );
  }
}
