import 'dart:convert';
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role; // 'fan' or 'admin'
  final String status; // 'active', 'suspended', 'banned'
  final String? avatarUrl;
  final String? bio;
  final String? city;
  final String? fanbase;
  final List<String> badges;
  final List<String> selectedFandoms;
  final List<String> likedFandoms;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'fan',
    this.status = 'active',
    this.avatarUrl,
    this.bio,
    this.city,
    this.fanbase,
    this.badges = const [],
    this.selectedFandoms = const [],
    this.likedFandoms = const [],
  });

  bool get isAdmin => role == 'admin';
  bool get isActive => status == 'active';

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    List<String> parseList(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String && value.isNotEmpty) {
        // Try JSON array first: ["Anime & Manga", "Gaming & Esports"]
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) return decoded.map((e) => e.toString()).toList();
        } catch (_) {}
        // Try Dart List.toString() format: [Anime & Manga, Gaming & Esports]
        if (value.startsWith('[') && value.endsWith(']')) {
          final inner = value.substring(1, value.length - 1).trim();
          if (inner.isEmpty) return [];
          return inner.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        }
        // Single value string
        return [value];
      }
      return [];
    }

    return UserEntity(
      id: (map['user_id'] ?? map['id'] ?? '').toString(),
      name: (map['name'] ?? map['displayName'] ?? 'Fan Explorer').toString(),
      email: (map['email'] ?? '').toString(),
      role: (map['role'] ?? 'fan').toString(),
      status: (map['status'] ?? 'active').toString(),
      avatarUrl: (map['avatar_url'] ?? map['avatarUrl'])?.toString(),
      bio: map['bio']?.toString() ?? '',
      city: map['city']?.toString(),
      fanbase: map['fanbase']?.toString(),
      badges: parseList(map['badges']),
      selectedFandoms: parseList(map['selected_fandoms'] ?? map['selectedFandoms']),
      likedFandoms: parseList(map['liked_fandoms'] ?? map['likedFandoms']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': id,
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'avatar_url': avatarUrl,
      'bio': bio ?? '',
      'city': city,
      'fanbase': fanbase,
      'badges': jsonEncode(badges),
      'selected_fandoms': jsonEncode(selectedFandoms),
      'liked_fandoms': jsonEncode(likedFandoms),
    };
  }

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? status,
    String? avatarUrl,
    bool clearAvatar = false,
    String? bio,
    String? city,
    String? fanbase,
    List<String>? badges,
    List<String>? selectedFandoms,
    List<String>? likedFandoms,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      avatarUrl: clearAvatar ? null : (avatarUrl ?? this.avatarUrl),
      bio: bio ?? this.bio,
      city: city ?? this.city,
      fanbase: fanbase ?? this.fanbase,
      badges: badges ?? this.badges,
      selectedFandoms: selectedFandoms ?? this.selectedFandoms,
      likedFandoms: likedFandoms ?? this.likedFandoms,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        role,
        status,
        avatarUrl,
        bio,
        city,
        fanbase,
        badges,
        selectedFandoms,
        likedFandoms,
      ];
}

