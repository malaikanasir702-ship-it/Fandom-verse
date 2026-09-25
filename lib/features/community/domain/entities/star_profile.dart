import 'package:equatable/equatable.dart';

class StarProfile extends Equatable {
  final String id;
  final String name;
  final String category;
  final String roleTitle;
  final String bio;
  final String imageUrl;
  final String socialHandle;
  final List<String> famousWorks;
  final bool isBookmarked;

  const StarProfile({
    required this.id,
    required this.name,
    required this.category,
    required this.roleTitle,
    required this.bio,
    required this.imageUrl,
    required this.socialHandle,
    this.famousWorks = const [],
    this.isBookmarked = false,
  });

  String get avatarUrl => imageUrl;
  String get role => roleTitle;
  String get knownFor => famousWorks.join(', ');
  int get followersCount => 12500;

  StarProfile copyWith({
    String? id,
    String? name,
    String? category,
    String? roleTitle,
    String? bio,
    String? imageUrl,
    String? socialHandle,
    List<String>? famousWorks,
    bool? isBookmarked,
  }) {
    return StarProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      roleTitle: roleTitle ?? this.roleTitle,
      bio: bio ?? this.bio,
      imageUrl: imageUrl ?? this.imageUrl,
      socialHandle: socialHandle ?? this.socialHandle,
      famousWorks: famousWorks ?? this.famousWorks,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  factory StarProfile.fromDbMap(Map<String, dynamic> map) {
    return StarProfile(
      id: (map['star_id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      category: (map['fandom_category'] ?? 'Anime & Manga').toString(),
      roleTitle: (map['role_title'] ?? '').toString(),
      bio: (map['bio'] ?? '').toString(),
      imageUrl: (map['image_url'] ?? '').toString(),
      socialHandle: (map['social_handle'] ?? '').toString(),
      famousWorks: const [],
      isBookmarked: (map['is_bookmarked'] as num?)?.toInt() == 1,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'star_id': id,
      'name': name,
      'fandom_category': category,
      'role_title': roleTitle,
      'bio': bio,
      'image_url': imageUrl,
      'social_handle': socialHandle,
      'is_bookmarked': isBookmarked ? 1 : 0,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        roleTitle,
        bio,
        imageUrl,
        socialHandle,
        famousWorks,
        isBookmarked,
      ];
}
