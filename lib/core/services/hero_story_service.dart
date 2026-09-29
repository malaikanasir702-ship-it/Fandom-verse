import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/sqlite_helper.dart';
import '../database/seed_hero_stories.dart';
import 'firebase_service.dart';

class HeroStoryService {
  static final HeroStoryService _instance = HeroStoryService._();
  HeroStoryService._();
  static HeroStoryService get instance => _instance;

  static const String collectionName = 'hero_stories';

  FirebaseFirestore? get _firestore =>
      FirebaseService.isInitialized ? FirebaseFirestore.instance : null;

  /// Fetches hero stories from Firestore.
  /// If Firestore is empty, auto-seeds default heroes into Firestore.
  /// Synchronizes results to local SQLite cache.
  /// Falls back to SQLite if network or Firestore is unavailable.
  Future<List<Map<String, dynamic>>> getHeroStories() async {
    // 1. Try Firestore first
    if (_firestore != null) {
      try {
        final querySnap = await _firestore!
            .collection(collectionName)
            .get(const GetOptions(source: Source.serverAndCache))
            .timeout(const Duration(seconds: 8));

        if (querySnap.docs.isNotEmpty) {
          final List<Map<String, dynamic>> stories = [];
          for (final doc in querySnap.docs) {
            final data = Map<String, dynamic>.from(doc.data());
            data['story_id'] = (data['story_id'] ?? data['id'] ?? doc.id).toString();
            stories.add(data);

            // Sync to local SQLite cache in background
            SqliteHelper.instance.saveHeroStory(data).catchError((_) {});
          }

          stories.sort((a, b) {
            final aCreated = (a['created_at'] as num?)?.toInt() ?? 0;
            final bCreated = (b['created_at'] as num?)?.toInt() ?? 0;
            return aCreated.compareTo(bCreated);
          });

          debugPrint('[HeroStoryService] Fetched ${stories.length} stories from Firestore');
          return stories;
        } else {
          // Firestore is empty — auto-seed default heroes to Firestore
          debugPrint('[HeroStoryService] Firestore hero_stories is empty. Seeding defaults...');
          await seedFirestoreDefaults();
          return SeedHeroStories.defaultStories;
        }
      } catch (e) {
        debugPrint('[HeroStoryService] Firestore fetch error: $e. Falling back to SQLite.');
      }
    }

    // 2. Fallback to SQLite
    try {
      final localStories = await SqliteHelper.instance.getHeroStories();
      if (localStories.isNotEmpty) {
        debugPrint('[HeroStoryService] Loaded ${localStories.length} stories from SQLite');
        return localStories;
      }
    } catch (e) {
      debugPrint('[HeroStoryService] SQLite fallback error: $e');
    }

    // 3. Fallback to in-memory SeedHeroStories
    return SeedHeroStories.defaultStories;
  }

  /// Real-time stream of hero stories from Firestore.
  Stream<List<Map<String, dynamic>>> streamHeroStories() {
    if (_firestore == null) {
      return Stream.fromFuture(getHeroStories());
    }

    return _firestore!.collection(collectionName).snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return SeedHeroStories.defaultStories;
      }

      final List<Map<String, dynamic>> stories = [];
      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        data['story_id'] = (data['story_id'] ?? data['id'] ?? doc.id).toString();
        stories.add(data);
        SqliteHelper.instance.saveHeroStory(data).catchError((_) {});
      }

      stories.sort((a, b) {
        final aCreated = (a['created_at'] as num?)?.toInt() ?? 0;
        final bCreated = (b['created_at'] as num?)?.toInt() ?? 0;
        return aCreated.compareTo(bCreated);
      });

      return stories;
    });
  }

  /// Save or update a hero story in both Firestore and SQLite.
  Future<void> saveHeroStory(Map<String, dynamic> storyMap, {bool isEdit = false}) async {
    final storyId = (storyMap['story_id'] ?? storyMap['id'] ?? '').toString();
    if (storyId.isEmpty) return;

    final dataToSave = Map<String, dynamic>.from(storyMap);
    dataToSave['story_id'] = storyId;
    dataToSave['updated_at'] = DateTime.now().millisecondsSinceEpoch;

    // 1. Save to Firestore
    if (_firestore != null) {
      try {
        await _firestore!
            .collection(collectionName)
            .doc(storyId)
            .set(dataToSave, SetOptions(merge: true))
            .timeout(const Duration(seconds: 8));
        debugPrint('[HeroStoryService] Saved hero story $storyId to Firestore');
      } catch (e) {
        debugPrint('[HeroStoryService] Firestore save error for $storyId: $e');
      }
    }

    // 2. Save to local SQLite
    try {
      await SqliteHelper.instance.saveHeroStory(dataToSave);
      debugPrint('[HeroStoryService] Saved hero story $storyId to SQLite');
    } catch (e) {
      debugPrint('[HeroStoryService] SQLite save error for $storyId: $e');
    }
  }

  /// Delete a hero story from both Firestore and SQLite.
  Future<void> deleteHeroStory(String storyId) async {
    if (storyId.isEmpty) return;

    // 1. Delete from Firestore
    if (_firestore != null) {
      try {
        await _firestore!
            .collection(collectionName)
            .doc(storyId)
            .delete()
            .timeout(const Duration(seconds: 8));
        debugPrint('[HeroStoryService] Deleted hero story $storyId from Firestore');
      } catch (e) {
        debugPrint('[HeroStoryService] Firestore delete error for $storyId: $e');
      }
    }

    // 2. Delete from local SQLite
    try {
      await SqliteHelper.instance.deleteHeroStory(storyId);
      debugPrint('[HeroStoryService] Deleted hero story $storyId from SQLite');
    } catch (e) {
      debugPrint('[HeroStoryService] SQLite delete error for $storyId: $e');
    }
  }

  /// Auto-seed default stories into Firestore and SQLite
  Future<void> seedFirestoreDefaults() async {
    try {
      final defaults = SeedHeroStories.defaultStories;
      if (_firestore != null) {
        final batch = _firestore!.batch();
        for (final story in defaults) {
          final id = story['story_id'] as String;
          final ref = _firestore!.collection(collectionName).doc(id);
          batch.set(ref, {
            ...story,
            'seededAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
        await batch.commit().timeout(const Duration(seconds: 10));
        debugPrint('[HeroStoryService] Successfully seeded ${defaults.length} default heroes to Firestore');
      }

      for (final story in defaults) {
        await SqliteHelper.instance.saveHeroStory(story).catchError((_) {});
      }
    } catch (e) {
      debugPrint('[HeroStoryService] seedFirestoreDefaults error: $e');
    }
  }
}
