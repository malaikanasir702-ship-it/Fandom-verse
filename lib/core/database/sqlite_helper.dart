import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../constants/db_constants.dart';
import '../utils/password_hasher.dart';
import 'database_tables.dart';
import 'seed_data.dart';
import 'seed_data_extended.dart';
import 'seed_hero_stories.dart';

class SqliteHelper {
  static final SqliteHelper instance = SqliteHelper._internal();
  SqliteHelper._internal();

  Database? _db;

  Database get _database {
    if (_db == null) throw StateError('Database not initialized. Call initDatabase() first.');
    return _db!;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INIT & CREATE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> initDatabase() async {
    if (_db != null) return;

    final dbPath = await getDatabasesPath();
    final fullPath = p.join(dbPath, DbConstants.databaseName);

    _db = await openDatabase(
      fullPath,
      version: DbConstants.databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    // Ensure hero_stories table exists (supports non-reinstalled/upgraded dev databases)
    await _db!.execute(DatabaseTables.createHeroStoriesTable);
    await _seedHeroStoriesIfEmpty(_db!);

    debugPrint('✅ [SqliteHelper] Database ready at: $fullPath');
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint('🏗️ [SqliteHelper] Creating all 13 tables...');
    await _createAllTables(db);
    await _createAllIndexes(db);
    await _seedAllData(db);
    debugPrint('✅ [SqliteHelper] All tables created and seeded.');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('⬆️ [SqliteHelper] Safely upgrading DB from v$oldVersion → v$newVersion without dropping tables');
    // Non-destructive additive migrations (Bug 5.1/6.1)
    await _safeAddColumn(db, DbConstants.tableUsers, 'status', "TEXT NOT NULL DEFAULT 'active'");
    await _safeAddColumn(db, DbConstants.tableUsers, 'password_hash', 'TEXT');
    await _safeAddColumn(db, DbConstants.tableUsers, 'password_salt', 'TEXT');

    await _safeAddColumn(db, DbConstants.tableEvents, 'category', "TEXT DEFAULT 'Convention'");
    await _safeAddColumn(db, DbConstants.tableEvents, 'attendees_count', 'INTEGER DEFAULT 120');
    await _safeAddColumn(db, DbConstants.tableEvents, 'is_rsvped', 'INTEGER DEFAULT 0');

    await _safeAddColumn(db, DbConstants.tableDiscussions, 'is_upvoted', 'INTEGER DEFAULT 0');

    await _safeAddColumn(db, DbConstants.tableGlossary, 'is_bookmarked', 'INTEGER DEFAULT 0');

    await _safeAddColumn(db, DbConstants.tableSimulatedOrders, 'subtotal', 'REAL NOT NULL DEFAULT 0.0');
    await _safeAddColumn(db, DbConstants.tableSimulatedOrders, 'shipping_fee', 'REAL NOT NULL DEFAULT 0.0');
    await _safeAddColumn(db, DbConstants.tableSimulatedOrders, 'discount_amount', 'REAL NOT NULL DEFAULT 0.0');
    await _safeAddColumn(db, DbConstants.tableSimulatedOrders, 'tax_amount', 'REAL NOT NULL DEFAULT 0.0');
    await _safeAddColumn(db, DbConstants.tableSimulatedOrders, 'applied_coupon', "TEXT DEFAULT ''");
    await _safeAddColumn(db, DbConstants.tableSimulatedOrders, 'payment_method', "TEXT DEFAULT 'Cash on Delivery'");

    // Create any missing tables from single source of truth
    for (final sql in DatabaseTables.allCreateStatements) {
      await db.execute(sql);
    }
    await _createAllIndexes(db);
  }

  Future<void> _safeAddColumn(Database db, String table, String column, String definition) async {
    try {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    } catch (_) {
      // Column already exists, safe to ignore
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TABLE CREATION (13 Tables from database_schema.sql)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _createAllTables(Database db) async {
    for (final sql in DatabaseTables.allCreateStatements) {
      await db.execute(sql);
    }
  }

  Future<void> _createAllIndexes(Database db) async {
    await db.execute('CREATE INDEX IF NOT EXISTS idx_users_email ON ${DbConstants.tableUsers}(email)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_users_role ON ${DbConstants.tableUsers}(role)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_posts_category ON ${DbConstants.tablePosts}(category_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_posts_trending ON ${DbConstants.tablePosts}(is_trending)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_posts_bookmarked ON ${DbConstants.tablePosts}(is_bookmarked)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_glossary_term ON ${DbConstants.tableGlossary}(term)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_events_city ON ${DbConstants.tableEvents}(city_name)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_events_date ON ${DbConstants.tableEvents}(event_date)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_merch_category ON ${DbConstants.tableMerchandise}(category)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_merch_price ON ${DbConstants.tableMerchandise}(price)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_wishlists_user ON ${DbConstants.tableWishlists}(user_id)');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SEED DATA
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _seedAllData(Database db) async {
    final batch = db.batch();

    // Users (seeded with SHA-256 + salt password)
    for (final u in SeedData.defaultUsers) {
      final userMap = Map<String, dynamic>.from(u);
      final salt = u['role'] == 'admin' ? 'fandom_salt_admin' : 'fandom_salt_fan';
      final pwd = u['role'] == 'admin' ? 'admin123' : 'password123';
      userMap['password_salt'] = salt;
      userMap['password_hash'] = PasswordHasher.hashPassword(pwd, salt);
      userMap['status'] = userMap['status'] ?? 'active';
      batch.insert(DbConstants.tableUsers, userMap, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Categories
    for (final c in SeedData.defaultCategories) {
      batch.insert(DbConstants.tableCategories, c, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Merchandise
    for (final m in SeedData.defaultMerchandise) {
      batch.insert(DbConstants.tableMerchandise, m, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Events
    for (final e in SeedData.defaultEvents) {
      final eventMap = Map<String, dynamic>.from(e);
      eventMap['category'] = eventMap['category'] ?? 'Convention';
      eventMap['attendees_count'] = eventMap['attendees_count'] ?? 120;
      eventMap['is_rsvped'] = 0;
      batch.insert(DbConstants.tableEvents, eventMap, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Orders
    for (final o in SeedData.defaultOrders) {
      batch.insert(DbConstants.tableSimulatedOrders, o, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Audit Logs
    for (final l in SeedData.defaultAuditLogs) {
      batch.insert(DbConstants.tableAuditLogs, l, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Extended Seed Data (posts, glossary, discussions, stars)
    for (final post in SeedDataExtended.defaultPosts) {
      batch.insert(DbConstants.tablePosts, post, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    for (final term in SeedDataExtended.defaultGlossary) {
      batch.insert(DbConstants.tableGlossary, term, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    for (final thread in SeedDataExtended.defaultDiscussions) {
      final tMap = Map<String, dynamic>.from(thread);
      tMap['is_upvoted'] = 0;
      batch.insert(DbConstants.tableDiscussions, tMap, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    for (final reply in SeedDataExtended.defaultReplies) {
      batch.insert(DbConstants.tableDiscussionReplies, reply, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    for (final star in SeedDataExtended.defaultStarProfiles) {
      batch.insert(DbConstants.tableStarProfiles, star, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await batch.commit(noResult: true);
    debugPrint('🌱 [SqliteHelper] All seed data committed successfully.');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GENERIC CRUD
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> query(String tableName, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    await initDatabase();
    return _database.query(tableName,
        where: where, whereArgs: whereArgs, orderBy: orderBy, limit: limit);
  }

  Future<int> insert(String tableName, Map<String, dynamic> row) async {
    await initDatabase();
    return _database.insert(tableName, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(String tableName, String primaryKey, String keyValue,
      Map<String, dynamic> updatedFields) async {
    await initDatabase();
    return _database.update(tableName, updatedFields,
        where: '$primaryKey = ?', whereArgs: [keyValue]);
  }

  Future<int> delete(String tableName, String primaryKey, String keyValue) async {
    await initDatabase();
    return _database.delete(tableName,
        where: '$primaryKey = ?', whereArgs: [keyValue]);
  }

  Future<Map<String, dynamic>?> queryOne(String tableName, String primaryKey, String keyValue) async {
    await initDatabase();
    final result = await _database.query(tableName,
        where: '$primaryKey = ?', whereArgs: [keyValue], limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MERCHANDISE METHODS
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllMerchandise({
    String? category,
    String? sortBy,
    String? searchQuery,
  }) async {
    await initDatabase();
    String? whereClause;
    List<dynamic>? whereArgs;

    if (category != null && category.isNotEmpty && category != 'All') {
      whereClause = 'category = ?';
      whereArgs = [category];
    }

    String orderBy = 'is_featured DESC, rating DESC';
    if (sortBy == 'price_low_high') orderBy = 'price ASC';
    if (sortBy == 'price_high_low') orderBy = 'price DESC';
    if (sortBy == 'rating') orderBy = 'rating DESC';

    var products = await _database.query(
      DbConstants.tableMerchandise,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      products = products.where((p) {
        return (p['name'] ?? '').toString().toLowerCase().contains(q) ||
            (p['description'] ?? '').toString().toLowerCase().contains(q);
      }).toList();
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

  // ─────────────────────────────────────────────────────────────────────────
  // CART METHODS
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getCartItems() async {
    await initDatabase();
    final cartItems = await _database.query(DbConstants.tableCartItems);
    final List<Map<String, dynamic>> populated = [];

    for (final item in cartItems) {
      final product = await queryOne(DbConstants.tableMerchandise, 'product_id', item['product_id'] as String);
      if (product != null) {
        populated.add({...item, 'product': product});
      }
    }
    return populated;
  }

  Future<void> addToCart(String productId, int quantity, String variant) async {
    await initDatabase();
    final existing = await _database.query(
      DbConstants.tableCartItems,
      where: 'product_id = ? AND selected_variant = ?',
      whereArgs: [productId, variant],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final currentQty = existing.first['quantity'] as int? ?? 1;
      await _database.update(
        DbConstants.tableCartItems,
        {'quantity': currentQty + quantity},
        where: 'cart_id = ?',
        whereArgs: [existing.first['cart_id']],
      );
    } else {
      await insert(DbConstants.tableCartItems, {
        'cart_id': 'cart-${DateTime.now().millisecondsSinceEpoch}',
        'product_id': productId,
        'quantity': quantity,
        'selected_variant': variant,
        'added_at': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  Future<void> updateCartItemQuantity(String cartId, int newQuantity) async {
    await initDatabase();
    if (newQuantity <= 0) {
      await delete(DbConstants.tableCartItems, 'cart_id', cartId);
    } else {
      await update(DbConstants.tableCartItems, 'cart_id', cartId, {'quantity': newQuantity});
    }
  }

  Future<void> removeCartItem(String cartId) async {
    await delete(DbConstants.tableCartItems, 'cart_id', cartId);
  }

  Future<void> clearCart() async {
    await initDatabase();
    await _database.delete(DbConstants.tableCartItems);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WISHLIST METHODS
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getWishlist(String userId) async {
    await initDatabase();
    final wishes = await _database.query(
      DbConstants.tableWishlists,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    final List<Map<String, dynamic>> populated = [];
    for (final wish in wishes) {
      final product = await queryOne(DbConstants.tableMerchandise, 'product_id', wish['product_id'] as String);
      if (product != null) {
        populated.add({...wish, 'product': product});
      }
    }
    return populated;
  }

  Future<bool> isProductWishlisted(String userId, String productId) async {
    await initDatabase();
    final result = await _database.query(
      DbConstants.tableWishlists,
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<void> toggleWishlist(String userId, String productId) async {
    final exists = await isProductWishlisted(userId, productId);
    if (exists) {
      await initDatabase();
      await _database.delete(
        DbConstants.tableWishlists,
        where: 'user_id = ? AND product_id = ?',
        whereArgs: [userId, productId],
      );
    } else {
      await insert(DbConstants.tableWishlists, {
        'wish_id': 'wish-${DateTime.now().millisecondsSinceEpoch}',
        'user_id': userId,
        'product_id': productId,
        'saved_at': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ORDERS METHODS
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    await initDatabase();
    return _database.query(
      DbConstants.tableSimulatedOrders,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'order_date DESC',
    );
  }

  Future<void> createSimulatedOrder(Map<String, dynamic> orderData) async {
    await insert(DbConstants.tableSimulatedOrders, orderData);
    await clearCart();
    await logAdminAction(
      actionType: 'SIMULATED_ORDER',
      entityType: 'Store',
      description: 'New order #${orderData['order_id']} placed for \$${orderData['total_amount']}',
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ADMIN USERS METHODS
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    await initDatabase();
    return _database.query(DbConstants.tableUsers, orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    await initDatabase();
    final result = await _database.query(
      DbConstants.tableUsers,
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateUserStatus(String userId, String status) async {
    await update(DbConstants.tableUsers, 'user_id', userId, {'status': status});
    await logAdminAction(
      actionType: 'UPDATE_USER',
      entityType: 'Users',
      description: 'User $userId status changed to $status',
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AUDIT LOGS & KPI
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> logAdminAction({
    required String actionType,
    required String entityType,
    required String description,
    String adminEmail = 'admin@fandomverse.com',
  }) async {
    await initDatabase();
    await _database.insert(DbConstants.tableAuditLogs, {
      'log_id': 'log-${DateTime.now().millisecondsSinceEpoch}',
      'action_type': actionType,
      'entity_type': entityType,
      'description': description,
      'admin_email': adminEmail,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAuditLogs({int limit = 50}) async {
    await initDatabase();
    return _database.query(
      DbConstants.tableAuditLogs,
      orderBy: 'timestamp DESC',
      limit: limit,
    );
  }

  Future<Map<String, int>> getAdminDashboardMetrics() async {
    await initDatabase();
    final users = Sqflite.firstIntValue(
        await _database.rawQuery("SELECT COUNT(*) FROM ${DbConstants.tableUsers} WHERE role = 'fan'")) ?? 0;
    final posts = Sqflite.firstIntValue(
        await _database.rawQuery("SELECT COUNT(*) FROM ${DbConstants.tablePosts}")) ?? 0;
    final events = Sqflite.firstIntValue(
        await _database.rawQuery("SELECT COUNT(*) FROM ${DbConstants.tableEvents}")) ?? 0;
    final products = Sqflite.firstIntValue(
        await _database.rawQuery("SELECT COUNT(*) FROM ${DbConstants.tableMerchandise}")) ?? 0;

    return {
      'totalFans': users,
      'publishedArticles': posts,
      'upcomingEvents': events,
      'storeProducts': products,
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HERO STORIES CRUD
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _seedHeroStoriesIfEmpty(Database db) async {
    try {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ${DbConstants.tableHeroStories}'),
      ) ?? 0;
      if (count == 0) {
        final batch = db.batch();
        for (final story in SeedHeroStories.defaultStories) {
          batch.insert(
            DbConstants.tableHeroStories,
            story, // already a Map<String, dynamic>
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
        debugPrint('🦸 [SqliteHelper] Seeded ${SeedHeroStories.defaultStories.length} hero stories with rich backstories.');
      }
    } catch (e) {
      debugPrint('[SqliteHelper] Error seeding hero stories: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getHeroStories() async {
    await initDatabase();
    return _database.query(
      DbConstants.tableHeroStories,
      orderBy: 'created_at ASC',
    );
  }

  Future<void> saveHeroStory(Map<String, dynamic> storyMap) async {
    await initDatabase();
    await _database.insert(
      DbConstants.tableHeroStories,
      storyMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteHeroStory(String storyId) async {
    await initDatabase();
    await _database.delete(
      DbConstants.tableHeroStories,
      where: 'story_id = ?',
      whereArgs: [storyId],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CACHE SIZE (Real on-disk SQLite calculation)
  // ─────────────────────────────────────────────────────────────────────────

  Future<double> calculateCacheSizeMB() async {
    await initDatabase();
    try {
      final dbPath = await getDatabasesPath();
      final fullPath = p.join(dbPath, DbConstants.databaseName);
      final file = File(fullPath);
      if (await file.exists()) {
        final bytes = await file.length();
        return double.parse((bytes / (1024 * 1024)).toStringAsFixed(2));
      }
    } catch (e) {
      debugPrint('[SqliteHelper] Error calculating cache size: $e');
    }
    return 0.0;
  }

  Future<void> clearOfflineCache() async {
    await initDatabase();
    await _database.delete(DbConstants.tablePosts);
    await _database.delete(DbConstants.tableEvents);
    await _database.delete(DbConstants.tableDiscussions);
    await _database.delete(DbConstants.tableDiscussionReplies);
    await _database.delete(DbConstants.tableStarProfiles);
    await _database.delete(DbConstants.tableGlossary);
  }
}
