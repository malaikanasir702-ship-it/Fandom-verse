import 'package:equatable/equatable.dart';
import '../../../store/domain/entities/product_entity.dart';

class CartItemEntity extends Equatable {
  final String cartId;
  final String productId;
  final int quantity;
  final String selectedVariant;
  final ProductEntity product;

  const CartItemEntity({
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.selectedVariant,
    required this.product,
  });

  double get totalPrice => product.price * quantity;

  CartItemEntity copyWith({
    String? cartId,
    String? productId,
    int? quantity,
    String? selectedVariant,
    ProductEntity? product,
  }) {
    return CartItemEntity(
      cartId: cartId ?? this.cartId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      product: product ?? this.product,
    );
  }

  factory CartItemEntity.fromMap(Map<String, dynamic> map) {
    return CartItemEntity(
      cartId: map['cart_id'] ?? '',
      productId: map['product_id'] ?? '',
      quantity: map['quantity'] as int? ?? 1,
      selectedVariant: map['selected_variant'] ?? 'Standard',
      product: ProductEntity.fromMap(map['product'] as Map<String, dynamic>? ?? {}),
    );
  }

  @override
  List<Object?> get props => [cartId, productId, quantity, selectedVariant, product];
}
