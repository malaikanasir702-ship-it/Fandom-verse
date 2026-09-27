import 'package:flutter_test/flutter_test.dart';
import 'package:fandom_verse/features/fandom_hub/domain/entities/behind_scenes_entity.dart';

void main() {
  group('BehindScenesEntity', () {
    test('should create BehindScenesEntity with all fields', () {
      final behindScenes = BehindScenesEntity(
        id: 'bs_1',
        fandomCategory: 'Marvel',
        title: 'Making of Spider-Man',
        description: 'Behind the scenes look at the creation process',
        mediaType: 'video',
        mediaUrl: 'https://example.com/video.mp4',
        createdAt: 1234567890,
      );

      expect(behindScenes.id, 'bs_1');
      expect(behindScenes.fandomCategory, 'Marvel');
      expect(behindScenes.title, 'Making of Spider-Man');
      expect(behindScenes.description, 'Behind the scenes look at the creation process');
      expect(behindScenes.mediaType, 'video');
      expect(behindScenes.mediaUrl, 'https://example.com/video.mp4');
      expect(behindScenes.createdAt, 1234567890);
    });

    test('should serialize to database map correctly', () {
      final behindScenes = BehindScenesEntity(
        id: 'bs_1',
        fandomCategory: 'Marvel',
        title: 'Making of Spider-Man',
        description: 'Behind the scenes look at the creation process',
        mediaType: 'video',
        mediaUrl: 'https://example.com/video.mp4',
        createdAt: 1234567890,
      );

      final map = behindScenes.toDbMap();

      expect(map['scene_id'], 'bs_1');
      expect(map['fandom_category'], 'Marvel');
      expect(map['title'], 'Making of Spider-Man');
      expect(map['description'], 'Behind the scenes look at the creation process');
      expect(map['media_type'], 'video');
      expect(map['media_url'], 'https://example.com/video.mp4');
      expect(map['created_at'], 1234567890);
    });

    test('should deserialize from database map correctly', () {
      final map = {
        'scene_id': 'bs_1',
        'fandom_category': 'Marvel',
        'title': 'Making of Spider-Man',
        'description': 'Behind the scenes look at the creation process',
        'media_type': 'video',
        'media_url': 'https://example.com/video.mp4',
        'created_at': 1234567890,
      };

      final behindScenes = BehindScenesEntity.fromDbMap(map);

      expect(behindScenes.id, 'bs_1');
      expect(behindScenes.fandomCategory, 'Marvel');
      expect(behindScenes.title, 'Making of Spider-Man');
      expect(behindScenes.description, 'Behind the scenes look at the creation process');
      expect(behindScenes.mediaType, 'video');
      expect(behindScenes.mediaUrl, 'https://example.com/video.mp4');
      expect(behindScenes.createdAt, 1234567890);
    });

    test('should handle null mediaUrl', () {
      final map = {
        'scene_id': 'bs_2',
        'fandom_category': 'DC',
        'title': 'Batman Origins',
        'description': 'Story behind the Dark Knight',
        'media_type': 'article',
        'media_url': null,
        'created_at': 1234567890,
      };

      final behindScenes = BehindScenesEntity.fromDbMap(map);

      expect(behindScenes.mediaUrl, isNull);
      expect(behindScenes.mediaType, 'article');
    });

    test('should validate media_type - video', () {
      final map = {
        'scene_id': 'bs_3',
        'fandom_category': 'Anime',
        'title': 'Studio Tour',
        'description': 'Virtual tour of the animation studio',
        'media_type': 'video',
        'created_at': 1234567890,
      };

      final behindScenes = BehindScenesEntity.fromDbMap(map);
      expect(behindScenes.mediaType, 'video');
    });

    test('should validate media_type - image', () {
      final map = {
        'scene_id': 'bs_4',
        'fandom_category': 'Star Wars',
        'title': 'Concept Art',
        'description': 'Early concept designs for new characters',
        'media_type': 'image',
        'media_url': 'https://example.com/concept.jpg',
        'created_at': 1234567890,
      };

      final behindScenes = BehindScenesEntity.fromDbMap(map);
      expect(behindScenes.mediaType, 'image');
    });

    test('should validate media_type - article', () {
      final map = {
        'scene_id': 'bs_5',
        'fandom_category': 'Harry Potter',
        'title': 'Writing Process',
        'description': 'How the story was crafted',
        'media_type': 'article',
        'created_at': 1234567890,
      };

      final behindScenes = BehindScenesEntity.fromDbMap(map);
      expect(behindScenes.mediaType, 'article');
    });

    test('should throw FormatException for invalid media_type', () {
      final map = {
        'scene_id': 'bs_6',
        'fandom_category': 'Pokemon',
        'title': 'Game Development',
        'description': 'How the game was made',
        'media_type': 'audio',
        'created_at': 1234567890,
      };

      expect(
        () => BehindScenesEntity.fromDbMap(map),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Invalid media_type: audio'),
        )),
      );
    });

    test('should throw FormatException for missing scene_id', () {
      final map = {
        'fandom_category': 'Pokemon',
        'title': 'Game Development',
        'description': 'How the game was made',
        'media_type': 'video',
        'created_at': 1234567890,
      };

      expect(
        () => BehindScenesEntity.fromDbMap(map),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Missing required field: scene_id'),
        )),
      );
    });

    test('should handle missing optional fields with defaults', () {
      final map = {
        'scene_id': 'bs_7',
        'fandom_category': null,
        'title': null,
        'description': null,
        'media_type': 'video',
        'created_at': null,
      };

      final behindScenes = BehindScenesEntity.fromDbMap(map);

      expect(behindScenes.id, 'bs_7');
      expect(behindScenes.fandomCategory, '');
      expect(behindScenes.title, '');
      expect(behindScenes.description, '');
      expect(behindScenes.mediaType, 'video');
      expect(behindScenes.mediaUrl, isNull);
      expect(behindScenes.createdAt, 0);
    });

    test('should support round-trip serialization', () {
      final original = BehindScenesEntity(
        id: 'bs_8',
        fandomCategory: 'Lord of the Rings',
        title: 'Set Design',
        description: 'Creating Middle-earth',
        mediaType: 'image',
        mediaUrl: 'https://example.com/set.jpg',
        createdAt: 1234567890,
      );

      final map = original.toDbMap();
      final deserialized = BehindScenesEntity.fromDbMap(map);

      expect(deserialized.id, original.id);
      expect(deserialized.fandomCategory, original.fandomCategory);
      expect(deserialized.title, original.title);
      expect(deserialized.description, original.description);
      expect(deserialized.mediaType, original.mediaType);
      expect(deserialized.mediaUrl, original.mediaUrl);
      expect(deserialized.createdAt, original.createdAt);
    });

    test('should use copyWith correctly', () {
      final original = BehindScenesEntity(
        id: 'bs_9',
        fandomCategory: 'Star Trek',
        title: 'Ship Design',
        description: 'Enterprise blueprints',
        mediaType: 'image',
        mediaUrl: 'https://example.com/ship.jpg',
        createdAt: 1234567890,
      );

      final updated = original.copyWith(
        title: 'Updated Ship Design',
        description: 'New Enterprise blueprints',
        mediaType: 'video',
      );

      expect(updated.id, original.id);
      expect(updated.fandomCategory, original.fandomCategory);
      expect(updated.title, 'Updated Ship Design');
      expect(updated.description, 'New Enterprise blueprints');
      expect(updated.mediaType, 'video');
      expect(updated.mediaUrl, original.mediaUrl);
      expect(updated.createdAt, original.createdAt);
    });

    test('should support equality comparison', () {
      const behindScenes1 = BehindScenesEntity(
        id: 'bs_10',
        fandomCategory: 'Marvel',
        title: 'Iron Man Suit',
        description: 'Creating the armor',
        mediaType: 'video',
        mediaUrl: 'https://example.com/ironman.mp4',
        createdAt: 1234567890,
      );

      const behindScenes2 = BehindScenesEntity(
        id: 'bs_10',
        fandomCategory: 'Marvel',
        title: 'Iron Man Suit',
        description: 'Creating the armor',
        mediaType: 'video',
        mediaUrl: 'https://example.com/ironman.mp4',
        createdAt: 1234567890,
      );

      const behindScenes3 = BehindScenesEntity(
        id: 'bs_11',
        fandomCategory: 'DC',
        title: 'Batman Gadgets',
        description: 'Creating the tools',
        mediaType: 'article',
        createdAt: 1234567890,
      );

      expect(behindScenes1, equals(behindScenes2));
      expect(behindScenes1, isNot(equals(behindScenes3)));
    });

    test('should handle empty string media_type gracefully', () {
      final map = {
        'scene_id': 'bs_12',
        'fandom_category': 'Pokemon',
        'title': 'Game Development',
        'description': 'How the game was made',
        'media_type': '',
        'created_at': 1234567890,
      };

      // Empty media_type should be allowed but not in the valid list
      final behindScenes = BehindScenesEntity.fromDbMap(map);
      expect(behindScenes.mediaType, '');
    });
  });
}
