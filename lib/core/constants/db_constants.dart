class DbConstants {
  DbConstants._();

  static const String databaseName = 'fandom_verse.db';
  static const int databaseVersion = 1;

  // 12 Database Tables
  static const String tableUsers = 'users';
  static const String tableCategories = 'categories';
  static const String tablePosts = 'posts';
  static const String tableGlossary = 'glossary';
  static const String tableEvents = 'events';
  static const String tableMerchandise = 'merchandise';
  static const String tableCartItems = 'cart_items';
  static const String tableWishlists = 'wishlists';
  static const String tableDiscussions = 'discussions';
  static const String tableDiscussionReplies = 'discussion_replies';
  static const String tableStarProfiles = 'star_profiles';
  static const String tableSimulatedOrders = 'simulated_orders';
  static const String tableAuditLogs = 'admin_audit_logs';
  static const String tableHeroStories = 'hero_stories';

  // Default Pre-configured Coupons
  static const Map<String, double> validCoupons = {
    'FANDOM10': 0.10, // 10% off
    'CON2025': 0.15,  // 15% off
    'OTAKU20': 0.20,  // 20% off
    'SUPERFAN': 0.25, // 25% off
  };
}
