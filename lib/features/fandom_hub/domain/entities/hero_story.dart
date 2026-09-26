import 'dart:convert';
import 'package:flutter/material.dart';

/// A single fandom hero with multiple story images and deep origin & life history.
class HeroStory {
  final String id;
  final String heroName;
  final String category;
  final String avatarUrl;
  final Color ringColor;
  final String ringColorHex;
  final String tagline;
  final String originBackstory;
  final String lifeHistory;
  final String powersAndAbilities;
  final String firstAppearance;
  final List<HeroStorySlide> slides;
  bool seen;
  final int createdAt;

  HeroStory({
    String? id,
    required this.heroName,
    required this.category,
    required this.avatarUrl,
    Color? ringColor,
    String? ringColorHex,
    this.tagline = '',
    this.originBackstory = '',
    this.lifeHistory = '',
    this.powersAndAbilities = '',
    this.firstAppearance = '',
    required this.slides,
    this.seen = false,
    int? createdAt,
  })  : id = id ?? 'story-${heroName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
        ringColorHex = ringColorHex ?? _colorToHex(ringColor ?? const Color(0xFFE51924)),
        ringColor = ringColor ?? _hexToColor(ringColorHex ?? '#E51924'),
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  static Color _hexToColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '').trim();
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      } else if (clean.length == 8) {
        return Color(int.parse(clean, radix: 16));
      }
    } catch (_) {}
    return const Color(0xFFE51924);
  }

  HeroStory copyWith({
    String? id,
    String? heroName,
    String? category,
    String? avatarUrl,
    Color? ringColor,
    String? ringColorHex,
    String? tagline,
    String? originBackstory,
    String? lifeHistory,
    String? powersAndAbilities,
    String? firstAppearance,
    List<HeroStorySlide>? slides,
    bool? seen,
    int? createdAt,
  }) {
    return HeroStory(
      id: id ?? this.id,
      heroName: heroName ?? this.heroName,
      category: category ?? this.category,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      ringColor: ringColor ?? this.ringColor,
      ringColorHex: ringColorHex ?? this.ringColorHex,
      tagline: tagline ?? this.tagline,
      originBackstory: originBackstory ?? this.originBackstory,
      lifeHistory: lifeHistory ?? this.lifeHistory,
      powersAndAbilities: powersAndAbilities ?? this.powersAndAbilities,
      firstAppearance: firstAppearance ?? this.firstAppearance,
      slides: slides ?? this.slides,
      seen: seen ?? this.seen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'story_id': id,
      'hero_name': heroName,
      'category': category,
      'avatar_url': avatarUrl,
      'ring_color_hex': ringColorHex,
      'tagline': tagline,
      'origin_backstory': originBackstory,
      'life_history': lifeHistory,
      'powers_abilities': powersAndAbilities,
      'first_appearance': firstAppearance,
      'slides_json': jsonEncode(slides.map((s) => s.toMap()).toList()),
      'created_at': createdAt,
    };
  }

  factory HeroStory.fromMap(Map<String, dynamic> map) {
    List<HeroStorySlide> parsedSlides = [];
    final rawSlides = map['slides_json'] ?? map['slides'];

    if (rawSlides is String && rawSlides.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawSlides);
        if (decoded is List) {
          parsedSlides = decoded
              .map((item) => HeroStorySlide.fromMap(Map<String, dynamic>.from(item as Map)))
              .toList();
        }
      } catch (_) {}
    } else if (rawSlides is List) {
      parsedSlides = rawSlides
          .map((item) => HeroStorySlide.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    final hex = (map['ring_color_hex'] ?? map['color_hex'] ?? '#E51924').toString();

    return HeroStory(
      id: (map['story_id'] ?? map['id'] ?? '').toString(),
      heroName: (map['hero_name'] ?? map['heroName'] ?? '').toString(),
      category: (map['category'] ?? '').toString(),
      avatarUrl: (map['avatar_url'] ?? map['avatarUrl'] ?? '').toString(),
      ringColorHex: hex,
      ringColor: _hexToColor(hex),
      tagline: (map['tagline'] ?? '').toString(),
      originBackstory: (map['origin_backstory'] ?? map['originBackstory'] ?? '').toString(),
      lifeHistory: (map['life_history'] ?? map['lifeHistory'] ?? '').toString(),
      powersAndAbilities: (map['powers_abilities'] ?? map['powersAndAbilities'] ?? '').toString(),
      firstAppearance: (map['first_appearance'] ?? map['firstAppearance'] ?? '').toString(),
      slides: parsedSlides,
      seen: map['seen'] == 1 || map['seen'] == true,
      createdAt: (map['created_at'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}

class HeroStorySlide {
  final String imageUrl;
  final String caption;
  final String tag; // e.g. "#SpiderMan", "#Anime"

  const HeroStorySlide({
    required this.imageUrl,
    required this.caption,
    required this.tag,
  });

  Map<String, dynamic> toMap() => {
        'imageUrl': imageUrl,
        'caption': caption,
        'tag': tag,
      };

  factory HeroStorySlide.fromMap(Map<String, dynamic> map) => HeroStorySlide(
        imageUrl: (map['imageUrl'] ?? map['image_url'] ?? '').toString(),
        caption: (map['caption'] ?? '').toString(),
        tag: (map['tag'] ?? '').toString(),
      );
}
