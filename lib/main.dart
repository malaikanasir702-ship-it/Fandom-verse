import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'core/routes/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/fcm_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'core/theme/bloc/theme_state.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/fandom_hub/presentation/bloc/fandom_hub_bloc.dart';
import 'features/events/presentation/bloc/event_bloc.dart';
import 'features/community/presentation/bloc/community_bloc.dart';
import 'features/ai_assistant/presentation/bloc/ai_assistant_bloc.dart';
import 'features/store/presentation/bloc/store_bloc.dart';
import 'features/cart_checkout/presentation/bloc/cart_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent red/grey screen of death in release mode
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('?? [FlutterError] ${details.exceptionAsString()}');
  };

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // -- Critical path: Firebase + SQLite + SharedPrefs --
  await initDependencies();

  // -- Non-critical background inits — do NOT await --
  NotificationService.initialize().catchError((_) {});

  // FCM must initialize AFTER app is running — requestPermission() can block
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FCMService.initialize().catchError((_) {});
  });

  runApp(const FandomVerseApp());
}

class FandomVerseApp extends StatefulWidget {
  const FandomVerseApp({super.key});

  static FandomVerseAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<FandomVerseAppState>();

  @override
  State<FandomVerseApp> createState() => FandomVerseAppState();
}

class FandomVerseAppState extends State<FandomVerseApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<FandomHubBloc>(create: (_) => sl<FandomHubBloc>()),
        BlocProvider<EventCalendarBloc>(create: (_) => sl<EventCalendarBloc>()),
        BlocProvider<CommunityBloc>(create: (_) => sl<CommunityBloc>()),
        BlocProvider<AIAssistantBloc>(create: (_) => sl<AIAssistantBloc>()),
        BlocProvider<ThemeBloc>(create: (_) => sl<ThemeBloc>()),
        BlocProvider<StoreBloc>(create: (_) => sl<StoreBloc>()),
        BlocProvider<CartBloc>(create: (_) => sl<CartBloc>()),
        BlocProvider<ProfileBloc>(create: (_) => sl<ProfileBloc>()),
        BlocProvider<AdminBloc>(create: (_) => sl<AdminBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Fandom Verse Pocket Edition',
            debugShowCheckedModeBanner: false,
            color: const Color(0xFF0A0A1A),
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            initialRoute: '/splash',
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
