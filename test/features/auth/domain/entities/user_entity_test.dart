import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fandom_verse/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserEntity Serialization', () {
    test('toMap then fromMap preserves all fields', () {
      const user = UserEntity(
        id: 'user123',
        name: 'John Doe',
        email: 'john@example.com',
        role: 'fan',
        status: 'active',
        avatarUrl: 'https://example.com/avatar.png',
        bio: 'Test bio',
        badges: ['badge1', 'badge2'],
        selectedFandoms: ['gaming'],
        likedFandoms: ['anime', 'marvel'],
      );

      final map = user.toMap();
      final restored = UserEntity.fromMap(map);

      expect(restored.id, user.id);
      expect(restored.name, user.name);
      expect(restored.email, user.email);
      expect(restored.role, user.role);
      expect(restored.status, user.status);
      expect(restored.avatarUrl, user.avatarUrl);
      expect(restored.bio, user.bio);
      expect(restored.badges, user.badges);
      expect(restored.selectedFandoms, user.selectedFandoms);
      expect(restored.likedFandoms, user.likedFandoms);
      expect(restored, equals(user));
    });

    test('fromMap handles null bio with empty string default', () {
      final map = {
        'user_id': 'user123',
        'name': 'John',
        'email': 'john@example.com',
        'bio': null,
      };

      final user = UserEntity.fromMap(map);
      expect(user.bio, '');
    });

    test('fromMap parses liked_fandoms and selected_fandoms JSON arrays', () {
      final map = {
        'user_id': 'user123',
        'name': 'John',
        'email': 'john@example.com',
        'liked_fandoms': '["anime","marvel","gaming"]',
        'selected_fandoms': '["fandom1","fandom2"]',
        'badges': '["badge1"]',
      };

      final user = UserEntity.fromMap(map);
      expect(user.likedFandoms, ['anime', 'marvel', 'gaming']);
      expect(user.selectedFandoms, ['fandom1', 'fandom2']);
      expect(user.badges, ['badge1']);
    });

    test('fromMap handles List directly for fandoms and badges', () {
      final map = {
        'user_id': 'user123',
        'name': 'John',
        'email': 'john@example.com',
        'liked_fandoms': ['anime', 'marvel'],
        'selected_fandoms': ['gaming'],
        'badges': ['vip'],
      };

      final user = UserEntity.fromMap(map);
      expect(user.likedFandoms, ['anime', 'marvel']);
      expect(user.selectedFandoms, ['gaming']);
      expect(user.badges, ['vip']);
    });

    test('fromMap handles null lists with empty list defaults', () {
      final map = {
        'user_id': 'user123',
        'name': 'John',
        'email': 'john@example.com',
        'badges': null,
        'selected_fandoms': null,
        'liked_fandoms': null,
      };

      final user = UserEntity.fromMap(map);
      expect(user.badges, isEmpty);
      expect(user.selectedFandoms, isEmpty);
      expect(user.likedFandoms, isEmpty);
    });

    test('copyWith updates specified fields correctly', () {
      const user = UserEntity(
        id: 'u1',
        name: 'User 1',
        email: 'u1@example.com',
        bio: 'Old bio',
        likedFandoms: ['anime'],
      );

      final updated = user.copyWith(
        bio: 'New bio',
        likedFandoms: ['anime', 'sci-fi'],
      );

      expect(updated.bio, 'New bio');
      expect(updated.likedFandoms, ['anime', 'sci-fi']);
      expect(updated.name, user.name);
      expect(updated.id, user.id);
    });
  });
}
