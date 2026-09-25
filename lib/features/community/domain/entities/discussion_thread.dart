import 'package:equatable/equatable.dart';

class DiscussionReply extends Equatable {
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

  factory DiscussionReply.fromDbMap(Map<String, dynamic> map) {
    return DiscussionReply(
      id: (map['reply_id'] ?? '').toString(),
      userName: (map['user_name'] ?? 'Fan').toString(),
      userAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
      body: (map['reply_body'] ?? '').toString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['created_at'] as num?)?.toInt() ?? 0),
    );
  }

  Map<String, dynamic> toDbMap(String threadId) {
    return {
      'reply_id': id,
      'thread_id': threadId,
      'user_name': userName,
      'reply_body': body,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  @override
  List<Object?> get props => [id, userName, userAvatar, body, createdAt];
}

class DiscussionThread extends Equatable {
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

  factory DiscussionThread.fromDbMap(Map<String, dynamic> map, {List<DiscussionReply> replies = const []}) {
    return DiscussionThread(
      id: (map['thread_id'] ?? '').toString(),
      userId: (map['user_id'] ?? '').toString(),
      userName: (map['user_name'] ?? 'OtakuFan').toString(),
      userBadge: (map['user_badge'] ?? 'Master Lorekeeper').toString(),
      category: (map['category'] ?? 'Anime & Manga').toString(),
      title: (map['title'] ?? '').toString(),
      body: (map['body'] ?? '').toString(),
      upvotes: (map['upvotes'] as num?)?.toInt() ?? 0,
      isUpvoted: (map['is_upvoted'] as num?)?.toInt() == 1,
      replies: replies,
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['created_at'] as num?)?.toInt() ?? 0),
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'thread_id': id,
      'user_id': userId,
      'user_name': userName,
      'user_badge': userBadge,
      'category': category,
      'title': title,
      'body': body,
      'upvotes': upvotes,
      'is_upvoted': isUpvoted ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userBadge,
        category,
        title,
        body,
        upvotes,
        isUpvoted,
        replies,
        createdAt,
      ];
}
