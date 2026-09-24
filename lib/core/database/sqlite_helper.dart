import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../constants/db_constants.dart';
import 'seed_data.dart';
import 'seed_data_extended.dart';

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
    debugPrint('⬆️ [SqliteHelper] Upgrading DB from v$oldVersion → v$newVersion');
    // Drop and recreate on upgrade
    final tables = [
      DbConstants.tableAuditLogs,
      DbConstants.tableSimulatedOrders,
      DbConstants.tableStarProfiles,
      DbConstants.tableDiscussionReplies,
      DbConstants.tableDiscussions,
      DbConstants.tableWishlists,
      DbConstants.tableCartItems,
      DbConstants.tableMerchandise,
      DbConstants.tableEvents,
      DbConstants.tableGlossary,
      DbConstants.tablePosts,
      DbConstants.tableCategories,
      DbConstants.tableUsers,
    ];
    for (final t in tables) {
      await db.execute('DROP TABLE IF EXISTS $t');
    }
    await _onCreate(db, newVersion);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TABLE CREATION (13 Tables from database_schema.sql)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _createAllTables(Database db) async {
    // 1. USERS
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tableUsers} (
        user_id       TEXT PRIMARY KEY,
        name          TEXT NOT NULL,
        email         TEXT UNIQUE NOT NULL,
        role          TEXT NOT NULL DEFAULT 'fan',
        status        TEXT NOT NULL DEFAULT 'active',
        avatar_url    TEXT,
        bio           TEXT,
        badges        TEXT,
        selected_fandoms TEXT,
        created_at    INTEGER NOT NULL
      )
    ''');

    // 2. CATEGORIES
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tableCategories} (
        category_id   TEXT PRIMARY KEY,
        name          TEXT NOT NULL,
        description   TEXT,
        icon_name     TEXT,
        banner_url    TEXT,
        color_hex     TEXT
      )
    ''');

    // 3. POSTS & LORE ARTICLES
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tablePosts} (
        post_id       TEXT PRIMARY KEY,
        category_id   TEXT NOT NULL,
        title         TEXT NOT NULL,
        content_body  TEXT NOT NULL,
        author_name   TEXT,
        image_url     TEXT,
        is_trending   INTEGER DEFAULT 0,
        is_deep_dive  INTEGER DEFAULT 0,
        tags          TEXT,
        timestamp     INTEGER NOT NULL,
        is_bookmarked INTEGER DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES ${DbConstants.tableCategories}(category_id) ON DELETE CASCADE
      )
    ''');

    // 4. GLOSSARY
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tableGlossary} (
        term_id          TEXT PRIMARY KEY,
        term             TEXT NOT NULL,
        definition       TEXT NOT NULL,
        fandom_category  TEXT,
        example_usage    TEXT,
        phonetic         TEXT
      )
    ''');

    // 5. EVENTS & CONVENTIONS
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tableEvents} (
        event_id      TEXT PRIMARY KEY,
        title         TEXT NOT NULL,
        description   TEXT,
        city_name     TEXT NOT NULL,
        venue_name    TEXT NOT NULL,
        latitude      REAL NOT NULL,
        longitude     REAL NOT NULL,
        event_date    INTEGER NOT NULL,
        ticket_link   TEXT,
        banner_url    TEXT,
        is_bookmarked INTEGER DEFAULT 0
      )
    ''');

    // 6. MERCHANDISE CATALOG
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tableMerchandise} (
        product_id     TEXT PRIMARY KEY,
        name           TEXT NOT NULL,
        category       TEXT NOT NULL,
        price          REAL NOT NULL,
        original_price REAL,
        image_url      TEXT NOT NULL,
        description    TEXT,
        stock_count    INTEGER DEFAULT 10,
        rating         REAL DEFAULT 4.8,
        is_featured    INTEGER DEFAULT 0
      )
    ''');

    // 7. CART ITEMS
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tableCartItems} (
        cart_id          TEXT PRIMARY KEY,
        product_id       TEXT NOT NULL,
        quantity         INTEGER NOT NULL DEFAULT 1,
        selected_variant TEXT,
        added_at         INTEGER NOT NULL,
        FOREIGN KEY (product_id) REFERENCES ${DbConstants.tableMerchandise}(product_id) ON DELETE CASCADE
      )
    ''');

    // 8. WISHLISTS
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tableWishlists} (
        wish_id    TEXT PRIMARY KEY,
        user_id    TEXT NOT NULL,
        product_id TEXT NOT NULL,
        saved_at   INTEGER NOT NULL,
        FOREIGN KEY (product_id) REFERENCES ${DbConstants.tableMerchandise}(product_id) ON DELETE CASCADE
      )
    ''');

    // 9. COMMUNITY DISCUSSIONS
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tableDiscussions} (
        thread_id  TEXT PRIMARY KEY,
        user_id    TEXT NOT NULL,
        user_name  TEXT NOT NULL,
        user_badge TEXT,
        category   TEXT NOT NULL,
        title      TEXT NOT NULL,
        body       TEXT NOT NULL,
        upvotes    INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    // 10. DISCUSSION REPLIES
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tableDiscussionReplies} (
        reply_id   TEXT PRIMARY KEY,
        thread_id  TEXT NOT NULL,
        user_name  TEXT NOT NULL,
        reply_body TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (thread_id) REFERENCES ${DbConstants.tableDiscussions}(thread_id) ON DELETE CASCADE
      )
    ''');

    // 11. STAR PROFILES
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tableStarProfiles} (
        star_id          TEXT PRIMARY KEY,
        name             TEXT NOT NULL,
        fandom_category  TEXT NOT NULL,
        role_title       TEXT NOT NULL,
        bio              TEXT NOT NULL,
        image_url        TEXT NOT NULL,
        social_handle    TEXT,
        is_bookmarked    INTEGER DEFAULT 0
      )
    ''');

    // 12. SIMULATED ORDERS
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tableSimulatedOrders} (
        order_id         TEXT PRIMARY KEY,
        user_id          TEXT NOT NULL,
        order_date       INTEGER NOT NULL,
        total_amount     REAL NOT NULL,
        items_summary    TEXT NOT NULL,
        shipping_address TEXT NOT NULL,
        order_status     TEXT DEFAULT 'Completed'
      )
    ''');

    // 13. ADMIN AUDIT LOGS
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tableAuditLogs} (
        log_id       TEXT PRIMARY KEY,
        action_type  TEXT NOT NULL,
        entity_type  TEXT NOT NULL,
        description  TEXT NOT NULL,
        admin_email  TEXT NOT NULL,
        timestamp    INTEGER NOT NULL
      )
    ''');
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

    // Users
    for (final u in SeedData.defaultUsers) {
      batch.insert(DbConstants.tableUsers, u, conflictAlgorithm: ConflictAlgorithm.ignore);
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
      batch.insert(DbConstants.tableEvents, e, conflictAlgorithm: ConflictAlgorithm.ignore);
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
      batch.insert(DbConstants.tableDiscussions, thread, conflictAlgorithm: ConflictAlgorithm.ignore);
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
      'totalFans': 1240 + users,
      'publishedArticles': 84 + posts,
      'upcomingEvents': 16 + events,
      'storeProducts': products,
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CACHE SIZE (simulated)
  // ─────────────────────────────────────────────────────────────────────────

  Future<double> calculateCacheSizeMB() async {
    await initDatabase();
    return 45.2; // Baseline media cache estimate
  }

  Future<void> clearOfflineCache() async {
    await initDatabase();
    await _database.delete(DbConstants.tableCartItems);
  }
}
