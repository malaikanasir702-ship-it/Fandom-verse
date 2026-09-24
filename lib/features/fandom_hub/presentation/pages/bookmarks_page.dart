import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../bloc/fandom_hub_bloc.dart';
import '../bloc/fandom_hub_state.dart';

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
      appBar: AppBar(
        title: const Text('Saved Items', style: TextStyle(fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.darkSecondary,
          labelColor: AppColors.darkSecondary,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          tabs: const [
            Tab(text: '📖 Glossary'),
            Tab(text: '🗓️ Events'),
            Tab(text: '🗞️ News'),
          ],
        ),
      ),
      body: BlocBuilder<FandomHubBloc, FandomHubState>(
        builder: (context, state) {
          if (state is! FandomHubLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookmarkedGlossary = state.glossary.where((g) => g.isBookmarked).toList();
          final bookmarkedPosts = state.latestNews.where((p) => p.isBookmarked).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              // Glossary bookmarks
              bookmarkedGlossary.isEmpty
                  ? _EmptyBookmark(label: 'No glossary terms saved yet.\nGo to Lore Hub → Glossary and bookmark terms!')
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: bookmarkedGlossary.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final term = bookmarkedGlossary[i];
                        return GlassContainer(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                term.term,
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.darkSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(term.definition, style: AppTextStyles.bodySmall.copyWith(height: 1.5)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.darkPrimary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('📌 ${term.fandomCategory}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.darkPrimary, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

              // Events bookmarks
              const _EventBookmarksTab(),

              // News bookmarks
              bookmarkedPosts.isEmpty
                  ? _EmptyBookmark(label: 'No news articles saved.\nTap the bookmark icon on any news card!')
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: bookmarkedPosts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final post = bookmarkedPosts[i];
                        return GlassContainer(
                          padding: const EdgeInsets.all(12),
                          onTap: () => Navigator.of(context).pushNamed('/news-detail', arguments: post),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  post.imageUrl,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                      width: 64, height: 64, color: AppColors.darkSurface),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(post.category,
                                        style: const TextStyle(
                                            color: AppColors.darkPrimary, fontSize: 11, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 4),
                                    Text(post.title,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, height: 1.3),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text('${post.readTimeMinutes} min read',
                                        style: const TextStyle(fontSize: 11, color: AppColors.darkTextSecondary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ],
          );
        },
      ),
    );
  }
}

class _EventBookmarksTab extends StatelessWidget {
  const _EventBookmarksTab();

  @override
  Widget build(BuildContext context) {
    // Using a placeholder since EventBloc is separate
    return _EmptyBookmark(
        label: 'Bookmarked events appear here.\nGo to Event Radar and bookmark events!');
  }
}

class _EmptyBookmark extends StatelessWidget {
  final String label;
  const _EmptyBookmark({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔖', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
