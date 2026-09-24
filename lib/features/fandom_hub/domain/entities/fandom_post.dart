class FandomPost {
  final String id;
  final String category;
  final String title;
  final String contentBody;
  final String authorName;
  final String imageUrl;
  final bool isTrending;
  final bool isDeepDive;
  final int readTimeMinutes;
  final List<String> tags;
  final DateTime timestamp;
  final bool isBookmarked;

  const FandomPost({
    required this.id,
    required this.category,
    required this.title,
    required this.contentBody,
    required this.authorName,
    required this.imageUrl,
    this.isTrending = false,
    this.isDeepDive = false,
    this.readTimeMinutes = 4,
    this.tags = const [],
    required this.timestamp,
    this.isBookmarked = false,
  });

  String get summary => contentBody.length > 120 ? '${contentBody.substring(0, 117)}...' : contentBody;

  FandomPost copyWith({
    String? id,
    String? category,
    String? title,
    String? contentBody,
    String? authorName,
    String? imageUrl,
    bool? isTrending,
    bool? isDeepDive,
    int? readTimeMinutes,
    List<String>? tags,
    DateTime? timestamp,
    bool? isBookmarked,
  }) {
    return FandomPost(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      contentBody: contentBody ?? this.contentBody,
      authorName: authorName ?? this.authorName,
      imageUrl: imageUrl ?? this.imageUrl,
      isTrending: isTrending ?? this.isTrending,
      isDeepDive: isDeepDive ?? this.isDeepDive,
      readTimeMinutes: readTimeMinutes ?? this.readTimeMinutes,
      tags: tags ?? this.tags,
      timestamp: timestamp ?? this.timestamp,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
