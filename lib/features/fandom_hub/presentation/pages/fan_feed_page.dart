import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../bloc/fandom_hub_bloc.dart';
import '../bloc/fandom_hub_state.dart';
import '../../domain/entities/fandom_post.dart';

class FanFeedPage extends StatelessWidget {
  const FanFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FandomHubBloc, FandomHubState>(
      builder: (context, state) {
        if (state is FandomHubLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FandomHubLoaded) {
          return _FanFeedContent(state: state);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _FanFeedContent extends StatelessWidget {
  final FandomHubLoaded state;
  const _FanFeedContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        // ─── SliverAppBar: Greeting + Search ───
        SliverAppBar(
          floating: true,
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          expandedHeight: 110,
          flexibleSpace: FlexibleSpaceBar(
            background: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Morning, Fan! 👋',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            Text(
                              'Fandom Verse',
                              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        // Avatar
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed('/profile'),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [AppColors.darkPrimary, AppColors.darkSecondary],
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Search Bar
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/search'),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            Icon(
                              Icons.search_rounded,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Search lore, events, merch...',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Trending Fandoms Carousel ───
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('🔥 Trending Now', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See All', style: TextStyle(color: AppColors.darkSecondary)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 210,
                child: PageView.builder(
                  padEnds: false,
                  controller: PageController(viewportFraction: 0.88),
                  itemCount: state.trendingPosts.length,
                  itemBuilder: (context, index) {
                    final post = state.trendingPosts[index];
                    return _TrendingBannerCard(post: post);
                  },
                ),
              ),

              // ─── Quick Access Chips ───
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('⚡ Quick Access', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _QuickChip(
                      icon: Icons.school_rounded,
                      label: 'Beginner Hub',
                      color: AppColors.darkPrimary,
                      onTap: () => Navigator.of(context).pushNamed('/beginner-hub'),
                    ),
                    const SizedBox(width: 10),
                    _QuickChip(
                      icon: Icons.quiz_rounded,
                      label: 'Trivia Challenge',
                      color: AppColors.darkAccentGold,
                      onTap: () => _showTriviaDialog(context),
                    ),
                    const SizedBox(width: 10),
                    _QuickChip(
                      icon: Icons.radar_rounded,
                      label: 'Event Radar',
                      color: AppColors.darkSecondary,
                      onTap: () => Navigator.of(context).pushNamed('/events-map'),
                    ),
                    const SizedBox(width: 10),
                    _QuickChip(
                      icon: Icons.smart_toy_rounded,
                      label: 'AI Assistant',
                      color: AppColors.success,
                      onTap: () => Navigator.of(context).pushNamed('/ai-assistant'),
                    ),
                    const SizedBox(width: 10),
                    _QuickChip(
                      icon: Icons.shopping_bag_rounded,
                      label: 'Merch Store',
                      color: Colors.orangeAccent,
                      onTap: () => Navigator.of(context).pushNamed('/store'),
                    ),
                    const SizedBox(width: 10),
                    _QuickChip(
                      icon: Icons.shield_rounded,
                      label: 'Admin Portal',
                      color: AppColors.darkAccentGold,
                      onTap: () => Navigator.of(context).pushNamed('/admin-dashboard'),
                    ),
                  ],
                ),
              ),

              // ─── Latest Fandom News ───
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('📰 Latest News', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/multimedia'),
                      child: const Text('All Articles', style: TextStyle(color: AppColors.darkSecondary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...state.latestNews.map((post) => _NewsCard(post: post)),

              // ─── Community Spotlight ───
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('💬 Community Spotlight', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.darkPrimary.withValues(alpha: 0.2),
                            ),
                            child: const Center(child: Text('🏆', style: TextStyle(fontSize: 16))),
                          ),
                          const SizedBox(width: 10),
                          const Text('Top Discussion Today', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'House of the Dragon: The Real Meaning of Aegon\'s Prophecy',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '142 upvotes • 2 replies • #Sci-Fi & Fantasy',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pushNamed('/discussions'),
                          child: const Text('Join Discussion →', style: TextStyle(color: AppColors.darkSecondary)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  void _showTriviaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚡ Quick Trivia Challenge'),
        content: const Text(
          'In Dragon Ball Z, who was the first mortal to defeat Son Goku in combat?\n\nA) Vegeta\nB) Master Roshi (Jackie Chun)\nC) Yamcha\nD) Tien Shinhan',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 Correct! +50 Trivia XP earned!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Answer: B'),
          ),
        ],
      ),
    );
  }
}

class _TrendingBannerCard extends StatelessWidget {
  final FandomPost post;
  const _TrendingBannerCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(post.imageUrl),
          fit: BoxFit.cover,
          onError: (_, __) {},
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.82)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.darkPrimary.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                post.category.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              post.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${post.readTimeMinutes} min read • ${post.authorName}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final FandomPost post;
  const _NewsCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/news-detail', arguments: post),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: AppColors.darkSurfaceElevated,
                  child: const Icon(Icons.image_rounded, color: Colors.white30),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      post.category,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.darkPrimary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${post.readTimeMinutes} min read',
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
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
