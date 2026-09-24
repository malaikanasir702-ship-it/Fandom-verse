import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';
import '../bloc/community_state.dart';
import '../../domain/entities/discussion_thread.dart';

class DiscussionsPage extends StatelessWidget {
  const DiscussionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        if (state is CommunityLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (state is CommunityLoaded) {
          return _DiscussionsContent(state: state);
        }
        return const Scaffold(body: Center(child: Text('Error loading discussions.')));
      },
    );
  }
}

class _DiscussionsContent extends StatelessWidget {
  final CommunityLoaded state;
  const _DiscussionsContent({required this.state});

  static const _channels = ['All', 'Anime & Manga', 'Gaming & Esports', 'Sci-Fi & Fantasy', 'K-Pop & Idol Culture'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.people),
            onPressed: () => Navigator.of(context).pushNamed('/stars-directory'),
          ),
          IconButton(
            icon: const Icon(Iconsax.add_square),
            onPressed: () => Navigator.of(context).pushNamed('/create-thread'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Channel Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: _channels.map((ch) {
                final isSelected = state.activeCategory == ch;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => context.read<CommunityBloc>().add(FilterThreadsByCategoryEvent(ch)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.darkPrimary
                            : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.darkPrimary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                      ),
                      child: Text(
                        '#${ch.replaceAll(' & ', '&')}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : null,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Threads
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: state.filteredThreads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                return _ThreadCard(
                  thread: state.filteredThreads[i],
                  onUpvote: () => context.read<CommunityBloc>()
                      .add(UpvoteThreadEvent(state.filteredThreads[i].id)),
                  onTap: () => Navigator.of(context).pushNamed(
                    '/thread-detail',
                    arguments: state.filteredThreads[i],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  final DiscussionThread thread;
  final VoidCallback onUpvote;
  final VoidCallback onTap;

  const _ThreadCard({required this.thread, required this.onUpvote, required this.onTap});

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkPrimary.withValues(alpha: 0.2),
                ),
                child: Center(
                  child: Text(thread.userName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkPrimary)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(thread.userName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text(
                      '${thread.userBadge}  •  ${_timeAgo(thread.createdAt)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.darkPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${thread.category.split(' ').first}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.darkPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(thread.title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700, height: 1.3)),
          const SizedBox(height: 6),
          Text(
            thread.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),

          // Footer
          Row(
            children: [
              GestureDetector(
                onTap: onUpvote,
                child: Row(
                  children: [
                    Icon(
                      thread.isUpvoted ? Iconsax.arrow_up : Iconsax.arrow_up_2,
                      size: 16,
                      color: thread.isUpvoted ? AppColors.darkPrimary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${thread.upvotes}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: thread.isUpvoted ? AppColors.darkPrimary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Icon(Iconsax.message, size: 16, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              const SizedBox(width: 4),
              Text(
                '${thread.replies.length} replies',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


