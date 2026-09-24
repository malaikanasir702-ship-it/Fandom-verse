import 'package:get_it/get_it.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/fandom_hub/presentation/bloc/fandom_hub_bloc.dart';
import '../../features/events/presentation/bloc/event_bloc.dart';
import '../../features/community/presentation/bloc/community_bloc.dart';
import '../../features/ai_assistant/presentation/bloc/ai_assistant_bloc.dart';
import '../services/firebase_auth_service.dart';

void initDevADependencies(GetIt sl) {
  // Blocs
  sl.registerFactory(() => AuthBloc(authService: sl<FirebaseAuthService>()));
  sl.registerFactory(() => FandomHubBloc());
  sl.registerFactory(() => EventCalendarBloc());
  sl.registerFactory(() => CommunityBloc());
  sl.registerFactory(() => AIAssistantBloc());
}
