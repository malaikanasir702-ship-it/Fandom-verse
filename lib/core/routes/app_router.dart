import 'package:flutter/material.dart';
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

    // 2. Default Fallback Route
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: Colors.amber),
              const SizedBox(height: 12),
              Text('No route defined for: ${settings.name}'),
            ],
          ),
        ),
      ),
    );
  }
}
