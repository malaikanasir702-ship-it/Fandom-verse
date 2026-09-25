import '../constants/db_constants.dart';

class DatabaseTables {
  DatabaseTables._();

  static const String createUsersTable = '''
    CREATE TABLE IF NOT EXISTS ${DbConstants.tableUsers} (
      user_id          TEXT PRIMARY KEY,
      name             TEXT NOT NULL,
      email            TEXT UNIQUE NOT NULL,
      role             TEXT NOT NULL DEFAULT 'fan',
      status           TEXT NOT NULL DEFAULT 'active',
      avatar_url       TEXT,
      bio              TEXT,
      badges           TEXT,
      selected_fandoms TEXT,
      password_hash    TEXT,
      password_salt    TEXT,
      created_at       INTEGER NOT NULL
    );
  ''';

  static const String createCategoriesTable = '''
    CREATE TABLE IF NOT EXISTS ${DbConstants.tableCategories} (
      category_id TEXT PRIMARY KEY,
      name        TEXT NOT NULL,
      description TEXT,
      icon_name   TEXT,
      banner_url  TEXT,
      color_hex   TEXT
    );
  ''';

  static const String createPostsTable = '''
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
    );
  ''';

  static const String createGlossaryTable = '''
    CREATE TABLE IF NOT EXISTS ${DbConstants.tableGlossary} (
      term_id         TEXT PRIMARY KEY,
      term            TEXT NOT NULL,
      definition      TEXT NOT NULL,
      fandom_category TEXT,
      example_usage   TEXT,
      phonetic        TEXT,
      is_bookmarked   INTEGER DEFAULT 0
    );
  ''';

  static const String createEventsTable = '''
    CREATE TABLE IF NOT EXISTS ${DbConstants.tableEvents} (
      event_id        TEXT PRIMARY KEY,
      title           TEXT NOT NULL,
      description     TEXT,
      city_name       TEXT NOT NULL,
      venue_name      TEXT NOT NULL,
      latitude        REAL NOT NULL,
      longitude       REAL NOT NULL,
      event_date      INTEGER NOT NULL,
      ticket_link     TEXT,
      banner_url      TEXT,
      category        TEXT DEFAULT 'Convention',
      attendees_count INTEGER DEFAULT 120,
      is_bookmarked   INTEGER DEFAULT 0,
      is_rsvped       INTEGER DEFAULT 0
    );
  ''';

  static const String createMerchandiseTable = '''
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
    );
  ''';

  static const String createCartItemsTable = '''
    CREATE TABLE IF NOT EXISTS ${DbConstants.tableCartItems} (
      cart_id          TEXT PRIMARY KEY,
      product_id       TEXT NOT NULL,
      quantity         INTEGER NOT NULL DEFAULT 1,
      selected_variant TEXT,
      added_at         INTEGER NOT NULL,
      FOREIGN KEY (product_id) REFERENCES ${DbConstants.tableMerchandise}(product_id) ON DELETE CASCADE
    );
  ''';

  static const String createWishlistsTable = '''
    CREATE TABLE IF NOT EXISTS ${DbConstants.tableWishlists} (
      wish_id    TEXT PRIMARY KEY,
      user_id    TEXT NOT NULL,
      product_id TEXT NOT NULL,
      saved_at   INTEGER NOT NULL,
      FOREIGN KEY (product_id) REFERENCES ${DbConstants.tableMerchandise}(product_id) ON DELETE CASCADE
    );
  ''';

  static const String createDiscussionsTable = '''
    CREATE TABLE IF NOT EXISTS ${DbConstants.tableDiscussions} (
      thread_id  TEXT PRIMARY KEY,
      user_id    TEXT NOT NULL,
      user_name  TEXT NOT NULL,
      user_badge TEXT,
      category   TEXT NOT NULL,
      title      TEXT NOT NULL,
      body       TEXT NOT NULL,
      upvotes    INTEGER DEFAULT 0,
      is_upvoted INTEGER DEFAULT 0,
      created_at INTEGER NOT NULL
    );
  ''';

  static const String createDiscussionRepliesTable = '''
    CREATE TABLE IF NOT EXISTS ${DbConstants.tableDiscussionReplies} (
      reply_id   TEXT PRIMARY KEY,
      thread_id  TEXT NOT NULL,
      user_name  TEXT NOT NULL,
      reply_body TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      FOREIGN KEY (thread_id) REFERENCES ${DbConstants.tableDiscussions}(thread_id) ON DELETE CASCADE
    );
  ''';

  static const String createStarProfilesTable = '''
    CREATE TABLE IF NOT EXISTS ${DbConstants.tableStarProfiles} (
      star_id         TEXT PRIMARY KEY,
      name            TEXT NOT NULL,
      fandom_category TEXT NOT NULL,
      role_title      TEXT NOT NULL,
      bio             TEXT NOT NULL,
      image_url       TEXT NOT NULL,
      social_handle   TEXT,
      is_bookmarked   INTEGER DEFAULT 0
    );
  ''';

  static const String createSimulatedOrdersTable = '''
    CREATE TABLE IF NOT EXISTS ${DbConstants.tableSimulatedOrders} (
      order_id         TEXT PRIMARY KEY,
      user_id          TEXT NOT NULL,
      order_date       INTEGER NOT NULL,
      subtotal         REAL NOT NULL DEFAULT 0.0,
      shipping_fee     REAL NOT NULL DEFAULT 0.0,
      discount_amount  REAL NOT NULL DEFAULT 0.0,
      tax_amount       REAL NOT NULL DEFAULT 0.0,
      total_amount     REAL NOT NULL,
      applied_coupon   TEXT DEFAULT '',
      shipping_address TEXT NOT NULL,
      payment_method   TEXT DEFAULT 'Cash on Delivery',
      items_summary    TEXT NOT NULL,
      order_status     TEXT DEFAULT 'Completed'
    );
  ''';

  static const String createAuditLogsTable = '''
    CREATE TABLE IF NOT EXISTS ${DbConstants.tableAuditLogs} (
      log_id      TEXT PRIMARY KEY,
      action_type TEXT NOT NULL,
      entity_type TEXT NOT NULL,
      description TEXT NOT NULL,
      admin_email TEXT NOT NULL,
      timestamp   INTEGER NOT NULL
    );
  ''';

  static const List<String> allCreateStatements = [
    createUsersTable,
    createCategoriesTable,
    createPostsTable,
    createGlossaryTable,
    createEventsTable,
    createMerchandiseTable,
    createCartItemsTable,
    createWishlistsTable,
    createDiscussionsTable,
    createDiscussionRepliesTable,
    createStarProfilesTable,
    createSimulatedOrdersTable,
    createAuditLogsTable,
  ];
}
