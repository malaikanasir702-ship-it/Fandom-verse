import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/fandom_hub/presentation/bloc/fandom_hub_bloc.dart';
import 'features/events/presentation/bloc/event_bloc.dart';
import 'features/community/presentation/bloc/community_bloc.dart';
import 'features/ai_assistant/presentation/bloc/ai_assistant_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Clean Architecture Service Locator
  await initDependencies();

  runApp(const FandomVerseApp());
}

class FandomVerseApp extends StatefulWidget {
  const FandomVerseApp({super.key});

  static _FandomVerseAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_FandomVerseAppState>();

  @override
  State<FandomVerseApp> createState() => _FandomVerseAppState();
}

class _FandomVerseAppState extends State<FandomVerseApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<FandomHubBloc>(create: (_) => sl<FandomHubBloc>()),
        BlocProvider<EventCalendarBloc>(create: (_) => sl<EventCalendarBloc>()),
        BlocProvider<CommunityBloc>(create: (_) => sl<CommunityBloc>()),
        BlocProvider<AIAssistantBloc>(create: (_) => sl<AIAssistantBloc>()),
      ],
      child: MaterialApp(
        title: 'Fandom Verse Pocket Edition',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        initialRoute: '/splash',
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
