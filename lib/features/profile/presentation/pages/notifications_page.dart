import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static final List<Map<String, dynamic>> _mockNotifications = [
    {
      'title': 'Event Starting Soon!',
      'body': 'Anime Expo 2025 is scheduled to open in 3 days. Check your schedule and venue badges.',
      'time': '2 hours ago',
      'icon': Iconsax.clock,
      'color': AppColors.comicRed,
      'isRead': false,
    },
    {
      'title': 'New Discussion Reply',
      'body': 'Kenji_Art replied to your post "House of the Dragon: Prophecy Analysis".',
      'time': '5 hours ago',
      'icon': Iconsax.message,
      'color': AppColors.darkPrimary,
      'isRead': false,
    },
    {
      'title': 'Badge Unlocked: Lore Master',
      'body': 'You completed 10 Deep Dive Trivia challenges with 100% accuracy!',
      'time': '1 day ago',
      'icon': Iconsax.award,
      'color': AppColors.comicYellow,
      'isRead': true,
    },
    {
      'title': 'Breaking News Alert',
      'body': 'Marvel Studios officially revealed the full Phase 6 Multiverse slate.',
      'time': '2 days ago',
      'icon': Iconsax.document_text,
      'color': AppColors.success,
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.tick_circle),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read.')),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _mockNotifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _mockNotifications[index];
          final isRead = item['isRead'] as bool;
          final color = item['color'] as Color;

          return GlassContainer(
            padding: const EdgeInsets.all(14),
            borderColor: isRead ? null : color.withValues(alpha: 0.4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(item['icon'] as IconData, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['title'] as String,
                              style: TextStyle(
                                fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            item['time'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
                              'Unread',
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
          );
        },
      ),
    );
  }
}
