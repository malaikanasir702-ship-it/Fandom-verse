import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../fandom_hub/presentation/pages/fan_feed_page.dart';
import '../../../fandom_hub/presentation/pages/fandom_lore_hub_page.dart';
import '../../../events/presentation/pages/events_calendar_page.dart';
import '../../../community/presentation/pages/discussions_page.dart';
import '../../../fandom_hub/presentation/pages/bookmarks_page.dart';
import '../../../fandom_hub/presentation/bloc/fandom_hub_bloc.dart';
import '../../../fandom_hub/presentation/bloc/fandom_hub_event.dart';
import '../../../events/presentation/bloc/event_bloc.dart';
import '../../../events/presentation/bloc/event_event.dart';
import '../../../community/presentation/bloc/community_bloc.dart';
import '../../../community/presentation/bloc/community_event.dart';

class FanShellPage extends StatefulWidget {
  const FanShellPage({super.key});

  @override
  State<FanShellPage> createState() => _FanShellPageState();
}

class _FanShellPageState extends State<FanShellPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    FanFeedPage(),
    FandomLoreHubPage(),
    EventsCalendarPage(),
    DiscussionsPage(),
    BookmarksPage(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<FandomHubBloc>().add(const LoadFandomHubContentEvent());
    context.read<EventCalendarBloc>().add(const LoadAllEventsEvent());
    context.read<CommunityBloc>().add(const LoadDiscussionThreadsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.8,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          indicatorColor: isDark
              ? AppColors.darkSecondary.withValues(alpha: 0.18)
              : AppColors.lightPrimary.withValues(alpha: 0.12),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories_rounded),
              label: 'Lore Hub',
            ),
            NavigationDestination(
              icon: Icon(Icons.radar_outlined),
              selectedIcon: Icon(Icons.radar_rounded),
              label: 'Events',
            ),
            NavigationDestination(
              icon: Icon(Icons.forum_outlined),
              selectedIcon: Icon(Icons.forum_rounded),
              label: 'Community',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_outline_rounded),
              selectedIcon: Icon(Icons.bookmark_rounded),
              label: 'Saved',
            ),
          ],
        ),
      ),
    );
  }
}
