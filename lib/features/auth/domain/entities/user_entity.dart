class UserEntity {
  final String id;
  final String name;
  final String email;
  final String role; // 'fan' or 'admin'
  final String? avatarUrl;
  final String? bio;
  final List<String> badges;
  final List<String> selectedFandoms;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'fan',
    this.avatarUrl,
    this.bio,
    this.badges = const [],
    this.selectedFandoms = const [],
  });

  bool get isAdmin => role == 'admin';

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? avatarUrl,
    String? bio,
    List<String>? badges,
    List<String>? selectedFandoms,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      badges: badges ?? this.badges,
      selectedFandoms: selectedFandoms ?? this.selectedFandoms,
    );
  }
}
