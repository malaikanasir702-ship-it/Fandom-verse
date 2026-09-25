import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Pill nav height + bottom padding — pages use this to avoid content overlap
  static const double _navBarHeight = 64;
  static const double _navBottomPadding = 16;
  static const double _totalNavSpace = _navBarHeight + _navBottomPadding + 8;

  final List<Widget> _pages = const [
    FanFeedPage(),
    FandomLoreHubPage(),
    EventsCalendarPage(),
    DiscussionsPage(),
    BookmarksPage(),
  ];

  static const _navItems = [
    _NavItem(icon: Iconsax.home, label: 'Home'),
    _NavItem(icon: Iconsax.book, label: 'Lore'),
    _NavItem(icon: Iconsax.calendar, label: 'Events'),
    _NavItem(icon: Iconsax.messages, label: 'Community'),
    _NavItem(icon: Iconsax.bookmark, label: 'Saved'),
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
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      // No bottomNavigationBar — we float it over content
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages.map((page) {
          // Wrap each page so its ListView/content has bottom padding
          // equal to nav height, preventing content from hiding under the pill.
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: MediaQuery.of(context).padding.copyWith(
                bottom: _totalNavSpace + bottomInset,
              ),
            ),
            child: page,
          );
        }).toList(),
      ),

      // Floating pill nav bar
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: _navBottomPadding + bottomInset,
        ),
        child: _PillNavBar(
          currentIndex: _currentIndex,
          items: _navItems,
          isDark: isDark,
          height: _navBarHeight,
          onTap: (i) {
            HapticFeedback.lightImpact();
            setState(() => _currentIndex = i);
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pill Navigation Bar Widget
// ─────────────────────────────────────────────────────────────────────────────

class _PillNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;
  final bool isDark;
  final double height;

  const _PillNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
    required this.isDark,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.96)
        : Colors.white.withValues(alpha: 0.97);
    final borderColor =
        isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.45)
                : Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          return Expanded(
            child: _NavTile(
              item: items[i],
              isSelected: i == currentIndex,
              isDark: isDark,
              onTap: () => onTap(i),
            ),
          );
        }),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.comicRed;
    final inactiveColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pill indicator + icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                item.icon,
                size: 22,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? activeColor : inactiveColor,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
