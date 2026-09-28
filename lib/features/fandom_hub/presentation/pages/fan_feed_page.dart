import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/comic_ui_widgets.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/database/sqlite_helper.dart';
import '../bloc/fandom_hub_bloc.dart';
import '../bloc/fandom_hub_state.dart';
import '../../domain/entities/fandom_post.dart';
import '../../domain/entities/hero_story.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../community/presentation/widgets/filter_badge_chip.dart';
import '../bloc/fandom_hub_event.dart';
import '../widgets/hero_story_ring.dart';
import 'hero_story_viewer_page.dart';
import '../../../../core/widgets/app_user_avatar.dart';
import '../../../../core/services/notification_service.dart';

class FanFeedPage extends StatelessWidget {
  const FanFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is FanAuthenticated) {
          context.read<FandomHubBloc>().add(
                LoadFandomHubContentEvent(
                  selectedFandoms: authState.user.selectedFandoms,
                ),
              );
        }
      },
      child: BlocBuilder<FandomHubBloc, FandomHubState>(
        builder: (context, state) {
          if (state is FandomHubLoading || state is FandomHubInitial) {
            // Show skeleton while loading instead of blank screen
            return const SkeletonFeedPage();
          }
          if (state is FandomHubLoaded) {
            return _FanFeedContent(state: state);
          }
          // Error or unknown — show skeleton (app won't be blank)
          return const SkeletonFeedPage();
        },
      ),
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

  // ─── Auto-sliding banner ───
  final PageController _bannerController = PageController();
  int _bannerIndex = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _loadHeroStories();
    _startBannerTimer();
    NotificationService.refreshUnreadCount();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final total = widget.state.trendingPosts.length;
      if (total <= 1) return;
      final next = (_bannerIndex + 1) % total;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
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
    final trendingPosts = state.trendingPosts.isNotEmpty
        ? state.trendingPosts
        : (state.latestNews.isNotEmpty ? state.latestNews.take(4).toList() : <FandomPost>[]);

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
                    // Action Icons: Search, Notifications & Profile
                    Row(
                      children: [
                        // Search Button
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
                        // Notification Bell with unread badge (Live SQLite synced)
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed('/notifications').then((_) {
                            NotificationService.refreshUnreadCount();
                          }),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
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
                                  Iconsax.notification,
                                  size: 18,
                                  color: isDark ? Colors.white : AppColors.comicBlack,
                                ),
                              ),
                              ValueListenableBuilder<int>(
                                valueListenable: NotificationService.unreadCountNotifier,
                                builder: (context, unreadCount, _) {
                                  if (unreadCount <= 0) return const SizedBox.shrink();
                                  return Positioned(
                                    top: -2,
                                    right: -2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                      decoration: const BoxDecoration(
                                        color: AppColors.comicRed,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          unreadCount > 99 ? '99+' : '$unreadCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Profile Avatar (Instant update anywhere across app)
                        AppUserAvatar(
                          avatarUrl: currentUser?.avatarUrl,
                          displayName: currentUser?.name ?? 'Fan',
                          size: 38,
                          showBorder: true,
                          borderWidth: 1.5,
                          borderColor: AppColors.comicYellow,
                          onTap: () => Navigator.of(context).pushNamed('/profile').then((_) {
                            NotificationService.refreshUnreadCount();
                          }),
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
              // 1. AUTO-SLIDING TRENDING BANNER with dots
              if (trendingPosts.isNotEmpty)
                _TrendingBannerCarousel(
                  posts: trendingPosts,
                  controller: _bannerController,
                  currentIndex: _bannerIndex,
                  onPageChanged: (i) => setState(() => _bannerIndex = i),
                  isDark: isDark,
                ),

              const SizedBox(height: 12),

              // 2. YOUR FAVOURITE HEROES — Instagram-style Stories
              ComicSectionHeader(
                title: 'YOUR FAVOURITE HEROES',
                actionColor: AppColors.comicYellow,
                onActionTap: () => Navigator.of(context).pushNamed('/favourite-heroes'),
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

              // Preference Filter Badge Chip
              Builder(
                builder: (context) {
                  final currentUser = context.watch<AuthBloc>().currentUser;
                  final prefs = currentUser?.selectedFandoms ?? <String>[];
                  return FilterBadgeChip(
                    activePreferences: prefs,
                    onTap: () => Navigator.of(context).pushNamed('/interest-setup'),
                  );
                },
              ),

              if (state.latestNews.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Iconsax.info_circle,
                          size: 38,
                          color: AppColors.comicYellow,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No posts found for your preferences. Try selecting more fandoms!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // RepaintBoundary isolates each card from parent repaints
                ...state.latestNews.map((post) => RepaintBoundary(
                      child: _SolidNewsCard(post: post),
                    )),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  static const List<Map<String, dynamic>> _triviaQuestions = [
    {
      'q': 'In Dragon Ball Z, who was the first mortal to defeat Son Goku in combat?',
      'options': ['A) Vegeta', 'B) Master Roshi (Jackie Chun)', 'C) Yamcha', 'D) Tien Shinhan'],
      'answer': 1,
      'fact': 'Master Roshi disguised as Jackie Chun defeated young Goku in the 21st World Tournament.',
    },
    {
      'q': 'Which Infinity Stone was stored inside Vision\'s forehead in the MCU?',
      'options': ['A) Space Stone', 'B) Reality Stone', 'C) Mind Stone', 'D) Soul Stone'],
      'answer': 2,
      'fact': 'The Mind Stone (yellow) was embedded in Vision\'s forehead, giving him life and power.',
    },
    {
      'q': 'What is the name of the open-world map in Elden Ring?',
      'options': ['A) The Shattered Realm', 'B) The Lands Between', 'C) Lordran', 'D) Drangleic'],
      'answer': 1,
      'fact': 'The Lands Between is the realm governed by the Erdtree, where players explore as the Tarnished.',
    },
    {
      'q': 'K-Pop group BTS debuted under which South Korean entertainment company?',
      'options': ['A) SM Entertainment', 'B) YG Entertainment', 'C) HYBE (Big Hit)', 'D) JYP Entertainment'],
      'answer': 2,
      'fact': 'BTS debuted in 2013 under Big Hit Entertainment, now rebranded as HYBE Corporation.',
    },
    {
      'q': 'In One Piece, what is the name of Monkey D. Luffy\'s devil fruit?',
      'options': ['A) Gum-Gum Fruit (Gomu Gomu no Mi)', 'B) Dark-Dark Fruit', 'C) Flame-Flame Fruit', 'D) Barrier-Barrier Fruit'],
      'answer': 0,
      'fact': 'The Gomu Gomu no Mi (Gum-Gum Fruit) gave Luffy a rubber body — later revealed as the mythical Nika fruit.',
    },
    {
      'q': 'Which company developed the critically acclaimed game "Hollow Knight"?',
      'options': ['A) FromSoftware', 'B) Team Cherry', 'C) Supergiant Games', 'D) Playdead'],
      'answer': 1,
      'fact': 'Hollow Knight was developed by Australian indie studio Team Cherry, a 3-person team.',
    },
    {
      'q': 'What is the real name of Batman\'s butler Alfred?',
      'options': ['A) Alfred Pennyworth', 'B) Alfred Jarvis', 'C) Alfred Thaddeus Crane', 'D) Alfred Wayne'],
      'answer': 0,
      'fact': 'Alfred Pennyworth has served as Bruce Wayne\'s butler since Batman #16 (1943).',
    },
    {
      'q': 'In Attack on Titan, what is the name of the founder Titan?',
      'options': ['A) Ymir Fritz', 'B) Mikasa Ackerman', 'C) Eren Yeager', 'D) Karl Fritz'],
      'answer': 0,
      'fact': 'Ymir Fritz made a deal with an entity in the Paths realm 2000 years ago, becoming the first Titan.',
    },
    {
      'q': 'Which anime studio produced Demon Slayer: Kimetsu no Yaiba?',
      'options': ['A) Bones', 'B) MAPPA', 'C) Ufotable', 'D) Madhouse'],
      'answer': 2,
      'fact': 'Ufotable is renowned for their water and flame animation effects — Demon Slayer became their landmark work.',
    },
    {
      'q': 'What does "Isekai" mean in Japanese anime terminology?',
      'options': ['A) Another World', 'B) Time Travel', 'C) Magic System', 'D) Parallel Universe'],
      'answer': 0,
      'fact': 'Isekai (異世界) literally means "different world" — protagonist is transported to a fantasy realm.',
    },
  ];

  void _showTriviaDialog(BuildContext context) {
    final random = Random();
    int currentIndex = random.nextInt(_triviaQuestions.length);
    int? selectedAnswer;
    bool answered = false;
    int sessionScore = 0;
    int questionsAnswered = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final question = _triviaQuestions[currentIndex];
          final options = question['options'] as List<String>;
          final correctIndex = question['answer'] as int;

          return AlertDialog(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurface
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.comicBorderColor, width: 1.5),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Iconsax.cup, color: AppColors.comicYellow, size: 20),
                      const SizedBox(width: 8),
                      const Flexible(
                        child: Text(
                          'TRIVIA CHALLENGE',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: AppColors.comicRed,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.darkAccentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '⚡ $sessionScore pts',
                    style: const TextStyle(
                      color: AppColors.darkAccentGold,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question['q'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(options.length, (i) {
                    Color? bg;
                    Color borderColor = AppColors.comicBorderColor;
                    if (answered) {
                      if (i == correctIndex) {
                        bg = AppColors.success.withValues(alpha: 0.15);
                        borderColor = AppColors.success;
                      } else if (i == selectedAnswer) {
                        bg = AppColors.error.withValues(alpha: 0.15);
                        borderColor = AppColors.error;
                      }
                    } else if (selectedAnswer == i) {
                      bg = AppColors.darkPrimary.withValues(alpha: 0.15);
                      borderColor = AppColors.darkPrimary;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: answered ? null : () {
                          setDialogState(() {
                            selectedAnswer = i;
                            answered = true;
                            questionsAnswered++;
                            if (i == correctIndex) sessionScore += 50;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderColor, width: 1.2),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  options[i],
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (answered && i == correctIndex)
                                const Icon(Iconsax.tick_circle, color: AppColors.success, size: 18),
                              if (answered && i == selectedAnswer && i != correctIndex)
                                const Icon(Iconsax.close_circle, color: AppColors.error, size: 18),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (answered) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.darkAccentGold.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.darkAccentGold.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Iconsax.info_circle, size: 16, color: AppColors.darkAccentGold),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              question['fact'] as String,
                              style: const TextStyle(fontSize: 12, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  if (sessionScore > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🏆 Trivia session: $sessionScore XP earned from $questionsAnswered questions!'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Text('CLOSE', style: TextStyle(color: AppColors.comicGray, fontWeight: FontWeight.bold)),
              ),
              if (answered)
                SkewedButton(
                  text: 'NEXT QUESTION',
                  height: 40,
                  fontSize: 11,
                  backgroundColor: AppColors.comicRed,
                  onPressed: () {
                    setDialogState(() {
                      int next;
                      do {
                        next = Random().nextInt(_triviaQuestions.length);
                      } while (next == currentIndex && _triviaQuestions.length > 1);
                      currentIndex = next;
                      selectedAnswer = null;
                      answered = false;
                    });
                  },
                )
              else if (selectedAnswer == null)
                const SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// AUTO-SLIDING TRENDING BANNER CAROUSEL
/// Netflix-style full-width PageView with dot indicators + auto-advance
/// ─────────────────────────────────────────────────────────────────────────────
class _TrendingBannerCarousel extends StatelessWidget {
  final List<FandomPost> posts;
  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final bool isDark;

  const _TrendingBannerCarousel({
    required this.posts,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── PageView Banner ──
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: controller,
            itemCount: posts.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final post = posts[index];
              return GestureDetector(
                onTap: () => Navigator.of(context)
                    .pushNamed('/news-detail', arguments: post),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background image — cacheWidth limits decode size for speed
                        Image.network(
                          post.imageUrl,
                          fit: BoxFit.cover,
                          cacheWidth: 800, // prevents 4K decode of banner images
                          filterQuality: FilterQuality.medium,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.darkSurfaceElevated,
                            child: const Icon(Iconsax.image,
                                size: 48, color: Colors.white24),
                          ),
                        ),
                        // Gradient overlay bottom
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.85),
                              ],
                              stops: const [0.35, 1.0],
                            ),
                          ),
                        ),
                        // Top badges row
                        Positioned(
                          top: 12,
                          left: 14,
                          right: 14,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // TRENDING badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.comicRed,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Iconsax.flash,
                                        size: 12, color: Colors.white),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'TRENDING',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Page counter e.g. "2 / 4"
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${index + 1} / ${posts.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Bottom content
                        Positioned(
                          bottom: 14,
                          left: 14,
                          right: 14,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.darkPrimary
                                      .withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  post.category.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Title
                              Text(
                                post.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Author + read time
                              Row(
                                children: [
                                  const Icon(Iconsax.user,
                                      size: 12, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Text(
                                    post.authorName,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Iconsax.clock,
                                      size: 12, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${post.readTimeMinutes} min read',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // ── Dot Indicators ──
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(posts.length, (i) {
            final isActive = i == currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.comicRed
                    : (isDark ? Colors.white30 : Colors.black26),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
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
                cacheWidth: 168, // 2x for retina, exact size — no oversized decode
                filterQuality: FilterQuality.low,
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
