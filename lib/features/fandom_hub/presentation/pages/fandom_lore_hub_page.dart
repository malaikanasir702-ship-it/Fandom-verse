import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../bloc/fandom_hub_bloc.dart';
import '../bloc/fandom_hub_state.dart';
import '../bloc/fandom_hub_event.dart';
import '../widgets/fandom_card.dart';
import '../widgets/trivia_question_card.dart';
import '../widgets/advanced_lore_card.dart';
import '../widgets/behind_scenes_card.dart';
import '../widgets/interview_card.dart';
import 'gallery_view_page.dart';

class FandomLoreHubPage extends StatefulWidget {
  const FandomLoreHubPage({super.key});

  @override
  State<FandomLoreHubPage> createState() => _FandomLoreHubPageState();
}

class _FandomLoreHubPageState extends State<FandomLoreHubPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.lightBackground,
            title: const Text('Lore Hub',
                style: TextStyle(fontWeight: FontWeight.w800)),
            actions: [
              IconButton(
                onPressed: () => Navigator.of(context).pushNamed('/search'),
                icon: const Icon(Iconsax.search_normal_1),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.comicRed,
              labelColor: AppColors.comicRed,
              unselectedLabelColor: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(
                  icon: Icon(Iconsax.book_1, size: 18),
                  text: 'Beginner Hub',
                ),
                Tab(
                  icon: Icon(Iconsax.book, size: 18),
                  text: 'Glossary',
                ),
                Tab(
                  icon: Icon(Iconsax.video_play, size: 18),
                  text: 'Media',
                ),
                Tab(
                  icon: Icon(Iconsax.lamp_on, size: 18),
                  text: 'Deep Dive',
                ),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            _BeginnerHubTab(),
            _GlossaryTab(),
            _MediaTab(),
            _DeepDiveTab(),
          ],
        ),
      ),
    );
  }
}

// ─── BEGINNER HUB TAB ───
class _BeginnerHubTab extends StatelessWidget {
  const _BeginnerHubTab();

  static const _guides = [
    {
      'id': 'cat_anime',
      'title': 'Fate Series: Complete Viewing Order',
      'subtitle': 'Zero → Stay Night → UBW → Heaven\'s Feel',
      'icon': Iconsax.shield,
      'color': 0xFF9C27B0,
    },
    {
      'id': 'cat_scifi',
      'title': 'Star Wars Canon Chronology',
      'subtitle': 'From Phantom Menace to The Mandalorian',
      'icon': Iconsax.airplane,
      'color': 0xFF2196F3,
    },
    {
      'id': 'cat_marvel',
      'title': 'Marvel Comics Starting Points 2024',
      'subtitle': 'Essential reading for MCU fans entering comics',
      'icon': Iconsax.crown_1,
      'color': 0xFFE53935,
    },
    {
      'id': 'cat_gaming',
      'title': 'Dark Souls Lore: Where to Start',
      'subtitle': 'Understanding Age of Fire, Lords of Cinder & Hollowing',
      'icon': Iconsax.flash_1,
      'color': 0xFFFF9100,
    },
    {
      'id': 'cat_kpop',
      'title': 'K-Pop 101: Fandoms & Fan Culture',
      'subtitle': 'Albums, fan chants, lightsticks & fancafe essentials',
      'icon': Iconsax.music,
      'color': 0xFFE91E63,
    },
    {
      'id': 'cat_gaming',
      'title': 'Speedrunning Basics: Any% to 100%',
      'subtitle': 'Glossary, category rules, world record tracking',
      'icon': Iconsax.timer_1,
      'color': 0xFF00BCD4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = context.watch<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';
    final profileState = context.watch<ProfileBloc>().state;
    final likedFandoms = profileState is ProfileLoaded
        ? profileState.likedFandoms
        : (authState is AuthAuthenticated
            ? authState.user.likedFandoms
            : <String>[]);

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _guides.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final guide = _guides[i];
        final color = Color(guide['color'] as int);
        final catId = guide['id'] as String;
        final isLiked = likedFandoms.contains(catId);

        return GlassContainer(
          padding: const EdgeInsets.all(16),
          borderColor: color.withValues(alpha: 0.25),
          onTap: () =>
              Navigator.of(context).pushNamed('/beginner-hub', arguments: guide),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Icon(guide['icon'] as IconData, size: 24, color: color),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide['title'] as String,
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      guide['subtitle'] as String,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FandomLikeButton(
                categoryId: catId,
                isLiked: isLiked,
                onToggle: () {
                  if (userId.isNotEmpty) {
                    context.read<ProfileBloc>().add(
                          ToggleLikeFandomEvent(
                            userId: userId,
                            categoryId: catId,
                          ),
                        );
                  }
                },
              ),
              const SizedBox(width: 6),
              Icon(Iconsax.arrow_right_3, size: 16, color: color),
            ],
          ),
        );
      },
    );
  }
}

// ─── GLOSSARY TAB ───
class _GlossaryTab extends StatefulWidget {
  const _GlossaryTab();

  @override
  State<_GlossaryTab> createState() => _GlossaryTabState();
}

class _GlossaryTabState extends State<_GlossaryTab> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<FandomHubBloc, FandomHubState>(
      builder: (context, state) {
        if (state is! FandomHubLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: 6,
            itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: SkeletonLoader(
                width: double.infinity,
                height: 80,
                borderRadius: 12,
              ),
            ),
          );
        }

        final terms = state.glossary
            .where((t) =>
                _search.isEmpty ||
                t.term.toLowerCase().contains(_search.toLowerCase()) ||
                t.definition.toLowerCase().contains(_search.toLowerCase()))
            .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Iconsax.search_normal_1, size: 20),
                  hintText: 'Search fandom terms...',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: terms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final term = terms[i];
                  return GlassContainer(
                    padding: const EdgeInsets.all(14),
                    onTap: () => Navigator.of(context).pushNamed(
                      '/glossary-details',
                      arguments: term,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    term.term,
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: AppColors.comicRed,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    term.phonetic,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.read<FandomHubBloc>().add(
                                    ToggleBookmarkGlossaryEvent(term.id),
                                  ),
                              child: Icon(
                                term.isBookmarked
                                    ? Iconsax.bookmark
                                    : Iconsax.bookmark_2,
                                size: 18,
                                color: term.isBookmarked
                                    ? AppColors.comicYellow
                                    : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          term.definition,
                          style: AppTextStyles.bodySmall.copyWith(height: 1.5),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.comicRed.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Iconsax.tag,
                                  size: 12, color: AppColors.comicRed),
                              const SizedBox(width: 4),
                              Text(
                                term.fandomCategory,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.comicRed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── MEDIA TAB ───
class _MediaTab extends StatelessWidget {
  const _MediaTab();

  static const List<Map<String, dynamic>> _gallery = [
    {
      'title': 'Neo-Tokyo Reimagined',
      'img': 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=400',
      'artist': 'Kenji_Art',
      'likes': 3400,
    },
    {
      'title': 'Witcher: Kaer Morhen',
      'img': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400',
      'artist': 'GeraltFanatic',
      'likes': 5100,
    },
    {
      'title': 'Demon Slayer Water Form',
      'img': 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=400',
      'artist': 'Tanjiro_Draws',
      'likes': 4800,
    },
    {
      'title': 'Star Wars Coruscant',
      'img': 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=400',
      'artist': 'JediArchivist',
      'likes': 2900,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FandomHubBloc, FandomHubState>(
      builder: (context, state) {
        if (state is! FandomHubLoaded) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: 6,
            itemBuilder: (_, __) => const SkeletonLoader(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 14,
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                const Icon(Iconsax.gallery, size: 20, color: AppColors.comicRed),
                const SizedBox(width: 8),
                Text(
                  'Fan Art Gallery',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: _gallery.length,
              itemBuilder: (context, i) {
                final item = _gallery[i];
                return GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRouter.galleryView,
                    arguments: GalleryItem.fromMap(item),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          item['img']!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: AppColors.darkSurface),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.black.withValues(alpha: 0.6),
                            child: Text(
                              item['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// ─── DEEP DIVE TAB ───
class _DeepDiveTab extends StatefulWidget {
  const _DeepDiveTab();

  @override
  State<_DeepDiveTab> createState() => _DeepDiveTabState();
}

class _DeepDiveTabState extends State<_DeepDiveTab> {
  int _currentQ = 0;
  int _score = 0;
  bool _triviaCompleted = false;

  static final List<TriviaQuestion> _triviaQuestions = [
    const TriviaQuestion(
      question:
          'In Dragon Ball Z, who was the first mortal to defeat Goku in combat?',
      options: ['Vegeta', 'Master Roshi (Jackie Chun)', 'Yamcha', 'Tien'],
      correctAnswerIndex: 1,
      explanation:
          'Master Roshi disguised as Jackie Chun defeated young Goku in the 21st World Tournament.',
    ),
    const TriviaQuestion(
      question: 'What was the Nintendo GameCube\'s development codename?',
      options: [
        'Project Reality',
        'Project Dolphin',
        'Ultra 64',
        'Project Atlantis'
      ],
      correctAnswerIndex: 1,
      explanation:
          'The GameCube was developed as "Dolphin", hence model numbers start with DOL-001.',
    ),
    const TriviaQuestion(
      question:
          'Which Marvel villain created the Infinity Gauntlet in the original 1991 comics?',
      options: [
        'Eternity',
        'Thanos himself',
        'Eitri the Dwarf',
        'Adam Warlock'
      ],
      correctAnswerIndex: 1,
      explanation:
          'Thanos attached all 6 Infinity Gems to an ordinary glove — no Eitri was involved in the original.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Dispatch loads for lore sections
    context.read<FandomHubBloc>().add(const LoadAdvancedLoreEvent());
    context.read<FandomHubBloc>().add(const LoadBehindScenesEvent());
    context.read<FandomHubBloc>().add(const LoadInterviewsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<FandomHubBloc, FandomHubState>(
      builder: (context, hubState) {
        final currentLoaded =
            hubState is FandomHubLoaded ? hubState : null;
        final advancedLore = currentLoaded?.advancedLore;
        final behindScenes = currentLoaded?.behindScenes;
        final interviews = currentLoaded?.interviews;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Section 1: Deep Dive Trivia ──
            Row(
              children: [
                const Icon(Iconsax.lamp_charge,
                    size: 20, color: AppColors.comicRed),
                const SizedBox(width: 8),
                Text(
                  'Deep Dive Trivia',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Active Question or Completion Card
            if (!_triviaCompleted) ...[
              TriviaQuestionCard(
                key: ValueKey(_currentQ),
                question: _triviaQuestions[_currentQ],
                questionNumber: _currentQ + 1,
                totalQuestions: _triviaQuestions.length,
                onAnswerSelected: (selectedIdx, isCorrect) {
                  if (isCorrect) {
                    _score++;
                  }
                },
              ),
              const SizedBox(height: 14),
              SkewedButton(
                text: _currentQ < _triviaQuestions.length - 1
                    ? 'Next Question'
                    : 'Finish Trivia',
                icon: Iconsax.arrow_right_3,
                height: 48,
                fontSize: 13,
                onPressed: () {
                  setState(() {
                    if (_currentQ < _triviaQuestions.length - 1) {
                      _currentQ++;
                    } else {
                      _triviaCompleted = true;
                    }
                  });
                },
              ),
            ] else ...[
              // Final Score Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkAccentGold,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkAccentGold.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Iconsax.cup, size: 40, color: Colors.black87),
                    const SizedBox(height: 10),
                    const Text(
                      'Trivia Completed!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Score: $_score / ${_triviaQuestions.length}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _triviaCompleted = false;
                          _currentQ = 0;
                          _score = 0;
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Play Again'),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // ── Section 2: Advanced Lore ──
            Row(
              children: [
                const Icon(Iconsax.book_saved,
                    size: 20, color: AppColors.comicYellowDark),
                const SizedBox(width: 8),
                Text(
                  'ADVANCED LORE',
                  style: AppTextStyles.comicSectionHeader.copyWith(
                    fontSize: 15,
                    color: isDark ? Colors.white : AppColors.comicBlack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (advancedLore == null) ...[
              const SkeletonLoader(
                  width: double.infinity, height: 60, borderRadius: 12),
              const SizedBox(height: 8),
              const SkeletonLoader(
                  width: double.infinity, height: 60, borderRadius: 12),
              const SizedBox(height: 8),
              const SkeletonLoader(
                  width: double.infinity, height: 60, borderRadius: 12),
            ] else if (advancedLore.isEmpty) ...[
              GlassContainer(
                padding: const EdgeInsets.all(18),
                child: Center(
                  child: Text(
                    'Advanced lore content coming soon!',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ] else ...[
              ...advancedLore.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AdvancedLoreCard(lore: item),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // ── Section 3: Behind the Scenes ──
            Row(
              children: [
                const Icon(Iconsax.video_circle,
                    size: 20, color: AppColors.heroBlue),
                const SizedBox(width: 8),
                Text(
                  'BEHIND THE SCENES',
                  style: AppTextStyles.comicSectionHeader.copyWith(
                    fontSize: 15,
                    color: isDark ? Colors.white : AppColors.comicBlack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (behindScenes == null) ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.1,
                ),
                itemCount: 4,
                itemBuilder: (_, __) => const SkeletonLoader(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 14,
                ),
              ),
            ] else if (behindScenes.isEmpty) ...[
              GlassContainer(
                padding: const EdgeInsets.all(18),
                child: Center(
                  child: Text(
                    'Behind the scenes content coming soon!',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ] else ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.1,
                ),
                itemCount: behindScenes.length,
                itemBuilder: (context, index) {
                  final scene = behindScenes[index];
                  return BehindScenesCard(
                    scene: scene,
                    onTap: () => Navigator.of(context).pushNamed(
                      '/behind-scenes-detail',
                      arguments: scene,
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 32),

            // ── Section 4: Interviews ──
            Row(
              children: [
                const Icon(Iconsax.microphone_2,
                    size: 20, color: AppColors.heroGreen),
                const SizedBox(width: 8),
                Text(
                  'EXCLUSIVE INTERVIEWS',
                  style: AppTextStyles.comicSectionHeader.copyWith(
                    fontSize: 15,
                    color: isDark ? Colors.white : AppColors.comicBlack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (interviews == null) ...[
              const SkeletonLoader(
                  width: double.infinity, height: 75, borderRadius: 12),
              const SizedBox(height: 8),
              const SkeletonLoader(
                  width: double.infinity, height: 75, borderRadius: 12),
              const SizedBox(height: 8),
              const SkeletonLoader(
                  width: double.infinity, height: 75, borderRadius: 12),
            ] else if (interviews.isEmpty) ...[
              GlassContainer(
                padding: const EdgeInsets.all(18),
                child: Center(
                  child: Text(
                    'Check back soon for exclusive interviews!',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ] else ...[
              ...interviews.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InterviewCard(
                    interview: item,
                    onTap: () => Navigator.of(context).pushNamed(
                      '/interview-detail',
                      arguments: item,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 60),
          ],
        );
      },
    );
  }
}
