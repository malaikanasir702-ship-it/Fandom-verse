import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/repositories/i_community_repository.dart';
import '../../../../core/repositories/community_repository_impl.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/discussion_thread.dart';
import 'community_event.dart';
import 'community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final ICommunityRepository _repository;

  CommunityBloc({ICommunityRepository? repository})
      : _repository = repository ?? CommunityRepositoryImpl(),
        super(const CommunityLoading()) {
    on<LoadDiscussionThreadsEvent>(_onLoadThreads);
    on<LoadStarProfilesEvent>(_onLoadStars);
    on<FilterThreadsByCategoryEvent>(_onFilterCategory);
    on<UpvoteThreadEvent>(_onUpvoteThread);
    on<ToggleStarBookmarkEvent>(_onToggleStarBookmark);
    on<AddReplyToThreadEvent>(_onAddReply);
    on<CreateThreadEvent>(_onCreateThread);
  }

  Future<void> _onLoadThreads(
    LoadDiscussionThreadsEvent event,
    Emitter<CommunityState> emit,
  ) async {
    emit(const CommunityLoading());
    try {
      final threads = await _repository.getThreads();
      final stars = await _repository.getStarProfiles();
      emit(CommunityLoaded(threads: threads, starProfiles: stars));
    } catch (_) {
      emit(const CommunityLoaded(threads: [], starProfiles: []));
    }
  }

  Future<void> _onLoadStars(
    LoadStarProfilesEvent event,
    Emitter<CommunityState> emit,
  ) async {
    if (state is CommunityLoaded) return;
    emit(const CommunityLoading());
    try {
      final threads = await _repository.getThreads();
      final stars = await _repository.getStarProfiles();
      emit(CommunityLoaded(threads: threads, starProfiles: stars));
    } catch (_) {
      emit(const CommunityLoaded(threads: [], starProfiles: []));
    }
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

  Future<void> _onUpvoteThread(
    UpvoteThreadEvent event,
    Emitter<CommunityState> emit,
  ) async {
    if (state is CommunityLoaded) {
      final current = state as CommunityLoaded;
      int targetUpvotes = 0;
      bool targetIsUpvoted = false;

      final updatedThreads = current.threads.map((t) {
        if (t.id == event.threadId) {
          targetIsUpvoted = !t.isUpvoted;
          targetUpvotes = targetIsUpvoted ? t.upvotes + 1 : (t.upvotes > 0 ? t.upvotes - 1 : 0);
          return t.copyWith(
            upvotes: targetUpvotes,
            isUpvoted: targetIsUpvoted,
          );
        }
        return t;
      }).toList();

      emit(current.copyWith(threads: updatedThreads));

      // Persist to SQLite discussions table
      await _repository.upvoteThread(event.threadId, targetUpvotes, targetIsUpvoted);
    }
  }

  Future<void> _onToggleStarBookmark(
    ToggleStarBookmarkEvent event,
    Emitter<CommunityState> emit,
  ) async {
    if (state is CommunityLoaded) {
      final current = state as CommunityLoaded;
      bool targetBookmarkState = true;

      final updatedStars = current.starProfiles.map((s) {
        if (s.id == event.starId) {
          targetBookmarkState = !s.isBookmarked;
          return s.copyWith(isBookmarked: targetBookmarkState);
        }
        return s;
      }).toList();

      emit(current.copyWith(starProfiles: updatedStars));

      // Persist to SQLite star_profiles table
      await _repository.toggleStarBookmark(event.starId, targetBookmarkState);
    }
  }

  Future<void> _onAddReply(
    AddReplyToThreadEvent event,
    Emitter<CommunityState> emit,
  ) async {
    if (state is CommunityLoaded) {
      final current = state as CommunityLoaded;
      final newReply = DiscussionReply(
        id: 'rep-${DateTime.now().millisecondsSinceEpoch}',
        userName: event.userName,
        userAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
        body: event.replyText,
        createdAt: DateTime.now(),
      );

      // Optimistic UI update
      final updatedThreads = current.threads.map((t) {
        if (t.id == event.threadId) {
          return t.copyWith(replies: [...t.replies, newReply]);
        }
        return t;
      }).toList();
      emit(current.copyWith(threads: updatedThreads));

      // Asynchronous SQLite write + community reply notification
      _repository.addReply(event.threadId, newReply).then((_) {
        NotificationService.showCommunityReply(
          userName: event.userName,
          threadTitle: event.threadId,
        );
      }).ignore();
    }
  }

  Future<void> _onCreateThread(
    CreateThreadEvent event,
    Emitter<CommunityState> emit,
  ) async {
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
        isUpvoted: false,
        replies: const [],
        createdAt: DateTime.now(),
      );

      // Optimistic UI update
      emit(current.copyWith(threads: [newThread, ...current.threads]));

      // Asynchronous SQLite write
      _repository.createThread(newThread).ignore();
    }
  }
}
