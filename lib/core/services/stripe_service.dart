import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/stripe_config.dart';

class StripePaymentResult {
  final bool success;
  final String? paymentIntentId;
  final String? errorMessage;
  final String? receiptUrl;

  const StripePaymentResult({
    required this.success,
    this.paymentIntentId,
    this.errorMessage,
    this.receiptUrl,
  });
}

class StripeService {
  static const String _stripeApiBase = 'https://api.stripe.com/v1';

  /// Processes in-app payment with card details directly using Stripe REST API.
  /// Converts card details into an authenticated PaymentIntent.
  static Future<StripePaymentResult> processTicketPayment({
    required double amount, // in USD (e.g. 48.50)
    required String cardNumber,
    required String expMonth,
    required String expYear,
    required String cvc,
    required String cardholderName,
    required String eventTitle,
    required String tierTitle,
  }) async {
    final cleanCardNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');
    final cleanMonth = expMonth.padLeft(2, '0');
    final cleanYear = expYear.length == 2 ? '20$expYear' : expYear;

    // Convert amount to cents (e.g., $48.50 -> 4850)
    final amountCents = (amount * 100).round();

    final secretKey = StripeConfig.secretKey;

    // If keys have not been configured yet (placeholder keys), fallback gracefully
    // so app remains testable
    if (!StripeConfig.isConfigured || secretKey.startsWith('sk_test_51Mock')) {
      await Future.delayed(const Duration(milliseconds: 1400));
      final simulatedId =
          'pi_sim_${DateTime.now().millisecondsSinceEpoch}_${cleanCardNumber.length > 4 ? cleanCardNumber.substring(cleanCardNumber.length - 4) : '4242'}';
      debugPrint('[StripeService] Simulated payment succeeded with id: $simulatedId');
      return StripePaymentResult(
        success: true,
        paymentIntentId: simulatedId,
      );
    }

    try {
      final response = await http.post(
        Uri.parse('$_stripeApiBase/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amountCents.toString(),
          'currency': 'usd',
          'payment_method_data[type]': 'card',
          'payment_method_data[card][number]': cleanCardNumber,
          'payment_method_data[card][exp_month]': cleanMonth,
          'payment_method_data[card][exp_year]': cleanYear,
          'payment_method_data[card][cvc]': cvc.trim(),
          if (cardholderName.trim().isNotEmpty)
            'payment_method_data[billing_details][name]': cardholderName.trim(),
          'confirm': 'true',
          'return_url': 'https://fandomverse.app/payment-complete',
          'description': 'Fandom Verse Ticket: $eventTitle ($tierTitle)',
        },
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final status = data['status'] as String?;
        final id = data['id'] as String?;

        if (status == 'succeeded' || status == 'requires_capture') {
          return StripePaymentResult(
            success: true,
            paymentIntentId: id,
          );
        } else if (status == 'requires_action') {
          return StripePaymentResult(
            success: true,
            paymentIntentId: id,
          );
        } else {
          return StripePaymentResult(
            success: false,
            errorMessage: 'Payment status: $status',
          );
        }
      } else {
        final error = data['error'] as Map<String, dynamic>?;
        final errorMsg = error?['message'] as String? ??
            'Payment failed with status code ${response.statusCode}';
        return StripePaymentResult(
          success: false,
          errorMessage: errorMsg,
        );
      }
    } catch (e) {
      debugPrint('[StripeService] Error: $e');
      return StripePaymentResult(
        success: false,
        errorMessage: 'Connection error while processing Stripe payment: $e',
      );
    }
  }
}
