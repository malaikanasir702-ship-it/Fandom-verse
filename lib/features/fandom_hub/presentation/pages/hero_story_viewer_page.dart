import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import '../../domain/entities/hero_story.dart';

class HeroStoryViewerPage extends StatefulWidget {
  final List<HeroStory> stories;
  final int initialIndex;

  const HeroStoryViewerPage({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  State<HeroStoryViewerPage> createState() => _HeroStoryViewerPageState();
}

class _HeroStoryViewerPageState extends State<HeroStoryViewerPage> {
  late int _currentHeroIndex;
  late StoryController _storyController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentHeroIndex = widget.initialIndex;
    _storyController = StoryController();
    _pageController = PageController(initialPage: widget.initialIndex);
    widget.stories[_currentHeroIndex].seen = true;
  }

  @override
  void dispose() {
    _storyController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToPrevHero() {
    if (_currentHeroIndex > 0) {
      _storyController.dispose();
      _storyController = StoryController();
      setState(() {
        _currentHeroIndex--;
        widget.stories[_currentHeroIndex].seen = true;
      });
      _pageController.animateToPage(
        _currentHeroIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goToNextHero() {
    if (_currentHeroIndex < widget.stories.length - 1) {
      _storyController.dispose();
      _storyController = StoryController();
      setState(() {
        _currentHeroIndex++;
        widget.stories[_currentHeroIndex].seen = true;
      });
      _pageController.animateToPage(
        _currentHeroIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  List<StoryItem> _buildStoryItems(HeroStory hero) {
    return hero.slides.map((slide) {
      return StoryItem.pageImage(
        url: slide.imageUrl,
        controller: _storyController,
        duration: const Duration(seconds: 5),
        caption: Text(
          '${slide.tag}   ${slide.caption}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            height: 1.5,
            shadows: [Shadow(color: Colors.black87, blurRadius: 10)],
          ),
        ),
        imageFit: BoxFit.cover,
        shown: false,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final hero = widget.stories[_currentHeroIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.stories.length,
        itemBuilder: (context, pageIndex) {
          if (pageIndex != _currentHeroIndex) {
            return const SizedBox.shrink();
          }
          return _StoryPageContent(
            key: ValueKey(hero.heroName),
            hero: hero,
            storyItems: _buildStoryItems(hero),
            storyController: _storyController,
            onPrevHero: _goToPrevHero,
            onNextHero: _goToNextHero,
            onDismiss: () => Navigator.of(context).pop(),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StoryPageContent extends StatelessWidget {
  final HeroStory hero;
  final List<StoryItem> storyItems;
  final StoryController storyController;
  final VoidCallback onPrevHero;
  final VoidCallback onNextHero;
  final VoidCallback onDismiss;

  const _StoryPageContent({
    super.key,
    required this.hero,
    required this.storyItems,
    required this.storyController,
    required this.onPrevHero,
    required this.onNextHero,
    required this.onDismiss,
  });

  void _showBackstorySheet(BuildContext context) {
    // Pause the story
    storyController.pause();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HeroBackstorySheet(hero: hero),
    ).whenComplete(() {
      // Resume story when sheet is closed
      storyController.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasBackstory = hero.originBackstory.isNotEmpty ||
        hero.lifeHistory.isNotEmpty ||
        hero.powersAndAbilities.isNotEmpty;

    return Stack(
      children: [
        // ── StoryView ───────────────────────────────────────────────────────
        StoryView(
          storyItems: storyItems,
          controller: storyController,
          repeat: false,
          onComplete: onNextHero,
          onVerticalSwipeComplete: (direction) {
            if (direction == Direction.down) onDismiss();
          },
          onStoryShow: (storyItem, idx) {},
        ),

        // ── Top Overlay: Avatar + Hero name + Close ─────────────────────────
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: hero.ringColor, width: 2.5),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      hero.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: hero.ringColor,
                        child: Center(
                          child: Text(
                            hero.heroName[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hero.heroName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 4)
                          ],
                        ),
                      ),
                      Text(
                        hero.category,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onDismiss,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.38),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Left tap zone (prev hero) ────────────────────────────────────────
        Positioned(
          left: 0,
          top: 100,
          bottom: 100,
          width: 50,
          child: GestureDetector(
            onTap: onPrevHero,
            behavior: HitTestBehavior.translucent,
            child: const SizedBox.expand(),
          ),
        ),

        // ── "Read Origin & Backstory" button ────────────────────────────────
        if (hasBackstory)
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => _showBackstorySheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.62),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: hero.ringColor, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '📖',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Read Full Origin & Backstory',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        shadows: [
                          Shadow(color: hero.ringColor, blurRadius: 8),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: hero.ringColor, size: 14),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Backstory Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBackstorySheet extends StatefulWidget {
  final HeroStory hero;

  const _HeroBackstorySheet({required this.hero});

  @override
  State<_HeroBackstorySheet> createState() => _HeroBackstorySheetState();
}

class _HeroBackstorySheetState extends State<_HeroBackstorySheet> {
  bool _originExpanded = true;
  bool _historyExpanded = false;
  bool _powersExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hero = widget.hero;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.97,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF12121A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Avatar + Identity row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: hero.ringColor, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: hero.ringColor.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.network(
                                hero.avatarUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 56,
                                  height: 56,
                                  color: hero.ringColor,
                                  child: Center(
                                    child: Text(
                                      hero.heroName[0],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hero.heroName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: hero.ringColor.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: hero.ringColor.withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    hero.category,
                                    style: TextStyle(
                                      color: hero.ringColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (hero.tagline.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '"${hero.tagline}"',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (hero.firstAppearance.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _InfoChip(
                          label: '🎬 First Appearance',
                          value: hero.firstAppearance,
                          accentColor: hero.ringColor,
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Origin Backstory
                      if (hero.originBackstory.isNotEmpty)
                        _ExpandableSection(
                          icon: '📖',
                          title: 'Origin Backstory',
                          accentColor: hero.ringColor,
                          isExpanded: _originExpanded,
                          onToggle: () => setState(() => _originExpanded = !_originExpanded),
                          content: hero.originBackstory,
                        ),

                      if (hero.originBackstory.isNotEmpty) const SizedBox(height: 14),

                      // Life History
                      if (hero.lifeHistory.isNotEmpty)
                        _ExpandableSection(
                          icon: '📜',
                          title: 'Whole Life History & Lore',
                          accentColor: hero.ringColor,
                          isExpanded: _historyExpanded,
                          onToggle: () => setState(() => _historyExpanded = !_historyExpanded),
                          content: hero.lifeHistory,
                        ),

                      if (hero.lifeHistory.isNotEmpty) const SizedBox(height: 14),

                      // Powers & Abilities
                      if (hero.powersAndAbilities.isNotEmpty)
                        _ExpandableSection(
                          icon: '⚡',
                          title: 'Powers, Abilities & Equipment',
                          accentColor: hero.ringColor,
                          isExpanded: _powersExpanded,
                          onToggle: () => setState(() => _powersExpanded = !_powersExpanded),
                          content: hero.powersAndAbilities,
                        ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _InfoChip({required this.label, required this.value, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _ExpandableSection extends StatelessWidget {
  final String icon;
  final String title;
  final Color accentColor;
  final bool isExpanded;
  final VoidCallback onToggle;
  final String content;

  const _ExpandableSection({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.isExpanded,
    required this.onToggle,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded ? accentColor.withValues(alpha: 0.5) : Colors.white12,
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: accentColor,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                content,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13.5,
                  height: 1.7,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
