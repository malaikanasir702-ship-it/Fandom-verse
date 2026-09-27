import 'package:flutter_test/flutter_test.dart';
import 'package:fandom_verse/features/fandom_hub/domain/entities/advanced_lore_entity.dart';

void main() {
  group('AdvancedLoreEntity', () {
    group('fromDbMap', () {
      test('should create entity from valid database map', () {
        // Arrange
        final map = {
          'lore_id': 'lore_1',
          'fandom_category': 'Marvel',
          'title': 'The Infinity Stones',
          'content_body': 'The Infinity Stones are six powerful artifacts...',
          'difficulty_level': 'Expert',
          'created_at': 1640000000,
        };

        // Act
        final entity = AdvancedLoreEntity.fromDbMap(map);

        // Assert
        expect(entity.id, 'lore_1');
        expect(entity.fandomCategory, 'Marvel');
        expect(entity.title, 'The Infinity Stones');
        expect(entity.contentBody, 'The Infinity Stones are six powerful artifacts...');
        expect(entity.difficultyLevel, 'Expert');
        expect(entity.createdAt, 1640000000);
      });

      test('should use default difficulty level when not provided', () {
        // Arrange
        final map = {
          'lore_id': 'lore_2',
          'fandom_category': 'Star Wars',
          'title': 'The Force',
          'content_body': 'The Force is an energy field...',
          'created_at': 1640000000,
        };

        // Act
        final entity = AdvancedLoreEntity.fromDbMap(map);

        // Assert
        expect(entity.difficultyLevel, 'Intermediate');
      });

      test('should handle null values with defaults', () {
        // Arrange
        final map = {
          'lore_id': 'lore_3',
          'title': 'Test Title',
          'fandom_category': null,
          'content_body': null,
          'difficulty_level': null,
          'created_at': null,
        };

        // Act
        final entity = AdvancedLoreEntity.fromDbMap(map);

        // Assert
        expect(entity.id, 'lore_3');
        expect(entity.title, 'Test Title');
        expect(entity.fandomCategory, '');
        expect(entity.contentBody, '');
        expect(entity.difficultyLevel, 'Intermediate');
        expect(entity.createdAt, 0);
      });

      test('should throw FormatException when lore_id is missing', () {
        // Arrange
        final map = {
          'title': 'Test Title',
          'fandom_category': 'Marvel',
          'content_body': 'Test content',
          'created_at': 1640000000,
        };

        // Act & Assert
        expect(
          () => AdvancedLoreEntity.fromDbMap(map),
          throwsA(isA<FormatException>()),
        );
      });

      test('should throw FormatException when title is missing', () {
        // Arrange
        final map = {
          'lore_id': 'lore_4',
          'fandom_category': 'Marvel',
          'content_body': 'Test content',
          'created_at': 1640000000,
        };

        // Act & Assert
        expect(
          () => AdvancedLoreEntity.fromDbMap(map),
          throwsA(isA<FormatException>()),
        );
      });

      test('should throw FormatException for invalid difficulty level', () {
        // Arrange
        final map = {
          'lore_id': 'lore_5',
          'fandom_category': 'Marvel',
          'title': 'Test Title',
          'content_body': 'Test content',
          'difficulty_level': 'Invalid',
          'created_at': 1640000000,
        };

        // Act & Assert
        expect(
          () => AdvancedLoreEntity.fromDbMap(map),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('Invalid difficulty level'),
            ),
          ),
        );
      });

      test('should accept all valid difficulty levels', () {
        // Arrange
        final validLevels = ['Beginner', 'Intermediate', 'Expert'];

        for (final level in validLevels) {
          final map = {
            'lore_id': 'lore_$level',
            'fandom_category': 'Marvel',
            'title': 'Test Title',
            'content_body': 'Test content',
            'difficulty_level': level,
            'created_at': 1640000000,
          };

          // Act
          final entity = AdvancedLoreEntity.fromDbMap(map);

          // Assert
          expect(entity.difficultyLevel, level);
        }
      });
    });

    group('toDbMap', () {
      test('should convert entity to database map', () {
        // Arrange
        const entity = AdvancedLoreEntity(
          id: 'lore_1',
          fandomCategory: 'Marvel',
          title: 'The Infinity Stones',
          contentBody: 'The Infinity Stones are six powerful artifacts...',
          difficultyLevel: 'Expert',
          createdAt: 1640000000,
        );

        // Act
        final map = entity.toDbMap();

        // Assert
        expect(map['lore_id'], 'lore_1');
        expect(map['fandom_category'], 'Marvel');
        expect(map['title'], 'The Infinity Stones');
        expect(map['content_body'], 'The Infinity Stones are six powerful artifacts...');
        expect(map['difficulty_level'], 'Expert');
        expect(map['created_at'], 1640000000);
      });

      test('should preserve all fields in map', () {
        // Arrange
        const entity = AdvancedLoreEntity(
          id: 'lore_2',
          fandomCategory: 'Star Wars',
          title: 'The Force',
          contentBody: 'The Force is an energy field...',
          difficultyLevel: 'Beginner',
          createdAt: 1640000001,
        );

        // Act
        final map = entity.toDbMap();

        // Assert
        expect(map.length, 6);
        expect(map.containsKey('lore_id'), true);
        expect(map.containsKey('fandom_category'), true);
        expect(map.containsKey('title'), true);
        expect(map.containsKey('content_body'), true);
        expect(map.containsKey('difficulty_level'), true);
        expect(map.containsKey('created_at'), true);
      });
    });

    group('serialization round-trip', () {
      test('should maintain data integrity through toDbMap -> fromDbMap', () {
        // Arrange
        const original = AdvancedLoreEntity(
          id: 'lore_1',
          fandomCategory: 'Marvel',
          title: 'The Infinity Stones',
          contentBody: 'The Infinity Stones are six powerful artifacts...',
          difficultyLevel: 'Expert',
          createdAt: 1640000000,
        );

        // Act
        final map = original.toDbMap();
        final restored = AdvancedLoreEntity.fromDbMap(map);

        // Assert
        expect(restored, original);
        expect(restored.id, original.id);
        expect(restored.fandomCategory, original.fandomCategory);
        expect(restored.title, original.title);
        expect(restored.contentBody, original.contentBody);
        expect(restored.difficultyLevel, original.difficultyLevel);
        expect(restored.createdAt, original.createdAt);
      });
    });

    group('copyWith', () {
      test('should create a copy with updated fields', () {
        // Arrange
        const original = AdvancedLoreEntity(
          id: 'lore_1',
          fandomCategory: 'Marvel',
          title: 'Original Title',
          contentBody: 'Original content',
          difficultyLevel: 'Beginner',
          createdAt: 1640000000,
        );

        // Act
        final updated = original.copyWith(
          title: 'Updated Title',
          difficultyLevel: 'Expert',
        );

        // Assert
        expect(updated.id, original.id);
        expect(updated.fandomCategory, original.fandomCategory);
        expect(updated.title, 'Updated Title');
        expect(updated.contentBody, original.contentBody);
        expect(updated.difficultyLevel, 'Expert');
        expect(updated.createdAt, original.createdAt);
      });

      test('should preserve unchanged fields', () {
        // Arrange
        const original = AdvancedLoreEntity(
          id: 'lore_1',
          fandomCategory: 'Marvel',
          title: 'Original Title',
          contentBody: 'Original content',
          difficultyLevel: 'Intermediate',
          createdAt: 1640000000,
        );

        // Act
        final updated = original.copyWith();

        // Assert
        expect(updated, original);
      });
    });

    group('Equatable', () {
      test('should compare entities based on props', () {
        // Arrange
        const entity1 = AdvancedLoreEntity(
          id: 'lore_1',
          fandomCategory: 'Marvel',
          title: 'Test Title',
          contentBody: 'Test content',
          difficultyLevel: 'Beginner',
          createdAt: 1640000000,
        );

        const entity2 = AdvancedLoreEntity(
          id: 'lore_1',
          fandomCategory: 'Marvel',
          title: 'Test Title',
          contentBody: 'Test content',
          difficultyLevel: 'Beginner',
          createdAt: 1640000000,
        );

        // Act & Assert
        expect(entity1, entity2);
        expect(entity1.hashCode, entity2.hashCode);
      });

      test('should not be equal when fields differ', () {
        // Arrange
        const entity1 = AdvancedLoreEntity(
          id: 'lore_1',
          fandomCategory: 'Marvel',
          title: 'Test Title',
          contentBody: 'Test content',
          difficultyLevel: 'Beginner',
          createdAt: 1640000000,
        );

        const entity2 = AdvancedLoreEntity(
          id: 'lore_2',
          fandomCategory: 'Marvel',
          title: 'Test Title',
          contentBody: 'Test content',
          difficultyLevel: 'Beginner',
          createdAt: 1640000000,
        );

        // Act & Assert
        expect(entity1, isNot(entity2));
      });
    });
  });
}
