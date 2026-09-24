import 'package:get_it/get_it.dart';
import 'dev_a_injection.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // Developer A (Fan side dependencies)
  initDevADependencies(sl);

  // Developer B (Admin side dependencies placeholder for dual-developer zero-conflict)
}
