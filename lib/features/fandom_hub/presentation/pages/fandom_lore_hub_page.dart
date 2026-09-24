import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../bloc/fandom_hub_bloc.dart';
import '../bloc/fandom_hub_state.dart';
import '../bloc/fandom_hub_event.dart';

class FandomLoreHubPage extends StatefulWidget {
  const FandomLoreHubPage({super.key});

  @override
  State<FandomLoreHubPage> createState() => _FandomLoreHubPageState();
}

class _FandomLoreHubPageState extends State<FandomLoreHubPage> with SingleTickerProviderStateMixin {
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
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            title: const Text('Lore Hub', style: TextStyle(fontWeight: FontWeight.w800)),
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
              unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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
      'title': 'Fate Series: Complete Viewing Order',
      'subtitle': 'Zero → Stay Night → UBW → Heaven\'s Feel',
      'icon': Iconsax.shield,
      'color': 0xFF9C27B0,
    },
    {
      'title': 'Star Wars Canon Chronology',
      'subtitle': 'From Phantom Menace to The Mandalorian',
      'icon': Iconsax.airplane,
      'color': 0xFF2196F3,
    },
    {
      'title': 'Marvel Comics Starting Points 2024',
      'subtitle': 'Essential reading for MCU fans entering comics',
      'icon': Iconsax.crown_1,
      'color': 0xFFE53935,
    },
    {
      'title': 'Dark Souls Lore: Where to Start',
      'subtitle': 'Understanding Age of Fire, Lords of Cinder & Hollowing',
      'icon': Iconsax.flash_1,
      'color': 0xFFFF9100,
    },
    {
      'title': 'K-Pop 101: Fandoms & Fan Culture',
      'subtitle': 'Albums, fan chants, lightsticks & fancafe essentials',
      'icon': Iconsax.music,
      'color': 0xFFE91E63,
    },
    {
      'title': 'Speedrunning Basics: Any% to 100%',
      'subtitle': 'Glossary, category rules, world record tracking',
      'icon': Iconsax.timer_1,
      'color': 0xFF00BCD4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _guides.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final guide = _guides[i];
        final color = Color(guide['color'] as int);
        return GlassContainer(
          padding: const EdgeInsets.all(16),
          borderColor: color.withValues(alpha: 0.25),
          onTap: () => Navigator.of(context).pushNamed('/beginner-hub', arguments: guide),
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
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      guide['subtitle'] as String,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
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
        if (state is! FandomHubLoaded) return const Center(child: CircularProgressIndicator());

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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: terms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final term = terms[i];
                  return GlassContainer(
                    padding: const EdgeInsets.all(14),
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
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
                                term.isBookmarked ? Iconsax.bookmark : Iconsax.bookmark_2,
                                size: 18,
                                color: term.isBookmarked
                                    ? AppColors.comicYellow
                                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(term.definition, style: AppTextStyles.bodySmall.copyWith(height: 1.5)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.comicRed.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Iconsax.tag, size: 12, color: AppColors.comicRed),
                              const SizedBox(width: 4),
                              Text(
                                term.fandomCategory,
                                style: const TextStyle(fontSize: 11, color: AppColors.comicRed, fontWeight: FontWeight.w600),
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FandomHubBloc, FandomHubState>(
      builder: (context, state) {
        if (state is! FandomHubLoaded) return const Center(child: CircularProgressIndicator());
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                const Icon(Iconsax.gallery, size: 20, color: AppColors.comicRed),
                const SizedBox(width: 8),
                Text('Fan Art Gallery', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
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
              itemCount: 4,
              itemBuilder: (context, i) {
                final gallery = [
                  {'title': 'Neo-Tokyo Reimagined', 'img': 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=400', 'likes': '3.4k'},
                  {'title': 'Witcher: Kaer Morhen', 'img': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400', 'likes': '5.1k'},
                  {'title': 'Demon Slayer Water Form', 'img': 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=400', 'likes': '4.8k'},
                  {'title': 'Star Wars Coruscant', 'img': 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=400', 'likes': '2.9k'},
                ];
                final item = gallery[i];
                return GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/gallery-view', arguments: item),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(item['img']!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: AppColors.darkSurface)),
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.black.withValues(alpha: 0.6),
                            child: Text(item['title']!, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
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
  int? _selectedAnswer;
  bool _answered = false;
  int _currentQ = 0;
  int _score = 0;

  static final List<Map<String, dynamic>> _triviaList = [
    {
      'q': 'In Dragon Ball Z, who was the first mortal to defeat Goku in combat?',
      'options': ['Vegeta', 'Master Roshi (Jackie Chun)', 'Yamcha', 'Tien'],
      'answer': 1,
      'explanation': 'Master Roshi disguised as Jackie Chun defeated young Goku in the 21st World Tournament.',
    },
    {
      'q': 'What was the Nintendo GameCube\'s development codename?',
      'options': ['Project Reality', 'Project Dolphin', 'Ultra 64', 'Project Atlantis'],
      'answer': 1,
      'explanation': 'The GameCube was developed as "Dolphin", hence model numbers start with DOL-001.',
    },
    {
      'q': 'Which Marvel villain created the Infinity Gauntlet in the original 1991 comics?',
      'options': ['Eternity', 'Thanos himself', 'Eitri the Dwarf', 'Adam Warlock'],
      'answer': 1,
      'explanation': 'Thanos attached all 6 Infinity Gems to an ordinary glove — no Eitri was involved in the original.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final question = _triviaList[_currentQ];
    final options = question['options'] as List<String>;
    final correctIndex = question['answer'] as int;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Score Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Iconsax.lamp_charge, size: 20, color: AppColors.comicRed),
                const SizedBox(width: 8),
                Text('Deep Dive Trivia', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.darkAccentGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.star_1, size: 14, color: AppColors.darkAccentGold),
                  const SizedBox(width: 4),
                  Text(
                    'Score: $_score / ${_triviaList.length}',
                    style: const TextStyle(color: AppColors.darkAccentGold, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Question Card
        GlassContainer(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.comicRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q${_currentQ + 1} of ${_triviaList.length}',
                  style: const TextStyle(color: AppColors.comicRed, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              Text(question['q'] as String, style: AppTextStyles.titleMedium),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Options
        ...List.generate(options.length, (i) {
          Color? bg;
          if (_answered) {
            if (i == correctIndex) {
              bg = AppColors.success.withValues(alpha: 0.15);
            } else if (i == _selectedAnswer) {
              bg = AppColors.error.withValues(alpha: 0.15);
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: _answered ? null : () {
                setState(() {
                  _selectedAnswer = i;
                  _answered = true;
                  if (i == correctIndex) _score++;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bg ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _answered && i == correctIndex
                        ? AppColors.success
                        : _answered && i == _selectedAnswer
                            ? AppColors.error
                            : isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: _answered && (i == correctIndex || i == _selectedAnswer) ? 1.5 : 1,
                  ),
                ),
                child: Text(options[i], style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          );
        }),

        if (_answered) ...[
          const SizedBox(height: 6),
          GlassContainer(
            padding: const EdgeInsets.all(14),
            borderColor: AppColors.darkAccentGold.withValues(alpha: 0.3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Iconsax.info_circle, size: 18, color: AppColors.darkAccentGold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    question['explanation'] as String,
                    style: const TextStyle(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _answered = false;
                _selectedAnswer = null;
                _currentQ = (_currentQ + 1) % _triviaList.length;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_currentQ < _triviaList.length - 1 ? 'Next Question' : 'Restart Trivia'),
                const SizedBox(width: 6),
                const Icon(Iconsax.arrow_right_3, size: 16),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
