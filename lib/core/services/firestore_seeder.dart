import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';

/// FirestoreSeeder — One-time seeder that populates all Firestore
/// collections with initial data. Safe to call multiple times (idempotent).
class FirestoreSeeder {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static bool get _ready => FirebaseService.isInitialized;

  // ─────────────────────────────────────────────────────────────────────────
  // MAIN SEED ENTRY POINT
  // ─────────────────────────────────────────────────────────────────────────

  /// Seeds all collections. Call from admin dashboard or app init.
  static Future<Map<String, dynamic>> seedAll() async {
    if (!_ready) {
      await FirebaseService.initialize();
    }
    if (!_ready) {
      return {'success': false, 'message': 'Firebase not initialized. Please ensure internet is active and rebuild the app.'};
    }

    int seeded = 0;
    final errors = <String>[];

    try {
      // 1. Firebase Auth accounts
      await _seedAuthAccounts();

      // 2. Firestore collections (batched)
      seeded += await _seedCollection('categories', _categories());
      seeded += await _seedCollection('users', _users());
      seeded += await _seedCollection('fandom_posts', _posts());
      seeded += await _seedCollection('glossary', _glossary());
      seeded += await _seedCollection('events', _events());
      seeded += await _seedCollection('products', _products());
      seeded += await _seedCollection('discussions', _discussions());
      seeded += await _seedCollection('star_profiles', _starProfiles());
      seeded += await _seedCollection('orders', _orders());
      seeded += await _seedCollection('audit_logs', _auditLogs());

      debugPrint('✅ [FirestoreSeeder] $seeded documents seeded across 10 collections.');
      return {
        'success': true,
        'message': '$seeded documents seeded successfully!',
        'count': seeded,
      };
    } catch (e) {
      errors.add(e.toString());
      debugPrint('❌ [FirestoreSeeder] Error: $e');
      return {'success': false, 'message': 'Error: $e', 'errors': errors};
    }
  }

  /// Check if already seeded
  static Future<bool> isAlreadySeeded() async {
    if (!_ready) return false;
    final snap = await _db.collection('categories').limit(1).get();
    return snap.docs.isNotEmpty;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FIREBASE AUTH ACCOUNTS
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> _seedAuthAccounts() async {
    // Admin account
    await _createAuthUser(
      email: 'admin@fandomverse.com',
      password: 'admin123',
      displayName: 'Fandom Commander',
    );

    // Fan demo account
    await _createAuthUser(
      email: 'fan@fandomverse.com',
      password: 'fan123',
      displayName: 'Alex Mercer',
    );

    // Additional google demo fan
    await _createAuthUser(
      email: 'google.fan@fandomverse.com',
      password: 'fan123',
      displayName: 'Google Fan',
    );
  }

  static Future<void> _createAuthUser({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ Auth user created: $email');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        debugPrint('ℹ️ Auth user already exists: $email');
      } else {
        debugPrint('⚠️ Auth error for $email: ${e.message}');
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GENERIC COLLECTION SEEDER
  // ─────────────────────────────────────────────────────────────────────────

  static Future<int> _seedCollection(
    String collectionName,
    List<Map<String, dynamic>> docs,
  ) async {
    int count = 0;
    final batch = _db.batch();

    for (final doc in docs) {
      final id = doc['id'] as String? ?? doc['category_id'] as String? ??
          doc['post_id'] as String? ?? doc['term_id'] as String? ??
          doc['event_id'] as String? ?? doc['product_id'] as String? ??
          doc['thread_id'] as String? ?? doc['star_id'] as String? ??
          doc['order_id'] as String? ?? doc['log_id'] as String? ??
          _db.collection(collectionName).doc().id;

      final ref = _db.collection(collectionName).doc(id);
      batch.set(ref, {...doc, 'seededAt': FieldValue.serverTimestamp()},
          SetOptions(merge: true));
      count++;
    }

    await batch.commit();
    debugPrint('🌱 Seeded $count docs → $collectionName');
    return count;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SEED DATA: CATEGORIES (6)
  // ─────────────────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> _categories() => [
    {
      'category_id': 'cat_anime', 'id': 'cat_anime',
      'name': 'Anime & Manga',
      'description': 'Cosplay, Graphic Novels, Shonen & Seinen lore primers.',
      'iconName': 'auto_awesome',
      'bannerUrl': 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800',
      'colorHex': '#9C27B0',
    },
    {
      'category_id': 'cat_gaming', 'id': 'cat_gaming',
      'name': 'Gaming & Esports',
      'description': 'Speedruns, open-world RPG builds, competitive tournament meta.',
      'iconName': 'sports_esports',
      'bannerUrl': 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800',
      'colorHex': '#00E676',
    },
    {
      'category_id': 'cat_scifi', 'id': 'cat_scifi',
      'name': 'Sci-Fi & Fantasy',
      'description': 'Space operas, cybernetic lore, multi-century chronicles.',
      'iconName': 'rocket_launch',
      'bannerUrl': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800',
      'colorHex': '#00E5FF',
    },
    {
      'category_id': 'cat_comics', 'id': 'cat_comics',
      'name': 'Marvel & DC Comics',
      'description': 'Multiverse timelines, superhero dynasties, crossover arcs.',
      'iconName': 'menu_book',
      'bannerUrl': 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800',
      'colorHex': '#FF1744',
    },
    {
      'category_id': 'cat_kpop', 'id': 'cat_kpop',
      'name': 'K-Pop & Idol Culture',
      'description': 'Discographies, world tours, official lightsticks, member bios.',
      'iconName': 'music_note',
      'bannerUrl': 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800',
      'colorHex': '#FF4081',
    },
    {
      'category_id': 'cat_movies', 'id': 'cat_movies',
      'name': 'Pop Culture & Movies',
      'description': 'Cinematic sagas, film festival debuts, directors cuts.',
      'iconName': 'movie',
      'bannerUrl': 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800',
      'colorHex': '#FF9100',
    },
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // SEED DATA: USERS (2)
  // ─────────────────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> _users() => [
    {
      'id': 'admin-01',
      'name': 'Fandom Commander',
      'email': 'admin@fandomverse.com',
      'role': 'admin',
      'status': 'active',
      'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      'bio': 'Lead Operations Administrator & Content Overseer',
      'badges': ['Admin Commander', 'System Architect'],
      'selectedFandoms': ['All'],
      'createdAt': 1700000000000,
    },
    {
      'id': 'fan-01',
      'name': 'Alex Mercer',
      'email': 'fan@fandomverse.com',
      'role': 'fan',
      'status': 'active',
      'avatarUrl': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
      'bio': 'Anime watcher, speedrunner & convention fanatic.',
      'badges': ['Master Lorekeeper', 'Con Veteran 2025'],
      'selectedFandoms': ['Anime & Manga', 'Gaming & Esports'],
      'createdAt': 1700000000000,
    },
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // SEED DATA: POSTS (8)
  // ─────────────────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> _posts() => [
    {
      'post_id': 'trend-01', 'id': 'trend-01',
      'category': 'Anime & Manga',
      'categoryId': 'cat_anime',
      'title': 'Solo Leveling: Arise & The Monarch Wars Canon Explained',
      'contentBody': 'From the shadows of the Double Dungeon to the awakening of Sung Jin-woo as the Shadow Monarch, discover how the universe lore bridges the gap between webtoon and animation.',
      'authorName': 'Kenji Sato',
      'imageUrl': 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800',
      'isTrending': true,
      'isDeepDive': false,
      'tags': ['Anime', 'Monarchs', 'Lore'],
      'readTimeMinutes': 5,
      'timestamp': 1727000000000,
      'isBookmarked': false,
    },
    {
      'post_id': 'trend-02', 'id': 'trend-02',
      'category': 'Gaming & Esports',
      'categoryId': 'cat_gaming',
      'title': 'Elden Ring Shadow of the Erdtree: Miquella Lore Breakdown',
      'contentBody': 'A deep analytical journey into the Land of Shadow, exploring Saint Trina, Messmer the Impaler, and the ancient divine gate of Enir-Ilim.',
      'authorName': 'Elena Rostova',
      'imageUrl': 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800',
      'isTrending': true,
      'isDeepDive': true,
      'tags': ['Elden Ring', 'FromSoftware', 'Deep Lore'],
      'readTimeMinutes': 8,
      'timestamp': 1726900000000,
      'isBookmarked': false,
    },
    {
      'post_id': 'trend-03', 'id': 'trend-03',
      'category': 'Sci-Fi & Fantasy',
      'categoryId': 'cat_scifi',
      'title': 'Dune Messiah: Paul Atreides & The Jihad Consequences',
      'contentBody': 'Exploring Frank Herbert\'s thematic masterstroke: how prescience becomes a prison and why the Golden Path demands supreme sacrifice.',
      'authorName': 'David Thorne',
      'imageUrl': 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800',
      'isTrending': true,
      'isDeepDive': false,
      'tags': ['Dune', 'SciFi', 'Cinema'],
      'readTimeMinutes': 6,
      'timestamp': 1726800000000,
      'isBookmarked': false,
    },
    {
      'post_id': 'trend-04', 'id': 'trend-04',
      'category': 'Marvel & DC Comics',
      'categoryId': 'cat_comics',
      'title': 'Secret Wars & The Multiverse Collapse: Comic Timeline Primer',
      'contentBody': 'Before the MCU adapts Secret Wars, revisit Jonathan Hickman\'s 2015 saga where Doctor Doom created Battleworld out of dying realities.',
      'authorName': 'Marcus Vance',
      'imageUrl': 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800',
      'isTrending': true,
      'isDeepDive': true,
      'tags': ['Marvel', 'Comics', 'Multiverse'],
      'readTimeMinutes': 7,
      'timestamp': 1726700000000,
      'isBookmarked': false,
    },
    {
      'post_id': 'news-01', 'id': 'news-01',
      'category': 'Anime & Manga',
      'categoryId': 'cat_anime',
      'title': 'Chainsaw Man Reze Arc Movie Confirms Worldwide Theatrical Release',
      'contentBody': 'MAPPA studio unveils high-octane explosive teaser trailer featuring Denji and the Bomb Devil in a romantic yet lethal rendezvous across Tokyo.',
      'authorName': 'Akira Tanaka',
      'imageUrl': 'https://images.unsplash.com/photo-1563089145-599997674d42?w=600',
      'isTrending': false,
      'isDeepDive': false,
      'tags': ['Chainsaw Man', 'MAPPA', 'Movie'],
      'readTimeMinutes': 3,
      'timestamp': 1727100000000,
      'isBookmarked': false,
    },
    {
      'post_id': 'news-02', 'id': 'news-02',
      'category': 'Gaming & Esports',
      'categoryId': 'cat_gaming',
      'title': 'Worlds 2025 Grand Finals Announced for London O2 Arena',
      'contentBody': 'Riot Games confirms the premier League of Legends championship will return to Europe featuring the top 16 regional champions.',
      'authorName': 'Sarah Jenkins',
      'imageUrl': 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=600',
      'isTrending': false,
      'isDeepDive': false,
      'tags': ['Esports', 'LoL', 'Tournament'],
      'readTimeMinutes': 4,
      'timestamp': 1726950000000,
      'isBookmarked': false,
    },
    {
      'post_id': 'news-03', 'id': 'news-03',
      'category': 'K-Pop & Idol Culture',
      'categoryId': 'cat_kpop',
      'title': 'Stray Kids Shatters Stadium Attendance Records Across Asia Leg',
      'contentBody': 'The 8-member self-producing juggernaut wraps up historic stadium dates with bespoke orchestral arrangements of God\'s Menu and MANIAC.',
      'authorName': 'Min-ho Park',
      'imageUrl': 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600',
      'isTrending': false,
      'isDeepDive': false,
      'tags': ['K-Pop', 'Stray Kids', 'Concert'],
      'readTimeMinutes': 3,
      'timestamp': 1726850000000,
      'isBookmarked': false,
    },
    {
      'post_id': 'news-04', 'id': 'news-04',
      'category': 'Pop Culture & Movies',
      'categoryId': 'cat_movies',
      'title': 'Grand Admiral Thrawn Return Sets Stage for The Mandalorian Climax',
      'contentBody': 'Lucasfilm reveals production blueprints for Dave Filoni\'s upcoming theatrical feature weaving together Ahsoka, Din Djarin, and Imperial remnants.',
      'authorName': "Liam O'Connor",
      'imageUrl': 'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?w=600',
      'isTrending': false,
      'isDeepDive': false,
      'tags': ['Star Wars', 'Mandalorian', 'Thrawn'],
      'readTimeMinutes': 5,
      'timestamp': 1726780000000,
      'isBookmarked': false,
    },
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // SEED DATA: GLOSSARY (8)
  // ─────────────────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> _glossary() => [
    {
      'term_id': 'gl-01', 'id': 'gl-01',
      'term': 'Canon', 'phonetic': '/ˈkæn.ən/',
      'fandomCategory': 'Pop Culture & Movies',
      'definition': 'The official, authoritative storyline, events, and character arcs recognized as true within a fictional universe by its original creators.',
      'exampleUsage': 'The Expanded Universe novels were declared "Legends", making only the films and Clone Wars canon in 2014.',
    },
    {
      'term_id': 'gl-02', 'id': 'gl-02',
      'term': 'Isekai', 'phonetic': '/iː.seɪˈkaɪ/',
      'fandomCategory': 'Anime & Manga',
      'definition': 'A Japanese genre where a protagonist is transported, summoned, or reincarnated into a parallel or video game world.',
      'exampleUsage': 'That Time I Got Reincarnated as a Slime is one of the pinnacle modern Isekai light novels.',
    },
    {
      'term_id': 'gl-03', 'id': 'gl-03',
      'term': 'Speedrun Any%', 'phonetic': '/ˈspiːd.rʌn/',
      'fandomCategory': 'Gaming & Esports',
      'definition': 'A competitive gaming category where the player reaches the final credits as fast as possible using any glitches or sequence breaks.',
      'exampleUsage': 'The current Any% world record for Breath of the Wild sits under 24 minutes.',
    },
    {
      'term_id': 'gl-04', 'id': 'gl-04',
      'term': 'Waifu', 'phonetic': '/ˈwaɪ.fuː/',
      'fandomCategory': 'Anime & Manga',
      'definition': 'A fictional character from anime, manga, or video games that a fan has affectionate, devoted admiration for as an ideal partner.',
      'exampleUsage': 'Her room was decorated with tapestries of her favorite waifu, Yor Forger.',
    },
    {
      'term_id': 'gl-05', 'id': 'gl-05',
      'term': 'Retcon', 'phonetic': '/ˈrɛt.kɒn/',
      'fandomCategory': 'Marvel & DC Comics',
      'definition': 'Short for "Retroactive Continuity". Previously established facts in a fictional universe are altered or ignored by later works.',
      'exampleUsage': 'The revelation that Bucky Barnes survived and became the Winter Soldier was a masterclass comic retcon.',
    },
    {
      'term_id': 'gl-06', 'id': 'gl-06',
      'term': 'Stan', 'phonetic': '/stæn/',
      'fandomCategory': 'K-Pop & Idol Culture',
      'definition': 'An intensely enthusiastic, loyal, and supportive fan of a particular idol, music group, or pop icon.',
      'exampleUsage': 'I have been an active BTS stan since their 2015 HYYH era.',
    },
    {
      'term_id': 'gl-07', 'id': 'gl-07',
      'term': 'Filler', 'phonetic': '/ˈfɪl.ər/',
      'fandomCategory': 'Anime & Manga',
      'definition': 'Anime episodes or arcs not adapted from the original manga, produced so the manga author can write more material ahead.',
      'exampleUsage': 'Naruto Shippuden features over 40% filler episodes.',
    },
    {
      'term_id': 'gl-08', 'id': 'gl-08',
      'term': 'Cosplay', 'phonetic': '/ˈkɒz.pleɪ/',
      'fandomCategory': 'Pop Culture & Movies',
      'definition': 'A portmanteau of "costume play". Dressing up as a character from a movie, book, anime, or video game with handmade props.',
      'exampleUsage': 'She won best craft award at Comic-Con for her 7-foot robotic Armored Core cosplay.',
    },
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // SEED DATA: EVENTS (3)
  // ─────────────────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> _events() => [
    {
      'event_id': 'evt-001', 'id': 'evt-001',
      'title': 'Tokyo Anime Expo 2026',
      'description': 'The world\'s largest gathering of animators, mangaka, voice actors, and global otaku fans at Big Sight.',
      'cityName': 'Tokyo',
      'venueName': 'Tokyo Big Sight Exhibition Center',
      'latitude': 35.6298,
      'longitude': 139.7942,
      'eventDate': 1785000000000,
      'ticketLink': 'https://anime-expo.tokyo/tickets',
      'bannerUrl': 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=800',
      'isBookmarked': false,
    },
    {
      'event_id': 'evt-002', 'id': 'evt-002',
      'title': 'San Diego International Comic-Con 2026',
      'description': 'Hall H exclusive reveals, Hollywood superhero panels, and the world famous Masquerade cosplay contest.',
      'cityName': 'San Diego',
      'venueName': 'San Diego Convention Center',
      'latitude': 32.7071,
      'longitude': -117.1611,
      'eventDate': 1786500000000,
      'ticketLink': 'https://comic-con.org/register',
      'bannerUrl': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800',
      'isBookmarked': false,
    },
    {
      'event_id': 'evt-003', 'id': 'evt-003',
      'title': 'Seoul Esports World Invitational',
      'description': '16 international powerhouse teams battle across 5 premier titles in an electric 15,000 seat stadium.',
      'cityName': 'Seoul',
      'venueName': 'KSPO Dome Olympic Park',
      'latitude': 37.5195,
      'longitude': 127.1274,
      'eventDate': 1787800000000,
      'ticketLink': 'https://seoul-esports.kr/tickets',
      'bannerUrl': 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800',
      'isBookmarked': false,
    },
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // SEED DATA: PRODUCTS (8)
  // ─────────────────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> _products() => [
    {
      'product_id': 'prod-001', 'id': 'prod-001',
      'name': 'Chrono Blade Neon Katana (Replica 1:1)',
      'category': 'Replica Props',
      'price': 149.99, 'originalPrice': 189.99,
      'imageUrl': 'https://images.unsplash.com/photo-1595590424283-b8f17842773f?w=600',
      'description': 'Forged high-density carbon alloy blade with interactive RGB LED edge lighting and display stand.',
      'stockCount': 6, 'rating': 4.9, 'isFeatured': true,
    },
    {
      'product_id': 'prod-002', 'id': 'prod-002',
      'name': 'Cyber Otaku Oversized Hoodie [Night City]',
      'category': 'Apparel',
      'price': 69.50, 'originalPrice': 85.00,
      'imageUrl': 'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=600',
      'description': 'Heavyweight 450 GSM French Terry cotton hoodie with reflective typography print and hidden thumb cuffs.',
      'stockCount': 18, 'rating': 4.8, 'isFeatured': true,
    },
    {
      'product_id': 'prod-003', 'id': 'prod-003',
      'name': 'Valkyrie Prime Action Figure (Articulated)',
      'category': 'Action Figures',
      'price': 89.00, 'originalPrice': 110.00,
      'imageUrl': 'https://images.unsplash.com/photo-1608889175123-8ee362201f81?w=600',
      'description': 'Over 32 points of articulation with interchangeable hands, energy wings, and battle-damaged armor plates.',
      'stockCount': 4, 'rating': 5.0, 'isFeatured': true,
    },
    {
      'product_id': 'prod-004', 'id': 'prod-004',
      'name': 'Infinite Multiverse Hardcover Omnibus Vol. 1',
      'category': 'Manga/Comics',
      'price': 54.99, 'originalPrice': 65.00,
      'imageUrl': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600',
      'description': 'Over 850 pages collecting the legendary multiverse collision arc with exclusive author commentary.',
      'stockCount': 22, 'rating': 4.7, 'isFeatured': false,
    },
    {
      'product_id': 'prod-005', 'id': 'prod-005',
      'name': 'Aero-Glow Smart Idol Lightstick v3',
      'category': 'Digital Collectibles',
      'price': 42.00, 'originalPrice': 50.00,
      'imageUrl': 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=600',
      'description': 'Bluetooth synced concert lightstick capable of 16M colors with concert arena proximity sync protocol.',
      'stockCount': 35, 'rating': 4.9, 'isFeatured': true,
    },
    {
      'product_id': 'prod-006', 'id': 'prod-006',
      'name': 'Mecha G-Zero Collector Enamel Pin Set',
      'category': 'Digital Collectibles',
      'price': 24.99, 'originalPrice': 30.00,
      'imageUrl': 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=600',
      'description': 'Set of 4 double-posted hard enamel pins with gold electroplating and individual laser serial numbers.',
      'stockCount': 50, 'rating': 4.6, 'isFeatured': false,
    },
    {
      'product_id': 'prod-007', 'id': 'prod-007',
      'name': 'Demon Hunter Hand-Painted Resin Bust (1/4 Scale)',
      'category': 'Action Figures',
      'price': 229.00, 'originalPrice': 275.00,
      'imageUrl': 'https://images.unsplash.com/photo-1563089145-599997674d42?w=600',
      'description': 'Museum grade cold-cast resin statue with hand-finished gradient detailing and certificate of authenticity.',
      'stockCount': 3, 'rating': 5.0, 'isFeatured': true,
    },
    {
      'product_id': 'prod-008', 'id': 'prod-008',
      'name': 'Pixel Legend Retro Gaming Backpack',
      'category': 'Apparel',
      'price': 79.99, 'originalPrice': 99.00,
      'imageUrl': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600',
      'description': 'Water-resistant cordura pack with programmable LED matrix front screen to display animated 8-bit sprites.',
      'stockCount': 12, 'rating': 4.8, 'isFeatured': false,
    },
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // SEED DATA: DISCUSSIONS (5)
  // ─────────────────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> _discussions() => [
    {
      'thread_id': 'thread-01', 'id': 'thread-01',
      'userId': 'fan-01', 'userName': 'Alex Mercer',
      'userBadge': 'Master Lorekeeper',
      'category': 'Anime & Manga',
      'title': 'Which Anime Arc Had the Most Impactful Plot Twist of All Time?',
      'body': 'I\'ve been rewatching classic anime and I keep coming back to the Chimera Ant arc in HxH. What do you think is the most impactful plot twist ever?',
      'upvotes': 847,
      'createdAt': 1726500000000,
    },
    {
      'thread_id': 'thread-02', 'id': 'thread-02',
      'userId': 'fan-01', 'userName': 'Alex Mercer',
      'userBadge': 'Con Veteran 2025',
      'category': 'Gaming & Esports',
      'title': 'Elden Ring vs Dark Souls III — Which FromSoft Game is Actually Harder?',
      'body': 'Both games are notorious but I argue Elden Ring is actually easier because of summons, Spirit Ashes, and open-world leveling freedom. Change my mind.',
      'upvotes': 1204,
      'createdAt': 1726400000000,
    },
    {
      'thread_id': 'thread-03', 'id': 'thread-03',
      'userId': 'fan-01', 'userName': 'Alex Mercer',
      'userBadge': 'Master Lorekeeper',
      'category': 'Marvel & DC Comics',
      'title': 'MCU Phase 6 Secret Wars — Will It Live Up to the Comics?',
      'body': 'The Kang saga bombed. Multiverse of Madness was divisive. Now Secret Wars is the promised payoff. Do you think Marvel Studios can pull off the scale of Hickman\'s magnum opus?',
      'upvotes': 2341,
      'createdAt': 1726300000000,
    },
    {
      'thread_id': 'thread-04', 'id': 'thread-04',
      'userId': 'fan-01', 'userName': 'Alex Mercer',
      'userBadge': 'Con Veteran 2025',
      'category': 'K-Pop & Idol Culture',
      'title': 'Best K-Pop Albums of 2025 — Ranking Thread',
      'body': 'We are approaching year end and the drops have been incredible. My top 3: 1. STRAY KIDS - ATE  2. AESPA - Whiplash  3. LE SSERAFIM - CRAZY. What are yours?',
      'upvotes': 567,
      'createdAt': 1726200000000,
    },
    {
      'thread_id': 'thread-05', 'id': 'thread-05',
      'userId': 'fan-01', 'userName': 'Alex Mercer',
      'userBadge': 'Master Lorekeeper',
      'category': 'Sci-Fi & Fantasy',
      'title': 'Dune vs Foundation — Which Sci-Fi Universe Has Better World-Building?',
      'body': 'Both Asimov\'s Foundation and Herbert\'s Dune represent the pinnacle of speculative fiction. Which is the superior constructed universe and why?',
      'upvotes': 923,
      'createdAt': 1726100000000,
    },
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // SEED DATA: STAR PROFILES (6)
  // ─────────────────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> _starProfiles() => [
    {
      'star_id': 'star-01', 'id': 'star-01',
      'name': 'Yuki Kaji',
      'fandomCategory': 'Anime & Manga',
      'roleTitle': 'Voice Actor — Eren Yeager (AoT), Todoroki (MHA)',
      'bio': 'One of Japan\'s most prolific voice actors with over 300 anime characters. Known for intense emotional range as Eren Yeager in Attack on Titan.',
      'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      'socialHandle': '@yukikaji_official',
      'isBookmarked': false,
    },
    {
      'star_id': 'star-02', 'id': 'star-02',
      'name': 'Faker (Lee Sang-hyeok)',
      'fandomCategory': 'Gaming & Esports',
      'roleTitle': 'Professional LoL Player — T1 (Mid Lane)',
      'bio': 'The greatest esports player of all time with 4 World Championships. His mechanical skill and game IQ have made him a cultural icon across Asia.',
      'imageUrl': 'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?w=400',
      'socialHandle': '@faker',
      'isBookmarked': false,
    },
    {
      'star_id': 'star-03', 'id': 'star-03',
      'name': 'Bang Chan',
      'fandomCategory': 'K-Pop & Idol Culture',
      'roleTitle': 'Leader & Producer — Stray Kids (3RACHA)',
      'bio': 'Born in Australia, Bang Chan is the leader, main producer, and creative director of Stray Kids. He runs the beloved weekly Chan\'s Room livestream.',
      'imageUrl': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400',
      'socialHandle': '@realbangchan',
      'isBookmarked': false,
    },
    {
      'star_id': 'star-04', 'id': 'star-04',
      'name': 'Zack Snyder',
      'fandomCategory': 'Pop Culture & Movies',
      'roleTitle': 'Director — DC Extended Universe, Rebel Moon',
      'bio': 'Known for his distinctive visual style directing Man of Steel, Batman v Superman, and the legendary 4-hour Snyder Cut of Justice League.',
      'imageUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
      'socialHandle': '@zacksnyder',
      'isBookmarked': false,
    },
    {
      'star_id': 'star-05', 'id': 'star-05',
      'name': 'Eiichiro Oda',
      'fandomCategory': 'Anime & Manga',
      'roleTitle': 'Manga Author — One Piece (1997–Present)',
      'bio': 'Creator of One Piece, the best-selling manga in history with over 520 million copies. Building this world for 27+ years with unparalleled consistency.',
      'imageUrl': 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=400',
      'socialHandle': '@eiichiro_staff',
      'isBookmarked': false,
    },
    {
      'star_id': 'star-06', 'id': 'star-06',
      'name': 'Hideo Kojima',
      'fandomCategory': 'Gaming & Esports',
      'roleTitle': 'Game Director — Death Stranding, Metal Gear Solid',
      'bio': 'The "Spielberg of Gaming". Creative visionary behind Metal Gear Solid and Death Stranding. Kojima Productions pushes boundaries between cinema and games.',
      'imageUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      'socialHandle': '@HIDEO_KOJIMA_EN',
      'isBookmarked': false,
    },
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // SEED DATA: ORDERS (2)
  // ─────────────────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> _orders() => [
    {
      'order_id': 'FV-89241', 'id': 'FV-89241',
      'userId': 'fan-01',
      'orderDate': 1735000000000,
      'totalAmount': 204.49,
      'itemsSummary': 'Chrono Blade Neon Katana (x1), Mecha G-Zero Enamel Pin (x1)',
      'shippingAddress': 'Alex Mercer, 742 Evergreen Terrace, Sector 7-G, Neo Tokyo',
      'orderStatus': 'Completed',
    },
    {
      'order_id': 'FV-77104', 'id': 'FV-77104',
      'userId': 'fan-01',
      'orderDate': 1732000000000,
      'totalAmount': 62.55,
      'itemsSummary': 'Cyber Otaku Oversized Hoodie [Night City] (x1)',
      'shippingAddress': 'Alex Mercer, 742 Evergreen Terrace, Sector 7-G, Neo Tokyo',
      'orderStatus': 'Completed',
    },
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // SEED DATA: AUDIT LOGS (3)
  // ─────────────────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> _auditLogs() => [
    {
      'log_id': 'log-01', 'id': 'log-01',
      'actionType': 'SYSTEM_INIT',
      'entityType': 'Core',
      'description': 'Firestore database seeded with 10 collections and initial data.',
      'adminEmail': 'admin@fandomverse.com',
      'timestamp': 1735000000000,
    },
    {
      'log_id': 'log-02', 'id': 'log-02',
      'actionType': 'CREATE',
      'entityType': 'Merchandise',
      'description': 'Added "Chrono Blade Neon Katana (Replica 1:1)" to store catalog.',
      'adminEmail': 'admin@fandomverse.com',
      'timestamp': 1735100000000,
    },
    {
      'log_id': 'log-03', 'id': 'log-03',
      'actionType': 'BROADCAST',
      'entityType': 'Push Alert',
      'description': 'Broadcast alert "Summer Fandom Festival Tickets Live!" to 1,240 fans.',
      'adminEmail': 'admin@fandomverse.com',
      'timestamp': 1735120000000,
    },
  ];
}
