import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/comic_ui_widgets.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../bloc/fandom_hub_bloc.dart';
import '../bloc/fandom_hub_event.dart';
import '../bloc/fandom_hub_state.dart';
import '../../domain/entities/fandom_post.dart';

class AllComicsPage extends StatefulWidget {
  const AllComicsPage({super.key});

  @override
  State<AllComicsPage> createState() => _AllComicsPageState();
}

class _AllComicsPageState extends State<AllComicsPage> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  static const List<String> _categories = [
    'All',
    'Anime & Manga',
    'Marvel & DC Comics',
    'Gaming & Esports',
    'Sci-Fi & Fantasy',
    'K-Pop & Idol Culture',
    'Pop Culture & Movies',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<FandomPost> _buildAllComics(FandomHubLoaded state) {
    // Merge trending + latest, deduplicate by id
    final Map<String, FandomPost> seen = {};
    for (final p in [...state.trendingPosts, ...state.latestNews]) {
      seen[p.id] = p;
    }
    return seen.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<FandomPost> _filtered(List<FandomPost> all) {
    return all.where((p) {
      final matchesCat =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.authorName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const Icon(Iconsax.book, size: 20, color: AppColors.comicRed),
            const SizedBox(width: 8),
            Text(
              'All Comics',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<FandomHubBloc, FandomHubState>(
        builder: (context, state) {
          // ── Loading skeleton ──
          if (state is FandomHubLoading || state is FandomHubInitial) {
            return GridView.builder(
              padding: EdgeInsets.fromLTRB(
                  16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.58,
              ),
              itemCount: 8,
              itemBuilder: (_, __) => const SkeletonLoader(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 14,
              ),
            );
          }

          if (state is! FandomHubLoaded) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.warning_2,
                      size: 48, color: AppColors.comicRed),
                  const SizedBox(height: 12),
                  const Text('Could not load comics.'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context
                        .read<FandomHubBloc>()
                        .add(const LoadFandomHubContentEvent()),
                    icon: const Icon(Iconsax.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final allComics = _buildAllComics(state);
          final filtered = _filtered(allComics);

          return Column(
            children: [
              // ── Search Bar ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Iconsax.search_normal_1, size: 20),
                    hintText: 'Search comics, titles, authors...',
                    hintStyle: const TextStyle(fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Category Filter Chips ──
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.comicRed
                              : (isDark
                                  ? AppColors.darkSurface
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.comicRed
                                : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Count ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} Comics',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Grid ──
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.book,
                                size: 48,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                            const SizedBox(height: 12),
                            Text(
                              'No comics found',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Try a different category or search term',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          4,
                          16,
                          16 + MediaQuery.of(context).padding.bottom,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.58,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final post = filtered[i];
                          return ComicCoverCard(
                            title: post.title,
                            subtitle:
                                '${post.category} • ${post.readTimeMinutes} min',
                            imageUrl: post.imageUrl,
                            publisher: post.authorName,
                            onTap: () => Navigator.of(context).pushNamed(
                              '/news-detail',
                              arguments: post,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
