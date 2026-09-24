import '../../domain/entities/discussion_thread.dart';
import '../../domain/entities/star_profile.dart';

abstract class CommunityState {
  const CommunityState();
}

class CommunityLoading extends CommunityState {
  const CommunityLoading();
}

class CommunityLoaded extends CommunityState {
  final List<DiscussionThread> threads;
  final List<StarProfile> starProfiles;
  final String activeCategory;

  const CommunityLoaded({
    required this.threads,
    required this.starProfiles,
    this.activeCategory = 'All',
  });

  List<DiscussionThread> get filteredThreads {
    if (activeCategory == 'All') return threads;
    return threads.where((t) => t.category == activeCategory).toList();
  }

  CommunityLoaded copyWith({
    List<DiscussionThread>? threads,
    List<StarProfile>? starProfiles,
    String? activeCategory,
  }) {
    return CommunityLoaded(
      threads: threads ?? this.threads,
      starProfiles: starProfiles ?? this.starProfiles,
      activeCategory: activeCategory ?? this.activeCategory,
    );
  }
}

class CommunityError extends CommunityState {
  final String message;
  const CommunityError(this.message);
}
