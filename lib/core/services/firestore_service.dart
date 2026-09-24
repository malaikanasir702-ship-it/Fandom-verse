import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class FirestoreService {
  FirebaseFirestore? get _firestore =>
      FirebaseService.isInitialized ? FirebaseFirestore.instance : null;

  // ─── Fandom Posts / News / Lore ───
  Future<List<Map<String, dynamic>>> getPosts({String? category}) async {
    if (_firestore == null) return [];
    try {
      Query query = _firestore!.collection('fandom_posts');
      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('[FirestoreService] getPosts error: $e');
      return [];
    }
  }

  // ─── Events & Conventions ───
  Future<List<Map<String, dynamic>>> getEvents({String? city}) async {
    if (_firestore == null) return [];
    try {
      Query query = _firestore!.collection('events');
      if (city != null && city != 'All') {
        query = query.where('cityName', isEqualTo: city);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('[FirestoreService] getEvents error: $e');
      return [];
    }
  }

  // ─── Store Products ───
  Future<List<Map<String, dynamic>>> getProducts({String? category}) async {
    if (_firestore == null) return [];
    try {
      Query query = _firestore!.collection('products');
      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('[FirestoreService] getProducts error: $e');
      return [];
    }
  }

  // ─── User Orders & Checkout ───
  Future<void> saveOrder(Map<String, dynamic> orderData) async {
    if (_firestore == null) return;
    try {
      await _firestore!.collection('orders').add({
        ...orderData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[FirestoreService] saveOrder error: $e');
    }
  }

  // ─── Admin Content Moderation ───
  Future<void> addOrUpdatePost(String id, Map<String, dynamic> data) async {
    if (_firestore == null) return;
    await _firestore!.collection('fandom_posts').doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> deletePost(String id) async {
    if (_firestore == null) return;
    await _firestore!.collection('fandom_posts').doc(id).delete();
  }
}
