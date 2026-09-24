import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// COMIC UI SECTION HEADER
/// Section title with solid yellow/red circular arrow action button.
/// ─────────────────────────────────────────────────────────────────────────────
class ComicSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onActionTap;
  final Color actionColor;

  const ComicSectionHeader({
    super.key,
    required this.title,
    this.onActionTap,
    this.actionColor = AppColors.comicYellow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.comicBlack;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.comicSectionHeader.copyWith(
              color: textColor,
            ),
          ),
          if (onActionTap != null)
            GestureDetector(
              onTap: onActionTap,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: actionColor,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.comicBlack,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// HERO AVATAR RING ("YOUR FAVOURITE HEROES")
/// Circular avatar ring with solid vibrant background and pop-out character art.
/// ─────────────────────────────────────────────────────────────────────────────
class HeroAvatarRing extends StatelessWidget {
  final String name;
  final String imageUrl;
  final Color ringColor;
  final VoidCallback? onTap;

  const HeroAvatarRing({
    super.key,
    required this.name,
    required this.imageUrl,
    this.ringColor = AppColors.heroRed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            // Circular solid color disk with character photo
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Solid colored background circle
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: ringColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : Colors.white,
                      width: 2.5,
                    ),
                  ),
                ),
                // Character Image
                ClipOval(
                  child: SizedBox(
                    width: 62,
                    height: 62,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'H',
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
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 72,
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.comicBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// COMIC COVER CARD ("TOP RATED COMICS")
/// Vertical comic book poster card with rounded corners, issue #, release, and ⚡ rating.
/// ─────────────────────────────────────────────────────────────────────────────
class ComicCoverCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final double rating;
  final String? publisher;
  final VoidCallback? onTap;

  const ComicCoverCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.rating = 8.6,
    this.publisher,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comic Cover Image Box
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 200,
                width: 140,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.comicGrayLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
                    width: 1.2,
                  ),
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.menu_book_rounded, size: 40, color: AppColors.comicGray),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Title (Issue # / Comic Name)
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white : AppColors.comicBlack,
              ),
            ),
            const SizedBox(height: 2),
            // Subtitle / Variant Edition / Date
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.comicGray,
              ),
            ),
            const SizedBox(height: 4),
            // Rating + Publisher Chip
            Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 16, color: AppColors.comicYellow),
                const SizedBox(width: 2),
                Text(
                  rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.comicBlack,
                  ),
                ),
                const Spacer(),
                if (publisher != null && publisher!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: AppColors.comicRed,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      publisher!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// HERO DYNAMIC POP-OUT BANNER (Top Hero Header in Image 1 & 2)
/// ─────────────────────────────────────────────────────────────────────────────
class HeroPopOutBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final double rating;
  final String badgeText;
  final VoidCallback? onTap;

  const HeroPopOutBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.rating = 9.2,
    this.badgeText = 'READ NOW',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 240,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.comicBlack,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.comicBorderColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Artwork
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.comicBlack),
            ),
            // Solid dark overlay panel at bottom for contrast
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                color: Colors.black.withValues(alpha: 0.75),
              ),
            ),
            // Title & Info on Left
            Positioned(
              left: 18,
              bottom: 16,
              right: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.comicTitleLarge.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.bolt_rounded, color: AppColors.comicYellow, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Solid Red Action Badge / Ribbon on Bottom Right
            Positioned(
              right: 14,
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.comicRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// COMIC SOLID RED ACTION BUTTON ("READ NOW")
/// Full-width solid red action button with bold italic text.
/// ─────────────────────────────────────────────────────────────────────────────
class ComicRedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;

  const ComicRedButton({
    super.key,
    this.label = 'READ NOW',
    this.onPressed,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.comicRed,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
