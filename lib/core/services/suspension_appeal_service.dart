import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../constants/db_constants.dart';
import '../database/sqlite_helper.dart';
import 'firebase_service.dart';

class SuspensionAppealService {
  static final SuspensionAppealService instance = SuspensionAppealService._internal();
  SuspensionAppealService._internal();

  final SqliteHelper _dbHelper = SqliteHelper.instance;

  FirebaseFirestore? get _firestore {
    try {
      if (FirebaseService.isInitialized) {
        return FirebaseFirestore.instance;
      }
    } catch (_) {}
    return null;
  }

  /// Submit an appeal for a suspended user
  Future<bool> submitAppeal({
    required String userId,
    required String email,
    required String name,
    required String reason,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final appealId = 'appeal_${userId}_$now';

    final appealData = {
      'appeal_id': appealId,
      'user_id': userId,
      'email': email.toLowerCase().trim(),
      'name': name.trim(),
      'reason': reason.trim(),
      'status': 'pending', // 'pending', 'approved', 'rejected'
      'created_at': now,
      'reviewed_at': null,
      'reviewed_by': null,
    };

    // 1. Save to SQLite
    try {
      await _dbHelper.insert(DbConstants.tableSuspensionAppeals, appealData);
    } catch (e) {
      debugPrint('[SuspensionAppealService] SQLite insert error: $e');
    }

    // 2. Save to Firestore if available
    if (_firestore != null) {
      try {
        await _firestore!
            .collection('suspension_appeals')
            .doc(appealId)
            .set(appealData)
            .timeout(const Duration(seconds: 8));
        debugPrint('[SuspensionAppealService] ✅ Appeal synced to Firestore');
      } catch (e) {
        debugPrint('[SuspensionAppealService] Firestore sync error: $e');
      }
    }

    return true;
  }

  /// Get latest appeal for a specific user
  Future<Map<String, dynamic>?> getAppealForUser(String userId) async {
    // 1. Try Firestore first
    if (_firestore != null) {
      try {
        final query = await _firestore!
            .collection('suspension_appeals')
            .where('user_id', isEqualTo: userId)
            .orderBy('created_at', descending: true)
            .limit(1)
            .get(const GetOptions(source: Source.serverAndCache))
            .timeout(const Duration(seconds: 6));

        if (query.docs.isNotEmpty) {
          final data = query.docs.first.data();
          return Map<String, dynamic>.from(data);
        }
      } catch (e) {
        debugPrint('[SuspensionAppealService] Firestore fetch error: $e');
      }
    }

    // 2. Fallback to SQLite
    try {
      final rows = await _dbHelper.query(
        DbConstants.tableSuspensionAppeals,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
        limit: 1,
      );
      if (rows.isNotEmpty) {
        return Map<String, dynamic>.from(rows.first);
      }
    } catch (e) {
      debugPrint('[SuspensionAppealService] SQLite fetch error: $e');
    }

    return null;
  }

  /// Real-time stream of user's appeal status
  Stream<Map<String, dynamic>?> streamAppealForUser(String userId) {
    if (_firestore == null) {
      return Stream.fromFuture(getAppealForUser(userId));
    }

    return _firestore!
        .collection('suspension_appeals')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final sorted = snapshot.docs.toList()
            ..sort((a, b) => ((b.data()['created_at'] as num?)?.toInt() ?? 0)
                .compareTo((a.data()['created_at'] as num?)?.toInt() ?? 0));
          return Map<String, dynamic>.from(sorted.first.data());
        });
  }

  /// Check whether a user is currently banned/suspended
  Future<bool> isUserBanned(String userId, {String? email}) async {
    // 1. Check SQLite
    try {
      final rows = await _dbHelper.query(
        DbConstants.tableUsers,
        where: 'user_id = ? OR email = ?',
        whereArgs: [userId, (email ?? '').toLowerCase().trim()],
      );
      if (rows.isNotEmpty) {
        final status = (rows.first['status'] ?? 'active').toString().toLowerCase();
        if (status == 'banned' || status == 'suspended') return true;
      }
    } catch (_) {}

    // 2. Check Firestore
    if (_firestore != null) {
      try {
        final doc = await _firestore!.collection('users').doc(userId).get();
        if (doc.exists) {
          final status = (doc.data()?['status'] ?? 'active').toString().toLowerCase();
          return status == 'banned' || status == 'suspended';
        }
      } catch (_) {}
    }

    return false;
  }

  /// Fetch all pending appeals for Admin review
  Future<List<Map<String, dynamic>>> getPendingAppeals() async {
    final Map<String, Map<String, dynamic>> appealsMap = {};

    // 1. Local SQLite appeals
    try {
      final local = await _dbHelper.query(
        DbConstants.tableSuspensionAppeals,
        where: "status = 'pending'",
        orderBy: 'created_at DESC',
      );
      for (final a in local) {
        appealsMap[a['appeal_id'].toString()] = Map<String, dynamic>.from(a);
      }
    } catch (_) {}

    // 2. Firestore appeals
    if (_firestore != null) {
      try {
        final snap = await _firestore!
            .collection('suspension_appeals')
            .where('status', isEqualTo: 'pending')
            .get()
            .timeout(const Duration(seconds: 6));

        for (final doc in snap.docs) {
          final data = doc.data();
          appealsMap[doc.id] = Map<String, dynamic>.from(data);
        }
      } catch (_) {}
    }

    return appealsMap.values.toList();
  }

  /// Admin approves an appeal -> Unbans the user immediately
  Future<void> approveAppeal({
    required String appealId,
    required String userId,
    String adminEmail = 'admin@fandomverse.com',
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. Update appeal in SQLite
    try {
      await _dbHelper.update(
        DbConstants.tableSuspensionAppeals,
        'appeal_id',
        appealId,
        {
          'status': 'approved',
          'reviewed_at': now,
          'reviewed_by': adminEmail,
        },
      );
    } catch (_) {}

    // 2. Unban user in SQLite
    try {
      await _dbHelper.updateUserStatus(userId, 'active');
    } catch (_) {}

    // 3. Update in Firestore
    if (_firestore != null) {
      try {
        await _firestore!.collection('suspension_appeals').doc(appealId).update({
          'status': 'approved',
          'reviewed_at': now,
          'reviewed_by': adminEmail,
        });

        // Set user status to active
        await _firestore!.collection('users').doc(userId).update({'status': 'active'});

        // Also query by user_id in case document ID differs
        final q = await _firestore!.collection('users').where('user_id', isEqualTo: userId).get();
        for (final doc in q.docs) {
          await doc.reference.update({'status': 'active'});
        }
      } catch (e) {
        debugPrint('[SuspensionAppealService] Firestore approve error: $e');
      }
    }
  }

  /// Admin rejects an appeal
  Future<void> rejectAppeal({
    required String appealId,
    required String userId,
    String adminEmail = 'admin@fandomverse.com',
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. Update SQLite
    try {
      await _dbHelper.update(
        DbConstants.tableSuspensionAppeals,
        'appeal_id',
        appealId,
        {
          'status': 'rejected',
          'reviewed_at': now,
          'reviewed_by': adminEmail,
        },
      );
    } catch (_) {}

    // 2. Update Firestore
    if (_firestore != null) {
      try {
        await _firestore!.collection('suspension_appeals').doc(appealId).update({
          'status': 'rejected',
          'reviewed_at': now,
          'reviewed_by': adminEmail,
        });
      } catch (_) {}
    }
  }
}
