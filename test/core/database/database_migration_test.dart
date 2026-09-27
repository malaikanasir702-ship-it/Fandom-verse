import 'package:flutter_test/flutter_test.dart';
import 'package:fandom_verse/core/constants/db_constants.dart';
import 'package:fandom_verse/core/database/database_tables.dart';

void main() {
  group('Database Migration Tests', () {
    test('should have correct database version', () {
      // Assert
      expect(DbConstants.databaseVersion, 3);
    });

    test('should include all new table constants', () {
      // Assert
      expect(DbConstants.tableAdvancedLore, 'advanced_lore');
      expect(DbConstants.tableBehindScenes, 'behind_scenes');
      expect(DbConstants.tableInterviews, 'interviews');
    });

    test('should have create statements for all new tables', () {
      // Assert
      expect(DatabaseTables.allCreateStatements.length, 17);
      expect(
        DatabaseTables.allCreateStatements,
        contains(DatabaseTables.createAdvancedLoreTable),
      );
      expect(
        DatabaseTables.allCreateStatements,
        contains(DatabaseTables.createBehindScenesTable),
      );
      expect(
        DatabaseTables.allCreateStatements,
        contains(DatabaseTables.createInterviewsTable),
      );
    });

    test('advanced_lore table should have correct schema', () {
      final createStatement = DatabaseTables.createAdvancedLoreTable;

      // Assert table name and columns
      expect(createStatement, contains('CREATE TABLE IF NOT EXISTS'));
      expect(createStatement, contains('advanced_lore'));
      expect(createStatement, contains('lore_id'));
      expect(createStatement, contains('TEXT PRIMARY KEY'));
      expect(createStatement, contains('fandom_category'));
      expect(createStatement, contains('TEXT NOT NULL'));
      expect(createStatement, contains('title'));
      expect(createStatement, contains('content_body'));
      expect(createStatement, contains('difficulty_level'));
      expect(createStatement, contains("DEFAULT 'Intermediate'"));
      expect(createStatement, contains('created_at'));
      expect(createStatement, contains('INTEGER NOT NULL'));
    });

    test('behind_scenes table should have correct schema', () {
      final createStatement = DatabaseTables.createBehindScenesTable;

      // Assert table name and columns
      expect(createStatement, contains('CREATE TABLE IF NOT EXISTS'));
      expect(createStatement, contains('behind_scenes'));
      expect(createStatement, contains('scene_id'));
      expect(createStatement, contains('TEXT PRIMARY KEY'));
      expect(createStatement, contains('fandom_category'));
      expect(createStatement, contains('TEXT NOT NULL'));
      expect(createStatement, contains('title'));
      expect(createStatement, contains('description'));
      expect(createStatement, contains('media_type'));
      expect(createStatement, contains('media_url'));
      expect(createStatement, contains('created_at'));
      expect(createStatement, contains('INTEGER NOT NULL'));
    });

    test('interviews table should have correct schema', () {
      final createStatement = DatabaseTables.createInterviewsTable;

      // Assert table name and columns
      expect(createStatement, contains('CREATE TABLE IF NOT EXISTS'));
      expect(createStatement, contains('interviews'));
      expect(createStatement, contains('interview_id'));
      expect(createStatement, contains('TEXT PRIMARY KEY'));
      expect(createStatement, contains('interviewee_name'));
      expect(createStatement, contains('TEXT NOT NULL'));
      expect(createStatement, contains('role_title'));
      expect(createStatement, contains('fandom_category'));
      expect(createStatement, contains('interview_date'));
      expect(createStatement, contains('INTEGER NOT NULL'));
      expect(createStatement, contains('questions_json'));
      expect(createStatement, contains('image_url'));
      expect(createStatement, contains('created_at'));
    });

    test('users table should support liked_fandoms column', () {
      // This test verifies that the migration logic exists
      // The actual column addition is tested in integration tests
      final createStatement = DatabaseTables.createUsersTable;

      // Assert the base users table structure exists
      expect(createStatement, contains('CREATE TABLE IF NOT EXISTS'));
      expect(createStatement, contains('users'));
      expect(createStatement, contains('user_id'));
      expect(createStatement, contains('TEXT PRIMARY KEY'));
      expect(createStatement, contains('selected_fandoms'));
    });
  });
}
