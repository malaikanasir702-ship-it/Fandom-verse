import 'package:get_it/get_it.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/fandom_hub/presentation/bloc/fandom_hub_bloc.dart';
import '../../features/events/presentation/bloc/event_bloc.dart';
import '../../features/community/presentation/bloc/community_bloc.dart';
import '../../features/ai_assistant/presentation/bloc/ai_assistant_bloc.dart';
import '../repositories/i_fandom_hub_repository.dart';
import '../repositories/fandom_hub_repository_impl.dart';
import '../repositories/i_events_repository.dart';
import '../repositories/events_repository_impl.dart';
import '../repositories/i_community_repository.dart';
import '../repositories/community_repository_impl.dart';
import '../services/firebase_auth_service.dart';

void initDevADependencies(GetIt sl) {
  // Repositories
  sl.registerLazySingleton<IFandomHubRepository>(() => FandomHubRepositoryImpl());
  sl.registerLazySingleton<IEventsRepository>(() => EventsRepositoryImpl());
  sl.registerLazySingleton<ICommunityRepository>(() => CommunityRepositoryImpl());

  // Blocs
  sl.registerLazySingleton<AuthBloc>(() => AuthBloc(authService: sl<FirebaseAuthService>()));
  sl.registerFactory(() => FandomHubBloc(repository: sl<IFandomHubRepository>()));
  sl.registerFactory(() => EventCalendarBloc(repository: sl<IEventsRepository>()));
  sl.registerFactory(() => CommunityBloc(repository: sl<ICommunityRepository>()));
  sl.registerFactory(() => AIAssistantBloc());
}
