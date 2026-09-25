import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/repositories/i_cart_repository.dart';
import '../../../../core/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/order_invoice_entity.dart';
import '../../../store/domain/entities/product_entity.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final ICartRepository _repository;
  String _activeCoupon = '';
  double _couponDiscountRate = 0.0;
  List<ProductEntity> _cachedWishlist = [];

  CartBloc({ICartRepository? repository})
      : _repository = repository ?? CartRepositoryImpl(),
        super(const CartInitial()) {
    on<LoadCartEvent>(_onLoadCart);
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<RemoveCartItemEvent>(_onRemoveCartItem);
    on<ApplyCouponEvent>(_onApplyCoupon);
    on<ClearCartEvent>(_onClearCart);
    on<ExecuteCheckoutEvent>(_onExecuteCheckout);
    on<LoadWishlistEvent>(_onLoadWishlist);
    on<ToggleWishlistEvent>(_onToggleWishlist);
  }

  /// Shared private calculation for consistent shipping fee (Bug 10.1)
  double _calculateShippingFee(double subtotal) {
    if (subtotal == 0.0 || subtotal > 50.0) {
      return 0.0;
    }
    return 5.00;
  }

  Future<void> _onLoadCart(
    LoadCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      final rawItems = await _repository.getCartItems();
      final items = rawItems.map((e) => CartItemEntity.fromMap(e)).toList();

      final subtotal = items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
      final shippingFee = _calculateShippingFee(subtotal);
      final discountAmount = subtotal * _couponDiscountRate;
      final taxAmount = (subtotal - discountAmount) * 0.08; // 8% sales tax
      final total = (subtotal - discountAmount + taxAmount + shippingFee).clamp(0.0, double.infinity);

      emit(CartLoaded(
        items: items,
        subtotal: subtotal,
        shippingFee: shippingFee,
        discountAmount: discountAmount,
        taxAmount: taxAmount,
        total: total,
        appliedCoupon: _activeCoupon,
        wishlist: _cachedWishlist,
      ));
    } catch (e) {
      emit(CartError('Failed to load cart: ${e.toString()}'));
    }
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _repository.addToCart(event.product.id, event.quantity, event.variant);
      add(const LoadCartEvent());
    } catch (e) {
      emit(CartError('Could not add to cart: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateQuantity(
    UpdateQuantityEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      if (state is CartLoaded) {
        final current = (state as CartLoaded).items.firstWhere(
          (i) => i.cartId == event.cartId,
          orElse: () => throw Exception('Item not found'),
        );
        final newQty = current.quantity + event.delta;
        await _repository.updateCartItemQuantity(event.cartId, newQty);
        add(const LoadCartEvent());
      }
    } catch (e) {
      emit(CartError('Could not update quantity: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveCartItem(
    RemoveCartItemEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _repository.removeCartItem(event.cartId);
      add(const LoadCartEvent());
    } catch (e) {
      emit(CartError('Could not remove item: ${e.toString()}'));
    }
  }

  Future<void> _onApplyCoupon(
    ApplyCouponEvent event,
    Emitter<CartState> emit,
  ) async {
    final code = event.couponCode.trim().toUpperCase();
    if (DbConstants.validCoupons.containsKey(code)) {
      _activeCoupon = code;
      _couponDiscountRate = DbConstants.validCoupons[code]!;
      add(const LoadCartEvent());
    } else {
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        emit(CartLoaded(
          items: currentState.items,
          subtotal: currentState.subtotal,
          shippingFee: currentState.shippingFee,
          discountAmount: currentState.discountAmount,
          taxAmount: currentState.taxAmount,
          total: currentState.total,
          appliedCoupon: currentState.appliedCoupon,
          wishlist: currentState.wishlist,
          message: 'Invalid Coupon Code "$code". Try FANDOM10 or CON2025',
        ));
      }
    }
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _repository.clearCart();
      _activeCoupon = '';
      _couponDiscountRate = 0.0;
      add(const LoadCartEvent());
    } catch (e) {
      emit(CartError('Failed to clear cart: ${e.toString()}'));
    }
  }

  Future<void> _onExecuteCheckout(
    ExecuteCheckoutEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    try {
      final rawItems = await _repository.getCartItems();
      final items = rawItems.map((e) => CartItemEntity.fromMap(e)).toList();

      if (items.isEmpty) {
        emit(const CartError('Your cart is empty. Add products first.'));
        return;
      }

      final subtotal = items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
      final shippingFee = _calculateShippingFee(subtotal);
      final discountAmount = subtotal * _couponDiscountRate;
      final taxAmount = (subtotal - discountAmount) * 0.08;
      final total = subtotal - discountAmount + taxAmount + shippingFee;

      final orderId = 'FV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final invoice = OrderInvoiceEntity(
        orderId: orderId,
        userId: event.userId,
        orderDate: DateTime.now(),
        subtotal: subtotal,
        shippingFee: shippingFee,
        discountAmount: discountAmount,
        taxAmount: taxAmount,
        totalAmount: total,
        appliedCoupon: _activeCoupon,
        shippingAddress: event.shippingAddress,
        paymentMethod: event.paymentMethod,
        items: items
            .map((i) => {
                  'name': i.product.name,
                  'price': i.product.price,
                  'quantity': i.quantity,
                  'variant': i.selectedVariant,
                })
            .toList(),
      );

      await _repository.createOrder(invoice.toDbMap());

      // Reset coupon
      _activeCoupon = '';
      _couponDiscountRate = 0.0;

      emit(CheckoutSuccess(invoice));
    } catch (e) {
      emit(CartError('Simulated checkout failed: ${e.toString()}'));
    }
  }

  Future<void> _onLoadWishlist(
    LoadWishlistEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      final wishes = await _repository.getWishlist(event.userId);
      _cachedWishlist = wishes.map((w) => ProductEntity.fromMap(w['product'])).toList();
      add(const LoadCartEvent());
    } catch (_) {}
  }

  Future<void> _onToggleWishlist(
    ToggleWishlistEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _repository.toggleWishlist(event.userId, event.productId);
      add(LoadWishlistEvent(event.userId));
    } catch (_) {}
  }
}
