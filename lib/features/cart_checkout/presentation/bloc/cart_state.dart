import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/order_invoice_entity.dart';
import '../../../store/domain/entities/product_entity.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  final List<CartItemEntity> items;
  final double subtotal;
  final double shippingFee;
  final double discountAmount;
  final double taxAmount;
  final double total;
  final String appliedCoupon;
  final List<ProductEntity> wishlist;
  final String? message;

  const CartLoaded({
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.discountAmount,
    required this.taxAmount,
    required this.total,
    this.appliedCoupon = '',
    this.wishlist = const [],
    this.message,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [
        items,
        subtotal,
        shippingFee,
        discountAmount,
        taxAmount,
        total,
        appliedCoupon,
        wishlist,
        message,
      ];
}

class CheckoutSuccess extends CartState {
  final OrderInvoiceEntity invoice;

  const CheckoutSuccess(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}
