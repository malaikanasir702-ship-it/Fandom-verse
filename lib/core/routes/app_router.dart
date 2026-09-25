import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'fan_routes.dart';
import 'admin_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // 1. Check Developer A (Fan-side) Routes
    final fanRoute = FanRoutes.onGenerateRoute(settings);
    if (fanRoute != null) {
      return fanRoute;
    }

    // 2. Check Developer B (Admin & Store & Cart) Routes
    final adminRoute = AdminRoutes.onGenerateRoute(settings);
    if (adminRoute != null) {
      return adminRoute;
    }

    // 3. Fallback for unmapped /admin routes - protect with AdminRoutes.guardAdminRoute
    if (settings.name != null && settings.name!.startsWith('/admin')) {
      return AdminRoutes.guardAdminRoute(
        Scaffold(
          appBar: AppBar(title: const Text('Admin Area')),
          body: const Center(child: Text('Admin area not found.')),
        ),
      );
    }

    // 4. Default Fallback Route
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.info_circle, size: 64, color: Colors.amber),
              const SizedBox(height: 12),
              Text('No route defined for: ${settings.name}'),
            ],
          ),
        ),
      ),
    );
  }
}
