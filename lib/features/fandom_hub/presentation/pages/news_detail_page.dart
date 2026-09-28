import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/comic_ui_widgets.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../../core/widgets/app_display_image.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../bloc/fandom_hub_bloc.dart';
import '../bloc/fandom_hub_event.dart';
import '../bloc/fandom_hub_state.dart';
import '../../domain/entities/fandom_post.dart';

class NewsDetailPage extends StatefulWidget {
  final FandomPost post;

  const NewsDetailPage({super.key, required this.post});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage>
    with TickerProviderStateMixin {
  bool _isSynopsisExpanded = true;
  late bool _isBookmarked;
  bool _isLiked = false;
  int _likeCount = 0;

  // Heart burst animation
  late AnimationController _heartController;
  late Animation<double> _heartScale;
  late Animation<double> _heartOpacity;
  final List<_HeartParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.post.isBookmarked;
    _likeCount = math.Random().nextInt(4800) + 200;

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heartScale = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );
    _heartOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _heartController,
          curve: const Interval(0.0, 0.3, curve: Curves.easeIn)),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _toggleBookmark() {
    context.read<FandomHubBloc>().add(ToggleBookmarkPostEvent(widget.post.id));
    setState(() => _isBookmarked = !_isBookmarked);
    AppSnackbar.show(
      context,
      _isBookmarked ? 'Saved to your collection!' : 'Removed from saved items.',
      type: _isBookmarked ? SnackbarType.success : SnackbarType.info,
      duration: const Duration(seconds: 2),
    );
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
      if (_isLiked) {
        _particles.clear();
        final rng = math.Random();
        for (int i = 0; i < 8; i++) {
          _particles.add(_HeartParticle(
            angle: rng.nextDouble() * 2 * math.pi,
            distance: 30 + rng.nextDouble() * 40,
          ));
        }
        _heartController.forward(from: 0);
      }
    });
  }

  void _share() {
    final post = widget.post;
    Share.share(
      '🎌 Check out this Fandom Verse article!\n\n'
      '"${post.title}"\n\n'
      'Category: ${post.category}\n'
      '${post.summary}\n\n'
      '📲 Download Fandom Verse — Your fandom pocket companion!',
      subject: post.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<FandomHubBloc, FandomHubState>(
      listener: (context, state) {
        if (state is FandomHubLoaded) {
          final found = [
            ...state.latestNews,
            ...state.trendingPosts,
          ].where((p) => p.id == post.id).firstOrNull;
          if (found != null && found.isBookmarked != _isBookmarked) {
            setState(() => _isBookmarked = found.isBookmarked);
          }
        }
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.comicYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.arrow_left,
                      color: AppColors.comicBlack, size: 18),
                ),
              ),
            ),
          ),
          title: Text(
            post.category.toUpperCase(),
            style: AppTextStyles.comicSectionHeader.copyWith(
              fontSize: 18,
              color: isDark ? Colors.white : AppColors.comicBlack,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Audio Lore narration started...'),
                        backgroundColor: AppColors.comicBlack,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.comicYellow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.headphone,
                        color: AppColors.comicBlack, size: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover image
                  Center(
                    child: Container(
                      width: 190,
                      height: 270,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.comicBorderColor,
                          width: 1.5,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AppDisplayImage(
                        pathOrUrl: post.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: const Center(
                          child: Icon(Iconsax.book,
                              size: 50, color: AppColors.comicGray),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Metadata bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${post.readTimeMinutes} min read',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.comicGray,
                        ),
                      ),
                      Text(
                        'ISSUE #1',
                        style: AppTextStyles.comicRating.copyWith(
                          fontSize: 16,
                          color: isDark ? Colors.white : AppColors.comicBlack,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Iconsax.flash,
                              color: AppColors.comicYellow, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '8.6',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color:
                                  isDark ? Colors.white : AppColors.comicBlack,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Also Read
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.comicBorderColor,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ALSO READ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: isDark
                                ? AppColors.comicYellow
                                : AppColors.comicRed,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildVariantRow('001 Variant Edition', isDark),
                        const Divider(height: 14, thickness: 0.8),
                        _buildVariantRow("002 Director's Cut", isDark),
                        const Divider(height: 14, thickness: 0.8),
                        _buildVariantRow('003 Foil Cover Edition', isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Featured Characters
                  Text(
                    'FEATURED CHARACTERS',
                    style: AppTextStyles.comicSectionHeader.copyWith(
                      fontSize: 14,
                      color:
                          isDark ? Colors.white : AppColors.comicBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildCharacterChip(post.authorName, AppColors.heroRed),
                      _buildCharacterChip(post.category, AppColors.heroBlue),
                      _buildCharacterChip(
                          'The Fandom Hero', AppColors.heroYellow),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Synopsis
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.comicBorderColor,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SYNOPSIS',
                              style: AppTextStyles.comicSectionHeader.copyWith(
                                fontSize: 15,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.comicBlack,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() =>
                                  _isSynopsisExpanded = !_isSynopsisExpanded),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: AppColors.comicRed,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isSynopsisExpanded
                                      ? Iconsax.arrow_up_2
                                      : Iconsax.arrow_down_1,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          post.summary,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            color:
                                isDark ? Colors.white : AppColors.comicBlack,
                          ),
                        ),
                        if (_isSynopsisExpanded) ...[
                          const SizedBox(height: 10),
                          Text(
                            'The story delves deeper into the uncharted territories of the verse. As ancient tensions reignite, loyalties are tested and legends are reborn through supreme conflict and heroic determination.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.55,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.comicGray,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Action Row: Like + Save + Share ──────────────────────
                  Row(
                    children: [
                      // Like button with heart burst
                      _LikeButton(
                        isLiked: _isLiked,
                        likeCount: _likeCount,
                        heartController: _heartController,
                        heartScale: _heartScale,
                        heartOpacity: _heartOpacity,
                        particles: _particles,
                        onTap: _toggleLike,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      // Save
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _isBookmarked
                                  ? AppColors.comicRed
                                  : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.comicBorderColor),
                              width: 1.5,
                            ),
                            backgroundColor: _isBookmarked
                                ? AppColors.comicRed.withValues(alpha: 0.1)
                                : null,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: Icon(
                            Iconsax.bookmark,
                            color: _isBookmarked
                                ? AppColors.comicRed
                                : (isDark ? Colors.white : AppColors.comicBlack),
                            size: 16,
                          ),
                          label: Text(
                            _isBookmarked ? 'SAVED' : 'SAVE',
                            style: TextStyle(
                              color: _isBookmarked
                                  ? AppColors.comicRed
                                  : (isDark ? Colors.white : AppColors.comicBlack),
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                          onPressed: _toggleBookmark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Share — native share sheet
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.comicBorderColor,
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: Icon(
                            Iconsax.share,
                            color: isDark ? Colors.white : AppColors.comicBlack,
                            size: 16,
                          ),
                          label: Text(
                            'SHARE',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : AppColors.comicBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          onPressed: _share,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Pinned READ NOW button
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: ComicRedButton(
                label: 'READ NOW',
                onPressed: () => _showReadingViewer(context, post),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantRow(String title, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.comicBlack,
          ),
        ),
        const Icon(Iconsax.arrow_right_3,
            size: 14, color: AppColors.comicGray),
      ],
    );
  }

  Widget _buildCharacterChip(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        name,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  void _showReadingViewer(BuildContext context, FandomPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        maxChildSize: 0.96,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                post.title.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AppDisplayImage(
                    pathOrUrl: post.imageUrl, fit: BoxFit.cover),
              ),
              const SizedBox(height: 20),
              Text(
                post.summary,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 15, height: 1.6),
              ),
              const SizedBox(height: 30),
              SkewedButton(
                text: 'Close Reader',
                height: 48,
                fontSize: 13,
                backgroundColor: AppColors.comicRed,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Heart particle data ───────────────────────────────────────────────────
class _HeartParticle {
  final double angle;
  final double distance;
  _HeartParticle({required this.angle, required this.distance});
}

// ── Like button with burst animation ─────────────────────────────────────
class _LikeButton extends StatelessWidget {
  final bool isLiked;
  final int likeCount;
  final AnimationController heartController;
  final Animation<double> heartScale;
  final Animation<double> heartOpacity;
  final List<_HeartParticle> particles;
  final VoidCallback onTap;
  final bool isDark;

  const _LikeButton({
    required this.isLiked,
    required this.likeCount,
    required this.heartController,
    required this.heartScale,
    required this.heartOpacity,
    required this.particles,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background pill
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isLiked
                      ? AppColors.comicRed
                      : (isDark
                          ? AppColors.darkBorder
                          : AppColors.comicBorderColor),
                  width: isLiked ? 1.5 : 1.2,
                ),
                color: isLiked
                    ? AppColors.comicRed.withValues(alpha: 0.1)
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: heartController,
                    builder: (_, __) => Transform.scale(
                      scale: isLiked ? heartScale.value : 1.0,
                      child: Icon(
                        isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isLiked
                            ? AppColors.comicRed
                            : (isDark ? Colors.white : AppColors.comicBlack),
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatCount(likeCount),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isLiked
                          ? AppColors.comicRed
                          : (isDark ? Colors.white : AppColors.comicBlack),
                    ),
                  ),
                ],
              ),
            ),

            // Burst particles
            if (isLiked)
              ...particles.map((p) => AnimatedBuilder(
                    animation: heartController,
                    builder: (_, __) {
                      final progress = heartController.value;
                      final dist = p.distance * progress;
                      final opacity = (1.0 - progress).clamp(0.0, 1.0);
                      return Positioned(
                        left: 40 + dist * math.cos(p.angle) - 6,
                        top: 22 + dist * math.sin(p.angle) - 6,
                        child: Opacity(
                          opacity: opacity,
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: AppColors.comicRed,
                            size: 12,
                          ),
                        ),
                      );
                    },
                  )),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '$count';
  }
}
