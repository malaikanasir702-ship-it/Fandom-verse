import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';

class MultimediaGalleryPage extends StatefulWidget {
  const MultimediaGalleryPage({super.key});

  @override
  State<MultimediaGalleryPage> createState() => _MultimediaGalleryPageState();
}

class _MultimediaGalleryPageState extends State<MultimediaGalleryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _artworks = [
    {
      'title': 'Neo-Tokyo Cyberpunk Reimagined',
      'artist': 'Kenji_Art',
      'fandom': 'Anime & Sci-Fi',
      'imageUrl': 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=800',
      'likes': 3420,
      'isLiked': false,
    },
    {
      'title': 'Witcher: Kaer Morhen Citadel Sunset',
      'artist': 'GeraltFanatic',
      'fandom': 'Gaming',
      'imageUrl': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800',
      'likes': 5100,
      'isLiked': true,
    },
    {
      'title': 'Demon Slayer Water Breathing Form X',
      'artist': 'Tanjiro_Draws',
      'fandom': 'Anime',
      'imageUrl': 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800',
      'likes': 4890,
      'isLiked': false,
    },
    {
      'title': 'Star Wars Coruscant Underworld Neon',
      'artist': 'JediArchivist',
      'fandom': 'Sci-Fi & Fantasy',
      'imageUrl': 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800',
      'likes': 2950,
      'isLiked': false,
    },
    {
      'title': 'Elden Ring: Erdtree in Golden Bloom',
      'artist': 'TarnishedPainter',
      'fandom': 'Gaming',
      'imageUrl': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800',
      'likes': 6200,
      'isLiked': false,
    },
    {
      'title': 'BTS: Permission to Dance Stage Art',
      'artist': 'ARMY_Creative',
      'fandom': 'K-Pop',
      'imageUrl': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
      'likes': 4150,
      'isLiked': false,
    },
  ];

  final List<Map<String, dynamic>> _cosplays = [
    {
      'character': 'Malenia, Blade of Miquella',
      'cosplayer': 'ValkyrieCrafts',
      'event': 'Tokyo Game Show 2024',
      'imageUrl': 'https://images.unsplash.com/photo-1563089145-599997674d42?w=800',
      'award': 'Best Armor Crafting',
    },
    {
      'character': 'Spider-Man 2099 (Miguel O\'Hara)',
      'cosplayer': 'WebHead_Cosplay',
      'event': 'San Diego Comic-Con',
      'imageUrl': 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800',
      'award': 'Audience Favorite',
    },
    {
      'character': 'Zero Two — Darling in the FranXX',
      'cosplayer': 'SakuraCoscraft',
      'event': 'Anime Expo LA 2024',
      'imageUrl': 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800',
      'award': 'Best Character Accuracy',
    },
  ];

  // ── Video Clips Data ────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _videoClips = [
    {
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
      'title': 'Demon Slayer Season 4 — Hashira Training Arc Review',
      'channel': 'AnimeAnalysis',
      'fandom': 'Anime & Manga',
      'duration': '15:55',
      'views': '4.3M',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1553356084-58ef4a67b2a7?w=800',
      'videoUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      'isBookmarked': false,
    },
  ];

  // ── Podcasts Data ───────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _podcasts = [
    {
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Multimedia Hub',
            style: TextStyle(fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.comicRed,
          labelColor: AppColors.comicRed,
          unselectedLabelColor:
              isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(icon: Icon(Iconsax.brush_1, size: 18), text: 'Fan Art'),
            Tab(icon: Icon(Iconsax.mask, size: 18), text: 'Cosplay'),
            Tab(icon: Icon(Iconsax.video_play, size: 18), text: 'Videos'),
            Tab(icon: Icon(Iconsax.microphone_2, size: 18), text: 'Podcasts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildArtGrid(isDark),
          _buildCosplayList(isDark),
          _buildVideoClips(isDark),
          _buildPodcasts(isDark),
        ],
      ),
    );
  }

  // ── Fan Art Tab ─────────────────────────────────────────────────────────
  Widget _buildArtGrid(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: _artworks.length,
      itemBuilder: (context, index) {
        final item = _artworks[index];
        final isLiked = item['isLiked'] as bool;
        final likes = item['likes'] as int;

        return GlassContainer(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        item['imageUrl'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.darkSurfaceElevated,
                          child: const Icon(Iconsax.image),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.black.withValues(alpha: 0.6),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Iconsax.heart,
                            size: 16,
                            color: isLiked ? AppColors.comicRed : Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              item['isLiked'] = !isLiked;
                              item['likes'] =
                                  isLiked ? likes - 1 : likes + 1;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['fandom'] as String,
                      style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.comicRed,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['title'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'by ${item['artist']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Iconsax.heart,
                                size: 12, color: AppColors.comicRed),
                            const SizedBox(width: 4),
                            Text(
                              '${item['likes']}',
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Cosplay Tab ─────────────────────────────────────────────────────────
  Widget _buildCosplayList(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _cosplays.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final c = _cosplays[index];
        return GlassContainer(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 220,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    c['imageUrl'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.darkSurfaceElevated,
                      child: const Icon(Iconsax.mask, size: 48),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.darkAccentGold
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Iconsax.award,
                                  size: 13,
                                  color: AppColors.darkAccentGold),
                              const SizedBox(width: 4),
                              Text(
                                c['award'] as String,
                                style: const TextStyle(
                                  color: AppColors.darkAccentGold,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          c['event'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c['character'] as String,
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cosplayer: ${c['cosplayer']}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Video Clips Tab ─────────────────────────────────────────────────────
  Widget _buildVideoClips(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _videoClips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final v = _videoClips[index];
        final isBookmarked = v['isBookmarked'] as bool;

        return GestureDetector(
          onTap: () => _launchUrl(v['videoUrl'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail with play overlay
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          v['thumbnailUrl'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.darkSurfaceElevated,
                            child: const Icon(Iconsax.video_play,
                                size: 48, color: Colors.white30),
                          ),
                        ),
                      ),
                    ),
                    // Play button overlay
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Iconsax.play,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                    // Duration badge
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          v['duration'] as String,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // Fandom tag
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.comicRed.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          v['fandom'] as String,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),

                // Video info
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v['title'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                height: 1.3,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Iconsax.video,
                                    size: 13, color: AppColors.comicRed),
                                const SizedBox(width: 4),
                                Text(
                                  v['channel'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(Iconsax.eye,
                                    size: 13, color: AppColors.comicYellowDark),
                                const SizedBox(width: 4),
                                Text(
                                  '${v['views']} views',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isBookmarked
                              ? Iconsax.bookmark
                              : Iconsax.bookmark_2,
                          size: 20,
                          color: isBookmarked
                              ? AppColors.comicYellow
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                        ),
                        onPressed: () {
                          setState(() {
                            v['isBookmarked'] = !isBookmarked;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Podcasts Tab ────────────────────────────────────────────────────────
  Widget _buildPodcasts(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _podcasts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final p = _podcasts[index];
        final isPlaying = p['isPlaying'] as bool;

        return GlassContainer(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Podcast cover art
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      p['coverUrl'] as String,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 72,
                        height: 72,
                        color: AppColors.darkSurfaceElevated,
                        child: const Icon(Iconsax.microphone_2,
                            size: 32, color: Colors.white54),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Episode + fandom badge row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.comicRed
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                p['episode'] as String,
                                style: const TextStyle(
                                    color: AppColors.comicRed,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                p['fandom'] as String,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          p['title'] as String,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            height: 1.3,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Iconsax.people,
                                size: 12, color: AppColors.comicYellowDark),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                p['host'] as String,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Description
              Text(
                p['description'] as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),

              const SizedBox(height: 12),

              // Bottom bar: duration, date, play button
              Row(
                children: [
                  const Icon(Iconsax.timer_1,
                      size: 14, color: AppColors.comicRed),
                  const SizedBox(width: 4),
                  Text(
                    p['duration'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Iconsax.calendar_1,
                      size: 14,
                      color: AppColors.comicYellowDark),
                  const SizedBox(width: 4),
                  Text(
                    p['date'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const Spacer(),
                  // Play / Listen button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        // Pause all other episodes, toggle this one
                        for (final ep in _podcasts) {
                          ep['isPlaying'] = false;
                        }
                        p['isPlaying'] = !isPlaying;
                      });
                      if (!isPlaying) {
                        _launchUrl(p['podcastUrl'] as String);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isPlaying
                            ? AppColors.comicRed
                            : (isDark
                                ? AppColors.darkSurfaceElevated
                                : AppColors.lightSurface),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isPlaying
                              ? AppColors.comicRed
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPlaying
                                ? Iconsax.pause
                                : Iconsax.play,
                            size: 15,
                            color: isPlaying
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isPlaying ? 'Pause' : 'Listen',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isPlaying
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
