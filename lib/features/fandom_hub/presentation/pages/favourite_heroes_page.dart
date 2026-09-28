import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/comic_ui_widgets.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../../core/database/sqlite_helper.dart';
import '../../domain/entities/hero_story.dart';
import 'hero_story_viewer_page.dart';

class FavouriteHeroesPage extends StatefulWidget {
  const FavouriteHeroesPage({super.key});

  @override
  State<FavouriteHeroesPage> createState() => _FavouriteHeroesPageState();
}

class _FavouriteHeroesPageState extends State<FavouriteHeroesPage> {
  List<HeroStory> _allHeroes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _favoritesOnly = false;
  final Set<String> _favoriteHeroIds = {};
  final TextEditingController _searchController = TextEditingController();

  static const String _favPrefsKey = 'favorite_heroes_ids';

  @override
  void initState() {
    super.initState();
    _loadHeroesAndFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHeroesAndFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedFavs = prefs.getStringList(_favPrefsKey) ?? ['story-spiderman', 'story-batman'];
      _favoriteHeroIds.addAll(savedFavs);

      final rows = await SqliteHelper.instance.getHeroStories();
      final heroes = rows.map((r) => HeroStory.fromMap(r)).toList();

      if (mounted) {
        setState(() {
          _allHeroes = heroes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite(String heroId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteHeroIds.contains(heroId)) {
        _favoriteHeroIds.remove(heroId);
      } else {
        _favoriteHeroIds.add(heroId);
      }
    });
    await prefs.setStringList(_favPrefsKey, _favoriteHeroIds.toList());
  }

  List<HeroStory> get _filteredHeroes {
    return _allHeroes.where((hero) {
      final matchesSearch = _searchQuery.isEmpty ||
          hero.heroName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          hero.tagline.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          hero.powersAndAbilities.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          hero.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' ||
          hero.category.toLowerCase().contains(_selectedCategory.toLowerCase());

      final matchesFavorites = !_favoritesOnly || _favoriteHeroIds.contains(hero.id);

      return matchesSearch && matchesCategory && matchesFavorites;
    }).toList();
  }

  void _openStoryForHero(HeroStory hero) {
    final heroIndex = _allHeroes.indexWhere((h) => h.id == hero.id);
    if (heroIndex == -1) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => HeroStoryViewerPage(
          stories: _allHeroes,
          initialIndex: heroIndex,
        ),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showHeroDetailsSheet(HeroStory hero) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFav = _favoriteHeroIds.contains(hero.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: hero.ringColor.withValues(alpha: 0.25),
                        blurRadius: 30,
                        spreadRadius: 2,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Header with Avatar & Title
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: hero.ringColor, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: hero.ringColor.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: hero.avatarUrl,
                                fit: BoxFit.cover,
                                width: 76,
                                height: 76,
                                placeholder: (_, __) => Container(
                                  color: hero.ringColor.withValues(alpha: 0.2),
                                  child: const Icon(Iconsax.star_1, color: Colors.white54, size: 32),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: hero.ringColor,
                                  child: const Icon(Iconsax.star_1, color: Colors.white, size: 36),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: hero.ringColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: hero.ringColor.withValues(alpha: 0.4)),
                                      ),
                                      child: Text(
                                        hero.category.toUpperCase(),
                                        style: TextStyle(
                                          color: hero.ringColor,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 10,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isFav ? Icons.favorite : Icons.favorite_border,
                                        color: isFav ? AppColors.comicRed : (isDark ? Colors.white60 : Colors.black45),
                                        size: 26,
                                      ),
                                      onPressed: () {
                                        _toggleFavorite(hero.id);
                                        setModalState(() {});
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hero.heroName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                if (hero.firstAppearance.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Debut: ${hero.firstAppearance}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (hero.tagline.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: hero.ringColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border(left: BorderSide(color: hero.ringColor, width: 4)),
                          ),
                          child: Text(
                            '"${hero.tagline}"',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.comicBlack,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Action Button to View Stories
                      SkewedButton(
                        text: 'WATCH HERO STORIES',
                        icon: Iconsax.play_circle,
                        height: 50,
                        fontSize: 12,
                        backgroundColor: hero.ringColor,
                        textColor: Colors.black,
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _openStoryForHero(hero);
                        },
                      ),

                      const SizedBox(height: 24),

                      // Powers & Abilities Section
                      if (hero.powersAndAbilities.isNotEmpty) ...[
                        const Text(
                          'POWERS & ABILITIES',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1,
                            color: AppColors.comicYellow,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            hero.powersAndAbilities,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Origin Backstory Section
                      if (hero.originBackstory.isNotEmpty) ...[
                        const Text(
                          'ORIGIN BACKSTORY',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1,
                            color: AppColors.comicRed,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            hero.originBackstory,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: isDark ? Colors.white70 : AppColors.comicBlack,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Life History Section
                      if (hero.lifeHistory.isNotEmpty) ...[
                        const Text(
                          'LIFE HISTORY & CHRONICLES',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1,
                            color: AppColors.comicBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            hero.lifeHistory,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: isDark ? Colors.white70 : AppColors.comicBlack,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heroes = _filteredHeroes;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'YOUR FAVOURITE HEROES',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 0.8,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _favoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: _favoritesOnly ? AppColors.comicRed : (isDark ? Colors.white : AppColors.comicBlack),
            ),
            tooltip: 'Filter Favorites',
            onPressed: () => setState(() => _favoritesOnly = !_favoritesOnly),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.comicYellow))
          : CustomScrollView(
              slivers: [
                // ── Heroic Header Banner ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(16),
                      borderColor: AppColors.comicYellow.withValues(alpha: 0.5),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.comicYellow.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Iconsax.star_1, color: AppColors.comicYellow, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'HEROES MULTIVERSE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Explore legendary backstories, powers, and chronicles.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.comicRed,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_allHeroes.length} ICONS',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Search Bar ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
                          width: 1.2,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white : AppColors.comicBlack,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search heroes, powers, comics...',
                          hintStyle: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                          prefixIcon: const Icon(Iconsax.search_normal, size: 18),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Category Filter Chips ──
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: ['All', 'Marvel', 'DC', 'Anime', 'Sci-Fi'].map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedCategory = cat),
                            selectedColor: AppColors.comicYellow.withValues(alpha: 0.25),
                            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.comicYellow
                                  : (isDark ? Colors.white70 : AppColors.comicBlack),
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.comicYellow
                                    : (isDark ? AppColors.darkBorder : AppColors.comicBorderColor),
                                width: 1.2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // ── Heroes Grid ──
                if (heroes.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Iconsax.search_status,
                              size: 54,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'No Heroes Found',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Try searching for another hero or reset your filters.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SkewedButton(
                              text: 'Reset Filters',
                              icon: Iconsax.refresh,
                              height: 44,
                              fontSize: 13,
                              backgroundColor: AppColors.comicYellow,
                              textColor: Colors.black,
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _selectedCategory = 'All';
                                  _favoritesOnly = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.62,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final hero = heroes[index];
                          final isFav = _favoriteHeroIds.contains(hero.id);

                          return GestureDetector(
                            onTap: () => _showHeroDetailsSheet(hero),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCard : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: hero.ringColor.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: hero.ringColor.withValues(alpha: 0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── Hero Image (fixed height) ──────────
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                    child: SizedBox(
                                      height: 130,
                                      width: double.infinity,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: hero.avatarUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) => Container(
                                              color: hero.ringColor
                                                  .withValues(alpha: 0.2),
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color:
                                                      AppColors.comicYellow,
                                                ),
                                              ),
                                            ),
                                            errorWidget: (_, __, ___) =>
                                                Container(
                                              color: hero.ringColor
                                                  .withValues(alpha: 0.3),
                                              child: Center(
                                                child: Icon(Iconsax.star_1,
                                                    color: hero.ringColor,
                                                    size: 40),
                                              ),
                                            ),
                                          ),
                                          // Category Pill
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withValues(alpha: 0.75),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: hero.ringColor,
                                                    width: 1),
                                              ),
                                              child: Text(
                                                hero.category
                                                    .split(' ')
                                                    .first
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color: hero.ringColor,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Favourite Button
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  _toggleFavorite(hero.id),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.65),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  isFav
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: isFav
                                                      ? AppColors.comicRed
                                                      : Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // ── Hero Info (Expanded fills remaining height) ──
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 8, 10, 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Name + tagline
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                hero.heroName,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 14,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                hero.tagline.isNotEmpty
                                                    ? hero.tagline
                                                    : hero.category,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  height: 1.3,
                                                  fontStyle: FontStyle.italic,
                                                  color: isDark
                                                      ? AppColors
                                                          .darkTextSecondary
                                                      : AppColors
                                                          .lightTextSecondary,
                                                ),
                                              ),
                                            ],
                                          ),

                                          // View Story button
                                          SkewedButton(
                                            text: 'VIEW STORY',
                                            icon: Iconsax.play,
                                            height: 34,
                                            fontSize: 10,
                                            backgroundColor: hero.ringColor,
                                            textColor: Colors.white,
                                            skewAngle: 0.10,
                                            onPressed: () =>
                                                _openStoryForHero(hero),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: heroes.length,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
