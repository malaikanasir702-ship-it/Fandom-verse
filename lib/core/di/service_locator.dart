import 'package:get_it/get_it.dart';
import 'dev_a_injection.dart';

import 'dev_b_injection.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // Developer A (Fan side dependencies)
  initDevADependencies(sl);

  // Developer B (Database, Store, Cart, Admin & Theme dependencies)
  await initDevBInjection(sl);
}
