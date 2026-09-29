import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Stripe configuration loaded from .env file.
/// Keys are never committed to git — only .env.example is committed.
class StripeConfig {
  StripeConfig._();

  /// Stripe Publishable Key — loaded from .env at runtime
  static String get publishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';

  /// Stripe Secret Key — loaded from .env at runtime
  static String get secretKey =>
      dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  /// Whether valid keys are configured
  static bool get isConfigured =>
      publishableKey.startsWith('pk_') && secretKey.startsWith('sk_');
}
