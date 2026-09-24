import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';
import '../../domain/entities/event_entity.dart';

class EventsCalendarPage extends StatelessWidget {
  const EventsCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCalendarBloc, EventCalendarState>(
      builder: (context, state) {
        if (state is EventLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (state is EventLoaded) {
          return _EventsContent(state: state);
        }
        return const Scaffold(body: Center(child: Text('No events found.')));
      },
    );
  }
}

class _EventsContent extends StatelessWidget {
  final EventLoaded state;
  const _EventsContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            title: const Text('Event Radar', style: TextStyle(fontWeight: FontWeight.w800)),
            actions: [
              IconButton(
                icon: const Icon(Icons.map_rounded),
                onPressed: () => Navigator.of(context).pushNamed('/events-map'),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: AppConstants.popularCities.map((city) {
                    final isSelected = state.selectedCity == city;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => context.read<EventCalendarBloc>()
                            .add(FilterEventsByCityEvent(city)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.darkSecondary
                                : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.darkSecondary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                          ),
                          child: Text(
                            city,
                            style: TextStyle(
                              color: isSelected ? Colors.black : null,
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
            ),
          ),
        ],
        body: state.filteredEvents.isEmpty
            ? const Center(child: Text('No events found for this city.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.filteredEvents.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  return _EventCard(
                    event: state.filteredEvents[i],
                    onBookmark: () => context.read<EventCalendarBloc>()
                        .add(ToggleEventBookmarkEvent(state.filteredEvents[i].id)),
                    onTap: () => Navigator.of(context).pushNamed(
                      '/event-detail',
                      arguments: state.filteredEvents[i],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventEntity event;
  final VoidCallback onBookmark;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.onBookmark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final daysUntil = event.eventDate.difference(now).inDays;
    final dateStr = DateFormat('MMM dd, yyyy').format(event.eventDate);
    final isUpcoming = daysUntil > 0;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Image.network(
                event.bannerUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.darkSurface,
                  child: const Icon(Icons.event_rounded, size: 48, color: Colors.white30),
                ),
              ),
            ),
            // Gradient Overlay
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.88)],
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category + Days badge
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.darkPrimary.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(event.category,
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 8),
                              if (isUpcoming)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'In $daysUntil days',
                                    style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w700),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            event.title,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15, height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 13, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                '${event.cityName}  •  $dateStr',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.people_outline_rounded, size: 13, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                '${NumberFormat.compact().format(event.attendeesCount)} attendees',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Bookmark Button
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            event.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                            color: event.isBookmarked ? AppColors.darkAccentGold : Colors.white70,
                          ),
                          onPressed: onBookmark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
