import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../database/sqlite_helper.dart';
import '../../features/profile/domain/entities/app_notification_entity.dart';

/// Handles local push notifications for Fandom Verse.
/// Covers: event reminders, order confirmations, price drops, community replies.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  // Notification channel IDs
  static const String _channelGeneral = 'fandom_general';
  static const String _channelOrders = 'fandom_orders';
  static const String _channelEvents = 'fandom_events';
  static const String _channelCommunity = 'fandom_community';
  static const String _channelStore = 'fandom_store';

  // Preferences keys
  static const String _prefPush = 'pushNotifications';
  static const String _prefEvents = 'eventReminders';
  static const String _prefPriceDrop = 'priceDropAlerts';
  static const String _prefCommunity = 'communityReplies';

  /// Initialize the notification plugin. Call once in main().
  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Android notification channels
    await _createChannel(
      id: _channelGeneral,
      name: 'General',
      description: 'Fandom Verse general announcements',
    );
    await _createChannel(
      id: _channelOrders,
      name: 'Orders',
      description: 'Order confirmations and delivery updates',
    );
    await _createChannel(
      id: _channelEvents,
      name: 'Events',
      description: 'Convention reminders and event alerts',
    );
    await _createChannel(
      id: _channelCommunity,
      name: 'Community',
      description: 'Discussion replies and community updates',
    );
    await _createChannel(
      id: _channelStore,
      name: 'Store & Price Drops',
      description: 'Wishlist price drop alerts and order updates',
    );

    _initialized = true;
    await refreshUnreadCount();
    debugPrint('✅ [NotificationService] Initialized successfully.');
  }

  /// Refresh unread notifications count from SQLite and notify all listeners
  static Future<void> refreshUnreadCount() async {
    try {
      final count = await SqliteHelper.instance.getUnreadNotificationsCount();
      unreadCountNotifier.value = count;
    } catch (e) {
      debugPrint('[NotificationService] Error refreshing unread count: $e');
    }
  }

  static Future<void> _createChannel({
    required String id,
    required String name,
    required String description,
  }) async {
    final channel = AndroidNotificationChannel(
      id,
      name,
      description: description,
      importance: Importance.high,
      playSound: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('[NotificationService] Tapped: ${response.payload}');
    // Navigation can be wired here via a global navigator key if needed.
  }

  // ─────────────────────────────────────────────────────────────────
  // PUBLIC API
  // ─────────────────────────────────────────────────────────────────

  /// Show a general push notification immediately and persist to SQLite.
  static Future<void> showTestNotification({
    required String title,
    required String body,
    String? targetRoute,
    String? iconName,
    String? colorHex,
  }) async {
    await _show(
      id: 0,
      title: title,
      body: body,
      channelId: _channelGeneral,
    );

    try {
      final notif = AppNotificationEntity(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
        type: 'general',
        targetRoute: targetRoute,
        iconName: iconName ?? 'bell',
        colorHex: colorHex ?? '#00E676',
        isRead: false,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await SqliteHelper.instance.saveNotification(notif);
      await refreshUnreadCount();
    } catch (_) {}
  }

  /// Show an order confirmation notification.
  static Future<void> showOrderConfirmation({
    required String orderId,
    required double total,
  }) async {
    final prefs = await getPreferences();
    if (prefs[_prefPush] == false) return;

    await _show(
      id: orderId.hashCode,
      title: '✅ Order Confirmed!',
      body: 'Order #$orderId — \$${total.toStringAsFixed(2)} has been placed.',
      channelId: _channelOrders,
      payload: 'order:$orderId',
    );
  }

  /// Show an event reminder notification.
  static Future<void> showEventReminder({
    required String eventTitle,
    required String daysLeft,
  }) async {
    final prefs = await getPreferences();
    if (prefs[_prefEvents] == false) return;

    await _show(
      id: eventTitle.hashCode,
      title: '🎪 Event Reminder',
      body: '$eventTitle starts in $daysLeft. Don\'t miss it!',
      channelId: _channelEvents,
      payload: 'event',
    );
  }

  /// Show a price drop alert for a wishlist item.
  static Future<void> showPriceDropAlert({
    required String productName,
    required double newPrice,
  }) async {
    final prefs = await getPreferences();
    if (prefs[_prefPriceDrop] == false) return;

    await _show(
      id: productName.hashCode,
      title: '🏷️ Price Drop Alert',
      body: '$productName is now \$${newPrice.toStringAsFixed(2)}!',
      channelId: _channelStore,
      payload: 'store',
    );
  }

  /// Show a community reply notification.
  static Future<void> showCommunityReply({
    required String userName,
    required String threadTitle,
  }) async {
    final prefs = await getPreferences();
    if (prefs[_prefCommunity] == false) return;

    await _show(
      id: '${userName}_$threadTitle'.hashCode,
      title: '💬 New Reply',
      body: '$userName replied to "$threadTitle"',
      channelId: _channelCommunity,
      payload: 'community',
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // PREFERENCES (SharedPreferences)
  // ─────────────────────────────────────────────────────────────────

  static Future<Map<String, bool>> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      _prefPush: prefs.getBool(_prefPush) ?? true,
      _prefEvents: prefs.getBool(_prefEvents) ?? true,
      _prefPriceDrop: prefs.getBool(_prefPriceDrop) ?? true,
      _prefCommunity: prefs.getBool(_prefCommunity) ?? true,
    };
  }

  static Future<void> savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    debugPrint('[NotificationService] Saved pref: $key = $value');
  }

  // ─────────────────────────────────────────────────────────────────
  // INTERNAL
  // ─────────────────────────────────────────────────────────────────

  static Future<void> _show({
    required int id,
    required String title,
    required String body,
    required String channelId,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }
}
