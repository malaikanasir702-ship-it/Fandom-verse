import 'dart:convert';

class UserEntity {
  final String id;
  final String name;
  final String email;
  final String role; // 'fan' or 'admin'
  final String status; // 'active', 'suspended', 'banned'
  final String? avatarUrl;
  final String? bio;
  final List<String> badges;
  final List<String> selectedFandoms;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'fan',
    this.status = 'active',
    this.avatarUrl,
    this.bio,
    this.badges = const [],
    this.selectedFandoms = const [],
  });

  bool get isAdmin => role == 'admin';
  bool get isActive => status == 'active';

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    List<String> parseList(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String && value.isNotEmpty) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) return decoded.map((e) => e.toString()).toList();
        } catch (_) {
          return [value];
        }
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
      bio: map['bio']?.toString(),
      badges: parseList(map['badges']),
      selectedFandoms: parseList(map['selected_fandoms'] ?? map['selectedFandoms']),
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
      'bio': bio,
      'badges': jsonEncode(badges),
      'selected_fandoms': jsonEncode(selectedFandoms),
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
    List<String>? badges,
    List<String>? selectedFandoms,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      avatarUrl: clearAvatar ? null : (avatarUrl ?? this.avatarUrl),
      bio: bio ?? this.bio,
      badges: badges ?? this.badges,
      selectedFandoms: selectedFandoms ?? this.selectedFandoms,
    );
  }
}

