import 'package:equatable/equatable.dart';

class AdvancedLoreEntity extends Equatable {
  final String id;
  final String fandomCategory;
  final String title;
  final String contentBody;
  final String difficultyLevel;
  final int createdAt;

  const AdvancedLoreEntity({
    required this.id,
    required this.fandomCategory,
    required this.title,
    required this.contentBody,
    this.difficultyLevel = 'Intermediate',
    required this.createdAt,
  });

  /// Creates a copy of this entity with the given fields replaced with new values
  AdvancedLoreEntity copyWith({
    String? id,
    String? fandomCategory,
    String? title,
    String? contentBody,
    String? difficultyLevel,
    int? createdAt,
  }) {
    return AdvancedLoreEntity(
      id: id ?? this.id,
      fandomCategory: fandomCategory ?? this.fandomCategory,
      title: title ?? this.title,
      contentBody: contentBody ?? this.contentBody,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Creates an AdvancedLoreEntity from a database map
  factory AdvancedLoreEntity.fromDbMap(Map<String, dynamic> map) {
    // Validate required fields
    if (!map.containsKey('lore_id') || !map.containsKey('title')) {
      throw FormatException('Missing required fields: lore_id or title');
    }

    try {
      final difficultyLevel = map['difficulty_level']?.toString() ?? 'Intermediate';
      
      // Validate difficulty level
      if (!_isValidDifficultyLevel(difficultyLevel)) {
        throw FormatException(
          'Invalid difficulty level: $difficultyLevel. Must be one of: Beginner, Intermediate, Expert',
        );
      }

      return AdvancedLoreEntity(
        id: map['lore_id'].toString(),
        fandomCategory: (map['fandom_category'] ?? '').toString(),
        title: map['title'].toString(),
        contentBody: (map['content_body'] ?? '').toString(),
        difficultyLevel: difficultyLevel,
        createdAt: (map['created_at'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      if (e is FormatException) {
        rethrow;
      }
      throw FormatException('Invalid field type in advanced lore map: ${e.toString()}');
    }
  }

  /// Converts this entity to a database map
  Map<String, dynamic> toDbMap() {
    return {
      'lore_id': id,
      'fandom_category': fandomCategory,
      'title': title,
      'content_body': contentBody,
      'difficulty_level': difficultyLevel,
      'created_at': createdAt,
    };
  }

  /// Validates if the difficulty level is one of the allowed values
  static bool _isValidDifficultyLevel(String level) {
    const validLevels = ['Beginner', 'Intermediate', 'Expert'];
    return validLevels.contains(level);
  }

  @override
  List<Object?> get props => [
        id,
        fandomCategory,
        title,
        contentBody,
        difficultyLevel,
        createdAt,
      ];
}
