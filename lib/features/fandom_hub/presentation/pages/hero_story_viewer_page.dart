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

    // Mark current hero as seen
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
            shadows: [
              Shadow(color: Colors.black87, blurRadius: 10),
            ],
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // StoryView
        StoryView(
          storyItems: storyItems,
          controller: storyController,
          repeat: false,
          onComplete: onNextHero,
          onVerticalSwipeComplete: (direction) {
            if (direction == Direction.down) {
              onDismiss();
            }
          },
          onStoryShow: (storyItem, idx) {},
        ),

        // Top overlay: Avatar + Hero name + Close button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
            child: Row(
              children: [
                // Hero avatar with color ring
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

                // Hero name & category
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
                          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
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

                // Close button
                GestureDetector(
                  onTap: onDismiss,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.38),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Left swipe zone (prev hero)
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
      ],
    );
  }
}
