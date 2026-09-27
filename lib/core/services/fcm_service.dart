import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_service.dart';

/// Background handler — must be top-level function (not inside a class)
@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
  debugPrint('[FCM] Title: ${message.notification?.title}');
  debugPrint('[FCM] Body: ${message.notification?.body}');
}

/// Firebase Cloud Messaging Service for Fandom Verse
/// Handles: permission, token management, foreground/background/tap handlers
class FCMService {
  static final FCMService _instance = FCMService._();
  FCMService._();
  static FCMService get instance => _instance;

  static FirebaseMessaging? get _fcm =>
      FirebaseService.isInitialized ? FirebaseMessaging.instance : null;

  static FirebaseFirestore? get _firestore =>
      FirebaseService.isInitialized ? FirebaseFirestore.instance : null;

  static const AndroidNotificationChannel _fcmChannel =
      AndroidNotificationChannel(
    'fandom_fcm_high', // same channel as NotificationService
    'Fandom FCM Notifications',
    description: 'Real-time push notifications from Fandom Verse',
    importance: Importance.high,
  );

  static final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  // ── Initialize ────────────────────────────────────────────────────────────
  static Future<void> initialize() async {
    if (_fcm == null) {
      debugPrint('[FCM] Firebase not initialized — skipping FCM setup.');
      return;
    }

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);

    // Create Android high-importance channel for FCM
    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_fcmChannel);

    // Request permission (iOS prompts, Android 13+ prompts)
    final settings = await _fcm!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');

    // Show foreground notifications as heads-up banners on iOS
    await _fcm!.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // ── Foreground message handler ──
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // ── Notification tap when app is in background (resumed) ──
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] App opened from background tap: ${message.data}');
      _handleNotificationTap(message.data);
    });

    // ── App launched from terminated state via notification tap ──
    final initialMessage = await _fcm!.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[FCM] App launched from terminated tap: ${initialMessage.data}');
      _handleNotificationTap(initialMessage.data);
    }

    // ── Token refresh listener ──
    _fcm!.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] Token refreshed: $newToken');
      // Token is stored per-user; refresh is handled on next login
    });

    debugPrint('[FCM] ✅ FCM Service initialized successfully.');
  }

  // ── Get current FCM token ─────────────────────────────────────────────────
  static Future<String?> getToken() async {
    if (_fcm == null) return null;
    try {
      final token = await _fcm!.getToken();
      debugPrint('[FCM] Device token: $token');
      return token;
    } catch (e) {
      debugPrint('[FCM] Failed to get token: $e');
      return null;
    }
  }

  // ── Save token to Firestore for this user ─────────────────────────────────
  /// Call this after successful login so admin can send targeted notifications
  static Future<void> saveTokenForUser(String userId) async {
    if (_firestore == null) return;
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) return;

      await _firestore!.collection('users').doc(userId).set(
        {
          'fcm_token': token,
          'fcm_token_updated_at': FieldValue.serverTimestamp(),
          'platform': defaultTargetPlatform.name.toLowerCase(),
        },
        SetOptions(merge: true),
      );
      debugPrint('[FCM] ✅ Token saved for user: $userId');
    } catch (e) {
      debugPrint('[FCM] Failed to save token: $e');
    }
  }

  // ── Remove token on logout ────────────────────────────────────────────────
  static Future<void> removeTokenForUser(String userId) async {
    if (_firestore == null) return;
    try {
      await _firestore!.collection('users').doc(userId).set(
        {'fcm_token': FieldValue.delete()},
        SetOptions(merge: true),
      );
      await _fcm?.deleteToken();
      debugPrint('[FCM] Token removed for user: $userId');
    } catch (e) {
      debugPrint('[FCM] Failed to remove token: $e');
    }
  }

  // ── Subscribe to topic (e.g. "all_fans", "anime_fans") ───────────────────
  static Future<void> subscribeToTopic(String topic) async {
    if (_fcm == null) return;
    await _fcm!.subscribeToTopic(topic);
    debugPrint('[FCM] Subscribed to topic: $topic');
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    if (_fcm == null) return;
    await _fcm!.unsubscribeFromTopic(topic);
    debugPrint('[FCM] Unsubscribed from topic: $topic');
  }

  // ── Show local notification for foreground FCM message ───────────────────
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'fandom_fcm_high',
      'Fandom FCM Notifications',
      channelDescription: 'Real-time push from Fandom Verse',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotif.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  // ── Handle notification tap → navigate ───────────────────────────────────
  static void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? '';
    debugPrint('[FCM] Notification tap type: $type');
    // Navigation is handled by the app router via a global key
    // For now log the data — can be wired to NavigationService
    switch (type) {
      case 'event':
        debugPrint('[FCM] Navigate to events');
        break;
      case 'store':
        debugPrint('[FCM] Navigate to store');
        break;
      case 'community':
        debugPrint('[FCM] Navigate to community');
        break;
      case 'news':
        debugPrint('[FCM] Navigate to feed');
        break;
    }
  }
}
