import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/repositories/i_admin_repository.dart';
import '../../../../core/repositories/admin_repository_impl.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final IAdminRepository _repository;

  AdminBloc({IAdminRepository? repository})
      : _repository = repository ?? AdminRepositoryImpl(),
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
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<BroadcastNotificationEvent>(_onBroadcastNotification);
    on<CreateOrUpdateHeroStoryEvent>(_onCreateOrUpdateHeroStory);
    on<DeleteHeroStoryEvent>(_onDeleteHeroStory);
  }

  Future<void> _onLoadDashboard(
    LoadAdminDashboardStatsEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final metrics = await _repository.getDashboardMetrics();
      final logs = await _repository.getAuditLogs();
      final articles = await _repository.query(DbConstants.tablePosts);
      final events = await _repository.query(DbConstants.tableEvents);
      final products = await _repository.query(DbConstants.tableMerchandise);
      final users = await _repository.query(DbConstants.tableUsers);
      final categories = await _repository.query(DbConstants.tableCategories);
      final heroStories = await _repository.query(DbConstants.tableHeroStories, orderBy: 'created_at ASC');

      emit(AdminStatsLoaded(
        metrics: metrics,
        recentLogs: logs,
        articles: articles,
        events: events,
        products: products,
        users: users,
        categories: categories,
        heroStories: heroStories,
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
}
