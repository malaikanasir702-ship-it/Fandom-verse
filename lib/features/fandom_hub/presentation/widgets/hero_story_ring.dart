import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/hero_story.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA: All hero stories with multiple slides each
// ─────────────────────────────────────────────────────────────────────────────

final List<HeroStory> kHeroStories = [
  HeroStory(
    heroName: 'Spider-Man',
    category: 'Marvel Comics',
    avatarUrl: 'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=400',
    ringColor: AppColors.heroRed,
    slides: const [
      HeroStorySlide(
        imageUrl: 'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=800',
        caption: '🕷️ "With great power comes great responsibility."',
        tag: '#SpiderMan',
      ),
      HeroStorySlide(
        imageUrl: 'https://images.unsplash.com/photo-1601645191163-3fc0d5d64e35?w=800',
        caption: 'Peter Parker swings into action across Manhattan! 🌆',
        tag: '#Marvel',
      ),
      HeroStorySlide(
        imageUrl: 'https://images.unsplash.com/photo-1608889175123-8ee362201f81?w=800',
        caption: 'The Multiverse saga continues… are you ready? 🌌',
        tag: '#NoWayHome',
      ),
    ],
  ),
  HeroStory(
    heroName: 'Batman',
    category: 'DC Comics',
    avatarUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=400',
    ringColor: AppColors.heroBlue,
    slides: const [
      HeroStorySlide(
        imageUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800',
        caption: '🦇 "I am vengeance. I am the night."',
        tag: '#Batman',
      ),
      HeroStorySlide(
        imageUrl: 'https://images.unsplash.com/photo-1613376023733-0a73315d9b06?w=800',
        caption: 'Gotham City never sleeps — neither does the Dark Knight. 🌃',
        tag: '#DCComics',
      ),
      HeroStorySlide(
        imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
        caption: 'Billionaire by day. Vigilante by night. 🖤',
        tag: '#BruceWayne',
      ),
    ],
  ),
  HeroStory(
    heroName: 'Wolverine',
    category: 'X-Men',
    avatarUrl: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=400',
    ringColor: AppColors.heroYellow,
    slides: const [
      HeroStorySlide(
        imageUrl: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=800',
        caption: '⚡ "I\'m the best there is at what I do."',
        tag: '#Wolverine',
      ),
      HeroStorySlide(
        imageUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=800',
        caption: 'Adamantium claws. Healing factor. Unlimited rage. 🔥',
        tag: '#XMen',
      ),
    ],
  ),
  HeroStory(
    heroName: 'Wonder Woman',
    category: 'DC Comics',
    avatarUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400',
    ringColor: AppColors.heroRed,
    slides: const [
      HeroStorySlide(
        imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800',
        caption: '⚡ Diana, Princess of the Amazons.',
        tag: '#WonderWoman',
      ),
      HeroStorySlide(
        imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
        caption: 'Born from clay, forged for war, fighting for love. 🏛️',
        tag: '#DCComics',
      ),
    ],
  ),
  HeroStory(
    heroName: 'Deadpool',
    category: 'Marvel Comics',
    avatarUrl: 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=400',
    ringColor: AppColors.heroPurple,
    slides: const [
      HeroStorySlide(
        imageUrl: 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800',
        caption: '🎭 Breaking the 4th wall since 1991.',
        tag: '#Deadpool',
      ),
      HeroStorySlide(
        imageUrl: 'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=800',
        caption: 'Maximum effort! 💥',
        tag: '#MercWithAMouth',
      ),
    ],
  ),
  HeroStory(
    heroName: 'Paul Atreides',
    category: 'Sci-Fi / Dune',
    avatarUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400',
    ringColor: AppColors.heroOrange,
    slides: const [
      HeroStorySlide(
        imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800',
        caption: '🏜️ "The spice must flow."',
        tag: '#Dune',
      ),
      HeroStorySlide(
        imageUrl: 'https://images.unsplash.com/photo-1543722530-d2c3201371e7?w=800',
        caption: 'Arrakis. Dune. Desert planet. 🌅',
        tag: '#PaulAtreides',
      ),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: Instagram-style story ring avatar
// ─────────────────────────────────────────────────────────────────────────────

class HeroStoryRing extends StatelessWidget {
  final HeroStory story;
  final VoidCallback onTap;

  const HeroStoryRing({
    super.key,
    required this.story,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Gradient ring (unseen) or grey ring (seen) ──
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: story.seen
                    ? null
                    : LinearGradient(
                        colors: [
                          story.ringColor,
                          story.ringColor.withValues(
                              alpha: 1,
                              red: ((story.ringColor.r * 255).round() + 60).clamp(0, 255) / 255.0,
                              green: story.ringColor.g,
                              blue: story.ringColor.b),
                          AppColors.comicYellow,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: story.seen
                    ? (isDark ? AppColors.darkBorder : Colors.grey[350])
                    : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkBackground : Colors.white,
                    width: 2.5,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    story.avatarUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: story.ringColor.withValues(alpha: 0.3),
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: story.ringColor,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: story.ringColor,
                      child: Center(
                        child: Text(
                          story.heroName[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),

            // ── Hero name label ──
            SizedBox(
              width: 74,
              child: Text(
                story.heroName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? (story.seen
                          ? AppColors.darkTextSecondary
                          : AppColors.darkTextPrimary)
                      : (story.seen
                          ? AppColors.lightTextSecondary
                          : AppColors.lightTextPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
