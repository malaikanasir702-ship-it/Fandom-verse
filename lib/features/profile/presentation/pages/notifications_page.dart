import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/database/sqlite_helper.dart';
import '../../domain/entities/app_notification_entity.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<AppNotificationEntity> _notifications = [];
  bool _isLoading = true;
  String _selectedFilter = 'All'; // 'All', 'Unread', 'Tickets', 'Events'
  StreamSubscription<QuerySnapshot>? _broadcastSubscription;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _setupFCMListener();
    _setupBroadcastListener();
  }

  @override
  void dispose() {
    _broadcastSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      final list = await SqliteHelper.instance.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = list;
          _isLoading = false;
        });
        await NotificationService.refreshUnreadCount();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _setupFCMListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        final notif = AppNotificationEntity(
          id: 'fcm-${DateTime.now().millisecondsSinceEpoch}',
          title: message.notification!.title ?? 'New Notification',
          body: message.notification!.body ?? '',
          type: (message.data['type'] ?? 'general').toString(),
          targetRoute: message.data['target_route'] as String?,
          iconName: 'bell',
          colorHex: '#E53935',
          isRead: false,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
        await SqliteHelper.instance.saveNotification(notif);
        if (mounted) {
          _loadNotifications();
        }
      }
    });
  }

  /// Listen to Firestore 'broadcasts' collection for admin-sent notifications.
  /// New documents trigger a local inbox entry + local push.
  void _setupBroadcastListener() {
    if (!FirebaseService.isInitialized) return;
    try {
      // Only listen to broadcasts from the last 24 hours to avoid loading history
      final since = DateTime.now()
          .subtract(const Duration(hours: 24))
          .millisecondsSinceEpoch;

      _broadcastSubscription = FirebaseFirestore.instance
          .collection('broadcasts')
          .where('created_at_ms', isGreaterThan: since)
          .orderBy('created_at_ms', descending: true)
          .snapshots()
          .listen((snapshot) async {
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data();
            if (data == null) continue;

            final broadcastId = data['broadcast_id'] as String? ?? change.doc.id;

            // Check if already saved to avoid duplicates
            final existing = await SqliteHelper.instance.getNotifications();
            final alreadySaved = existing.any((n) => n.id == broadcastId);
            if (alreadySaved) continue;

            final notif = AppNotificationEntity(
              id: broadcastId,
              title: (data['title'] ?? 'New Announcement').toString(),
              body: (data['body'] ?? '').toString(),
              type: (data['type'] ?? 'general').toString(),
              targetRoute: data['target_route'] as String?,
              iconName: (data['icon_name'] ?? 'bell').toString(),
              colorHex: (data['color_hex'] ?? '#E53935').toString(),
              isRead: false,
              createdAt: data['created_at_ms'] is int
                  ? data['created_at_ms'] as int
                  : DateTime.now().millisecondsSinceEpoch,
            );

            await SqliteHelper.instance.saveNotification(notif);

            // Show local push banner
            await NotificationService.showTestNotification(
              title: notif.title,
              body: notif.body,
              iconName: notif.iconName,
              colorHex: notif.colorHex,
            );

            if (mounted) _loadNotifications();
          }
        }
      });
    } catch (e) {
      debugPrint('[NotificationsPage] Broadcast listener error: $e');
    }
  }

  Future<void> _markAllRead() async {
    await SqliteHelper.instance.markAllNotificationsAsRead();
    await NotificationService.refreshUnreadCount();
    if (mounted) {
      setState(() {
        _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read.'),
          backgroundColor: AppColors.comicBlack,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleNotificationTap(AppNotificationEntity item) async {
    // 1. Mark as read in DB if unread
    if (!item.isRead) {
      await SqliteHelper.instance.markNotificationAsRead(item.id);
      await NotificationService.refreshUnreadCount();
      if (mounted) {
        setState(() {
          final index = _notifications.indexWhere((n) => n.id == item.id);
          if (index != -1) {
            _notifications[index] = _notifications[index].copyWith(isRead: true);
          }
        });
      }
    }

    // 2. Perform Real Navigation
    if (!mounted) return;
    if (item.targetRoute != null && item.targetRoute!.isNotEmpty) {
      Navigator.of(context).pushNamed(item.targetRoute!);
    } else {
      // Default contextual routing based on type
      switch (item.type.toLowerCase()) {
        case 'ticket':
          Navigator.of(context).pushNamed('/ticket-history');
          break;
        case 'event':
          Navigator.of(context).pushNamed('/events-calendar');
          break;
        case 'hero':
          Navigator.of(context).pushNamed('/favourite-heroes');
          break;
        case 'community':
          Navigator.of(context).pushNamed('/discussions');
          break;
        case 'badge':
          Navigator.of(context).pushNamed('/badges');
          break;
        default:
          break;
      }
    }
  }

  Future<void> _deleteNotification(AppNotificationEntity item, int index) async {
    // Optimistically remove from list
    setState(() {
      _notifications.removeAt(index);
    });

    await SqliteHelper.instance.deleteNotification(item.id);
    await NotificationService.refreshUnreadCount();

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed: "${item.title}"'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: AppColors.comicYellow,
            onPressed: () async {
              await SqliteHelper.instance.saveNotification(item);
              await NotificationService.refreshUnreadCount();
              if (mounted) {
                setState(() {
                  _notifications.insert(index, item);
                });
              }
            },
          ),
        ),
      );
    }
  }

  Future<void> _sendTestNotification() async {
    await NotificationService.showTestNotification(
      title: '🔔 Test Push Notification',
      body: 'Notifications are synchronized live with SQLite database!',
      targetRoute: '/notifications',
      iconName: 'bell',
      colorHex: '#00E676',
    );
    await _loadNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification created and saved!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  List<AppNotificationEntity> get _filteredNotifications {
    switch (_selectedFilter) {
      case 'Unread':
        return _notifications.where((n) => !n.isRead).toList();
      case 'Tickets':
        return _notifications.where((n) => n.type == 'ticket').toList();
      case 'Events':
        return _notifications.where((n) => n.type == 'event').toList();
      case 'All':
      default:
        return _notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _filteredNotifications;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const Text(
              'Notifications',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.comicRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_unreadCount NEW',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification_bing),
            tooltip: 'Send Test Notification',
            onPressed: _sendTestNotification,
          ),
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Iconsax.tick_circle),
              tooltip: 'Mark All Read',
              onPressed: _markAllRead,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.comicRed),
            )
          : Column(
              children: [
                // ─── Filter Tabs ───
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: ['All', 'Unread', 'Tickets', 'Events'].map((tab) {
                      final isSelected = _selectedFilter == tab;
                      int badgeCount = 0;
                      if (tab == 'Unread') badgeCount = _unreadCount;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(tab),
                              if (badgeCount > 0) ...[
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.comicRed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$badgeCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedFilter = tab),
                          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                          selectedColor: AppColors.comicRed.withValues(alpha: 0.18),
                          checkmarkColor: AppColors.comicRed,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.comicRed
                                : (isDark ? Colors.white70 : AppColors.comicBlack),
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.comicRed
                                  : (isDark ? AppColors.darkBorder : AppColors.comicBorderColor),
                              width: 1.2,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // ─── Swipe-to-delete Helper Hint ───
                if (items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${items.length} ${items.length == 1 ? 'Notification' : 'Notifications'}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Iconsax.arrow_left_2,
                              size: 11,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Swipe left to remove',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // ─── Notifications List with Swipe Left to Dismiss ───
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: (isDark ? AppColors.darkSurface : Colors.white),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Iconsax.notification_bing,
                                  size: 36,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedFilter == 'All'
                                    ? 'No notifications yet'
                                    : 'No $_selectedFilter notifications',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'You are all caught up!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = items[index];

                            return Dismissible(
                              key: ValueKey(item.id),
                              direction: DismissDirection.endToStart, // Swipe left to remove
                              onDismissed: (_) => _deleteNotification(item, index),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.comicRed,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.comicRed.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'DELETE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Iconsax.trash, color: Colors.white, size: 22),
                                  ],
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () => _handleNotificationTap(item),
                                child: GlassContainer(
                                  padding: const EdgeInsets.all(14),
                                  borderColor: item.isRead
                                      ? (isDark ? AppColors.darkBorder : AppColors.comicBorderColor.withValues(alpha: 0.3))
                                      : item.color.withValues(alpha: 0.6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Notification Icon Avatar with Accent
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          CircleAvatar(
                                            radius: 22,
                                            backgroundColor: item.color.withValues(alpha: 0.16),
                                            child: Icon(item.icon, color: item.color, size: 22),
                                          ),
                                          if (!item.isRead)
                                            Positioned(
                                              top: -1,
                                              right: -1,
                                              child: Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: AppColors.comicRed,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: isDark ? AppColors.darkSurface : Colors.white,
                                                    width: 1.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 14),

                                      // Content & Navigation indicator
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.title,
                                                    style: TextStyle(
                                                      fontWeight: item.isRead ? FontWeight.w700 : FontWeight.w900,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  item.timeAgo,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark
                                                        ? AppColors.darkTextSecondary
                                                        : AppColors.lightTextSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              item.body,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                height: 1.35,
                                                color: isDark
                                                    ? AppColors.darkTextSecondary
                                                    : AppColors.lightTextSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                                  decoration: BoxDecoration(
                                                    color: item.color.withValues(alpha: 0.12),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    item.type.toUpperCase(),
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.w800,
                                                      color: item.color,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'View Details',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: item.color,
                                                        fontWeight: FontWeight.w800,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Icon(Iconsax.arrow_right_3, size: 12, color: item.color),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
