import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_service.dart';
import 'secure_storage_service.dart';
import '../database/sqlite_helper.dart';
import '../constants/db_constants.dart';
import '../utils/password_hasher.dart';

/// Network timeout for all Firebase/Firestore calls.
/// If the server doesn't respond within this duration the app
/// falls back to the local SQLite database automatically.
const _kNetworkTimeout = Duration(seconds: 10);

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
        final credential = await _auth!
            .signInWithEmailAndPassword(
              email: normalizedEmail,
              password: trimmedPassword,
            )
            .timeout(
              _kNetworkTimeout,
              onTimeout: () => throw TimeoutException(
                'Firebase sign-in timed out. Falling back to offline mode.',
              ),
            );

        final token = await credential.user
            ?.getIdToken()
            .timeout(_kNetworkTimeout, onTimeout: () => null);
        if (token != null) {
          await SecureStorageService.saveAuthToken(token);
        }

        final uid = credential.user?.uid;
        if (uid != null) {
          final profile = await getUserProfile(uid, email: normalizedEmail);
          if (profile != null) {
            await SecureStorageService.saveUserCredentials(
              email: normalizedEmail,
              role: (profile['role'] ?? 'fan').toString(),
            );
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
            await _firestore!.collection('users').doc(uid).set(defaultProfile)
                .timeout(_kNetworkTimeout, onTimeout: () {});
          }
          await _syncToSqlite(defaultProfile);
          await SecureStorageService.saveUserCredentials(
            email: normalizedEmail,
            role: 'fan',
          );
          return defaultProfile;
        }
        throw Exception('User authentication failed: UID missing.');
      } on FirebaseAuthException catch (e) {
        debugPrint('[FirebaseAuthService] Firebase Sign-in error: ${e.code} - ${e.message}');
        rethrow;
      } on TimeoutException catch (e) {
        debugPrint('[FirebaseAuthService] Network timeout during sign-in: $e. Using offline auth.');
        // Fall through to SQLite offline auth below
      } on SocketException catch (e) {
        debugPrint('[FirebaseAuthService] Socket error during sign-in: $e. Using offline auth.');
        // Fall through to SQLite offline auth below
      } catch (e) {
        // Catch any other network-level errors (e.g., wsarecv) and fall through
        if (e.toString().contains('wsarecv') ||
            e.toString().contains('connection') ||
            e.toString().contains('network')) {
          debugPrint('[FirebaseAuthService] Network error: $e. Using offline auth.');
          // Fall through to SQLite offline auth below
        } else {
          rethrow;
        }
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

    // Bug 1.1 / 2.1: Verify Password Hash using SHA-256 and salt
    final storedHash = user['password_hash'] as String?;
    final storedSalt = user['password_salt'] as String?;

    if (storedHash != null && storedSalt != null) {
      final isValid = PasswordHasher.verifyPassword(
        password: trimmedPassword,
        salt: storedSalt,
        storedHash: storedHash,
      );
      if (!isValid) {
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message: 'The password entered is incorrect.',
        );
      }
    } else {
      // Legacy seed fallback: verify against standard default passwords
      final defaultPwd = user['role'] == 'admin' ? 'admin123' : 'password123';
      if (trimmedPassword != defaultPwd) {
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message: 'The password entered is incorrect.',
        );
      }
      // Upgrade legacy record with SHA-256 hash and salt
      final salt = PasswordHasher.generateSalt();
      final hash = PasswordHasher.hashPassword(trimmedPassword, salt);
      await SqliteHelper.instance.update(
        DbConstants.tableUsers,
        'user_id',
        user['user_id'] as String,
        {'password_salt': salt, 'password_hash': hash},
      );
    }

    // Save credentials securely
    await SecureStorageService.saveUserCredentials(
      email: normalizedEmail,
      role: (user['role'] ?? 'fan').toString(),
    );

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

    final salt = PasswordHasher.generateSalt();
    final passwordHash = PasswordHasher.hashPassword(trimmedPassword, salt);

    if (FirebaseService.isInitialized && _auth != null) {
      try {
        final credential = await _auth!
            .createUserWithEmailAndPassword(
              email: normalizedEmail,
              password: trimmedPassword,
            )
            .timeout(
              _kNetworkTimeout,
              onTimeout: () => throw TimeoutException(
                'Firebase sign-up timed out. Falling back to offline mode.',
              ),
            );

        final token = await credential.user
            ?.getIdToken()
            .timeout(_kNetworkTimeout, onTimeout: () => null);
        if (token != null) {
          await SecureStorageService.saveAuthToken(token);
        }

        final uid = credential.user?.uid ?? 'usr_${DateTime.now().millisecondsSinceEpoch}';
        await credential.user?.updateDisplayName(trimmedName)
            .timeout(_kNetworkTimeout, onTimeout: () {});

        final userData = {
          'id': uid,
          'user_id': uid,
          'email': normalizedEmail,
          'name': trimmedName,
          'role': role,
          'status': 'active',
          'selectedFandoms': selectedFandoms.isEmpty ? ['Anime & Manga'] : selectedFandoms,
          'badges': role == 'admin' ? ['Admin Commander', 'System Architect'] : ['Novice Otaku'],
          'password_hash': passwordHash,
          'password_salt': salt,
          'createdAt': FieldValue.serverTimestamp(),
        };

        if (_firestore != null) {
          await _firestore!.collection('users').doc(uid).set(userData)
              .timeout(_kNetworkTimeout, onTimeout: () {});
        }

        await _syncToSqlite(userData);
        await SecureStorageService.saveUserCredentials(email: normalizedEmail, role: role);
        return userData;
      } on FirebaseAuthException catch (e) {
        debugPrint('[FirebaseAuthService] Firebase Sign-up error: ${e.code} - ${e.message}');
        rethrow;
      } on TimeoutException catch (e) {
        debugPrint('[FirebaseAuthService] Network timeout during sign-up: $e. Using offline mode.');
        // Fall through to SQLite offline registration below
      } on SocketException catch (e) {
        debugPrint('[FirebaseAuthService] Socket error during sign-up: $e. Using offline mode.');
        // Fall through to SQLite offline registration below
      } catch (e) {
        if (e.toString().contains('wsarecv') ||
            e.toString().contains('connection') ||
            e.toString().contains('network')) {
          debugPrint('[FirebaseAuthService] Network error during sign-up: $e. Using offline mode.');
          // Fall through to SQLite offline registration below
        } else {
          rethrow;
        }
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
      'password_hash': passwordHash,
      'password_salt': salt,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    };

    await SqliteHelper.instance.insert(DbConstants.tableUsers, userData);
    await SecureStorageService.saveUserCredentials(email: normalizedEmail, role: role);
    return userData;
  }

  /// Retrieve user profile from Firestore or SQLite
  Future<Map<String, dynamic>?> getUserProfile(String uid, {String? email}) async {
    if (_firestore != null) {
      try {
        final doc = await _firestore!
            .collection('users')
            .doc(uid)
            .get()
            .timeout(_kNetworkTimeout);
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
              .get()
              .timeout(_kNetworkTimeout);
          if (query.docs.isNotEmpty) {
            final data = query.docs.first.data();
            await _syncToSqlite(data);
            return data;
          }
        }
      } on TimeoutException catch (e) {
        debugPrint('[FirebaseAuthService] Firestore getUserProfile timeout: $e. Using SQLite.');
      } on SocketException catch (e) {
        debugPrint('[FirebaseAuthService] Firestore getUserProfile socket error: $e. Using SQLite.');
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

  /// Sign in with Google OAuth
  Future<Map<String, dynamic>> signInWithGoogle() async {
    if (!FirebaseService.isInitialized || _auth == null) {
      throw Exception('Google Sign-In requires Firebase. Please check your connection.');
    }

    final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

    // Trigger the Google account picker
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign-In was cancelled.');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth!
        .signInWithCredential(credential)
        .timeout(_kNetworkTimeout);

    final token = await userCredential.user
        ?.getIdToken()
        .timeout(_kNetworkTimeout, onTimeout: () => null);
    if (token != null) {
      await SecureStorageService.saveAuthToken(token);
    }

    final uid = userCredential.user!.uid;
    final email = userCredential.user!.email ?? googleUser.email;
    final displayName = userCredential.user!.displayName ?? googleUser.displayName ?? email.split('@').first;
    final photoUrl = userCredential.user!.photoURL ?? googleUser.photoUrl;

    // Check if profile already exists
    final existing = await getUserProfile(uid, email: email);
    if (existing != null) {
      // Update avatar if Google has a newer one
      if (photoUrl != null && (existing['avatar_url'] == null || existing['avatar_url'].toString().isEmpty)) {
        await updateUserProfile(uid: uid, avatarUrl: photoUrl);
      }
      await SecureStorageService.saveUserCredentials(
        email: email,
        role: (existing['role'] ?? 'fan').toString(),
      );
      return existing;
    }

    // Create new profile for first-time Google sign-in
    final userData = {
      'id': uid,
      'user_id': uid,
      'email': email,
      'name': displayName,
      'role': 'fan',
      'status': 'active',
      'avatar_url': photoUrl ?? '',
      'avatarUrl': photoUrl ?? '',
      'bio': 'Fandom Universe Explorer',
      'selectedFandoms': ['Anime & Manga'],
      'badges': ['Novice Otaku'],
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (_firestore != null) {
      await _firestore!
          .collection('users')
          .doc(uid)
          .set(userData, SetOptions(merge: true))
          .timeout(_kNetworkTimeout, onTimeout: () {});
    }

    await _syncToSqlite(userData);
    await SecureStorageService.saveUserCredentials(email: email, role: 'fan');
    return userData;
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (_auth != null) {
      await _auth!.sendPasswordResetEmail(email: normalizedEmail);
    }
  }

  /// Sign out (also disconnects Google if active)
  Future<void> signOut() async {
    if (_auth != null) {
      await _auth!.signOut();
    }
    // Disconnect Google session silently
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (_) {}
    await SecureStorageService.clearAuthData();
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
