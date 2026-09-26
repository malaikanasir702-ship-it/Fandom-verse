import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/comic_ui_widgets.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../../core/database/sqlite_helper.dart';
import '../bloc/fandom_hub_bloc.dart';
import '../bloc/fandom_hub_state.dart';
import '../../domain/entities/fandom_post.dart';
import '../../domain/entities/hero_story.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../widgets/hero_story_ring.dart';
import 'hero_story_viewer_page.dart';

class FanFeedPage extends StatelessWidget {
  const FanFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FandomHubBloc, FandomHubState>(
      builder: (context, state) {
        if (state is FandomHubLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.comicRed));
        }
        if (state is FandomHubLoaded) {
          return _FanFeedContent(state: state);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _FanFeedContent extends StatefulWidget {
  final FandomHubLoaded state;
  const _FanFeedContent({required this.state});

  @override
  State<_FanFeedContent> createState() => _FanFeedContentState();
}

class _FanFeedContentState extends State<_FanFeedContent> {
  List<HeroStory> _stories = [];
  bool _storiesLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadHeroStories();
  }

  Future<void> _loadHeroStories() async {
    try {
      final rows = await SqliteHelper.instance.getHeroStories();
      final stories = rows.map((r) => HeroStory.fromMap(r)).toList();
      if (mounted) {
        setState(() {
          _stories = stories;
          _storiesLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _storiesLoaded = true);
    }
  }

  void _openStory(int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => HeroStoryViewerPage(
          stories: _stories,
          initialIndex: index,
        ),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ).then((_) {
      // Refresh rings after returning from story viewer
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final featuredPost = state.trendingPosts.isNotEmpty
        ? state.trendingPosts.first
        : (state.latestNews.isNotEmpty ? state.latestNews.first : null);

    final currentUser = context.watch<AuthBloc>().currentUser;
    final hasAvatar = currentUser?.avatarUrl != null && currentUser!.avatarUrl!.trim().isNotEmpty;

    return CustomScrollView(
      slivers: [
        // ─── Comic Header Bar ───
        SliverAppBar(
          floating: true,
          automaticallyImplyLeading: false,
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          expandedHeight: 80,
          flexibleSpace: FlexibleSpaceBar(
            background: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Comic Brand Title
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'POCKET EDITION',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: isDark ? AppColors.comicYellow : AppColors.comicRed,
                          ),
                        ),
                        Text(
                          'FANDOM VERSE',
                          style: AppTextStyles.comicSectionHeader.copyWith(
                            fontSize: 22,
                            color: isDark ? Colors.white : AppColors.comicBlack,
                          ),
                        ),
                      ],
                    ),
                    // Action Icons: Search & Profile (Iconsax)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed('/search'),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
                                width: 1.2,
                              ),
                            ),
                            child: Icon(
                              Iconsax.search_normal,
                              size: 18,
                              color: isDark ? Colors.white : AppColors.comicBlack,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed('/profile'),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.comicRed,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.comicYellow,
                                width: 1.5,
                              ),
                            ),
                            child: ClipOval(
                              child: hasAvatar
                                  ? Image.network(
                                      currentUser.avatarUrl!,
                                      fit: BoxFit.cover,
                                      width: 38,
                                      height: 38,
                                      errorBuilder: (_, __, ___) => const Center(
                                        child: Icon(Iconsax.user, color: Colors.white, size: 18),
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(Iconsax.user, color: Colors.white, size: 18),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ─── Main Comic Feed Body ───
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP DYNAMIC HERO BANNER (Left Mockup Style)
              if (featuredPost != null)
                HeroPopOutBanner(
                  title: featuredPost.title,
                  subtitle: '${featuredPost.category.toUpperCase()} • ${featuredPost.authorName}',
                  imageUrl: featuredPost.imageUrl,
                  rating: 9.2,
                  badgeText: 'READ NOW',
                  onTap: () => Navigator.of(context).pushNamed('/news-detail', arguments: featuredPost),
                ),

              const SizedBox(height: 12),

              // 2. YOUR FAVOURITE HEROES — Instagram-style Stories
              ComicSectionHeader(
                title: 'YOUR FAVOURITE HEROES',
                actionColor: AppColors.comicYellow,
                onActionTap: () => Navigator.of(context).pushNamed('/community'),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 112,
                child: !_storiesLoaded
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.comicYellow,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: _stories.length,
                        itemBuilder: (context, index) {
                          return HeroStoryRing(
                            story: _stories[index],
                            onTap: () => _openStory(index),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 16),

              // 3. TOP RATED COMICS (Image Section 2)
              ComicSectionHeader(
                title: 'TOP RATED COMICS',
                actionColor: AppColors.comicYellow,
                onActionTap: () => Navigator.of(context).pushNamed('/multimedia'),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 275,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: state.trendingPosts.length,
                  itemBuilder: (context, index) {
                    final post = state.trendingPosts[index];
                    return ComicCoverCard(
                      title: post.title,
                      subtitle: '${post.category} • ${post.readTimeMinutes} min',
                      imageUrl: post.imageUrl,
                      rating: 8.5 + (index % 5) * 0.2,
                      publisher: post.category.length > 6 ? post.category.substring(0, 6) : post.category,
                      onTap: () => Navigator.of(context).pushNamed('/news-detail', arguments: post),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // 4. QUICK ACCESS CHIPS (Iconsax icons)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Iconsax.flash, size: 18, color: AppColors.comicYellow),
                    const SizedBox(width: 6),
                    Text(
                      'QUICK ACCESS',
                      style: AppTextStyles.comicSectionHeader.copyWith(
                        fontSize: 16,
                        color: isDark ? Colors.white : AppColors.comicBlack,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _SolidQuickChip(
                      icon: Iconsax.book,
                      label: 'Beginner Hub',
                      color: AppColors.comicRed,
                      onTap: () => Navigator.of(context).pushNamed('/beginner-hub'),
                    ),
                    const SizedBox(width: 10),
                    _SolidQuickChip(
                      icon: Iconsax.cup,
                      label: 'Trivia Challenge',
                      color: AppColors.comicYellowDark,
                      onTap: () => _showTriviaDialog(context),
                    ),
                    const SizedBox(width: 10),
                    _SolidQuickChip(
                      icon: Iconsax.radar,
                      label: 'Event Radar',
                      color: AppColors.heroBlue,
                      onTap: () => Navigator.of(context).pushNamed('/events-map'),
                    ),
                    const SizedBox(width: 10),
                    _SolidQuickChip(
                      icon: Iconsax.lamp_on,
                      label: 'AI Assistant',
                      color: AppColors.heroGreen,
                      onTap: () => Navigator.of(context).pushNamed('/ai-assistant'),
                    ),
                    const SizedBox(width: 10),
                    _SolidQuickChip(
                      icon: Iconsax.shop,
                      label: 'Merch Store',
                      color: AppColors.heroPurple,
                      onTap: () => Navigator.of(context).pushNamed('/store'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 5. LATEST ISSUES & LORE (Solid Card list)
              ComicSectionHeader(
                title: 'LATEST LORE & ISSUES',
                actionColor: AppColors.comicYellow,
                onActionTap: () => Navigator.of(context).pushNamed('/multimedia'),
              ),
              const SizedBox(height: 8),
              ...state.latestNews.map((post) => _SolidNewsCard(post: post)),

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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.comicBorderColor, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Iconsax.cup, color: AppColors.comicYellow, size: 26),
            SizedBox(width: 8),
            Text(
              'TRIVIA CHALLENGE',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.comicBlack,
              ),
            ),
          ],
        ),
        content: const Text(
          'In Dragon Ball Z, who was the first mortal to defeat Son Goku in combat?\n\nA) Vegeta\nB) Master Roshi (Jackie Chun)\nC) Yamcha\nD) Tien Shinhan',
          style: TextStyle(fontSize: 14, color: AppColors.comicBlack, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.comicGray, fontWeight: FontWeight.bold)),
          ),
          SkewedButton(
            text: 'ANSWER: B',
            height: 44,
            fontSize: 12,
            backgroundColor: AppColors.comicRed,
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Correct! +50 Trivia XP earned!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// SOLID NEWS & LORE CARD (Zero Gradients, Zero Blur, Iconsax Icons)
/// ─────────────────────────────────────────────────────────────────────────────
class _SolidNewsCard extends StatelessWidget {
  final FandomPost post;
  const _SolidNewsCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/news-detail', arguments: post),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
            width: 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.imageUrl,
                width: 84,
                height: 84,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 84,
                  height: 84,
                  color: isDark ? AppColors.darkSurfaceElevated : AppColors.comicGrayLight,
                  child: const Icon(Iconsax.book, color: AppColors.comicGray),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.comicRed,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      post.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                      height: 1.25,
                      color: isDark ? Colors.white : AppColors.comicBlack,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Iconsax.flash, size: 14, color: AppColors.comicYellow),
                      const SizedBox(width: 4),
                      Text(
                        '8.6',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white70 : AppColors.comicBlack,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${post.readTimeMinutes} min read',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.comicGray,
                        ),
                      ),
                    ],
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

/// ─────────────────────────────────────────────────────────────────────────────
/// SOLID QUICK CHIP (Iconsax Icons)
/// ─────────────────────────────────────────────────────────────────────────────
class _SolidQuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SolidQuickChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.comicBlack,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
