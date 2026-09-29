import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/db_constants.dart';
import '../database/seed_data.dart';
import '../database/sqlite_helper.dart';
import '../services/firebase_service.dart';
import '../services/hero_story_service.dart';
import '../utils/password_hasher.dart';
import 'i_admin_repository.dart';

class AdminRepositoryImpl implements IAdminRepository {
  final SqliteHelper _dbHelper;

  AdminRepositoryImpl({SqliteHelper? dbHelper})
      : _dbHelper = dbHelper ?? SqliteHelper.instance;

  @override
  Future<Map<String, int>> getDashboardMetrics() {
    return _dbHelper.getAdminDashboardMetrics();
  }

  @override
  Future<List<Map<String, dynamic>>> getAuditLogs({int limit = 50}) {
    return _dbHelper.getAuditLogs(limit: limit);
  }

  @override
  Future<void> logAdminAction({
    required String actionType,
    required String entityType,
    required String description,
    String adminEmail = 'admin@fandomverse.com',
  }) {
    return _dbHelper.logAdminAction(
      actionType: actionType,
      entityType: entityType,
      description: description,
      adminEmail: adminEmail,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final Map<String, Map<String, dynamic>> combined = {};

    // 1. Fetch from SQLite first
    try {
      final local = await _dbHelper.getAllUsers();
      for (final u in local) {
        final key = (u['email'] ?? u['user_id'] ?? '').toString().toLowerCase().trim();
        if (key.isNotEmpty) {
          combined[key] = Map<String, dynamic>.from(u);
        }
      }
      debugPrint('[AdminRepository] SQLite users loaded: ${local.length}');
    } catch (e) {
      debugPrint('[AdminRepository] SQLite users fetch error: $e');
    }

    // 2. Fetch from Firestore users collection (if Firebase is active)
    if (FirebaseService.isInitialized) {
      try {
        // Try server first, fallback to cache
        QuerySnapshot<Map<String, dynamic>> snap;
        try {
          snap = await FirebaseFirestore.instance
              .collection('users')
              .get(const GetOptions(source: Source.server))
              .timeout(const Duration(seconds: 20));
          debugPrint('[AdminRepository] Firestore server users: ${snap.docs.length}');
        } catch (_) {
          // Fallback to cache if server fails
          snap = await FirebaseFirestore.instance
              .collection('users')
              .get(const GetOptions(source: Source.cache));
          debugPrint('[AdminRepository] Firestore cache users: ${snap.docs.length}');
        }

        for (final doc in snap.docs) {
          final Map<String, dynamic> data = doc.data();
          final uid = doc.id;
          final email = (data['email'] ?? '').toString().toLowerCase().trim();
          final name = (data['name'] ?? data['displayName'] ?? '').toString().trim();
          final role = (data['role'] ?? 'fan').toString().toLowerCase();
          final status = (data['status'] ?? 'active').toString().toLowerCase();
          final avatarUrl = (data['avatar_url'] ?? data['avatarUrl'] ?? data['photoURL'] ?? '').toString();
          final bio = (data['bio'] ?? '').toString();

          // Fix badges: handle List or String
          String badges = '[]';
          if (data['badges'] is List) {
            badges = jsonEncode(data['badges']);
          } else if (data['badges'] != null) {
            badges = data['badges'].toString();
          }

          // Fix fandoms: avoid null-check ordering bug
          String fandoms = '[]';
          final rawFandoms = data['selectedFandoms'] ?? data['selected_fandoms'];
          if (rawFandoms is List) {
            fandoms = jsonEncode(rawFandoms);
          } else if (rawFandoms != null) {
            fandoms = rawFandoms.toString();
          }

          // Handle Firestore Timestamp for createdAt
          int createdAtMs = DateTime.now().millisecondsSinceEpoch;
          final rawCreatedAt = data['createdAt'] ?? data['created_at'];
          if (rawCreatedAt is Timestamp) {
            createdAtMs = rawCreatedAt.millisecondsSinceEpoch;
          } else if (rawCreatedAt is int) {
            createdAtMs = rawCreatedAt;
          }

          final userMap = {
            'user_id': (data['user_id'] ?? data['id'] ?? uid).toString(),
            'name': name.isNotEmpty ? name : 'Fan #${uid.substring(0, 6)}',
            'email': email,
            'role': role,
            'status': status,
            'avatar_url': avatarUrl,
            'bio': bio,
            'badges': badges,
            'selected_fandoms': fandoms,
            'created_at': createdAtMs,
          };

          final key = email.isNotEmpty ? email : uid.toLowerCase();
          // Firestore data always wins (it's the source of truth)
          combined[key] = userMap;

          // Background sync to SQLite (ConflictAlgorithm.replace handles duplicates)
          _dbHelper.insert(DbConstants.tableUsers, userMap).catchError((_) => 0);
        }
      } catch (e) {
        debugPrint('[AdminRepository] Firestore users fetch error: $e');
      }
    }

    // 3. Fallback: if totally empty, seed users
    if (combined.isEmpty) {
      for (final u in SeedData.defaultUsers) {
        final userMap = Map<String, dynamic>.from(u);
        final salt = u['role'] == 'admin' ? 'fandom_salt_admin' : 'fandom_salt_fan';
        final pwd = u['role'] == 'admin' ? 'admin123' : 'password123';
        userMap['password_salt'] = salt;
        userMap['password_hash'] = PasswordHasher.hashPassword(pwd, salt);
        userMap['status'] = userMap['status'] ?? 'active';
        final key = (userMap['email'] ?? userMap['user_id'] ?? '').toString().toLowerCase().trim();
        combined[key] = userMap;
        try {
          await _dbHelper.insert(DbConstants.tableUsers, userMap);
        } catch (_) {}
      }
    }

    final result = combined.values.toList();
    result.sort((a, b) {
      if (a['role'] == 'admin' && b['role'] != 'admin') return -1;
      if (a['role'] != 'admin' && b['role'] == 'admin') return 1;
      return (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString());
    });

    return result;
  }

  @override
  Future<void> updateUserStatus(String userId, String status) async {
    await _dbHelper.updateUserStatus(userId, status);
    if (FirebaseService.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'status': status})
            .timeout(const Duration(seconds: 4));
      } catch (_) {}
      try {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .where('user_id', isEqualTo: userId)
            .get();
        for (final doc in snap.docs) {
          await doc.reference.update({'status': status});
        }
      } catch (_) {}
    }
  }

  @override
  Future<List<Map<String, dynamic>>> query(String tableName, {String? where, List<dynamic>? whereArgs, String? orderBy, int? limit}) async {
    if (tableName == DbConstants.tableHeroStories) {
      return HeroStoryService.instance.getHeroStories();
    }
    if (tableName == DbConstants.tableCategories) {
      // ── Try Firestore first for categories (source of truth) ──
      if (FirebaseService.isInitialized) {
        try {
          final snap = await FirebaseFirestore.instance
              .collection('categories')
              .get(const GetOptions(source: Source.server))
              .timeout(const Duration(seconds: 8));

          if (snap.docs.isNotEmpty) {
            final firestoreCats = snap.docs.map((doc) {
              final data = Map<String, dynamic>.from(doc.data());
              // Ensure category_id is set
              data['category_id'] = data['category_id'] ?? doc.id;
              return data;
            }).toList();

            // Sync Firestore categories back to SQLite cache
            for (final cat in firestoreCats) {
              _dbHelper.insert(DbConstants.tableCategories, cat).catchError((_) => 0);
            }

            debugPrint('[AdminRepository] Categories loaded from Firestore: ${firestoreCats.length}');
            return firestoreCats;
          }
        } catch (e) {
          debugPrint('[AdminRepository] Firestore categories fetch error, falling back to SQLite: $e');
        }
      }

      // ── Fallback to SQLite ──
      final rows = await _dbHelper.query(tableName, where: where, whereArgs: whereArgs, orderBy: orderBy, limit: limit);
      if (rows.isNotEmpty) return rows;

      // ── Last resort: seed defaults ──
      for (final c in SeedData.defaultCategories) {
        try {
          await _dbHelper.insert(DbConstants.tableCategories, c);
        } catch (_) {}
      }
      return _dbHelper.query(tableName, where: where, whereArgs: whereArgs, orderBy: orderBy, limit: limit);
    }
    return _dbHelper.query(tableName, where: where, whereArgs: whereArgs, orderBy: orderBy, limit: limit);
  }

  @override
  Future<int> insert(String tableName, Map<String, dynamic> row) async {
    if (tableName == DbConstants.tableHeroStories) {
      await HeroStoryService.instance.saveHeroStory(row, isEdit: false);
      return 1;
    }

    final result = await _dbHelper.insert(tableName, row);

    // ── Sync categories to Firestore so they appear app-wide ──
    if (tableName == DbConstants.tableCategories && FirebaseService.isInitialized) {
      try {
        final docId = (row['category_id'] ?? '').toString();
        if (docId.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('categories')
              .doc(docId)
              .set(row, SetOptions(merge: true))
              .timeout(const Duration(seconds: 8));
          debugPrint('[AdminRepository] Category "$docId" synced to Firestore.');
        }
      } catch (e) {
        debugPrint('[AdminRepository] Firestore category insert error (non-fatal): $e');
      }
    }

    return result;
  }

  @override
  Future<int> update(String tableName, String primaryKey, String keyValue, Map<String, dynamic> updatedFields) async {
    if (tableName == DbConstants.tableHeroStories) {
      final data = Map<String, dynamic>.from(updatedFields);
      data['story_id'] = keyValue;
      await HeroStoryService.instance.saveHeroStory(data, isEdit: true);
      return 1;
    }

    final result = await _dbHelper.update(tableName, primaryKey, keyValue, updatedFields);

    // ── Sync category updates to Firestore ──
    if (tableName == DbConstants.tableCategories && FirebaseService.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(keyValue)
            .set(updatedFields, SetOptions(merge: true))
            .timeout(const Duration(seconds: 8));
        debugPrint('[AdminRepository] Category "$keyValue" update synced to Firestore.');
      } catch (e) {
        debugPrint('[AdminRepository] Firestore category update error (non-fatal): $e');
      }
    }

    return result;
  }

  @override
  Future<int> delete(String tableName, String primaryKey, String keyValue) async {
    if (tableName == DbConstants.tableHeroStories) {
      await HeroStoryService.instance.deleteHeroStory(keyValue);
      return 1;
    }

    // ── For users: also delete from Firestore so they cannot log back in ──
    if (tableName == DbConstants.tableUsers && FirebaseService.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(keyValue)
            .delete()
            .timeout(const Duration(seconds: 8));
        debugPrint('[AdminRepository] Deleted user $keyValue from Firestore.');
      } catch (e) {
        debugPrint('[AdminRepository] Firestore user delete error (non-fatal): $e');
        // Non-fatal: proceed with SQLite delete regardless
      }
    }

    // ── For categories: also delete from Firestore ──
    if (tableName == DbConstants.tableCategories && FirebaseService.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(keyValue)
            .delete()
            .timeout(const Duration(seconds: 8));
        debugPrint('[AdminRepository] Deleted category $keyValue from Firestore.');
      } catch (e) {
        debugPrint('[AdminRepository] Firestore category delete error (non-fatal): $e');
      }
    }

    return _dbHelper.delete(tableName, primaryKey, keyValue);
  }
}
