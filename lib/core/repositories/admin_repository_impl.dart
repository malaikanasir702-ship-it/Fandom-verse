import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/db_constants.dart';
import '../database/seed_data.dart';
import '../database/sqlite_helper.dart';
import '../services/firebase_service.dart';
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
    } catch (e) {
      debugPrint('[AdminRepository] SQLite users fetch error: $e');
    }

    // 2. Fetch from Firestore users collection (if Firebase is active)
    if (FirebaseService.isInitialized) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .get()
            .timeout(const Duration(seconds: 5));

        for (final doc in snap.docs) {
          final data = doc.data();
          final uid = doc.id;
          final email = (data['email'] ?? '').toString().toLowerCase().trim();
          final name = (data['name'] ?? data['displayName'] ?? 'Registered Fan').toString().trim();
          final role = (data['role'] ?? 'fan').toString().toLowerCase();
          final status = (data['status'] ?? 'active').toString().toLowerCase();
          final avatarUrl = (data['avatar_url'] ?? data['avatarUrl'] ?? data['photoURL'] ?? '').toString();
          final bio = (data['bio'] ?? '').toString();
          final badges = data['badges'] is List ? jsonEncode(data['badges']) : (data['badges'] ?? '[]').toString();
          final fandoms = (data['selectedFandoms'] ?? data['selected_fandoms']) is List
              ? jsonEncode(data['selectedFandoms'] ?? data['selected_fandoms'])
              : (data['selectedFandoms'] ?? data['selected_fandoms'] ?? '[]').toString();

          final userMap = {
            'user_id': (data['user_id'] ?? data['id'] ?? uid).toString(),
            'name': name.isNotEmpty ? name : 'Registered Fan',
            'email': email,
            'role': role,
            'status': status,
            'avatar_url': avatarUrl,
            'bio': bio,
            'badges': badges,
            'selected_fandoms': fandoms,
            'created_at': DateTime.now().millisecondsSinceEpoch,
          };

          final key = email.isNotEmpty ? email : uid.toLowerCase();
          combined[key] = userMap;

          // Background sync to SQLite
          try {
            await _dbHelper.insert(DbConstants.tableUsers, userMap);
          } catch (_) {}
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
    }
  }

  @override
  Future<List<Map<String, dynamic>>> query(String tableName, {String? where, List<dynamic>? whereArgs, String? orderBy, int? limit}) {
    return _dbHelper.query(tableName, where: where, whereArgs: whereArgs, orderBy: orderBy, limit: limit);
  }

  @override
  Future<int> insert(String tableName, Map<String, dynamic> row) {
    return _dbHelper.insert(tableName, row);
  }

  @override
  Future<int> update(String tableName, String primaryKey, String keyValue, Map<String, dynamic> updatedFields) {
    return _dbHelper.update(tableName, primaryKey, keyValue, updatedFields);
  }

  @override
  Future<int> delete(String tableName, String primaryKey, String keyValue) {
    return _dbHelper.delete(tableName, primaryKey, keyValue);
  }
}
