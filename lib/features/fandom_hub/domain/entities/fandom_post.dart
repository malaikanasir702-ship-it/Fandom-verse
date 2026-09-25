import 'dart:convert';
import 'package:equatable/equatable.dart';

class FandomPost extends Equatable {
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

  factory FandomPost.fromDbMap(Map<String, dynamic> map) {
    List<String> parsedTags = [];
    final rawTags = map['tags'];
    if (rawTags is String && rawTags.isNotEmpty) {
      try {
        if (rawTags.startsWith('[')) {
          parsedTags = List<String>.from(jsonDecode(rawTags));
        } else {
          parsedTags = rawTags.split(',').map((e) => e.trim()).toList();
        }
      } catch (_) {
        parsedTags = [rawTags];
      }
    } else if (rawTags is List) {
      parsedTags = List<String>.from(rawTags);
    }

    return FandomPost(
      id: (map['post_id'] ?? '').toString(),
      category: (map['category_id'] ?? map['category'] ?? 'Anime & Manga').toString(),
      title: (map['title'] ?? '').toString(),
      contentBody: (map['content_body'] ?? '').toString(),
      authorName: (map['author_name'] ?? 'Fandom Chronicler').toString(),
      imageUrl: (map['image_url'] ?? '').toString(),
      isTrending: (map['is_trending'] as num?)?.toInt() == 1,
      isDeepDive: (map['is_deep_dive'] as num?)?.toInt() == 1,
      readTimeMinutes: 5,
      tags: parsedTags,
      timestamp: DateTime.fromMillisecondsSinceEpoch((map['timestamp'] as num?)?.toInt() ?? 0),
      isBookmarked: (map['is_bookmarked'] as num?)?.toInt() == 1,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'post_id': id,
      'category_id': category,
      'title': title,
      'content_body': contentBody,
      'author_name': authorName,
      'image_url': imageUrl,
      'is_trending': isTrending ? 1 : 0,
      'is_deep_dive': isDeepDive ? 1 : 0,
      'tags': jsonEncode(tags),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'is_bookmarked': isBookmarked ? 1 : 0,
    };
  }

  @override
  List<Object?> get props => [
        id,
        category,
        title,
        contentBody,
        authorName,
        imageUrl,
        isTrending,
        isDeepDive,
        readTimeMinutes,
        tags,
        timestamp,
        isBookmarked,
      ];
}
