import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdminDashboardStatsEvent extends AdminEvent {
  const LoadAdminDashboardStatsEvent();
}

class CreateOrUpdateArticleEvent extends AdminEvent {
  final Map<String, dynamic> post;
  final bool isEdit;

  const CreateOrUpdateArticleEvent(this.post, {this.isEdit = false});

  @override
  List<Object?> get props => [post, isEdit];
}

class DeleteArticleEvent extends AdminEvent {
  final String postId;

  const DeleteArticleEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}

class CreateOrUpdateEventEvent extends AdminEvent {
  final Map<String, dynamic> event;
  final bool isEdit;

  const CreateOrUpdateEventEvent(this.event, {this.isEdit = false});

  @override
  List<Object?> get props => [event, isEdit];
}

class DeleteEventEvent extends AdminEvent {
  final String eventId;

  const DeleteEventEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class CreateOrUpdateProductEvent extends AdminEvent {
  final Map<String, dynamic> product;
  final bool isEdit;

  const CreateOrUpdateProductEvent(this.product, {this.isEdit = false});

  @override
  List<Object?> get props => [product, isEdit];
}

class DeleteProductEvent extends AdminEvent {
  final String productId;

  const DeleteProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class UpdateStockQuickEvent extends AdminEvent {
  final String productId;
  final int newStock;

  const UpdateStockQuickEvent(this.productId, this.newStock);

  @override
  List<Object?> get props => [productId, newStock];
}

class ToggleUserStatusEvent extends AdminEvent {
  final String userId;
  final String newStatus;

  const ToggleUserStatusEvent(this.userId, this.newStatus);

  @override
  List<Object?> get props => [userId, newStatus];
}

class CreateUserEvent extends AdminEvent {
  final Map<String, dynamic> user;
  final String? password;

  const CreateUserEvent(this.user, {this.password});

  @override
  List<Object?> get props => [user, password];
}

class UpdateUserEvent extends AdminEvent {
  final Map<String, dynamic> user;
  final String? newPassword;

  const UpdateUserEvent(this.user, {this.newPassword});

  @override
  List<Object?> get props => [user, newPassword];
}

class DeleteUserEvent extends AdminEvent {
  final String userId;

  const DeleteUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}


class CreateCategoryEvent extends AdminEvent {
  final Map<String, dynamic> category;

  const CreateCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateCategoryEvent extends AdminEvent {
  final Map<String, dynamic> category;

  const UpdateCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteCategoryEvent extends AdminEvent {
  final String categoryId;

  const DeleteCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class BroadcastNotificationEvent extends AdminEvent {
  final String title;
  final String message;
  final String audience;

  const BroadcastNotificationEvent({
    required this.title,
    required this.message,
    required this.audience,
  });

  @override
  List<Object?> get props => [title, message, audience];
}

class CreateOrUpdateHeroStoryEvent extends AdminEvent {
  final Map<String, dynamic> story;
  final bool isEdit;

  const CreateOrUpdateHeroStoryEvent(this.story, {this.isEdit = false});

  @override
  List<Object?> get props => [story, isEdit];
}

class DeleteHeroStoryEvent extends AdminEvent {
  final String storyId;

  const DeleteHeroStoryEvent(this.storyId);

  @override
  List<Object?> get props => [storyId];
}

// ── DEEP DIVE CRUD EVENTS ──

class CreateOrUpdateTriviaEvent extends AdminEvent {
  final Map<String, dynamic> trivia;
  final bool isEdit;

  const CreateOrUpdateTriviaEvent(this.trivia, {this.isEdit = false});

  @override
  List<Object?> get props => [trivia, isEdit];
}

class DeleteTriviaEvent extends AdminEvent {
  final String triviaId;

  const DeleteTriviaEvent(this.triviaId);

  @override
  List<Object?> get props => [triviaId];
}

class CreateOrUpdateAdvancedLoreEvent extends AdminEvent {
  final Map<String, dynamic> lore;
  final bool isEdit;

  const CreateOrUpdateAdvancedLoreEvent(this.lore, {this.isEdit = false});

  @override
  List<Object?> get props => [lore, isEdit];
}

class DeleteAdvancedLoreEvent extends AdminEvent {
  final String loreId;

  const DeleteAdvancedLoreEvent(this.loreId);

  @override
  List<Object?> get props => [loreId];
}

class CreateOrUpdateBehindScenesEvent extends AdminEvent {
  final Map<String, dynamic> scene;
  final bool isEdit;

  const CreateOrUpdateBehindScenesEvent(this.scene, {this.isEdit = false});

  @override
  List<Object?> get props => [scene, isEdit];
}

class DeleteBehindScenesEvent extends AdminEvent {
  final String sceneId;

  const DeleteBehindScenesEvent(this.sceneId);

  @override
  List<Object?> get props => [sceneId];
}

class CreateOrUpdateInterviewEvent extends AdminEvent {
  final Map<String, dynamic> interview;
  final bool isEdit;

  const CreateOrUpdateInterviewEvent(this.interview, {this.isEdit = false});

  @override
  List<Object?> get props => [interview, isEdit];
}

class DeleteInterviewEvent extends AdminEvent {
  final String interviewId;

  const DeleteInterviewEvent(this.interviewId);

  @override
  List<Object?> get props => [interviewId];
}
