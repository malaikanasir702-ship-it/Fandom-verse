import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../fandom_hub/presentation/bloc/fandom_hub_bloc.dart';
import '../../../fandom_hub/presentation/bloc/fandom_hub_state.dart';
import '../../../events/presentation/bloc/event_bloc.dart';
import '../../../events/presentation/bloc/event_state.dart';

class OfflineContentPage extends StatefulWidget {
  const OfflineContentPage({super.key});

  @override
  State<OfflineContentPage> createState() => _OfflineContentPageState();
}

class _OfflineContentPageState extends State<OfflineContentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Reload profile stats when entering this page
    final userId = context.read<AuthBloc>().currentUser?.id;
    if (userId != null && userId.isNotEmpty) {
      context.read<ProfileBloc>().add(LoadUserProfileEvent(userId: userId));
    }
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
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Offline Content',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.comicRed,
          labelColor: AppColors.comicRed,
          unselectedLabelColor: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(icon: Icon(Iconsax.book, size: 18), text: 'Articles'),
            Tab(icon: Icon(Iconsax.calendar_2, size: 18), text: 'Events'),
            Tab(icon: Icon(Iconsax.book_1, size: 18), text: 'Glossary'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Cache Info Banner ──────────────────────────────────────────
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is! ProfileLoaded) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.wifi_square,
                        color: AppColors.comicRed, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Local Cache: ${state.cacheSizeMB} MB',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${state.offlinePostsCount} articles · '
                            '${state.offlineEventsCount} events · '
                            '${state.offlineGlossaryCount} glossary terms',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Clear cache button
                    TextButton.icon(
                      onPressed: () => _confirmClearCache(context),
                      icon: const Icon(Iconsax.trash,
                          size: 14, color: AppColors.error),
                      label: const Text(
                        'Clear',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ── Tab Content ────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ArticlesOfflineTab(isDark: isDark),
                _EventsOfflineTab(isDark: isDark),
                _GlossaryOfflineTab(isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: AppColors.error.withValues(alpha: 0.3)),
        ),
        title: const Row(
          children: [
            Icon(Iconsax.warning_2, color: AppColors.error, size: 22),
            SizedBox(width: 8),
            Text(
              'Clear Offline Cache?',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.comicBlack),
            ),
          ],
        ),
        content: const Text(
          'This will remove all locally cached articles, events, and glossary data. You will need an internet connection to reload them.',
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.comicGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              final userId =
                  context.read<AuthBloc>().currentUser?.id ?? '';
              context.read<ProfileBloc>().add(
                    ClearLocalCacheStorageEvent(userId: userId),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Offline cache cleared successfully.'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Clear Cache',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ── Articles Tab ───────────────────────────────────────────────────────────
class _ArticlesOfflineTab extends StatelessWidget {
  final bool isDark;
  const _ArticlesOfflineTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FandomHubBloc, FandomHubState>(
      builder: (context, state) {
        if (state is! FandomHubLoaded) {
          return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.comicRed));
        }

        // Show all cached posts (all are available offline via SQLite)
        final posts = [
          ...state.latestNews,
          ...state.trendingPosts,
        ];
        // Deduplicate by id
        final seen = <String>{};
        final unique = posts
            .where((p) => seen.add(p.id))
            .toList();

        if (unique.isEmpty) {
          return _EmptyOffline(
            icon: Iconsax.book,
            title: 'No Articles Cached',
            subtitle: 'Browse Lore Hub to cache articles for offline reading.',
            isDark: isDark,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: unique.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final post = unique[i];
            return GestureDetector(
              onTap: () => Navigator.of(context)
                  .pushNamed('/news-detail', arguments: post),
              child: Container(
                padding: const EdgeInsets.all(12),
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
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        post.imageUrl,
                        width: 66,
                        height: 66,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 66,
                          height: 66,
                          color: AppColors.comicGrayLight,
                          child: const Icon(Iconsax.book,
                              color: AppColors.comicGray),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.comicRed,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  post.category.toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Offline badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.success
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Iconsax.wifi_square,
                                        size: 9,
                                        color: AppColors.success),
                                    SizedBox(width: 2),
                                    Text(
                                      'OFFLINE',
                                      style: TextStyle(
                                          color: AppColors.success,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            post.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              height: 1.25,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.comicBlack,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${post.readTimeMinutes} min read',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.comicGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Iconsax.arrow_right_3,
                        size: 14, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Events Tab ─────────────────────────────────────────────────────────────
class _EventsOfflineTab extends StatelessWidget {
  final bool isDark;
  const _EventsOfflineTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCalendarBloc, EventCalendarState>(
      builder: (context, state) {
        if (state is! EventLoaded) {
          return const Center(
              child:
                  CircularProgressIndicator(color: AppColors.comicRed));
        }

        final events = state.allEvents;

        if (events.isEmpty) {
          return _EmptyOffline(
            icon: Iconsax.calendar_2,
            title: 'No Events Cached',
            subtitle:
                'Visit Event Calendar to cache upcoming conventions offline.',
            isDark: isDark,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final event = events[i];
            final daysUntil =
                event.eventDate.difference(DateTime.now()).inDays;
            return GestureDetector(
              onTap: () => Navigator.of(context)
                  .pushNamed('/event-detail', arguments: event),
              child: GlassContainer(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        event.bannerUrl,
                        width: 66,
                        height: 66,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 66,
                          height: 66,
                          color: AppColors.comicGrayLight,
                          child: const Icon(Iconsax.calendar_2,
                              color: AppColors.comicGray),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.heroBlue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  event.category.toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              if (event.isBookmarked) ...[
                                const SizedBox(width: 6),
                                const Icon(Iconsax.bookmark,
                                    size: 12,
                                    color: AppColors.comicYellow),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.comicBlack,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Iconsax.location,
                                  size: 11,
                                  color: AppColors.comicGray),
                              const SizedBox(width: 3),
                              Text(
                                event.cityName,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.comicGray,
                                ),
                              ),
                              if (daysUntil > 0) ...[
                                const SizedBox(width: 8),
                                Text(
                                  'In $daysUntil days',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Iconsax.arrow_right_3,
                        size: 14, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Glossary Tab ───────────────────────────────────────────────────────────
class _GlossaryOfflineTab extends StatelessWidget {
  final bool isDark;
  const _GlossaryOfflineTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FandomHubBloc, FandomHubState>(
      builder: (context, state) {
        if (state is! FandomHubLoaded) {
          return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.comicRed));
        }

        final terms = state.glossary;

        if (terms.isEmpty) {
          return _EmptyOffline(
            icon: Iconsax.book_1,
            title: 'No Glossary Terms Cached',
            subtitle: 'Visit Lore Hub → Glossary to cache fandom terms.',
            isDark: isDark,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: terms.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final term = terms[i];
            return GlassContainer(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              term.term,
                              style: const TextStyle(
                                color: AppColors.comicRed,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (term.phonetic.isNotEmpty)
                              Text(
                                term.phonetic,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          term.definition,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.comicBlack,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.comicYellow
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            term.fandomCategory.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.comicBlack,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Offline badge
                  const Column(
                    children: [
                      Icon(Iconsax.wifi_square,
                          size: 16, color: AppColors.success),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Empty State Widget ─────────────────────────────────────────────────────
class _EmptyOffline extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  const _EmptyOffline({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.comicRed.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: AppColors.comicRed),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    isDark ? AppColors.darkTextSecondary : AppColors.comicGray,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
