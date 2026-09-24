import 'package:flutter/material.dart';

// Auth Pages
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/admin_login_page.dart';
import '../../features/auth/presentation/pages/interest_setup_page.dart';
import '../../features/auth/presentation/pages/badge_setup_page.dart';
import '../../features/auth/presentation/pages/fan_shell_page.dart';

// Fandom Hub Pages
import '../../features/fandom_hub/presentation/pages/fan_feed_page.dart';
import '../../features/fandom_hub/presentation/pages/fandom_lore_hub_page.dart';
import '../../features/fandom_hub/presentation/pages/bookmarks_page.dart';
import '../../features/fandom_hub/presentation/pages/news_detail_page.dart';
import '../../features/fandom_hub/presentation/pages/search_explore_page.dart';
import '../../features/fandom_hub/presentation/pages/beginner_hub_detail_page.dart';
import '../../features/fandom_hub/presentation/pages/multimedia_gallery_page.dart';
import '../../features/fandom_hub/domain/entities/fandom_post.dart';

// Events Pages
import '../../features/events/presentation/pages/events_calendar_page.dart';
import '../../features/events/presentation/pages/event_detail_page.dart';
import '../../features/events/presentation/pages/events_map_page.dart';
import '../../features/events/domain/entities/event_entity.dart';

// Community Pages
import '../../features/community/presentation/pages/discussions_page.dart';
import '../../features/community/presentation/pages/thread_detail_page.dart';
import '../../features/community/presentation/pages/create_thread_page.dart';
import '../../features/community/presentation/pages/stars_directory_page.dart';
import '../../features/community/presentation/pages/star_detail_page.dart';
import '../../features/community/domain/entities/discussion_thread.dart';
import '../../features/community/domain/entities/star_profile.dart';

// AI Assistant
import '../../features/ai_assistant/presentation/pages/ai_assistant_page.dart';

// Profile & Settings Pages
import '../../features/profile/presentation/pages/fan_profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/profile/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/badges_achievements_page.dart';

class FanRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashPage());

      case '/role-selection':
        return MaterialPageRoute(builder: (_) => const RoleSelectionPage());

      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingPage());

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case '/admin-login':
        return MaterialPageRoute(builder: (_) => const AdminLoginPage());

      case '/interest-setup':
        return MaterialPageRoute(builder: (_) => const InterestSetupPage());

      case '/badge-setup':
        return MaterialPageRoute(builder: (_) => const BadgeSetupPage());

      case '/fan-shell':
        return MaterialPageRoute(builder: (_) => const FanShellPage());

      case '/feed':
        return MaterialPageRoute(builder: (_) => const FanFeedPage());

      case '/lore-hub':
        return MaterialPageRoute(builder: (_) => const FandomLoreHubPage());

      case '/bookmarks':
        return MaterialPageRoute(builder: (_) => const BookmarksPage());

      case '/news-detail':
        final post = settings.arguments as FandomPost;
        return MaterialPageRoute(builder: (_) => NewsDetailPage(post: post));

      case '/search':
        return MaterialPageRoute(builder: (_) => const SearchExplorePage());

      case '/beginner-hub':
        final data = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => BeginnerHubDetailPage(guideData: data));

      case '/multimedia':
        return MaterialPageRoute(builder: (_) => const MultimediaGalleryPage());

      case '/events-calendar':
        return MaterialPageRoute(builder: (_) => const EventsCalendarPage());

      case '/event-detail':
        final event = settings.arguments as EventEntity;
        return MaterialPageRoute(builder: (_) => EventDetailPage(event: event));

      case '/events-map':
        return MaterialPageRoute(builder: (_) => const EventsMapPage());

      case '/ai-assistant':
        return MaterialPageRoute(builder: (_) => const AIAssistantPage());

      case '/discussions':
        return MaterialPageRoute(builder: (_) => const DiscussionsPage());

      case '/thread-detail':
        final thread = settings.arguments as DiscussionThread;
        return MaterialPageRoute(builder: (_) => ThreadDetailPage(thread: thread));

      case '/create-thread':
        return MaterialPageRoute(builder: (_) => const CreateThreadPage());

      case '/stars-directory':
        return MaterialPageRoute(builder: (_) => const StarsDirectoryPage());

      case '/star-detail':
        final star = settings.arguments as StarProfile;
        return MaterialPageRoute(builder: (_) => StarDetailPage(star: star));

      case '/profile':
        return MaterialPageRoute(builder: (_) => const FanProfilePage());

      case '/edit-profile':
        return MaterialPageRoute(builder: (_) => const EditProfilePage());

      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsPage());

      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsPage());

      case '/badges':
        return MaterialPageRoute(builder: (_) => const BadgesAchievementsPage());

      default:
        return null;
    }
  }
}
