class StarProfile {
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
}
