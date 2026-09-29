import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class InterestSetupPage extends StatefulWidget {
  const InterestSetupPage({super.key});

  @override
  State<InterestSetupPage> createState() => _InterestSetupPageState();
}

class _InterestSetupPageState extends State<InterestSetupPage> {
  late Set<String> _selectedFandoms;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      // Pre-populate from the user's already-saved interests
      final currentUser = context.read<AuthBloc>().currentUser;
      final saved = currentUser?.selectedFandoms ?? [];
      _selectedFandoms = saved.isNotEmpty
          ? Set<String>.from(saved)
          : {'Anime & Manga', 'Gaming & Esports'};
      _initialized = true;
    }
  }

  // ── Category image assets — save these PNGs to assets/images/ ──
  // Images are placed with BlendMode.screen to remove black backgrounds.
  // File naming convention:
  //   cat_anime.png   → Anime warrior (red coat)
  //   cat_kpop.png    → K-Pop idol (blonde girl)
  //   cat_movies.png  → 3D animated character
  //   cat_scifi.png   → Anime girl (pink hair)
  //   cat_marvel.png  → Spider-Man
  //   cat_gaming.png  → Digital art woman (colorful pixels)
  final Map<String, String> _categoryImages = {
    'Anime & Manga':        'assets/images/cat_anime.png',
    'Gaming & Esports':     'assets/images/cat_gaming.png',
    'Sci-Fi & Fantasy':     'assets/images/cat_scifi.png',
    'Marvel & DC Comics':   'assets/images/cat_marvel.png',
    'K-Pop & Idol Culture': 'assets/images/cat_kpop.png',
    'Pop Culture & Movies': 'assets/images/cat_movies.png',
  };

  // Fallback icons — shown when image file is not yet in assets
  final Map<String, IconData> _categoryIcons = {
    'Anime & Manga':        Iconsax.video_play,
    'Gaming & Esports':     Iconsax.game,
    'Sci-Fi & Fantasy':     Iconsax.star_1,
    'Marvel & DC Comics':   Iconsax.book_1,
    'K-Pop & Idol Culture': Iconsax.music,
    'Pop Culture & Movies': Iconsax.ticket_2,
  };

  final Map<String, Color> _categoryColors = {
    'Anime & Manga':        AppColors.animeViolet,
    'Gaming & Esports':     AppColors.gamingGreen,
    'Sci-Fi & Fantasy':     AppColors.sciFiCyan,
    'Marvel & DC Comics':   AppColors.marvelRed,
    'K-Pop & Idol Culture': AppColors.kpopPink,
    'Pop Culture & Movies': AppColors.comicsAmber,
  };

  void _toggleCategory(String cat) {
    setState(() {
      if (_selectedFandoms.contains(cat)) {
        if (_selectedFandoms.length > 1) {
          _selectedFandoms.remove(cat);
        } else {
          AppSnackbar.show(
            context,
            'Select at least 2 fandoms to personalize your feed.',
            type: SnackbarType.warning,
            duration: const Duration(seconds: 2),
          );
        }
      } else {
        _selectedFandoms.add(cat);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is SetupInProgress) {
          Navigator.of(context).pushReplacementNamed('/badge-setup');
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // ── Header row ─────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              AppColors.darkPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'PREFERENCES • 1 OF 2',
                          style: AppTextStyles.badgeText
                              .copyWith(color: AppColors.darkPrimary),
                        ),
                      ),
                      Text(
                        '${_selectedFandoms.length} Selected',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text('Choose Your Universes',
                      style: AppTextStyles.displaySmall),
                  const SizedBox(height: 6),
                  Text(
                    'Select your primary fandom passions to tailor trending carousels, convention radars, and merchandise drops.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Categories Grid ─────────────────────────────────────
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.88, // taller cards = more image
                      ),
                      itemCount: AppConstants.defaultCategories.length,
                      itemBuilder: (context, index) {
                        final cat = AppConstants.defaultCategories[index];
                        final isSelected = _selectedFandoms.contains(cat);
                        final color =
                            _categoryColors[cat] ?? AppColors.darkSecondary;
                        final imagePath = _categoryImages[cat]!;
                        final fallbackIcon =
                            _categoryIcons[cat] ?? Iconsax.star_1;

                        return GlassContainer(
                          padding: EdgeInsets.zero,
                          borderRadius: 20,
                          borderColor: isSelected ? color : null,
                          backgroundColor: isSelected
                              ? color.withValues(alpha: 0.12)
                              : null,
                          onTap: () => _toggleCategory(cat),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // ── Character image filling the card ───────
                                _CategoryImage(
                                  imagePath: imagePath,
                                  fallbackIcon: fallbackIcon,
                                  fallbackColor: color,
                                ),

                                // ── Bottom gradient for text legibility ────
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.75),
                                        ],
                                        stops: const [0.45, 1.0],
                                      ),
                                    ),
                                  ),
                                ),

                                // ── Selected checkmark badge ────────────────
                                if (isSelected)
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: color
                                                .withValues(alpha: 0.5),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                                    ),
                                  ),

                                // ── Category label at bottom ────────────────
                                Positioned(
                                  left: 10,
                                  right: 10,
                                  bottom: 10,
                                  child: Text(
                                    cat,
                                    style:
                                        AppTextStyles.titleMedium.copyWith(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.9),
                                          blurRadius: 8,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  SkewedButton(
                    text: 'Proceed to Badge Selection',
                    icon: Iconsax.arrow_right,
                    height: 52,
                    fontSize: 13,
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<AuthBloc>().add(
                                  UpdateUserInterestsEvent(
                                      _selectedFandoms.toList()),
                                );
                          },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Renders a category character image with [BlendMode.screen] applied.
/// BlendMode.screen makes pure black pixels fully transparent while
/// keeping all coloured pixels intact — perfect for character art with
/// solid black backgrounds.
class _CategoryImage extends StatelessWidget {
  final String imagePath;
  final IconData fallbackIcon;
  final Color fallbackColor;

  const _CategoryImage({
    required this.imagePath,
    required this.fallbackIcon,
    required this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        // Fallback if PNG not yet added to assets/images/
        return Container(
          color: fallbackColor.withValues(alpha: 0.15),
          alignment: Alignment.center,
          child: Icon(fallbackIcon, color: fallbackColor, size: 56),
        );
      },
    );
  }
}
