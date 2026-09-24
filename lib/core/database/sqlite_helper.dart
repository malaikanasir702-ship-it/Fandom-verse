import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/db_constants.dart';
import 'seed_data.dart';

class SqliteHelper {
  static final SqliteHelper instance = SqliteHelper._internal();
  SqliteHelper._internal();

  bool _isInitialized = false;
  late SharedPreferences _prefs;

  // In-memory cache synced with persistent storage
  final Map<String, List<Map<String, dynamic>>> _tables = {};

  Future<void> initDatabase() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();

    // Initialize or load all 12 tables
    for (final table in [
      DbConstants.tableUsers,
      DbConstants.tableCategories,
      DbConstants.tablePosts,
      DbConstants.tableGlossary,
      DbConstants.tableEvents,
      DbConstants.tableMerchandise,
      DbConstants.tableCartItems,
      DbConstants.tableWishlists,
      DbConstants.tableDiscussions,
      DbConstants.tableDiscussionReplies,
      DbConstants.tableStarProfiles,
      DbConstants.tableSimulatedOrders,
      DbConstants.tableAuditLogs,
    ]) {
      final storedData = _prefs.getString('sqlite_table_$table');
      if (storedData != null && storedData.isNotEmpty) {
        try {
          final List<dynamic> decoded = jsonDecode(storedData);
          _tables[table] = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        } catch (_) {
          _tables[table] = [];
        }
      } else {
        _tables[table] = [];
      }
    }

    // Seed initial data if tables are empty
    await _seedIfEmpty();
    _isInitialized = true;
  }

  Future<void> _seedIfEmpty() async {
    if (_tables[DbConstants.tableUsers]!.isEmpty) {
      _tables[DbConstants.tableUsers] = List.from(SeedData.defaultUsers);
      await _persistTable(DbConstants.tableUsers);
    }
    if (_tables[DbConstants.tableCategories]!.isEmpty) {
      _tables[DbConstants.tableCategories] = List.from(SeedData.defaultCategories);
      await _persistTable(DbConstants.tableCategories);
    }
    if (_tables[DbConstants.tableMerchandise]!.isEmpty) {
      _tables[DbConstants.tableMerchandise] = List.from(SeedData.defaultMerchandise);
      await _persistTable(DbConstants.tableMerchandise);
    }
    if (_tables[DbConstants.tableEvents]!.isEmpty) {
      _tables[DbConstants.tableEvents] = List.from(SeedData.defaultEvents);
      await _persistTable(DbConstants.tableEvents);
    }
    if (_tables[DbConstants.tableSimulatedOrders]!.isEmpty) {
      _tables[DbConstants.tableSimulatedOrders] = List.from(SeedData.defaultOrders);
      await _persistTable(DbConstants.tableSimulatedOrders);
    }
    if (_tables[DbConstants.tableAuditLogs]!.isEmpty) {
      _tables[DbConstants.tableAuditLogs] = List.from(SeedData.defaultAuditLogs);
      await _persistTable(DbConstants.tableAuditLogs);
    }
  }

  Future<void> _persistTable(String tableName) async {
    final data = _tables[tableName] ?? [];
    await _prefs.setString('sqlite_table_$tableName', jsonEncode(data));
  }

  // --- GENERIC CRUD HELPERS ---
  Future<List<Map<String, dynamic>>> query(String tableName) async {
    await initDatabase();
    return List<Map<String, dynamic>>.from(_tables[tableName] ?? []);
  }

  Future<void> insert(String tableName, Map<String, dynamic> row) async {
    await initDatabase();
    _tables[tableName] ??= [];
    _tables[tableName]!.add(Map<String, dynamic>.from(row));
    await _persistTable(tableName);
  }

  Future<void> update(String tableName, String primaryKey, String keyValue, Map<String, dynamic> updatedFields) async {
    await initDatabase();
    final list = _tables[tableName] ?? [];
    final index = list.indexWhere((item) => item[primaryKey] == keyValue);
    if (index != -1) {
      list[index] = {...list[index], ...updatedFields};
      await _persistTable(tableName);
    }
  }

  Future<void> delete(String tableName, String primaryKey, String keyValue) async {
    await initDatabase();
    final list = _tables[tableName] ?? [];
    list.removeWhere((item) => item[primaryKey] == keyValue);
    await _persistTable(tableName);
  }

  // --- MERCHANDISE METHODS ---
  Future<List<Map<String, dynamic>>> getAllMerchandise({
    String? category,
    String? sortBy,
    String? searchQuery,
  }) async {
    await initDatabase();
    var products = List<Map<String, dynamic>>.from(_tables[DbConstants.tableMerchandise] ?? []);

    if (category != null && category.isNotEmpty && category != 'All') {
      products = products.where((p) => p['category'] == category).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      products = products.where((p) {
        final name = (p['name'] ?? '').toString().toLowerCase();
        final desc = (p['description'] ?? '').toString().toLowerCase();
        return name.contains(q) || desc.contains(q);
      }).toList();
    }

    if (sortBy == 'price_low_high') {
      products.sort((a, b) => ((a['price'] as num?) ?? 0).compareTo((b['price'] as num?) ?? 0));
    } else if (sortBy == 'price_high_low') {
      products.sort((a, b) => ((b['price'] as num?) ?? 0).compareTo((a['price'] as num?) ?? 0));
    } else if (sortBy == 'rating') {
      products.sort((a, b) => ((b['rating'] as num?) ?? 0).compareTo((a['rating'] as num?) ?? 0));
    }

    return products;
  }

  Future<void> updateProductStock(String productId, int newStock) async {
    await update(DbConstants.tableMerchandise, 'product_id', productId, {'stock_count': newStock});
    await logAdminAction(
      actionType: 'UPDATE_STOCK',
      entityType: 'Merchandise',
      description: 'Stock updated to $newStock for product $productId',
    );
  }

  // --- CART METHODS ---
  Future<List<Map<String, dynamic>>> getCartItems() async {
    await initDatabase();
    final cartList = List<Map<String, dynamic>>.from(_tables[DbConstants.tableCartItems] ?? []);
    final merchList = List<Map<String, dynamic>>.from(_tables[DbConstants.tableMerchandise] ?? []);

    final List<Map<String, dynamic>> populated = [];
    for (final item in cartList) {
      final product = merchList.firstWhere(
        (m) => m['product_id'] == item['product_id'],
        orElse: () => {},
      );
      if (product.isNotEmpty) {
        populated.add({
          ...item,
          'product': product,
        });
      }
    }
    return populated;
  }

  Future<void> addToCart(String productId, int quantity, String variant) async {
    await initDatabase();
    final cartList = _tables[DbConstants.tableCartItems] ?? [];
    final existingIndex = cartList.indexWhere(
      (item) => item['product_id'] == productId && item['selected_variant'] == variant,
    );

    if (existingIndex != -1) {
      final currentQty = cartList[existingIndex]['quantity'] as int? ?? 1;
      cartList[existingIndex]['quantity'] = currentQty + quantity;
    } else {
      cartList.add({
        'cart_id': 'cart-${DateTime.now().millisecondsSinceEpoch}',
        'product_id': productId,
        'quantity': quantity,
        'selected_variant': variant,
        'added_at': DateTime.now().millisecondsSinceEpoch,
      });
    }
    await _persistTable(DbConstants.tableCartItems);
  }

  Future<void> updateCartItemQuantity(String cartId, int newQuantity) async {
    await initDatabase();
    final cartList = _tables[DbConstants.tableCartItems] ?? [];
    if (newQuantity <= 0) {
      cartList.removeWhere((item) => item['cart_id'] == cartId);
    } else {
      final index = cartList.indexWhere((item) => item['cart_id'] == cartId);
      if (index != -1) {
        cartList[index]['quantity'] = newQuantity;
      }
    }
    await _persistTable(DbConstants.tableCartItems);
  }

  Future<void> removeCartItem(String cartId) async {
    await delete(DbConstants.tableCartItems, 'cart_id', cartId);
  }

  Future<void> clearCart() async {
    await initDatabase();
    _tables[DbConstants.tableCartItems] = [];
    await _persistTable(DbConstants.tableCartItems);
  }

  // --- WISHLIST METHODS ---
  Future<List<Map<String, dynamic>>> getWishlist(String userId) async {
    await initDatabase();
    final wishList = List<Map<String, dynamic>>.from(_tables[DbConstants.tableWishlists] ?? []);
    final merchList = List<Map<String, dynamic>>.from(_tables[DbConstants.tableMerchandise] ?? []);

    final userWishes = wishList.where((w) => w['user_id'] == userId).toList();
    final List<Map<String, dynamic>> populated = [];
    for (final wish in userWishes) {
      final product = merchList.firstWhere(
        (m) => m['product_id'] == wish['product_id'],
        orElse: () => {},
      );
      if (product.isNotEmpty) {
        populated.add({
          ...wish,
          'product': product,
        });
      }
    }
    return populated;
  }

  Future<bool> isProductWishlisted(String userId, String productId) async {
    await initDatabase();
    final wishList = _tables[DbConstants.tableWishlists] ?? [];
    return wishList.any((w) => w['user_id'] == userId && w['product_id'] == productId);
  }

  Future<void> toggleWishlist(String userId, String productId) async {
    await initDatabase();
    final wishList = _tables[DbConstants.tableWishlists] ?? [];
    final exists = wishList.any((w) => w['user_id'] == userId && w['product_id'] == productId);

    if (exists) {
      wishList.removeWhere((w) => w['user_id'] == userId && w['product_id'] == productId);
    } else {
      wishList.add({
        'wish_id': 'wish-${DateTime.now().millisecondsSinceEpoch}',
        'user_id': userId,
        'product_id': productId,
        'saved_at': DateTime.now().millisecondsSinceEpoch,
      });
    }
    await _persistTable(DbConstants.tableWishlists);
  }

  // --- ORDERS METHODS ---
  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    await initDatabase();
    final orders = List<Map<String, dynamic>>.from(_tables[DbConstants.tableSimulatedOrders] ?? []);
    return orders.where((o) => o['user_id'] == userId).toList()
      ..sort((a, b) => (b['order_date'] as num).compareTo(a['order_date'] as num));
  }

  Future<void> createSimulatedOrder(Map<String, dynamic> orderData) async {
    await insert(DbConstants.tableSimulatedOrders, orderData);
    await clearCart();
    await logAdminAction(
      actionType: 'SIMULATED_ORDER',
      entityType: 'Store',
      description: 'New simulated order #${orderData['order_id']} placed for \$${orderData['total_amount']}',
    );
  }

  // --- AUDIT LOGS & KPI STATS ---
  Future<void> logAdminAction({
    required String actionType,
    required String entityType,
    required String description,
    String adminEmail = 'admin@fandomverse.com',
  }) async {
    await initDatabase();
    final logs = _tables[DbConstants.tableAuditLogs] ?? [];
    logs.insert(0, {
      'log_id': 'log-${DateTime.now().millisecondsSinceEpoch}',
      'action_type': actionType,
      'entity_type': entityType,
      'description': description,
      'admin_email': adminEmail,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    if (logs.length > 50) logs.removeLast();
    await _persistTable(DbConstants.tableAuditLogs);
  }

  Future<List<Map<String, dynamic>>> getAuditLogs() async {
    await initDatabase();
    return List<Map<String, dynamic>>.from(_tables[DbConstants.tableAuditLogs] ?? []);
  }

  Future<Map<String, int>> getAdminDashboardMetrics() async {
    await initDatabase();
    return {
      'totalFans': 1240 + (_tables[DbConstants.tableUsers]?.length ?? 0),
      'publishedArticles': 84 + (_tables[DbConstants.tablePosts]?.length ?? 0),
      'upcomingEvents': 16 + (_tables[DbConstants.tableEvents]?.length ?? 0),
      'storeProducts': _tables[DbConstants.tableMerchandise]?.length ?? 42,
    };
  }

  // --- STORAGE & CACHE MANAGEMENT ---
  Future<double> calculateCacheSizeMB() async {
    await initDatabase();
    int totalBytes = 0;
    for (final key in _prefs.getKeys()) {
      final val = _prefs.get(key);
      if (val is String) {
        totalBytes += val.length;
      }
    }
    // Baseline asset cache + DB footprint
    return (totalBytes / (1024 * 1024)) + 45.2; // ~45MB baseline media cache
  }

  Future<void> clearOfflineCache() async {
    await initDatabase();
    // Clear temporary tables/cache while preserving core seeded structure
    _tables[DbConstants.tableCartItems] = [];
    await _persistTable(DbConstants.tableCartItems);
  }
}
