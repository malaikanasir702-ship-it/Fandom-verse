import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/fandom_hub_bloc.dart';
import '../bloc/fandom_hub_event.dart';
import '../bloc/fandom_hub_state.dart';
import '../../domain/entities/fandom_post.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        title: const Text(
          'SAVED ITEMS',
          style: TextStyle(fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.comicRed,
          labelColor: AppColors.comicRed,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.comicGray,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          tabs: const [
            Tab(text: 'COMICS & LORE'),
            Tab(text: 'GLOSSARY'),
            Tab(text: 'EVENTS'),
          ],
        ),
      ),
      body: BlocBuilder<FandomHubBloc, FandomHubState>(
        builder: (context, state) {
          if (state is! FandomHubLoaded) {
            return const Center(child: CircularProgressIndicator(color: AppColors.comicRed));
          }

          // Combine and deduplicate saved posts from latestNews and trendingPosts
          final Map<String, FandomPost> savedPostsMap = {};
          for (final post in state.latestNews) {
            if (post.isBookmarked) savedPostsMap[post.id] = post;
          }
          for (final post in state.trendingPosts) {
            if (post.isBookmarked) savedPostsMap[post.id] = post;
          }
          final bookmarkedPosts = savedPostsMap.values.toList();
          final bookmarkedGlossary = state.glossary.where((g) => g.isBookmarked).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              // ─── TAB 1: COMICS & LORE (DEFAULT) ───
              bookmarkedPosts.isEmpty
                  ? const _EmptyBookmark(
                      icon: Iconsax.book,
                      title: 'No Comics or Lore Saved',
                      subtitle: 'Tap the "SAVE" button on any comic or news article to read it offline anytime!',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: bookmarkedPosts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final post = bookmarkedPosts[i];
                        return GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed('/news-detail', arguments: post),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    post.imageUrl,
                                    width: 74,
                                    height: 74,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 74,
                                      height: 74,
                                      color: AppColors.comicGrayLight,
                                      child: const Icon(Iconsax.book, color: AppColors.comicGray),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.comicRed,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          post.category.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        post.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          height: 1.25,
                                          color: isDark ? Colors.white : AppColors.comicBlack,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${post.readTimeMinutes} min read • Tap to view',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.comicGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Remove Bookmark Button
                                IconButton(
                                  icon: const Icon(Iconsax.bookmark, color: AppColors.comicRed, size: 20),
                                  tooltip: 'Remove',
                                  onPressed: () {
                                    context.read<FandomHubBloc>().add(ToggleBookmarkPostEvent(post.id));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Removed from saved items.'),
                                        backgroundColor: AppColors.comicBlack,
                                        behavior: SnackBarBehavior.floating,
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

              // ─── TAB 2: GLOSSARY ───
              bookmarkedGlossary.isEmpty
                  ? const _EmptyBookmark(
                      icon: Iconsax.book_1,
                      title: 'No Glossary Terms Saved',
                      subtitle: 'Go to Lore Hub → Glossary to bookmark fandom terms & definitions!',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: bookmarkedGlossary.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final term = bookmarkedGlossary[i];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    term.term,
                                    style: const TextStyle(
                                      color: AppColors.comicRed,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Iconsax.bookmark, color: AppColors.comicRed, size: 18),
                                    onPressed: () {
                                      context.read<FandomHubBloc>().add(ToggleBookmarkGlossaryEvent(term.id));
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                term.definition,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: isDark ? Colors.white70 : AppColors.comicBlack,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.comicYellow,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  term.fandomCategory.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: AppColors.comicBlack,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

              // ─── TAB 3: EVENTS ───
              const _EmptyBookmark(
                icon: Iconsax.calendar,
                title: 'No Events Saved',
                subtitle: 'Go to Events Calendar or Event Radar to bookmark exciting fandom cons!',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyBookmark extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyBookmark({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.comicYellow,
              ),
              child: Icon(icon, size: 34, color: AppColors.comicBlack),
            ),
            const SizedBox(height: 16),
            Text(
              title.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.comicGray,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
