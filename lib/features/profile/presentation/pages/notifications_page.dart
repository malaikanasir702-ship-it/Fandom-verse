import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Notification items — in production these would come from
  // a notifications table or FCM history. For now seeded locally.
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'Welcome to Fandom Verse!',
      'body': 'Explore fandoms, events, and the merch store. Your journey starts here.',
      'time': 'Just now',
      'icon': Iconsax.star_1,
      'color': AppColors.darkSecondary,
      'isRead': false,
    },
    {
      'id': 2,
      'title': 'Event Reminder',
      'body': 'Anime Expo 2025 opens in 3 days. Check the Events tab for details.',
      'time': '2 hours ago',
      'icon': Iconsax.clock,
      'color': AppColors.comicRed,
      'isRead': false,
    },
    {
      'id': 3,
      'title': 'New Discussion Reply',
      'body': 'Someone replied to your post in the Community tab.',
      'time': '5 hours ago',
      'icon': Iconsax.message,
      'color': AppColors.darkPrimary,
      'isRead': true,
    },
    {
      'id': 4,
      'title': 'Badge Unlocked: Lore Master',
      'body': 'You completed 10 Deep Dive Trivia challenges. Keep going!',
      'time': '1 day ago',
      'icon': Iconsax.award,
      'color': AppColors.comicYellow,
      'isRead': true,
    },
    {
      'id': 5,
      'title': 'Marvel Phase 6 News',
      'body': 'Marvel Studios officially revealed the full Phase 6 Multiverse slate.',
      'time': '2 days ago',
      'icon': Iconsax.document_text,
      'color': AppColors.success,
      'isRead': true,
    },
  ];

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read.')),
    );
  }

  void _markRead(int id) {
    setState(() {
      final item = _notifications.firstWhere((n) => n['id'] == id,
          orElse: () => {});
      if (item.isNotEmpty) item['isRead'] = true;
    });
  }

  void _sendTestNotification() async {
    await NotificationService.showTestNotification(
      title: '🔔 Test Notification',
      body: 'Push notifications are working on your device!',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  int get _unreadCount =>
      _notifications.where((n) => n['isRead'] == false).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const Text('Notifications',
                style: TextStyle(fontWeight: FontWeight.w800)),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.comicRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification),
            tooltip: 'Send Test',
            onPressed: _sendTestNotification,
          ),
          IconButton(
            icon: const Icon(Iconsax.tick_circle),
            tooltip: 'Mark all read',
            onPressed: _markAllRead,
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.notification_bing,
                      size: 64,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                  const SizedBox(height: 14),
                  const Text('No notifications yet',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _notifications[index];
                final isRead = item['isRead'] as bool;
                final color = item['color'] as Color;

                return GestureDetector(
                  onTap: () => _markRead(item['id'] as int),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(14),
                    borderColor:
                        isRead ? null : color.withValues(alpha: 0.4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: color.withValues(alpha: 0.15),
                          child: Icon(item['icon'] as IconData,
                              color: color, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['title'] as String,
                                      style: TextStyle(
                                        fontWeight: isRead
                                            ? FontWeight.w600
                                            : FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    item['time'] as String,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['body'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                              if (!isRead) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Tap to mark read',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: color,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
