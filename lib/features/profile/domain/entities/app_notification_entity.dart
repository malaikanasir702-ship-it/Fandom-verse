import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';

class AppNotificationEntity {
  final String id;
  final String title;
  final String body;
  final String type; // 'ticket', 'event', 'community', 'badge', 'hero', 'store', 'news', 'general'
  final String? targetRoute;
  final String? targetId;
  final String iconName;
  final String colorHex;
  final bool isRead;
  final int createdAt;

  const AppNotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.targetRoute,
    this.targetId,
    this.iconName = 'notification',
    this.colorHex = '#E53935',
    this.isRead = false,
    required this.createdAt,
  });

  AppNotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    String? targetRoute,
    String? targetId,
    String? iconName,
    String? colorHex,
    bool? isRead,
    int? createdAt,
  }) {
    return AppNotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      targetRoute: targetRoute ?? this.targetRoute,
      targetId: targetId ?? this.targetId,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notification_id': id,
      'title': title,
      'body': body,
      'type': type,
      'target_route': targetRoute,
      'target_id': targetId,
      'icon_name': iconName,
      'color_hex': colorHex,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory AppNotificationEntity.fromMap(Map<String, dynamic> map) {
    return AppNotificationEntity(
      id: (map['notification_id'] ?? map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      body: (map['body'] ?? '').toString(),
      type: (map['type'] ?? 'general').toString(),
      targetRoute: map['target_route'] as String?,
      targetId: map['target_id'] as String?,
      iconName: (map['icon_name'] ?? 'notification').toString(),
      colorHex: (map['color_hex'] ?? '#E53935').toString(),
      isRead: (map['is_read'] is int && map['is_read'] == 1) || map['is_read'] == true,
      createdAt: map['created_at'] is int
          ? map['created_at'] as int
          : (int.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  Color get color {
    try {
      final hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (_) {}
    return AppColors.comicRed;
  }

  IconData get icon {
    switch (iconName.toLowerCase()) {
      case 'ticket':
        return Iconsax.ticket;
      case 'event':
      case 'calendar':
      case 'clock':
        return Iconsax.calendar_1;
      case 'community':
      case 'message':
      case 'chat':
        return Iconsax.messages_1;
      case 'badge':
      case 'award':
      case 'trophy':
        return Iconsax.award;
      case 'hero':
      case 'star':
        return Iconsax.star_1;
      case 'store':
      case 'shop':
      case 'shopping_bag':
        return Iconsax.shopping_bag;
      case 'news':
      case 'document':
        return Iconsax.document_text;
      case 'bell':
      case 'notification':
      default:
        return Iconsax.notification_bing;
    }
  }

  String get timeAgo {
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - createdAt;
    if (diff < 60 * 1000) return 'Just now';
    if (diff < 60 * 60 * 1000) {
      final minutes = (diff / (60 * 1000)).floor();
      return '$minutes ${minutes == 1 ? 'min' : 'mins'} ago';
    }
    if (diff < 24 * 60 * 60 * 1000) {
      final hours = (diff / (60 * 60 * 1000)).floor();
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }
    final days = (diff / (24 * 60 * 60 * 1000)).floor();
    return '$days ${days == 1 ? 'day' : 'days'} ago';
  }
}
