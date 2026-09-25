import 'package:equatable/equatable.dart';
import '../../../store/domain/entities/product_entity.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCartEvent extends CartEvent {
  const LoadCartEvent();
}

class AddToCartEvent extends CartEvent {
  final ProductEntity product;
  final int quantity;
  final String variant;

  const AddToCartEvent({
    required this.product,
    this.quantity = 1,
    this.variant = 'Standard',
  });

  @override
  List<Object?> get props => [product, quantity, variant];
}

class UpdateQuantityEvent extends CartEvent {
  final String cartId;
  final int delta; // +1 or -1 or absolute

  const UpdateQuantityEvent({
    required this.cartId,
    required this.delta,
  });

  @override
  List<Object?> get props => [cartId, delta];
}

class RemoveCartItemEvent extends CartEvent {
  final String cartId;

  const RemoveCartItemEvent(this.cartId);

  @override
  List<Object?> get props => [cartId];
}

class ApplyCouponEvent extends CartEvent {
  final String couponCode;

  const ApplyCouponEvent(this.couponCode);

  @override
  List<Object?> get props => [couponCode];
}

class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}

class ExecuteCheckoutEvent extends CartEvent {
  final String userId;
  final String shippingAddress;
  final String paymentMethod;

  const ExecuteCheckoutEvent({
    required this.userId,
    required this.shippingAddress,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [userId, shippingAddress, paymentMethod];
}

class LoadWishlistEvent extends CartEvent {
  final String userId;

  const LoadWishlistEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ToggleWishlistEvent extends CartEvent {
  final String userId;
  final String productId;

  const ToggleWishlistEvent({
    required this.userId,
    required this.productId,
  });

  @override
  List<Object?> get props => [userId, productId];
}
