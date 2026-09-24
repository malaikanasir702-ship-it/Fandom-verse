abstract class CommunityEvent {
  const CommunityEvent();
}

class LoadDiscussionThreadsEvent extends CommunityEvent {
  final String category;
  const LoadDiscussionThreadsEvent({this.category = 'All'});
}

class LoadStarProfilesEvent extends CommunityEvent {
  final String category;
  const LoadStarProfilesEvent({this.category = 'All'});
}

class FilterThreadsByCategoryEvent extends CommunityEvent {
  final String category;
  const FilterThreadsByCategoryEvent(this.category);
}

class UpvoteThreadEvent extends CommunityEvent {
  final String threadId;
  const UpvoteThreadEvent(this.threadId);
}

class ToggleStarBookmarkEvent extends CommunityEvent {
  final String starId;
  const ToggleStarBookmarkEvent(this.starId);
}

class AddReplyToThreadEvent extends CommunityEvent {
  final String threadId;
  final String replyText;
  final String userName;
  const AddReplyToThreadEvent({
    required this.threadId,
    required this.replyText,
    required this.userName,
  });
}

class CreateThreadEvent extends CommunityEvent {
  final String category;
  final String title;
  final String body;
  final String userName;
  const CreateThreadEvent({
    required this.category,
    required this.title,
    required this.body,
    required this.userName,
  });
}
