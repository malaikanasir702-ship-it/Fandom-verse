import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class MultimediaService {
  static final MultimediaService _instance = MultimediaService._();
  MultimediaService._();
  static MultimediaService get instance => _instance;

  FirebaseFirestore? get _firestore =>
      FirebaseService.isInitialized ? FirebaseFirestore.instance : null;

  static const String collectionName = 'multimedia';

  // ── Auto-seed initial items into Firestore if empty ─────────────────────────
  Future<void> ensureInitialized() async {
    if (_firestore == null) return;
    try {
      final snap = await _firestore!.collection(collectionName).limit(1).get();
      if (snap.docs.isEmpty) {
        debugPrint('[MultimediaService] Initializing default multimedia items into Firestore...');
        final batch = _firestore!.batch();
        for (final item in _defaultItems) {
          final docRef = _firestore!.collection(collectionName).doc(item['id'] as String);
          batch.set(docRef, {
            ...item,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
        debugPrint('[MultimediaService] Seeded ${_defaultItems.length} default multimedia items.');
      }
    } catch (e) {
      debugPrint('[MultimediaService] ensureInitialized error: $e');
    }
  }

  // ── Real-time stream of multimedia items ──────────────────────────────────
  Stream<List<Map<String, dynamic>>> streamItems({String? type}) {
    if (_firestore == null) {
      return Stream.value(
        type == null
            ? _defaultItems
            : _defaultItems.where((i) => i['type'] == type).toList(),
      );
    }

    Query query = _firestore!.collection(collectionName);
    if (type != null && type != 'All') {
      query = query.where('type', isEqualTo: type);
    }

    return query.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        // Return default items if collection empty yet
        return type == null
            ? _defaultItems
            : _defaultItems.where((i) => i['type'] == type).toList();
      }
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // ── Fetch one-time ────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getItems({String? type}) async {
    if (_firestore == null) {
      return type == null
          ? _defaultItems
          : _defaultItems.where((i) => i['type'] == type).toList();
    }

    try {
      Query query = _firestore!.collection(collectionName);
      if (type != null && type != 'All') {
        query = query.where('type', isEqualTo: type);
      }
      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        return type == null
            ? _defaultItems
            : _defaultItems.where((i) => i['type'] == type).toList();
      }
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('[MultimediaService] getItems error: $e');
      return type == null
          ? _defaultItems
          : _defaultItems.where((i) => i['type'] == type).toList();
    }
  }

  // ── Create Item ───────────────────────────────────────────────────────────
  Future<String> createItem(Map<String, dynamic> data) async {
    if (_firestore == null) {
      final newId = 'mm_${DateTime.now().millisecondsSinceEpoch}';
      data['id'] = newId;
      _defaultItems.insert(0, data);
      return newId;
    }

    final docRef = _firestore!.collection(collectionName).doc();
    data['id'] = docRef.id;
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(data);
    return docRef.id;
  }

  // ── Update Item ───────────────────────────────────────────────────────────
  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    if (_firestore == null) {
      final index = _defaultItems.indexWhere((i) => i['id'] == id);
      if (index != -1) {
        _defaultItems[index] = {..._defaultItems[index], ...data};
      }
      return;
    }

    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore!.collection(collectionName).doc(id).set(data, SetOptions(merge: true));
  }

  // ── Delete Item ───────────────────────────────────────────────────────────
  Future<void> deleteItem(String id) async {
    if (_firestore == null) {
      _defaultItems.removeWhere((i) => i['id'] == id);
      return;
    }

    await _firestore!.collection(collectionName).doc(id).delete();
  }

  // ── Default Seed Items ───────────────────────────────────────────────────
  static final List<Map<String, dynamic>> _defaultItems = [
    // 🎨 Fan Art
    {
      'id': 'art_01',
      'type': 'fan_art',
      'title': 'Neo-Tokyo Cyberpunk Reimagined',
      'artist': 'Kenji_Art',
      'fandom': 'Anime & Sci-Fi',
      'imageUrl': 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=800',
      'likes': 3420,
      'isLiked': false,
    },
    {
      'id': 'art_02',
      'type': 'fan_art',
      'title': 'Witcher: Kaer Morhen Citadel Sunset',
      'artist': 'GeraltFanatic',
      'fandom': 'Gaming',
      'imageUrl': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800',
      'likes': 5100,
      'isLiked': true,
    },
    {
      'id': 'art_03',
      'type': 'fan_art',
      'title': 'Demon Slayer Water Breathing Form X',
      'artist': 'Tanjiro_Draws',
      'fandom': 'Anime',
      'imageUrl': 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800',
      'likes': 4890,
      'isLiked': false,
    },
    {
      'id': 'art_04',
      'type': 'fan_art',
      'title': 'Star Wars Coruscant Underworld Neon',
      'artist': 'JediArchivist',
      'fandom': 'Sci-Fi & Fantasy',
      'imageUrl': 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800',
      'likes': 2950,
      'isLiked': false,
    },
    {
      'id': 'art_05',
      'type': 'fan_art',
      'title': 'Elden Ring: Erdtree in Golden Bloom',
      'artist': 'TarnishedPainter',
      'fandom': 'Gaming',
      'imageUrl': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800',
      'likes': 6200,
      'isLiked': false,
    },
    {
      'id': 'art_06',
      'type': 'fan_art',
      'title': 'BTS: Permission to Dance Stage Art',
      'artist': 'ARMY_Creative',
      'fandom': 'K-Pop',
      'imageUrl': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
      'likes': 4150,
      'isLiked': false,
    },

    // 🎭 Cosplay
    {
      'id': 'cos_01',
      'type': 'cosplay',
      'title': 'Malenia, Blade of Miquella',
      'character': 'Malenia, Blade of Miquella',
      'cosplayer': 'ValkyrieCrafts',
      'event': 'Tokyo Game Show 2024',
      'fandom': 'Gaming',
      'imageUrl': 'https://images.unsplash.com/photo-1563089145-599997674d42?w=800',
      'award': 'Best Armor Crafting',
    },
    {
      'id': 'cos_02',
      'type': 'cosplay',
      'title': 'Spider-Man 2099 (Miguel O\'Hara)',
      'character': 'Spider-Man 2099 (Miguel O\'Hara)',
      'cosplayer': 'WebHead_Cosplay',
      'event': 'San Diego Comic-Con',
      'fandom': 'Marvel & DC',
      'imageUrl': 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800',
      'award': 'Audience Favorite',
    },
    {
      'id': 'cos_03',
      'type': 'cosplay',
      'title': 'Zero Two — Darling in the FranXX',
      'character': 'Zero Two — Darling in the FranXX',
      'cosplayer': 'SakuraCoscraft',
      'event': 'Anime Expo LA 2024',
      'fandom': 'Anime & Manga',
      'imageUrl': 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800',
      'award': 'Best Character Accuracy',
    },

    // 🎬 Videos
    {
      'id': 'vid_01',
      'type': 'video',
      'title': 'Top 10 Anime Fights of 2024',
      'channel': 'AnimeVault',
      'fandom': 'Anime & Manga',
      'duration': '12:34',
      'views': '2.4M',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800',
      'videoUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      'isBookmarked': false,
    },
    {
      'id': 'vid_02',
      'type': 'video',
      'title': 'Elden Ring Shadow of Erdtree — Full Lore Deep Dive',
      'channel': 'VaatiVidya',
      'fandom': 'Gaming',
      'duration': '45:12',
      'views': '5.1M',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1538481199705-c710c4e965fc?w=800',
      'videoUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      'isBookmarked': true,
    },
    {
      'id': 'vid_03',
      'type': 'video',
      'title': 'Marvel Phase 6 — Everything We Know So Far',
      'channel': 'ComicsExplained',
      'fandom': 'Marvel & DC',
      'duration': '28:47',
      'views': '3.8M',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=800',
      'videoUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      'isBookmarked': false,
    },
    {
      'id': 'vid_04',
      'type': 'video',
      'title': 'BTS Festa 2025 — Behind The Scenes Full Cut',
      'channel': 'BANGTANTV',
      'fandom': 'K-Pop',
      'duration': '18:22',
      'views': '9.2M',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
      'videoUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      'isBookmarked': false,
    },
    {
      'id': 'vid_05',
      'type': 'video',
      'title': 'San Diego Comic-Con 2024 — Official Recap',
      'channel': 'Comic-Con HQ',
      'fandom': 'Comics & Events',
      'duration': '22:08',
      'views': '1.7M',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1612036782180-6f0b6cd846fe?w=800',
      'videoUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      'isBookmarked': false,
    },
    {
      'id': 'vid_06',
      'type': 'video',
      'title': 'Demon Slayer Season 4 — Hashira Training Arc Review',
      'channel': 'AnimeAnalysis',
      'fandom': 'Anime & Manga',
      'duration': '15:55',
      'views': '4.3M',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1553356084-58ef4a67b2a7?w=800',
      'videoUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      'isBookmarked': false,
    },

    // 🎙️ Podcasts
    {
      'id': 'pod_01',
      'type': 'podcast',
      'title': 'The Fandom Verse Podcast — Ep. 47: Anime of the Decade',
      'host': 'Alex Rivera & Mia Chen',
      'fandom': 'Anime & Manga',
      'duration': '1h 12m',
      'episode': 'EP 47',
      'date': 'Sep 18, 2026',
      'coverUrl': 'https://images.unsplash.com/photo-1478737270239-2f02b77fc618?w=400',
      'podcastUrl': 'https://open.spotify.com/show/fandomverse',
      'isPlaying': false,
      'description':
          'We rank the most influential anime of the past decade — from Attack on Titan\'s finale to the Demon Slayer phenomenon. Community votes included.',
    },
    {
      'id': 'pod_02',
      'type': 'podcast',
      'title': 'Lore Lords — Ep. 92: Dark Souls Mythology Explained',
      'host': 'TheOracle & SoulsBorne Wiki',
      'fandom': 'Gaming',
      'duration': '58m',
      'episode': 'EP 92',
      'date': 'Sep 12, 2026',
      'coverUrl': 'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=400',
      'podcastUrl': 'https://open.spotify.com/show/lorelords',
      'isPlaying': false,
      'description':
          'Deep dive into the interconnected mythology of all three Dark Souls games, Elden Ring, and Bloodborne. How does it all fit together?',
    },
    {
      'id': 'pod_03',
      'type': 'podcast',
      'title': 'Marvel Multiverse Weekly — Ep. 31: Secret Wars 2027 Theories',
      'host': 'ComicsKing & NerdAlert',
      'fandom': 'Marvel & DC',
      'duration': '44m',
      'episode': 'EP 31',
      'date': 'Sep 5, 2026',
      'coverUrl': 'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=400',
      'podcastUrl': 'https://open.spotify.com/show/marvelweekly',
      'isPlaying': false,
      'description':
          'We analyze every confirmed and leaked detail about Avengers: Secret Wars — who survives, what earths merge, and what Phase 7 could look like.',
    },
    {
      'id': 'pod_04',
      'type': 'podcast',
      'title': 'K-Pop Chronicle — Ep. 115: Why HYBE Changed Everything',
      'host': 'Hana & JiMin_Analysis',
      'fandom': 'K-Pop',
      'duration': '52m',
      'episode': 'EP 115',
      'date': 'Aug 29, 2026',
      'coverUrl': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
      'podcastUrl': 'https://open.spotify.com/show/kpopchronicle',
      'isPlaying': false,
      'description':
          'From BTS\'s global explosion to the second generation of HYBE artists, we trace how one company restructured the entire K-Pop industry.',
    },
    {
      'id': 'pod_05',
      'type': 'podcast',
      'title': 'Convention Chronicles — Ep. 22: Anime Expo 2026 Full Recap',
      'host': 'FestivalNerd',
      'fandom': 'Events & Cosplay',
      'duration': '38m',
      'episode': 'EP 22',
      'date': 'Aug 20, 2026',
      'coverUrl': 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=400',
      'podcastUrl': 'https://open.spotify.com/show/conchronicles',
      'isPlaying': false,
      'description':
          'Live coverage from the Anime Expo 2026 floor — exclusive announcements, cosplay competition results, and panel highlights.',
    },
  ];
}
