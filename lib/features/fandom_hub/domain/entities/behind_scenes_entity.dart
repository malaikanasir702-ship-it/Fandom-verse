import 'package:equatable/equatable.dart';

class BehindScenesEntity extends Equatable {
  final String id;
  final String fandomCategory;
  final String title;
  final String description;
  final String mediaType;
  final String? mediaUrl;
  final int createdAt;

  const BehindScenesEntity({
    required this.id,
    required this.fandomCategory,
    required this.title,
    required this.description,
    required this.mediaType,
    this.mediaUrl,
    required this.createdAt,
  });

  BehindScenesEntity copyWith({
    String? id,
    String? fandomCategory,
    String? title,
    String? description,
    String? mediaType,
    String? mediaUrl,
    int? createdAt,
  }) {
    return BehindScenesEntity(
      id: id ?? this.id,
      fandomCategory: fandomCategory ?? this.fandomCategory,
      title: title ?? this.title,
      description: description ?? this.description,
      mediaType: mediaType ?? this.mediaType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory BehindScenesEntity.fromDbMap(Map<String, dynamic> map) {
    // Validate required fields
    if (!map.containsKey('scene_id')) {
      throw FormatException('Missing required field: scene_id');
    }

    // Validate media_type
    final mediaType = (map['media_type'] ?? '').toString();
    final validMediaTypes = ['video', 'image', 'article'];
    if (mediaType.isNotEmpty && !validMediaTypes.contains(mediaType)) {
      throw FormatException(
        'Invalid media_type: $mediaType. Must be one of: ${validMediaTypes.join(', ')}',
      );
    }

    return BehindScenesEntity(
      id: (map['scene_id']).toString(),
      fandomCategory: (map['fandom_category'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      mediaType: mediaType,
      mediaUrl: map['media_url']?.toString(),
      createdAt: (map['created_at'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'scene_id': id,
      'fandom_category': fandomCategory,
      'title': title,
      'description': description,
      'media_type': mediaType,
      'media_url': mediaUrl,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        fandomCategory,
        title,
        description,
        mediaType,
        mediaUrl,
        createdAt,
      ];
}
