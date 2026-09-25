abstract class IStoreRepository {
  Future<List<Map<String, dynamic>>> getMerchandise({
    String? category,
    String? sortBy,
    String? searchQuery,
  });

  Future<void> updateProductStock(String productId, int newStock);
}
