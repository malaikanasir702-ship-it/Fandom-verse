import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../data/fandom_mock_data.dart';
import '../../domain/entities/fandom_post.dart';
import '../../domain/entities/glossary_term.dart';

class SearchExplorePage extends StatefulWidget {
  const SearchExplorePage({super.key});

  @override
  State<SearchExplorePage> createState() => _SearchExplorePageState();
}

class _SearchExplorePageState extends State<SearchExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  String _activeQuery = '';
  String _selectedCategory = 'All';

  final List<String> _recentSearches = [
    'Marvel Earth-616',
    'Demon Slayer Infinity Castle',
    'Comic-Con San Diego',
    'Elden Ring Shadow of Erdtree',
    'BTS Festa 2025',
  ];

  final List<String> _categories = [
    'All',
    'Anime',
    'Gaming',
    'Marvel/DC',
    'K-Pop',
    'Fantasy',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<FandomPost> matchedPosts = FandomMockData.trendingPosts.where((post) {
      final matchesQuery = _activeQuery.isEmpty ||
          post.title.toLowerCase().contains(_activeQuery.toLowerCase()) ||
          post.summary.toLowerCase().contains(_activeQuery.toLowerCase()) ||
          post.category.toLowerCase().contains(_activeQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' ||
          post.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      return matchesQuery && matchesCategory;
    }).toList();

    final List<GlossaryTerm> matchedGlossary = FandomMockData.glossaryTerms.where((term) {
      return _activeQuery.isNotEmpty &&
          (term.term.toLowerCase().contains(_activeQuery.toLowerCase()) ||
              term.definition.toLowerCase().contains(_activeQuery.toLowerCase()));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (val) {
              setState(() {
                _activeQuery = val.trim();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search lore, characters, events...',
              prefixIcon: const Icon(Iconsax.search_normal_1, size: 20),
              suffixIcon: _activeQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Iconsax.close_circle, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _activeQuery = '';
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    selectedColor: isDark
                        ? AppColors.darkSecondary.withValues(alpha: 0.25)
                        : AppColors.lightPrimary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? (isDark ? AppColors.darkSecondary : AppColors.lightPrimary)
                          : null,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: _activeQuery.isEmpty
                ? _buildRecentSearches(isDark)
                : _buildSearchResults(isDark, matchedPosts, matchedGlossary),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Iconsax.clock, size: 18, color: AppColors.comicRed),
                const SizedBox(width: 8),
                Text(
                  'Recent Searches',
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _recentSearches.clear();
                });
              },
              child: const Text('Clear All', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._recentSearches.map((term) => ListTile(
              leading: const Icon(Iconsax.clock, size: 18),
              title: Text(term, style: const TextStyle(fontSize: 14)),
              trailing: const Icon(Iconsax.arrow_right_3, size: 16),
              onTap: () {
                _searchController.text = term;
                setState(() {
                  _activeQuery = term;
                });
              },
            )),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Iconsax.flash_1, size: 18, color: AppColors.comicYellow),
            const SizedBox(width: 8),
            Text(
              'Popular Fandom Tags',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            '#DragonBall',
            '#MCUPhase6',
            '#DemonSlayer',
            '#EldenRingDLC',
            '#BTSArmy',
            '#StarWarsAcolyte',
            '#FateGrandOrder',
          ].map((tag) => ActionChip(
                label: Text(tag),
                onPressed: () {
                  final query = tag.replaceAll('#', '');
                  _searchController.text = query;
                  setState(() {
                    _activeQuery = query;
                  });
                },
              )).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchResults(
    bool isDark,
    List<FandomPost> posts,
    List<GlossaryTerm> glossary,
  ) {
    if (posts.isEmpty && glossary.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.search_status, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'No universe found for "$_activeQuery"',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'Try searching with another character, universe, or lore tag.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (glossary.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Iconsax.book, size: 18, color: AppColors.comicRed),
              const SizedBox(width: 8),
              Text(
                'Lore Glossary Matches (${glossary.length})',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...glossary.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GlassContainer(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            g.term,
                            style: const TextStyle(
                              color: AppColors.comicRed,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.comicRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              g.fandomCategory,
                              style: const TextStyle(fontSize: 10, color: AppColors.comicRed),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        g.definition,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 20),
        ],

        if (posts.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Iconsax.document_text, size: 18, color: AppColors.comicRed),
              const SizedBox(width: 8),
              Text(
                'Articles & Guides (${posts.length})',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...posts.map((post) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassContainer(
                  onTap: () {
                    Navigator.of(context).pushNamed('/news-detail', arguments: post);
                  },
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          post.imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey.withValues(alpha: 0.2),
                            child: const Icon(Iconsax.image),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.category,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.darkPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              post.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${post.readTimeMinutes} min read • By ${post.authorName}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ],
    );
  }
}
