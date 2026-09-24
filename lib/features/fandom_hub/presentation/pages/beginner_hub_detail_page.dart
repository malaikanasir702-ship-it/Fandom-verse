import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';

class BeginnerHubDetailPage extends StatelessWidget {
  final Map<String, dynamic>? guideData;

  const BeginnerHubDetailPage({super.key, this.guideData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final title = guideData?['title'] as String? ?? 'Fate Series: Complete Viewing Order';
    final subtitle = guideData?['subtitle'] as String? ?? 'From Fate/Zero to Heaven\'s Feel';
    final iconData = guideData?['icon'] is IconData
        ? guideData!['icon'] as IconData
        : Iconsax.book_1;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Iconsax.arrow_left, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.comicRed,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(iconData, size: 52, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Box
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Iconsax.info_circle, color: AppColors.comicRed, size: 20),
                            SizedBox(width: 8),
                            Text('Beginner Road Map Overview', style: TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Entering complex franchises can be intimidating with decades of interconnected lore, spin-offs, and alternate timelines. This guide simplifies the journey into clear, bite-sized steps so you get the most enjoyable canonical experience without spoilers.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            height: 1.5,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Step-by-Step Chronological Journey', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),

                  _buildTimelineStep(
                    context,
                    step: 1,
                    title: 'The Foundation: The Prologue & World Setup',
                    duration: '24 Episodes / 1 Season',
                    desc: 'Establishes the core magic system, historical heroic spirits, and high-stakes philosophical conflicts between the seven factions.',
                    tag: 'Essential Watch',
                  ),
                  _buildTimelineStep(
                    context,
                    step: 2,
                    title: 'The Divergent Paths: Visual Novel Routes',
                    duration: 'Movie Trilogy / 26 Episodes',
                    desc: 'Where character motivations drastically diverge. Highlighting ufotable\'s ground-breaking animation cinematography and soundtrack.',
                    tag: 'Peak Animation',
                  ),
                  _buildTimelineStep(
                    context,
                    step: 3,
                    title: 'The Alternate Continuities & Spin-offs',
                    duration: 'Stand-alone OVAs & Series',
                    desc: 'Explore the Apocrypha Grail War, Extra/Last Encore digital virtual realm, and the Lord El-Melloi II detective lore mysteries.',
                    tag: 'Expanded Universe',
                  ),
                  const SizedBox(height: 24),

                  // Lore Tips & Common Pitfalls
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderColor: AppColors.comicYellow.withValues(alpha: 0.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Iconsax.lamp_on, color: AppColors.comicYellow, size: 20),
                            SizedBox(width: 8),
                            Text('Pro Tips for Beginners', style: TextStyle(fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildTipItem('Do not get paralyzed by "Release Order vs Chronological Order" debates. Starting with the most modern adaptation retains engagement!'),
                        _buildTipItem('Keep a wiki or glossary handy for character noble phantasms and magical crest terminology.'),
                        _buildTipItem('Join the community discussion channels on Fandom Verse to ask friendly veteran lore-keepers questions.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    BuildContext context, {
    required int step,
    required String title,
    required String duration,
    required String desc,
    required String tag,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.darkPrimary,
            child: Text(
              '$step',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GlassContainer(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.darkSecondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: AppColors.darkSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    duration,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: const TextStyle(fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.w800)),
          Expanded(
            child: Text(tip, style: const TextStyle(fontSize: 12, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
