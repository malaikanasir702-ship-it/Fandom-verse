import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import '../database/sqlite_helper.dart';
import '../constants/db_constants.dart';

class FirebaseAuthService {
  FirebaseAuth? get _auth => FirebaseService.isInitialized ? FirebaseAuth.instance : null;
  FirebaseFirestore? get _firestore => FirebaseService.isInitialized ? FirebaseFirestore.instance : null;

  final StreamController<User?> _localAuthStreamController = StreamController<User?>.broadcast();

  /// Real-time stream of authentication state changes
  Stream<User?> get authStateChanges {
    if (_auth != null) {
      return _auth!.authStateChanges();
    }
    return _localAuthStreamController.stream;
  }

  User? get currentUser => _auth?.currentUser;

  /// Sign In with Email & Password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();

    if (normalizedEmail.isEmpty || trimmedPassword.isEmpty) {
      throw const FormatException('Please provide both email and password.');
    }

    if (FirebaseService.isInitialized && _auth != null) {
      try {
        final credential = await _auth!.signInWithEmailAndPassword(
          email: normalizedEmail,
          password: trimmedPassword,
        );

        final uid = credential.user?.uid;
        if (uid != null) {
          final profile = await getUserProfile(uid, email: normalizedEmail);
          if (profile != null) {
            return profile;
          }

          // If no profile exists yet in Firestore, create default profile
          final defaultProfile = {
            'id': uid,
            'user_id': uid,
            'email': normalizedEmail,
            'name': credential.user?.displayName ?? normalizedEmail.split('@').first,
            'role': 'fan',
            'status': 'active',
            'badges': ['Novice Otaku'],
            'selectedFandoms': ['Anime & Manga'],
            'createdAt': FieldValue.serverTimestamp(),
          };

          if (_firestore != null) {
            await _firestore!.collection('users').doc(uid).set(defaultProfile);
          }
          await _syncToSqlite(defaultProfile);
          return defaultProfile;
        }
        throw Exception('User authentication failed: UID missing.');
      } on FirebaseAuthException catch (e) {
        debugPrint('[FirebaseAuthService] Firebase Sign-in error: ${e.code} - ${e.message}');
        rethrow;
      }
    }

    // Offline / Local Database Auth Fallback
    debugPrint('[FirebaseAuthService] Operating in local database authentication mode.');
    final users = await SqliteHelper.instance.query(
      DbConstants.tableUsers,
      where: 'LOWER(email) = ?',
      whereArgs: [normalizedEmail],
    );

    if (users.isEmpty) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No account found with this email. Please sign up first.',
      );
    }

    final user = users.first;
    final status = (user['status'] ?? 'active').toString().toLowerCase();
    if (status == 'banned' || status == 'suspended') {
      throw FirebaseAuthException(
        code: 'user-disabled',
        message: 'Your account has been suspended by an administrator.',
      );
    }

    return Map<String, dynamic>.from(user);
  }

  /// Register new user account (Fan or Admin)
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'fan',
    List<String> selectedFandoms = const [],
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();
    final trimmedName = name.trim();

    if (trimmedName.isEmpty || normalizedEmail.isEmpty || trimmedPassword.isEmpty) {
      throw const FormatException('Name, email, and password are all required.');
    }

    if (FirebaseService.isInitialized && _auth != null) {
      try {
        final credential = await _auth!.createUserWithEmailAndPassword(
          email: normalizedEmail,
          password: trimmedPassword,
        );

        final uid = credential.user?.uid ?? 'usr_${DateTime.now().millisecondsSinceEpoch}';
        await credential.user?.updateDisplayName(trimmedName);

        final userData = {
          'id': uid,
          'user_id': uid,
          'email': normalizedEmail,
          'name': trimmedName,
          'role': role,
          'status': 'active',
          'selectedFandoms': selectedFandoms.isEmpty ? ['Anime & Manga'] : selectedFandoms,
          'badges': role == 'admin' ? ['Admin Commander', 'System Architect'] : ['Novice Otaku'],
          'createdAt': FieldValue.serverTimestamp(),
        };

        if (_firestore != null) {
          await _firestore!.collection('users').doc(uid).set(userData);
        }

        await _syncToSqlite(userData);
        return userData;
      } on FirebaseAuthException catch (e) {
        debugPrint('[FirebaseAuthService] Firebase Sign-up error: ${e.code} - ${e.message}');
        rethrow;
      }
    }

    // Offline / Local SQLite Mode
    debugPrint('[FirebaseAuthService] Operating in local database registration mode.');
    final existing = await SqliteHelper.instance.query(
      DbConstants.tableUsers,
      where: 'LOWER(email) = ?',
      whereArgs: [normalizedEmail],
    );

    if (existing.isNotEmpty) {
      throw FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'An account with this email address already exists.',
      );
    }

    final uid = 'usr_${DateTime.now().millisecondsSinceEpoch}';
    final userData = {
      'user_id': uid,
      'name': trimmedName,
      'email': normalizedEmail,
      'role': role,
      'status': 'active',
      'avatar_url': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
      'bio': role == 'admin' ? 'Authorized System Administrator' : 'Fandom Universe Explorer',
      'badges': role == 'admin' ? '["Admin Commander", "System Architect"]' : '["Novice Otaku"]',
      'selected_fandoms': selectedFandoms.isEmpty ? '["Anime & Manga"]' : selectedFandoms.toString(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    };

    await SqliteHelper.instance.insert(DbConstants.tableUsers, userData);
    return userData;
  }

  /// Retrieve user profile from Firestore or SQLite
  Future<Map<String, dynamic>?> getUserProfile(String uid, {String? email}) async {
    if (_firestore != null) {
      try {
        final doc = await _firestore!.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          await _syncToSqlite(data);
          return data;
        }

        if (email != null) {
          final query = await _firestore!
              .collection('users')
              .where('email', isEqualTo: email.toLowerCase().trim())
              .limit(1)
              .get();
          if (query.docs.isNotEmpty) {
            final data = query.docs.first.data();
            await _syncToSqlite(data);
            return data;
          }
        }
      } catch (e) {
        debugPrint('[FirebaseAuthService] Firestore getUserProfile error: $e');
      }
    }

    // SQLite fallback
    try {
      final users = await SqliteHelper.instance.query(
        DbConstants.tableUsers,
        where: 'user_id = ? OR LOWER(email) = ?',
        whereArgs: [uid, (email ?? '').toLowerCase().trim()],
      );
      if (users.isNotEmpty) {
        return Map<String, dynamic>.from(users.first);
      }
    } catch (e) {
      debugPrint('[FirebaseAuthService] SQLite getUserProfile error: $e');
    }

    return null;
  }

  /// Update selected fandoms in Firestore and SQLite
  Future<void> updateUserInterests(String uid, List<String> fandoms) async {
    if (_firestore != null) {
      try {
        await _firestore!.collection('users').doc(uid).update({
          'selectedFandoms': fandoms,
        });
      } catch (_) {}
    }

    try {
      await SqliteHelper.instance.update(
        DbConstants.tableUsers,
        'user_id',
        uid,
        {'selected_fandoms': fandoms.toString()},
      );
    } catch (_) {}
  }

  /// Update user profile (name, bio, avatar_url) in SQLite & Firestore
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? bio,
    String? avatarUrl,
    bool removeAvatar = false,
  }) async {
    final Map<String, dynamic> sqliteUpdates = {};
    final Map<String, dynamic> firestoreUpdates = {};

    if (name != null) {
      sqliteUpdates['name'] = name;
      firestoreUpdates['name'] = name;
    }
    if (bio != null) {
      sqliteUpdates['bio'] = bio;
      firestoreUpdates['bio'] = bio;
    }
    if (removeAvatar) {
      sqliteUpdates['avatar_url'] = null;
      firestoreUpdates['avatar_url'] = null;
      firestoreUpdates['avatarUrl'] = null;
    } else if (avatarUrl != null) {
      sqliteUpdates['avatar_url'] = avatarUrl;
      firestoreUpdates['avatar_url'] = avatarUrl;
      firestoreUpdates['avatarUrl'] = avatarUrl;
    }

    // 1. Update SQLite
    try {
      if (sqliteUpdates.isNotEmpty) {
        await SqliteHelper.instance.update(
          DbConstants.tableUsers,
          'user_id',
          uid,
          sqliteUpdates,
        );
      }
    } catch (e) {
      debugPrint('[FirebaseAuthService] SQLite update error: $e');
    }

    // 2. Update Firestore
    if (_firestore != null && firestoreUpdates.isNotEmpty) {
      try {
        await _firestore!.collection('users').doc(uid).set(
          firestoreUpdates,
          SetOptions(merge: true),
        );
      } catch (e) {
        debugPrint('[FirebaseAuthService] Firestore update error: $e');
      }
    }

    // 3. Update Firebase Auth displayName / photoURL
    try {
      if (name != null) {
        await _auth?.currentUser?.updateDisplayName(name);
      }
      if (removeAvatar) {
        await _auth?.currentUser?.updatePhotoURL(null);
      } else if (avatarUrl != null) {
        await _auth?.currentUser?.updatePhotoURL(avatarUrl);
      }
    } catch (_) {}
  }

  /// Add a badge in Firestore and SQLite
  Future<void> addBadge(String uid, String badgeTitle) async {
    if (_firestore != null) {
      try {
        await _firestore!.collection('users').doc(uid).update({
          'badges': FieldValue.arrayUnion([badgeTitle]),
        });
      } catch (_) {}
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (_auth != null) {
      await _auth!.sendPasswordResetEmail(email: normalizedEmail);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (_auth != null) {
      await _auth!.signOut();
    }
    _localAuthStreamController.add(null);
  }

  /// Synchronize Firestore user data to SQLite cache
  Future<void> _syncToSqlite(Map<String, dynamic> data) async {
    try {
      final uid = (data['user_id'] ?? data['id'] ?? '').toString();
      if (uid.isEmpty) return;

      final sqliteData = {
        'user_id': uid,
        'name': (data['name'] ?? 'Fan').toString(),
        'email': (data['email'] ?? '').toString(),
        'role': (data['role'] ?? 'fan').toString(),
        'status': (data['status'] ?? 'active').toString(),
        'avatar_url': (data['avatarUrl'] ?? data['avatar_url'] ?? '').toString(),
        'bio': (data['bio'] ?? '').toString(),
        'badges': (data['badges'] ?? []).toString(),
        'selected_fandoms': (data['selectedFandoms'] ?? data['selected_fandoms'] ?? []).toString(),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };

      await SqliteHelper.instance.insert(
        DbConstants.tableUsers,
        sqliteData,
      );
    } catch (_) {
      // Ignored if already exists
    }
  }
}
