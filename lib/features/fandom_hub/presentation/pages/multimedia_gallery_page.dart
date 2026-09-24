import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';

class MultimediaGalleryPage extends StatefulWidget {
  const MultimediaGalleryPage({super.key});

  @override
  State<MultimediaGalleryPage> createState() => _MultimediaGalleryPageState();
}

class _MultimediaGalleryPageState extends State<MultimediaGalleryPage> with SingleTickerProviderStateMixin {
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
      'artist': 'TarnishedBrush',
      'fandom': 'Gaming',
      'imageUrl': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800',
      'likes': 6200,
      'isLiked': true,
    },
    {
      'title': 'K-Pop Cyber Hologram Stage Concept',
      'artist': 'SeoulVisuals',
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
      'award': 'Best Armor Crafting 🏆',
    },
    {
      'character': 'Spider-Man 2099 (Miguel O\'Hara)',
      'cosplayer': 'WebHead_Cosplay',
      'event': 'San Diego Comic-Con',
      'imageUrl': 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800',
      'award': 'Audience Favorite 🌟',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Multimedia & Gallery', style: TextStyle(fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.darkSecondary,
          labelColor: AppColors.darkSecondary,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.brush_rounded), text: 'Fan Art Gallery'),
            Tab(icon: Icon(Icons.theater_comedy_rounded), text: 'Cosplay Spotlight'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Fan Art Tab
          _buildArtGrid(isDark),

          // Cosplay Tab
          _buildCosplayList(isDark),
        ],
      ),
    );
  }

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
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        item['imageUrl'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.darkSurfaceElevated,
                          child: const Icon(Icons.image_not_supported_rounded),
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
                            isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 16,
                            color: isLiked ? Colors.redAccent : Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              item['isLiked'] = !isLiked;
                              item['likes'] = isLiked ? likes - 1 : likes + 1;
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
                        color: AppColors.darkPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['title'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'by ${item['artist']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        Text(
                          '❤️ ${item['likes']}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    c['imageUrl'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.darkSurfaceElevated,
                      child: const Icon(Icons.theater_comedy_rounded, size: 48),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.darkAccentGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            c['award'] as String,
                            style: const TextStyle(
                              color: AppColors.darkAccentGold,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Text(
                          c['event'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c['character'] as String,
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cosplayer: ${c['cosplayer']}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
}
