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
