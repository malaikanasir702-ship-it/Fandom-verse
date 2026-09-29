import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/database/sqlite_helper.dart';
import '../../../../core/repositories/i_admin_repository.dart';
import '../../../../core/repositories/admin_repository_impl.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/password_hasher.dart';
import '../../../../features/profile/domain/entities/app_notification_entity.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final IAdminRepository _repository;
  final FirebaseAuthService _authService;

  AdminBloc({IAdminRepository? repository, FirebaseAuthService? authService})
      : _repository = repository ?? AdminRepositoryImpl(),
        _authService = authService ?? FirebaseAuthService(),
        super(const AdminInitial()) {
    on<LoadAdminDashboardStatsEvent>(_onLoadDashboard);
    on<CreateOrUpdateArticleEvent>(_onCreateOrUpdateArticle);
    on<DeleteArticleEvent>(_onDeleteArticle);
    on<CreateOrUpdateEventEvent>(_onCreateOrUpdateEvent);
    on<DeleteEventEvent>(_onDeleteEvent);
    on<CreateOrUpdateProductEvent>(_onCreateOrUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<UpdateStockQuickEvent>(_onUpdateStockQuick);
    on<ToggleUserStatusEvent>(_onToggleUserStatus);
    on<CreateUserEvent>(_onCreateUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<BroadcastNotificationEvent>(_onBroadcastNotification);
    on<CreateOrUpdateHeroStoryEvent>(_onCreateOrUpdateHeroStory);
    on<DeleteHeroStoryEvent>(_onDeleteHeroStory);
    on<CreateOrUpdateTriviaEvent>(_onCreateOrUpdateTrivia);
    on<DeleteTriviaEvent>(_onDeleteTrivia);
    on<CreateOrUpdateAdvancedLoreEvent>(_onCreateOrUpdateAdvancedLore);
    on<DeleteAdvancedLoreEvent>(_onDeleteAdvancedLore);
    on<CreateOrUpdateBehindScenesEvent>(_onCreateOrUpdateBehindScenes);
    on<DeleteBehindScenesEvent>(_onDeleteBehindScenes);
    on<CreateOrUpdateInterviewEvent>(_onCreateOrUpdateInterview);
    on<DeleteInterviewEvent>(_onDeleteInterview);
  }

  Future<void> _onLoadDashboard(
    LoadAdminDashboardStatsEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final metrics = await _repository.getDashboardMetrics().catchError((e) {
        return <String, int>{};
      });
      final logs = await _repository.getAuditLogs().catchError((e) {
        return <Map<String, dynamic>>[];
      });
      final articles = await _repository.query(DbConstants.tablePosts).catchError((e) {
        return <Map<String, dynamic>>[];
      });
      final events = await _repository.query(DbConstants.tableEvents).catchError((e) {
        return <Map<String, dynamic>>[];
      });
      final products = await _repository.query(DbConstants.tableMerchandise).catchError((e) {
        return <Map<String, dynamic>>[];
      });
      final users = await _repository.getAllUsers().catchError((e) {
        return <Map<String, dynamic>>[];
      });
      final categories = await _repository.query(DbConstants.tableCategories).catchError((e) {
        return <Map<String, dynamic>>[];
      });
      final heroStories = await _repository
          .query(DbConstants.tableHeroStories, orderBy: 'created_at ASC')
          .catchError((e) => <Map<String, dynamic>>[]);
      final trivia = await _repository
          .query(DbConstants.tableDeepDiveTrivia, orderBy: 'created_at ASC')
          .catchError((e) => <Map<String, dynamic>>[]);
      final advancedLore = await _repository
          .query(DbConstants.tableAdvancedLore, orderBy: 'created_at DESC')
          .catchError((e) => <Map<String, dynamic>>[]);
      final behindScenes = await _repository
          .query(DbConstants.tableBehindScenes, orderBy: 'created_at DESC')
          .catchError((e) => <Map<String, dynamic>>[]);
      final interviews = await _repository
          .query(DbConstants.tableInterviews, orderBy: 'interview_date DESC')
          .catchError((e) => <Map<String, dynamic>>[]);

      emit(AdminStatsLoaded(
        metrics: metrics,
        recentLogs: logs,
        articles: articles,
        events: events,
        products: products,
        users: users,
        categories: categories,
        heroStories: heroStories,
        triviaList: trivia,
        advancedLoreList: advancedLore,
        behindScenesList: behindScenes,
        interviewsList: interviews,
      ));
    } catch (e) {
      emit(AdminError('Failed to load admin dashboard: ${e.toString()}'));
    }
  }

  Future<void> _onCreateOrUpdateArticle(
    CreateOrUpdateArticleEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final post = event.post;
      if (event.isEdit) {
        await _repository.update(
          DbConstants.tablePosts,
          'post_id',
          post['post_id'],
          post,
        );
        await _repository.logAdminAction(
          actionType: 'UPDATE',
          entityType: 'Article',
          description: 'Updated article "${post['title']}"',
        );
      } else {
        await _repository.insert(DbConstants.tablePosts, post);
        await _repository.logAdminAction(
          actionType: 'CREATE',
          entityType: 'Article',
          description: 'Published new article "${post['title']}"',
        );
      }
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to save article: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteArticle(
    DeleteArticleEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.delete(DbConstants.tablePosts, 'post_id', event.postId);
      await _repository.logAdminAction(
        actionType: 'DELETE',
        entityType: 'Article',
        description: 'Deleted article ${event.postId}',
      );
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to delete article: ${e.toString()}'));
    }
  }

  Future<void> _onCreateOrUpdateEvent(
    CreateOrUpdateEventEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final ev = event.event;
      if (event.isEdit) {
        await _repository.update(
          DbConstants.tableEvents,
          'event_id',
          ev['event_id'],
          ev,
        );
        await _repository.logAdminAction(
          actionType: 'UPDATE',
          entityType: 'Event',
          description: 'Updated convention "${ev['title']}"',
        );
      } else {
        await _repository.insert(DbConstants.tableEvents, ev);
        await _repository.logAdminAction(
          actionType: 'CREATE',
          entityType: 'Event',
          description: 'Added new convention "${ev['title']}" in ${ev['city_name']}',
        );
      }
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to save event: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteEvent(
    DeleteEventEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.delete(DbConstants.tableEvents, 'event_id', event.eventId);
      await _repository.logAdminAction(
        actionType: 'DELETE',
        entityType: 'Event',
        description: 'Deleted event ${event.eventId}',
      );
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to delete event: ${e.toString()}'));
    }
  }

  Future<void> _onCreateOrUpdateProduct(
    CreateOrUpdateProductEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final prod = event.product;
      if (event.isEdit) {
        await _repository.update(
          DbConstants.tableMerchandise,
          'product_id',
          prod['product_id'],
          prod,
        );
        await _repository.logAdminAction(
          actionType: 'UPDATE',
          entityType: 'Merchandise',
          description: 'Updated merchandise item "${prod['name']}"',
        );
      } else {
        await _repository.insert(DbConstants.tableMerchandise, prod);
        await _repository.logAdminAction(
          actionType: 'CREATE',
          entityType: 'Merchandise',
          description: 'Added new store product "${prod['name']}" (\$${prod['price']})',
        );
      }
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to save product: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.delete(DbConstants.tableMerchandise, 'product_id', event.productId);
      await _repository.logAdminAction(
        actionType: 'DELETE',
        entityType: 'Merchandise',
        description: 'Deleted merchandise ${event.productId}',
      );
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to delete product: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateStockQuick(
    UpdateStockQuickEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.update(
        DbConstants.tableMerchandise,
        'product_id',
        event.productId,
        {'stock_count': event.newStock},
      );
      await _repository.logAdminAction(
        actionType: 'UPDATE_STOCK',
        entityType: 'Merchandise',
        description: 'Stock updated to ${event.newStock} for product ${event.productId}',
      );
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to update stock: ${e.toString()}'));
    }
  }

  Future<void> _onToggleUserStatus(
    ToggleUserStatusEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.updateUserStatus(event.userId, event.newStatus);
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to update user: ${e.toString()}'));
    }
  }

  Future<void> _onCreateUser(
    CreateUserEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final user = Map<String, dynamic>.from(event.user);
      user['role'] = user['role'] ?? 'fan';
      user['status'] = user['status'] ?? 'active';
      user['created_at'] = DateTime.now().millisecondsSinceEpoch;
      user['badges'] = user['badges'] ?? '[]';
      user['selected_fandoms'] = user['selected_fandoms'] ?? '[]';

      final plainPassword = (event.password != null && event.password!.trim().isNotEmpty)
          ? event.password!.trim()
          : '123456';

      // ── Step 1: Create Firebase Auth account so user can actually log in ──
      String firebaseUid = user['user_id'] as String? ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
      if (FirebaseService.isInitialized) {
        try {
          final result = await _authService.signUp(
            email: (user['email'] as String).trim().toLowerCase(),
            password: plainPassword,
            name: (user['name'] as String? ?? '').trim(),
            role: user['role'] as String,
          );
          // Use the Firebase UID so SQLite/Firestore records are consistent
          firebaseUid = (result['user_id'] ?? result['id'] ?? firebaseUid).toString();
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            // Account already exists in Firebase Auth — still update local record
            emit(AdminError('A Firebase account with this email already exists. '
                'Password was NOT changed — use the edit option to update it.'));
            return;
          }
          rethrow;
        }
      }

      user['user_id'] = firebaseUid;

      // ── Step 2: Store hashed password for offline fallback ──
      final salt = PasswordHasher.generateSalt();
      user['password_salt'] = salt;
      user['password_hash'] = PasswordHasher.hashPassword(plainPassword, salt);

      // ── Step 3: Persist to SQLite (Firestore sync handled inside signUp) ──
      await _repository.insert(DbConstants.tableUsers, user);
      await _repository.logAdminAction(
        actionType: 'CREATE',
        entityType: 'User',
        description: 'Created new user "${user['name']}" (${user['email']})',
      );
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to create user: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final user = Map<String, dynamic>.from(event.user);
      final userId = user['user_id'] as String;

      if (event.newPassword != null && event.newPassword!.trim().isNotEmpty) {
        final newPwd = event.newPassword!.trim();

        // ── Step 1: Update Firebase Auth password ──
        // Admin cannot directly update another user's Firebase Auth password
        // without Admin SDK (server-side). Best client-side approach:
        // send a password reset email, OR use a Cloud Function.
        // Here we send a password reset email so the user can set their new pwd.
        if (FirebaseService.isInitialized) {
          try {
            await _authService.sendPasswordResetEmail(user['email'] as String);
          } catch (_) {
            // Non-fatal — still update the local hash below
          }

          // ── Also attempt direct update if this is the currently signed-in user ──
          try {
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null && currentUser.email?.toLowerCase() == (user['email'] as String).toLowerCase()) {
              await currentUser.updatePassword(newPwd);
            }
          } catch (_) {
            // Not the current user or requires re-auth — skip
          }
        }

        // ── Step 2: Update local SQLite hash for offline fallback ──
        final salt = PasswordHasher.generateSalt();
        user['password_salt'] = salt;
        user['password_hash'] = PasswordHasher.hashPassword(newPwd, salt);
      }

      await _repository.update(
        DbConstants.tableUsers,
        'user_id',
        userId,
        user,
      );
      await _repository.logAdminAction(
        actionType: 'UPDATE',
        entityType: 'User',
        description: 'Updated user "${user['name']}"',
      );
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to update user: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.delete(DbConstants.tableUsers, 'user_id', event.userId);
      await _repository.logAdminAction(
        actionType: 'DELETE',
        entityType: 'User',
        description: 'Deleted user ${event.userId}',
      );
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to delete user: ${e.toString()}'));
    }
  }

  Future<void> _onCreateCategory(
    CreateCategoryEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.insert(DbConstants.tableCategories, event.category);
      await _repository.logAdminAction(
        actionType: 'CREATE',
        entityType: 'Category',
        description: 'Created new fandom category "${event.category['name']}"',
      );
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to create category: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final cat = event.category;
      await _repository.update(
        DbConstants.tableCategories,
        'category_id',
        cat['category_id'],
        cat,
      );
      await _repository.logAdminAction(
        actionType: 'UPDATE',
        entityType: 'Category',
        description: 'Updated fandom category "${cat['name']}"',
      );
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to update category: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.delete(
        DbConstants.tableCategories,
        'category_id',
        event.categoryId,
      );
      await _repository.logAdminAction(
        actionType: 'DELETE',
        entityType: 'Category',
        description: 'Deleted fandom category ${event.categoryId}',
      );
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to delete category: ${e.toString()}'));
    }
  }

  Future<void> _onBroadcastNotification(
    BroadcastNotificationEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      // ── Step 1: Persist broadcast to Firestore 'broadcasts' collection ──
      // Each user's NotificationsPage FCM listener will pick this up when online.
      // The NotificationsPage also listens to Firestore for new broadcast docs.
      final broadcastId = 'broadcast_${DateTime.now().millisecondsSinceEpoch}';
      final broadcastData = {
        'broadcast_id': broadcastId,
        'title': event.title,
        'body': event.message,
        'type': 'general',
        'audience': event.audience,
        'icon_name': 'bell',
        'color_hex': '#E53935',
        'target_route': null,
        'created_at': FieldValue.serverTimestamp(),
        'created_at_ms': DateTime.now().millisecondsSinceEpoch,
        'is_read': false,
      };

      if (FirebaseService.isInitialized) {
        await FirebaseFirestore.instance
            .collection('broadcasts')
            .doc(broadcastId)
            .set(broadcastData)
            .timeout(const Duration(seconds: 8));
      }

      // ── Step 2: Save to local SQLite so admin device also shows it ──
      final localNotif = AppNotificationEntity(
        id: broadcastId,
        title: event.title,
        body: event.message,
        type: 'general',
        iconName: 'bell',
        colorHex: '#E53935',
        isRead: false,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await SqliteHelper.instance.saveNotification(localNotif);
      await NotificationService.refreshUnreadCount();

      // ── Step 3: Show local push on admin device too ──
      await NotificationService.showTestNotification(
        title: event.title,
        body: event.message,
        iconName: 'bell',
        colorHex: '#E53935',
      );

      await _repository.logAdminAction(
        actionType: 'BROADCAST',
        entityType: 'Push Alert',
        description: 'Dispatched alert "${event.title}" to ${event.audience}',
      );
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Broadcast alert failed: ${e.toString()}'));
    }
  }

  Future<void> _onCreateOrUpdateHeroStory(
    CreateOrUpdateHeroStoryEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final story = event.story;
      if (event.isEdit) {
        await _repository.update(
          DbConstants.tableHeroStories,
          'story_id',
          story['story_id'],
          story,
        );
        await _repository.logAdminAction(
          actionType: 'UPDATE',
          entityType: 'HeroStory',
          description: 'Updated hero story for "${story['hero_name']}"',
        );
      } else {
        await _repository.insert(DbConstants.tableHeroStories, story);
        await _repository.logAdminAction(
          actionType: 'CREATE',
          entityType: 'HeroStory',
          description: 'Published new hero story for "${story['hero_name']}"',
        );
      }
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to save hero story: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteHeroStory(
    DeleteHeroStoryEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.delete(DbConstants.tableHeroStories, 'story_id', event.storyId);
      await _repository.logAdminAction(
        actionType: 'DELETE',
        entityType: 'HeroStory',
        description: 'Deleted hero story ${event.storyId}',
      );
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to delete hero story: ${e.toString()}'));
    }
  }

  // ── DEEP DIVE CRUD HANDLERS ──

  Future<void> _onCreateOrUpdateTrivia(
    CreateOrUpdateTriviaEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final trivia = event.trivia;
      if (event.isEdit) {
        await _repository.update(
          DbConstants.tableDeepDiveTrivia,
          'trivia_id',
          trivia['trivia_id'],
          trivia,
        );
        await _repository.logAdminAction(
          actionType: 'UPDATE',
          entityType: 'Trivia',
          description: 'Updated trivia question "${trivia['question']}"',
        );
      } else {
        await _repository.insert(DbConstants.tableDeepDiveTrivia, trivia);
        await _repository.logAdminAction(
          actionType: 'CREATE',
          entityType: 'Trivia',
          description: 'Created trivia question "${trivia['question']}"',
        );
      }
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to save trivia question: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTrivia(
    DeleteTriviaEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.delete(DbConstants.tableDeepDiveTrivia, 'trivia_id', event.triviaId);
      await _repository.logAdminAction(
        actionType: 'DELETE',
        entityType: 'Trivia',
        description: 'Deleted trivia question ${event.triviaId}',
      );
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to delete trivia question: ${e.toString()}'));
    }
  }

  Future<void> _onCreateOrUpdateAdvancedLore(
    CreateOrUpdateAdvancedLoreEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final lore = event.lore;
      if (event.isEdit) {
        await _repository.update(
          DbConstants.tableAdvancedLore,
          'lore_id',
          lore['lore_id'],
          lore,
        );
        await _repository.logAdminAction(
          actionType: 'UPDATE',
          entityType: 'AdvancedLore',
          description: 'Updated advanced lore "${lore['title']}"',
        );
      } else {
        await _repository.insert(DbConstants.tableAdvancedLore, lore);
        await _repository.logAdminAction(
          actionType: 'CREATE',
          entityType: 'AdvancedLore',
          description: 'Created advanced lore "${lore['title']}"',
        );
      }
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to save advanced lore: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteAdvancedLore(
    DeleteAdvancedLoreEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.delete(DbConstants.tableAdvancedLore, 'lore_id', event.loreId);
      await _repository.logAdminAction(
        actionType: 'DELETE',
        entityType: 'AdvancedLore',
        description: 'Deleted advanced lore ${event.loreId}',
      );
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to delete advanced lore: ${e.toString()}'));
    }
  }

  Future<void> _onCreateOrUpdateBehindScenes(
    CreateOrUpdateBehindScenesEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final scene = event.scene;
      if (event.isEdit) {
        await _repository.update(
          DbConstants.tableBehindScenes,
          'scene_id',
          scene['scene_id'],
          scene,
        );
        await _repository.logAdminAction(
          actionType: 'UPDATE',
          entityType: 'BehindScenes',
          description: 'Updated behind the scenes "${scene['title']}"',
        );
      } else {
        await _repository.insert(DbConstants.tableBehindScenes, scene);
        await _repository.logAdminAction(
          actionType: 'CREATE',
          entityType: 'BehindScenes',
          description: 'Created behind the scenes "${scene['title']}"',
        );
      }
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to save behind the scenes: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteBehindScenes(
    DeleteBehindScenesEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.delete(DbConstants.tableBehindScenes, 'scene_id', event.sceneId);
      await _repository.logAdminAction(
        actionType: 'DELETE',
        entityType: 'BehindScenes',
        description: 'Deleted behind the scenes ${event.sceneId}',
      );
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to delete behind the scenes: ${e.toString()}'));
    }
  }

  Future<void> _onCreateOrUpdateInterview(
    CreateOrUpdateInterviewEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final interview = event.interview;
      if (event.isEdit) {
        await _repository.update(
          DbConstants.tableInterviews,
          'interview_id',
          interview['interview_id'],
          interview,
        );
        await _repository.logAdminAction(
          actionType: 'UPDATE',
          entityType: 'Interview',
          description: 'Updated interview with "${interview['interviewee_name']}"',
        );
      } else {
        await _repository.insert(DbConstants.tableInterviews, interview);
        await _repository.logAdminAction(
          actionType: 'CREATE',
          entityType: 'Interview',
          description: 'Created interview with "${interview['interviewee_name']}"',
        );
      }
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to save interview: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteInterview(
    DeleteInterviewEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.delete(DbConstants.tableInterviews, 'interview_id', event.interviewId);
      await _repository.logAdminAction(
        actionType: 'DELETE',
        entityType: 'Interview',
        description: 'Deleted interview ${event.interviewId}',
      );
      add(const LoadAdminDashboardStatsEvent());
    } catch (e) {
      emit(AdminError('Failed to delete interview: ${e.toString()}'));
    }
  }
}
