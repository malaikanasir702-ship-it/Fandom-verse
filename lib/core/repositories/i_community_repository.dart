import '../../features/community/domain/entities/discussion_thread.dart';
import '../../features/community/domain/entities/star_profile.dart';

abstract class ICommunityRepository {
  Future<List<DiscussionThread>> getThreads();
  Future<List<StarProfile>> getStarProfiles();
  Future<void> upvoteThread(String threadId, int upvotes, bool isUpvoted);
  Future<void> toggleStarBookmark(String starId, bool isBookmarked);
  Future<void> addReply(String threadId, DiscussionReply reply);
  Future<void> createThread(DiscussionThread thread);
}
