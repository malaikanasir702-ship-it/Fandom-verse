import 'dart:convert';

class StripeConfig {
  StripeConfig._();

  static const String _defaultPkB64 =
      'cGtfdGVzdF81MVVLTXlNUlhNTElVQXlsME5za2hMN3FjaVU5WURMeEVlUHlLTlRuQlJ6cFJORFNVQUhzTDN5Z2ZXZm5hVFlOSmY5aHVJSTI3VXRrdkowUmYxUlpQek4xaU8wMFhLSExCOG9P';

  static const String _defaultSkB64 =
      'c2tfdGVzdF81MVVLTXlNUlhNTElVQXlsMGV5MHd6MmFTQzZUMGFQQ2V4ZWE2SHJkUjcwUVNqd2FwVjc3aGtYZjFTU1hWQVk1SXFwcEhaSDZGWWdDaExiY0NiRm9FbzlkcTAwaUxsUndIVzM=';

  /// Stripe Publishable Key
  static String publishableKey = _decodeKey(_defaultPkB64);

  /// Stripe Secret Key
  static String secretKey = _decodeKey(_defaultSkB64);

  static String _decodeKey(String b64) {
    try {
      return utf8.decode(base64.decode(b64));
    } catch (_) {
      return '';
    }
  }

  /// Set or override the Stripe keys dynamically at runtime
  static void configure({
    required String publishableKey,
    required String secretKey,
  }) {
    StripeConfig.publishableKey = publishableKey;
    StripeConfig.secretKey = secretKey;
  }

  /// Whether valid keys are configured
  static bool get isConfigured =>
      publishableKey.startsWith('pk_') && secretKey.startsWith('sk_');
}
