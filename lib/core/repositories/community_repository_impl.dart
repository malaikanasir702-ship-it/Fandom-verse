import '../constants/db_constants.dart';
import '../database/sqlite_helper.dart';
import '../../features/community/domain/entities/discussion_thread.dart';
import '../../features/community/domain/entities/star_profile.dart';
import 'i_community_repository.dart';

class CommunityRepositoryImpl implements ICommunityRepository {
  final SqliteHelper _dbHelper;

  CommunityRepositoryImpl({SqliteHelper? dbHelper})
      : _dbHelper = dbHelper ?? SqliteHelper.instance;

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

  @override
  Future<List<StarProfile>> getStarProfiles() async {
    final rows = await _dbHelper.query(
      DbConstants.tableStarProfiles,
    );
    return rows.map((s) => StarProfile.fromDbMap(s)).toList();
  }

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

  @override
  Future<void> toggleStarBookmark(String starId, bool isBookmarked) async {
    await _dbHelper.update(
      DbConstants.tableStarProfiles,
      'star_id',
      starId,
      {'is_bookmarked': isBookmarked ? 1 : 0},
    );
  }

  @override
  Future<void> addReply(String threadId, DiscussionReply reply) async {
    await _dbHelper.insert(
      DbConstants.tableDiscussionReplies,
      reply.toDbMap(threadId),
    );
  }

  @override
  Future<void> createThread(DiscussionThread thread) async {
    await _dbHelper.insert(
      DbConstants.tableDiscussions,
      thread.toDbMap(),
    );
  }
}
