import 'package:flutter/material.dart';

/// A single fandom hero with multiple story images.
class HeroStory {
  final String heroName;
  final String category;
  final String avatarUrl;
  final Color ringColor;
  final List<HeroStorySlide> slides;
  bool seen;

  HeroStory({
    required this.heroName,
    required this.category,
    required this.avatarUrl,
    required this.ringColor,
    required this.slides,
    this.seen = false,
  });
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
}
