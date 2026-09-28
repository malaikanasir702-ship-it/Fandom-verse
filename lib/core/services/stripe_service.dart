import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import '../config/stripe_config.dart';

class StripePaymentResult {
  final bool success;
  final String? paymentIntentId;
  final String? errorMessage;

  const StripePaymentResult({
    required this.success,
    this.paymentIntentId,
    this.errorMessage,
  });
}

class StripeService {
  static const String _stripeApiBase = 'https://api.stripe.com/v1';

  /// Creates a PaymentIntent on Stripe's server using the secret key,
  /// then presents Stripe's native Payment Sheet UI.
  static Future<StripePaymentResult> presentPaymentSheet({
    required double amount, // USD (e.g. 48.50)
    required String description,
    String currency = 'usd',
  }) async {
    final amountCents = (amount * 100).round();
    final secretKey = StripeConfig.secretKey;

    // Guard: ensure keys are configured
    if (!StripeConfig.isConfigured) {
      return const StripePaymentResult(
        success: false,
        errorMessage: 'Stripe is not configured. Please set up your API keys.',
      );
    }

    try {
      // ── Step 1: Create PaymentIntent via Stripe REST API ────────────────
      final response = await http.post(
        Uri.parse('$_stripeApiBase/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amountCents.toString(),
          'currency': currency,
          'description': description,
          // Use automatic_payment_methods for broad card support
          'automatic_payment_methods[enabled]': 'true',
          'automatic_payment_methods[allow_redirects]': 'never',
        },
      );

      if (response.statusCode != 200) {
        final err = jsonDecode(response.body);
        final msg = err['error']?['message'] as String? ??
            'Failed to create PaymentIntent (${response.statusCode})';
        return StripePaymentResult(success: false, errorMessage: msg);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final clientSecret = data['client_secret'] as String?;
      final paymentIntentId = data['id'] as String?;

      if (clientSecret == null) {
        return const StripePaymentResult(
          success: false,
          errorMessage: 'No client secret returned from Stripe.',
        );
      }

      // ── Step 2: Initialize Payment Sheet ────────────────────────────────
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Fandom Verse',
          style: ThemeMode.dark,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFFE53935),
              background: Color(0xFF0A0A1A),
              componentBackground: Color(0xFF1A1A2E),
              primaryText: Colors.white,
              secondaryText: Color(0xFFAAAAAA),
              componentText: Colors.white,
              placeholderText: Color(0xFF666666),
              icon: Color(0xFFE53935),
              componentBorder: Color(0xFF333333),
              componentDivider: Color(0xFF333333),
            ),
            shapes: PaymentSheetShape(
              borderRadius: 12,
              borderWidth: 1,
            ),
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              colors: PaymentSheetPrimaryButtonTheme(
                dark: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFFE53935),
                  text: Colors.white,
                  border: Color(0xFFE53935),
                ),
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFFE53935),
                  text: Colors.white,
                  border: Color(0xFFE53935),
                ),
              ),
            ),
          ),
        ),
      );

      // ── Step 3: Present Payment Sheet ────────────────────────────────────
      await Stripe.instance.presentPaymentSheet();

      debugPrint('[StripeService] ✅ Payment succeeded: $paymentIntentId');
      return StripePaymentResult(
        success: true,
        paymentIntentId: paymentIntentId,
      );
    } on StripeException catch (e) {
      final code = e.error.code;
      // User dismissed the sheet — not an error
      if (code == FailureCode.Canceled) {
        return const StripePaymentResult(
          success: false,
          errorMessage: 'Payment was cancelled.',
        );
      }
      final msg = e.error.localizedMessage ??
          e.error.message ??
          'Stripe payment failed.';
      debugPrint('[StripeService] StripeException: $msg');
      return StripePaymentResult(success: false, errorMessage: msg);
    } catch (e) {
      debugPrint('[StripeService] Unexpected error: $e');
      return StripePaymentResult(
        success: false,
        errorMessage: 'Payment error: ${e.toString()}',
      );
    }
  }

  /// Ticket payment
  static Future<StripePaymentResult> processTicketPayment({
    required double amount,
    required String eventTitle,
    required String tierTitle,
  }) {
    return presentPaymentSheet(
      amount: amount,
      description: 'Fandom Verse Ticket: $eventTitle ($tierTitle)',
    );
  }

  /// Merch / store payment
  static Future<StripePaymentResult> processMerchPayment({
    required double amount,
    required String productName,
    required int quantity,
  }) {
    return presentPaymentSheet(
      amount: amount,
      description: 'Fandom Verse Merch: ${quantity}x $productName',
    );
  }
}
