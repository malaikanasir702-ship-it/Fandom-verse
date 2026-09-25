import '../database/sqlite_helper.dart';
import 'i_store_repository.dart';

class StoreRepositoryImpl implements IStoreRepository {
  final SqliteHelper _dbHelper;

  StoreRepositoryImpl({SqliteHelper? dbHelper})
      : _dbHelper = dbHelper ?? SqliteHelper.instance;

  @override
  Future<List<Map<String, dynamic>>> getMerchandise({
    String? category,
    String? sortBy,
    String? searchQuery,
  }) {
    return _dbHelper.getAllMerchandise(
      category: category,
      sortBy: sortBy,
      searchQuery: searchQuery,
    );
  }

  @override
  Future<void> updateProductStock(String productId, int newStock) {
    return _dbHelper.updateProductStock(productId, newStock);
  }
}
