import '../database/sqlite_helper.dart';
import 'i_cart_repository.dart';

class CartRepositoryImpl implements ICartRepository {
  final SqliteHelper _dbHelper;

  CartRepositoryImpl({SqliteHelper? dbHelper})
      : _dbHelper = dbHelper ?? SqliteHelper.instance;

  @override
  Future<List<Map<String, dynamic>>> getCartItems() {
    return _dbHelper.getCartItems();
  }

  @override
  Future<void> addToCart(String productId, int quantity, String variant) {
    return _dbHelper.addToCart(productId, quantity, variant);
  }

  @override
  Future<void> updateCartItemQuantity(String cartId, int newQuantity) {
    return _dbHelper.updateCartItemQuantity(cartId, newQuantity);
  }

  @override
  Future<void> removeCartItem(String cartId) {
    return _dbHelper.removeCartItem(cartId);
  }

  @override
  Future<void> clearCart() {
    return _dbHelper.clearCart();
  }

  @override
  Future<List<Map<String, dynamic>>> getWishlist(String userId) {
    return _dbHelper.getWishlist(userId);
  }

  @override
  Future<bool> isProductWishlisted(String userId, String productId) {
    return _dbHelper.isProductWishlisted(userId, productId);
  }

  @override
  Future<void> toggleWishlist(String userId, String productId) {
    return _dbHelper.toggleWishlist(userId, productId);
  }

  @override
  Future<void> createOrder(Map<String, dynamic> orderData) {
    return _dbHelper.createSimulatedOrder(orderData);
  }
}
