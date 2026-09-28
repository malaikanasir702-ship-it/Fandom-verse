import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';
import '../bloc/community_state.dart';
import '../../domain/entities/star_profile.dart';

/// Dedicated page showing all bookmarked star profiles.
/// These profiles are stored in SQLite via [CommunityRepositoryImpl.toggleStarBookmark],
/// so they are fully available offline after first load.
class StarProfileBookmarksPage extends StatelessWidget {
  const StarProfileBookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        title: const Text(
          'BOOKMARKED STARS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.4),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.wifi_square,
                      size: 12, color: AppColors.success),
                  SizedBox(width: 4),
                  Text(
                    'OFFLINE',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<CommunityBloc, CommunityState>(
        builder: (context, state) {
          if (state is CommunityLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.comicRed),
            );
          }

          final bookmarkedStars = state is CommunityLoaded
              ? state.starProfiles.where((s) => s.isBookmarked).toList()
              : <StarProfile>[];

          if (bookmarkedStars.isEmpty) {
            return _EmptyStarsBookmark(isDark: isDark);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bookmarkedStars.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final star = bookmarkedStars[index];
              return _StarBookmarkCard(star: star, isDark: isDark);
            },
          );
        },
      ),
    );
  }
}

// ── Star Bookmark Card ─────────────────────────────────────────────────────
class _StarBookmarkCard extends StatelessWidget {
  final StarProfile star;
  final bool isDark;

  const _StarBookmarkCard({required this.star, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.of(context).pushNamed('/star-detail', arguments: star),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Top banner image ────────────────────────────────────────
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: star.avatarUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.darkSurfaceElevated,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.comicRed,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.darkSurfaceElevated,
                    child: const Icon(
                      Iconsax.profile_circle,
                      size: 48,
                      color: Colors.white30,
                    ),
                  ),
                ),
              ),
            ),

            // ── Info Row ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circular mini avatar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: CachedNetworkImage(
                      imageUrl: star.avatarUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 44,
                        height: 44,
                        color: AppColors.comicGrayLight,
                        child: const Icon(Iconsax.profile_circle,
                            size: 22, color: AppColors.comicGray),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.darkSecondary
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            star.category.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.darkSecondary,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          star.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color:
                                isDark ? Colors.white : AppColors.comicBlack,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          star.role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.comicGray,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Remove bookmark button
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Iconsax.bookmark,
                            color: AppColors.darkAccentGold, size: 22),
                        tooltip: 'Remove bookmark',
                        onPressed: () {
                          context
                              .read<CommunityBloc>()
                              .add(ToggleStarBookmarkEvent(star.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${star.name} removed from bookmarks.'),
                              backgroundColor: AppColors.comicBlack,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Bio excerpt ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (star.bio.isNotEmpty)
                    Text(
                      star.bio.length > 110
                          ? '${star.bio.substring(0, 107)}...'
                          : star.bio,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  const SizedBox(height: 10),

                  // Footer: fans count + offline badge + view button
                  Row(
                    children: [
                      const Icon(Iconsax.people,
                          size: 13, color: AppColors.comicGray),
                      const SizedBox(width: 4),
                      Text(
                        '${star.followersCount} fans',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.comicGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.wifi_square,
                                size: 9, color: AppColors.success),
                            SizedBox(width: 2),
                            Text(
                              'OFFLINE',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'View Profile',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Iconsax.arrow_right_3,
                              size: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.comicGray,
                            ),
                          ],
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

// ── Empty State ────────────────────────────────────────────────────────────
class _EmptyStarsBookmark extends StatelessWidget {
  final bool isDark;
  const _EmptyStarsBookmark({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.comicYellow,
              ),
              child: const Icon(Iconsax.profile_circle,
                  size: 38, color: AppColors.comicBlack),
            ),
            const SizedBox(height: 16),
            const Text(
              'NO STARS BOOKMARKED',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Go to Community → Stars Directory and tap the bookmark icon on any star to save their profile for offline access.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.comicGray,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Iconsax.people, size: 16),
              label: const Text(
                'Browse Stars Directory',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.comicYellow,
                foregroundColor: AppColors.comicBlack,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () =>
                  Navigator.of(context).pushNamed('/stars-directory'),
            ),
          ],
        ),
      ),
    );
  }
}
