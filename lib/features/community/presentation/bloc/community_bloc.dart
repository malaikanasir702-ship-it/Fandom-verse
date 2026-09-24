import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/community_mock_data.dart';
import '../../domain/entities/discussion_thread.dart';
import 'community_event.dart';
import 'community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  CommunityBloc() : super(const CommunityLoading()) {
    on<LoadDiscussionThreadsEvent>(_onLoadThreads);
    on<LoadStarProfilesEvent>(_onLoadStars);
    on<FilterThreadsByCategoryEvent>(_onFilterCategory);
    on<UpvoteThreadEvent>(_onUpvoteThread);
    on<ToggleStarBookmarkEvent>(_onToggleStarBookmark);
    on<AddReplyToThreadEvent>(_onAddReply);
    on<CreateThreadEvent>(_onCreateThread);
  }

  void _onLoadThreads(
    LoadDiscussionThreadsEvent event,
    Emitter<CommunityState> emit,
  ) {
    emit(CommunityLoaded(
      threads: CommunityMockData.threads,
      starProfiles: CommunityMockData.starProfiles,
    ));
  }

  void _onLoadStars(
    LoadStarProfilesEvent event,
    Emitter<CommunityState> emit,
  ) {
    if (state is CommunityLoaded) return;
    emit(CommunityLoaded(
      threads: CommunityMockData.threads,
      starProfiles: CommunityMockData.starProfiles,
    ));
  }

  void _onFilterCategory(
    FilterThreadsByCategoryEvent event,
    Emitter<CommunityState> emit,
  ) {
    if (state is CommunityLoaded) {
      final current = state as CommunityLoaded;
      emit(current.copyWith(activeCategory: event.category));
    }
  }

  void _onUpvoteThread(
    UpvoteThreadEvent event,
    Emitter<CommunityState> emit,
  ) {
    if (state is CommunityLoaded) {
      final current = state as CommunityLoaded;
      final updatedThreads = current.threads.map((t) {
        if (t.id == event.threadId) {
          return t.copyWith(
            upvotes: t.isUpvoted ? t.upvotes - 1 : t.upvotes + 1,
            isUpvoted: !t.isUpvoted,
          );
        }
        return t;
      }).toList();
      emit(current.copyWith(threads: updatedThreads));
    }
  }

  void _onToggleStarBookmark(
    ToggleStarBookmarkEvent event,
    Emitter<CommunityState> emit,
  ) {
    if (state is CommunityLoaded) {
      final current = state as CommunityLoaded;
      final updatedStars = current.starProfiles.map((s) {
        if (s.id == event.starId) {
          return s.copyWith(isBookmarked: !s.isBookmarked);
        }
        return s;
      }).toList();
      emit(current.copyWith(starProfiles: updatedStars));
    }
  }

  void _onAddReply(
    AddReplyToThreadEvent event,
    Emitter<CommunityState> emit,
  ) {
    if (state is CommunityLoaded) {
      final current = state as CommunityLoaded;
      final newReply = DiscussionReply(
        id: 'rep-${DateTime.now().millisecondsSinceEpoch}',
        userName: event.userName,
        userAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
        body: event.replyText,
        createdAt: DateTime.now(),
      );
      final updatedThreads = current.threads.map((t) {
        if (t.id == event.threadId) {
          return t.copyWith(replies: [...t.replies, newReply]);
        }
        return t;
      }).toList();
      emit(current.copyWith(threads: updatedThreads));
    }
  }

  void _onCreateThread(
    CreateThreadEvent event,
    Emitter<CommunityState> emit,
  ) {
    if (state is CommunityLoaded) {
      final current = state as CommunityLoaded;
      final newThread = DiscussionThread(
        id: 'th-${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current-user',
        userName: event.userName,
        userBadge: 'Community Member',
        category: event.category,
        title: event.title,
        body: event.body,
        upvotes: 0,
        createdAt: DateTime.now(),
      );
      emit(current.copyWith(threads: [newThread, ...current.threads]));
    }
  }
}
