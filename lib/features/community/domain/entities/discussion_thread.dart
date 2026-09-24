class DiscussionReply {
  final String id;
  final String userName;
  final String userAvatar;
  final String body;
  final DateTime createdAt;

  const DiscussionReply({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.body,
    required this.createdAt,
  });
}

class DiscussionThread {
  final String id;
  final String userId;
  final String userName;
  final String userBadge;
  final String category;
  final String title;
  final String body;
  final int upvotes;
  final bool isUpvoted;
  final List<DiscussionReply> replies;
  final DateTime createdAt;

  const DiscussionThread({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userBadge,
    required this.category,
    required this.title,
    required this.body,
    this.upvotes = 0,
    this.isUpvoted = false,
    this.replies = const [],
    required this.createdAt,
  });

  DiscussionThread copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userBadge,
    String? category,
    String? title,
    String? body,
    int? upvotes,
    bool? isUpvoted,
    List<DiscussionReply>? replies,
    DateTime? createdAt,
  }) {
    return DiscussionThread(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userBadge: userBadge ?? this.userBadge,
      category: category ?? this.category,
      title: title ?? this.title,
      body: body ?? this.body,
      upvotes: upvotes ?? this.upvotes,
      isUpvoted: isUpvoted ?? this.isUpvoted,
      replies: replies ?? this.replies,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
