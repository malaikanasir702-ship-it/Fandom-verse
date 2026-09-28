import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated shimmer skeleton loader for content placeholders.
/// Usage:
///   SkeletonLoader(width: double.infinity, height: 200)
///   SkeletonBox(width: 120, height: 16, borderRadius: 8)
///   SkeletonFeedCard()
///   SkeletonEventCard()
///   SkeletonProductCard()
///   SkeletonProfileHeader()
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets? margin;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
    this.margin,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkSurface : const Color(0xFFE8E8E8);
    final shimmerColor = isDark ? AppColors.darkSurfaceElevated : Colors.white;

    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, shimmerColor, baseColor],
              stops: [
                (_shimmer.value - 1).clamp(0.0, 1.0),
                _shimmer.value.clamp(0.0, 1.0),
                (_shimmer.value + 1).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Convenience alias ──────────────────────────────────────────────────────
typedef SkeletonBox = SkeletonLoader;

// ── Feed Card Skeleton (for fan feed news cards) ───────────────────────────
class SkeletonFeedCard extends StatelessWidget {
  const SkeletonFeedCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(width: 84, height: 84, borderRadius: 12),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: 60, height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                SkeletonLoader(width: double.infinity, height: 14, borderRadius: 4),
                const SizedBox(height: 4),
                SkeletonLoader(width: double.infinity * 0.7, height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                SkeletonLoader(width: 80, height: 12, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Banner Skeleton (for trending carousel) ────────────────────────────────
class SkeletonBannerCarousel extends StatelessWidget {
  const SkeletonBannerCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SkeletonLoader(
            width: double.infinity,
            height: 220,
            borderRadius: 20,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            child: SkeletonLoader(
              width: i == 0 ? 22 : 7,
              height: 7,
              borderRadius: 4,
            ),
          )),
        ),
      ],
    );
  }
}

// ── Story Ring Row Skeleton ────────────────────────────────────────────────
class SkeletonStoryRings extends StatelessWidget {
  const SkeletonStoryRings({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: 6,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Column(
            children: [
              SkeletonLoader(width: 68, height: 68, borderRadius: 34),
              const SizedBox(height: 6),
              SkeletonLoader(width: 50, height: 10, borderRadius: 4),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Event Card Skeleton ────────────────────────────────────────────────────
class SkeletonEventCard extends StatelessWidget {
  const SkeletonEventCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: SkeletonLoader(
        width: double.infinity,
        height: 200,
        borderRadius: 20,
      ),
    );
  }
}

// ── Product Card Skeleton ──────────────────────────────────────────────────
class SkeletonProductCard extends StatelessWidget {
  const SkeletonProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonLoader(width: double.infinity, height: 160, borderRadius: 16),
        const SizedBox(height: 8),
        SkeletonLoader(width: 60, height: 10, borderRadius: 4),
        const SizedBox(height: 4),
        SkeletonLoader(width: double.infinity, height: 12, borderRadius: 4),
        const SizedBox(height: 4),
        SkeletonLoader(width: 80, height: 12, borderRadius: 4),
      ],
    );
  }
}

// ── Profile Header Skeleton ────────────────────────────────────────────────
class SkeletonProfileHeader extends StatelessWidget {
  const SkeletonProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Center(
          child: SkeletonLoader(width: 96, height: 96, borderRadius: 48),
        ),
        const SizedBox(height: 12),
        Center(child: SkeletonLoader(width: 140, height: 16, borderRadius: 6)),
        const SizedBox(height: 6),
        Center(child: SkeletonLoader(width: 200, height: 12, borderRadius: 4)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: SkeletonLoader(width: double.infinity, height: 56, borderRadius: 12)),
            const SizedBox(width: 12),
            Expanded(child: SkeletonLoader(width: double.infinity, height: 56, borderRadius: 12)),
            const SizedBox(width: 12),
            Expanded(child: SkeletonLoader(width: double.infinity, height: 56, borderRadius: 12)),
          ],
        ),
      ],
    );
  }
}

// ── Full Feed Page Skeleton (combined) ────────────────────────────────────
class SkeletonFeedPage extends StatelessWidget {
  const SkeletonFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          const SkeletonBannerCarousel(),
          const SizedBox(height: 16),
          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SkeletonLoader(width: 160, height: 14, borderRadius: 4),
          ),
          const SizedBox(height: 10),
          // Stories
          const SkeletonStoryRings(),
          const SizedBox(height: 20),
          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SkeletonLoader(width: 140, height: 14, borderRadius: 4),
          ),
          const SizedBox(height: 10),
          // News cards
          const SkeletonFeedCard(),
          const SkeletonFeedCard(),
          const SkeletonFeedCard(),
        ],
      ),
    );
  }
}

// ── Store Page Skeleton ────────────────────────────────────────────────────
class SkeletonStorePage extends StatelessWidget {
  const SkeletonStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SkeletonLoader(width: double.infinity, height: 48, borderRadius: 16),
          const SizedBox(height: 12),
          SkeletonLoader(width: double.infinity, height: 90, borderRadius: 20),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 6,
            itemBuilder: (_, __) => const SkeletonProductCard(),
          ),
        ],
      ),
    );
  }
}

// ── Events Calendar Skeleton ───────────────────────────────────────────────
class SkeletonEventsPage extends StatelessWidget {
  const SkeletonEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => const SkeletonEventCard(),
    );
  }
}

// ── Cart Page Skeleton ─────────────────────────────────────────────────────
class SkeletonCartPage extends StatelessWidget {
  const SkeletonCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        // Promo / Shipping Notice Skeleton
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SkeletonLoader(width: double.infinity, height: 42, borderRadius: 12),
        ),
        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: 3,
            itemBuilder: (_, __) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
                  width: 1.2,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(width: 80, height: 80, borderRadius: 12),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoader(width: double.infinity * 0.8, height: 16, borderRadius: 4),
                        const SizedBox(height: 6),
                        SkeletonLoader(width: 70, height: 12, borderRadius: 4),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SkeletonLoader(width: 60, height: 16, borderRadius: 4),
                            SkeletonLoader(width: 90, height: 28, borderRadius: 8),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Summary & Checkout Bar Skeleton
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonLoader(width: 80, height: 14, borderRadius: 4),
                  SkeletonLoader(width: 70, height: 14, borderRadius: 4),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonLoader(width: 100, height: 18, borderRadius: 4),
                  SkeletonLoader(width: 90, height: 20, borderRadius: 4),
                ],
              ),
              const SizedBox(height: 16),
              SkeletonLoader(width: double.infinity, height: 52, borderRadius: 14),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Order History Page Skeleton ────────────────────────────────────────────
class SkeletonOrderHistoryPage extends StatelessWidget {
  const SkeletonOrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLoader(width: 130, height: 16, borderRadius: 4),
                SkeletonLoader(width: 75, height: 22, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SkeletonLoader(width: 50, height: 50, borderRadius: 8),
                const SizedBox(width: 10),
                SkeletonLoader(width: 50, height: 50, borderRadius: 8),
                const SizedBox(width: 10),
                SkeletonLoader(width: 50, height: 50, borderRadius: 8),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLoader(width: 90, height: 14, borderRadius: 4),
                SkeletonLoader(width: 80, height: 16, borderRadius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stars / Creator Directory Skeleton ────────────────────────────────────
class SkeletonStarsDirectoryPage extends StatelessWidget {
  const SkeletonStarsDirectoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Category chips row
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SkeletonLoader(width: i == 0 ? 70 : 100, height: 36, borderRadius: 20),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Star Cards
        ...List.generate(
          4,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                SkeletonLoader(width: 64, height: 64, borderRadius: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(width: 140, height: 16, borderRadius: 4),
                      const SizedBox(height: 6),
                      SkeletonLoader(width: 90, height: 12, borderRadius: 4),
                      const SizedBox(height: 6),
                      SkeletonLoader(width: 110, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
                SkeletonLoader(width: 72, height: 32, borderRadius: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Admin Dashboard Skeleton ──────────────────────────────────────────────
class SkeletonAdminDashboardPage extends StatelessWidget {
  const SkeletonAdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & summary banner
          SkeletonLoader(width: double.infinity, height: 90, borderRadius: 16),
          const SizedBox(height: 16),
          // 4 Stat Cards in 2x2 grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            itemCount: 4,
            itemBuilder: (_, __) => SkeletonLoader(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 16,
            ),
          ),
          const SizedBox(height: 24),
          // Section header
          SkeletonLoader(width: 160, height: 18, borderRadius: 4),
          const SizedBox(height: 12),
          // Recent items list
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SkeletonLoader(width: double.infinity, height: 72, borderRadius: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Admin List Page Skeleton (Events, Store, Users, Content, Stories) ──────
class SkeletonAdminListPage extends StatelessWidget {
  const SkeletonAdminListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Admin panel is always light-themed — force light skeleton colors
    return Theme(
      data: Theme.of(context).copyWith(brightness: Brightness.light),
      child: Container(
        color: const Color(0xFFF8F9FA),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Search & Filter Bar
            Row(
              children: [
                Expanded(child: SkeletonLoader(width: double.infinity, height: 44, borderRadius: 12)),
                const SizedBox(width: 10),
                SkeletonLoader(width: 44, height: 44, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 16),
            // Filter pills
            SizedBox(
              height: 34,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SkeletonLoader(width: 80, height: 34, borderRadius: 17),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Admin Item Cards
            ...List.generate(
              5,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SkeletonLoader(width: double.infinity, height: 86, borderRadius: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Offline Content Page Skeleton ─────────────────────────────────────────
class SkeletonOfflineContentPage extends StatelessWidget {
  const SkeletonOfflineContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Storage Card
        SkeletonLoader(width: double.infinity, height: 110, borderRadius: 16),
        const SizedBox(height: 20),
        SkeletonLoader(width: 140, height: 16, borderRadius: 4),
        const SizedBox(height: 12),
        ...List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SkeletonLoader(width: double.infinity, height: 76, borderRadius: 14),
          ),
        ),
      ],
    );
  }
}

// ── Thread Detail Skeleton ────────────────────────────────────────────────
class SkeletonThreadDetailPage extends StatelessWidget {
  const SkeletonThreadDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonLoader(width: 44, height: 44, borderRadius: 22),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(width: 120, height: 14, borderRadius: 4),
                  const SizedBox(height: 4),
                  SkeletonLoader(width: 80, height: 10, borderRadius: 4),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SkeletonLoader(width: double.infinity, height: 20, borderRadius: 4),
          const SizedBox(height: 8),
          SkeletonLoader(width: double.infinity * 0.6, height: 20, borderRadius: 4),
          const SizedBox(height: 16),
          SkeletonLoader(width: double.infinity, height: 14, borderRadius: 4),
          const SizedBox(height: 6),
          SkeletonLoader(width: double.infinity, height: 14, borderRadius: 4),
          const SizedBox(height: 6),
          SkeletonLoader(width: double.infinity * 0.8, height: 14, borderRadius: 4),
          const SizedBox(height: 24),
          SkeletonLoader(width: 110, height: 16, borderRadius: 4),
          const SizedBox(height: 12),
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SkeletonLoader(width: double.infinity, height: 80, borderRadius: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Event Detail Skeleton ─────────────────────────────────────────────────
class SkeletonEventDetailPage extends StatelessWidget {
  const SkeletonEventDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(width: double.infinity, height: 260, borderRadius: 0),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: 90, height: 22, borderRadius: 11),
                const SizedBox(height: 10),
                SkeletonLoader(width: double.infinity * 0.85, height: 22, borderRadius: 4),
                const SizedBox(height: 14),
                SkeletonLoader(width: 160, height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                SkeletonLoader(width: 200, height: 14, borderRadius: 4),
                const SizedBox(height: 20),
                SkeletonLoader(width: double.infinity, height: 14, borderRadius: 4),
                const SizedBox(height: 6),
                SkeletonLoader(width: double.infinity, height: 14, borderRadius: 4),
                const SizedBox(height: 6),
                SkeletonLoader(width: double.infinity * 0.7, height: 14, borderRadius: 4),
                const SizedBox(height: 24),
                SkeletonLoader(width: double.infinity, height: 52, borderRadius: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Product Detail Skeleton ───────────────────────────────────────────────
class SkeletonProductDetailPage extends StatelessWidget {
  const SkeletonProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(width: double.infinity, height: 320, borderRadius: 0),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonLoader(width: 80, height: 14, borderRadius: 4),
                    SkeletonLoader(width: 60, height: 14, borderRadius: 4),
                  ],
                ),
                const SizedBox(height: 8),
                SkeletonLoader(width: double.infinity * 0.8, height: 22, borderRadius: 4),
                const SizedBox(height: 10),
                SkeletonLoader(width: 100, height: 24, borderRadius: 4),
                const SizedBox(height: 20),
                SkeletonLoader(width: double.infinity, height: 14, borderRadius: 4),
                const SizedBox(height: 6),
                SkeletonLoader(width: double.infinity, height: 14, borderRadius: 4),
                const SizedBox(height: 24),
                SkeletonLoader(width: double.infinity, height: 52, borderRadius: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Map Loading Skeleton ──────────────────────────────────────────────────
class SkeletonMapLoading extends StatelessWidget {
  const SkeletonMapLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: SkeletonLoader(width: double.infinity, height: double.infinity, borderRadius: 0),
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: SkeletonLoader(width: double.infinity, height: 48, borderRadius: 16),
        ),
        Positioned(
          bottom: 24,
          left: 16,
          right: 16,
          child: SkeletonLoader(width: double.infinity, height: 130, borderRadius: 20),
        ),
      ],
    );
  }
}
