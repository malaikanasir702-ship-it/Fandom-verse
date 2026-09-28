import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  /// No card details are handled in-app — they go directly to Stripe.
  static Future<StripePaymentResult> presentPaymentSheet({
    required double amount, // USD (e.g. 48.50)
    required String description,
    String currency = 'usd',
  }) async {
    final amountCents = (amount * 100).round();
    final secretKey = StripeConfig.secretKey;

    try {
      // Step 1: Create PaymentIntent via Stripe REST API
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
          'payment_method_types[]': 'card',
          'automatic_payment_methods[enabled]': 'false',
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

      // Step 2: Initialize the Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Fandom Verse',
          style: ThemeMode.system,
          appearance: PaymentSheetAppearance(
            colors: const PaymentSheetAppearanceColors(
              primary: Color(0xFFE53935), // comicRed
            ),
            shapes: const PaymentSheetShape(
              borderRadius: 12,
            ),
          ),
        ),
      );

      // Step 3: Present the Payment Sheet (Stripe's native modal)
      await Stripe.instance.presentPaymentSheet();

      debugPrint('[StripeService] Payment Sheet succeeded: $paymentIntentId');
      return StripePaymentResult(
        success: true,
        paymentIntentId: paymentIntentId,
      );
    } on StripeException catch (e) {
      final code = e.error.code;
      // User cancelled is not an error — just return cancelled
      if (code == FailureCode.Canceled) {
        return const StripePaymentResult(
          success: false,
          errorMessage: 'Payment was cancelled.',
        );
      }
      final msg = e.error.localizedMessage ?? e.error.message ?? 'Stripe payment failed.';
      debugPrint('[StripeService] StripeException: $msg');
      return StripePaymentResult(success: false, errorMessage: msg);
    } catch (e) {
      debugPrint('[StripeService] Error: $e');
      return StripePaymentResult(
        success: false,
        errorMessage: 'Unexpected error during payment: $e',
      );
    }
  }

  /// Convenience wrapper for ticket payments
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

  /// Convenience wrapper for merch/store payments
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
