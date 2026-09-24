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

import 'package:iconsax_flutter/iconsax_flutter.dart';

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
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          indicatorColor: AppColors.comicRed,
          destinations: const [
            NavigationDestination(
              icon: Icon(Iconsax.home),
              selectedIcon: Icon(Iconsax.home, color: Colors.white),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.book),
              selectedIcon: Icon(Iconsax.book, color: Colors.white),
              label: 'Lore Hub',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.calendar),
              selectedIcon: Icon(Iconsax.calendar, color: Colors.white),
              label: 'Events',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.messages),
              selectedIcon: Icon(Iconsax.messages, color: Colors.white),
              label: 'Community',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.bookmark),
              selectedIcon: Icon(Iconsax.bookmark, color: Colors.white),
              label: 'Saved',
            ),
          ],
        ),
      ),
    );
  }
}
