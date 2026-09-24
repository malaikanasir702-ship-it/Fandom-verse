import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class FirebaseAuthService {
  FirebaseAuth? get _auth => FirebaseService.isInitialized ? FirebaseAuth.instance : null;
  FirebaseFirestore? get _firestore => FirebaseService.isInitialized ? FirebaseFirestore.instance : null;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges {
    if (_auth != null) {
      return _auth!.authStateChanges();
    }
    return Stream.value(null);
  }

  User? get currentUser => _auth?.currentUser;

  /// Sign In with Email & Password
  Future<Map<String, dynamic>?> signIn({
    required String email,
    required String password,
  }) async {
    if (!FirebaseService.isInitialized || _auth == null) {
      debugPrint('[FirebaseAuthService] Firebase not active. Using mock auth.');
      return null;
    }

    try {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user?.uid;
      if (uid != null && _firestore != null) {
        final doc = await _firestore!.collection('users').doc(uid).get();
        if (doc.exists) {
          return doc.data();
        }
      }
      return {
        'id': uid ?? 'user-uid',
        'email': email,
        'role': email.contains('admin') ? 'admin' : 'fan',
      };
    } on FirebaseAuthException catch (e) {
      debugPrint('[FirebaseAuthService] Sign-in error: ${e.message}');
      rethrow;
    }
  }

  /// Register new Fan account
  Future<Map<String, dynamic>?> signUp({
    required String email,
    required String password,
    required String name,
    List<String> selectedFandoms = const [],
  }) async {
    if (!FirebaseService.isInitialized || _auth == null) {
      debugPrint('[FirebaseAuthService] Firebase not active. Using mock auth.');
      return null;
    }

    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user?.uid;
      if (uid != null && _firestore != null) {
        final userData = {
          'id': uid,
          'email': email.trim().toLowerCase(),
          'name': name.trim(),
          'role': 'fan',
          'selectedFandoms': selectedFandoms,
          'badges': ['Novice Otaku'],
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _firestore!.collection('users').doc(uid).set(userData);
        return userData;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('[FirebaseAuthService] Sign-up error: ${e.message}');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    if (_auth != null) {
      await _auth!.sendPasswordResetEmail(email: email.trim());
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (_auth != null) {
      await _auth!.signOut();
    }
  }
}
