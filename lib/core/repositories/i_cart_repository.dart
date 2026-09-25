abstract class ICartRepository {
  Future<List<Map<String, dynamic>>> getCartItems();
  Future<void> addToCart(String productId, int quantity, String variant);
  Future<void> updateCartItemQuantity(String cartId, int newQuantity);
  Future<void> removeCartItem(String cartId);
  Future<void> clearCart();
  Future<List<Map<String, dynamic>>> getWishlist(String userId);
  Future<bool> isProductWishlisted(String userId, String productId);
  Future<void> toggleWishlist(String userId, String productId);
  Future<void> createOrder(Map<String, dynamic> orderData);
}
