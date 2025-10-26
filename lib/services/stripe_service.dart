import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:techi_chat_bot/config/stripe_config.dart';

class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  String get backendUrl => StripeConfig.backendUrl;

  /// Initialize Stripe with publishable key
  static Future<void> init() async {
    try {
      Stripe.publishableKey = StripeConfig.publishableKey;
      await Stripe.instance.applySettings();
    } catch (e) {
      // Stripe is not supported on web, skip initialization
      debugPrint('Stripe initialization skipped (not supported on web): $e');
    }
  }

  /// Create payment intent on backend
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
  }) async {
    try {
      final url = Uri.parse('$backendUrl/create-payment-intent');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to create payment intent');
      }
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }

  /// Process payment with Stripe
  Future<bool> makePayment({
    required double amount,
  }) async {
    try {
      // 1. Create payment intent on backend
      final paymentIntentData = await createPaymentIntent(amount: amount);
      final clientSecret = paymentIntentData['clientSecret'];

      if (clientSecret == null) {
        throw Exception('Client secret is null');
      }

      // 2. Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'TechiBot',
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF6200EE),
            ),
          ),
        ),
      );

      // 3. Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        throw Exception('Payment cancelled');
      } else {
        throw Exception('Stripe error: ${e.error.message}');
      }
    } catch (e) {
      throw Exception('Payment failed: $e');
    }
  }

  /// Get payment status from backend
  Future<Map<String, dynamic>> getPaymentStatus(String paymentIntentId) async {
    try {
      final url = Uri.parse('$backendUrl/payment-status/$paymentIntentId');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to get payment status');
      }
    } catch (e) {
      throw Exception('Error getting payment status: $e');
    }
  }

  /// Create Checkout Session for web payments
  Future<Map<String, dynamic>> createCheckoutSession({
    required double amount,
  }) async {
    try {
      final url = Uri.parse('$backendUrl/create-checkout-session');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to create checkout session');
      }
    } catch (e) {
      throw Exception('Error creating checkout session: $e');
    }
  }

  /// Get checkout session status
  Future<Map<String, dynamic>> getCheckoutSessionStatus(String sessionId) async {
    try {
      final url = Uri.parse('$backendUrl/checkout-session/$sessionId');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to get checkout session status');
      }
    } catch (e) {
      throw Exception('Error getting checkout session status: $e');
    }
  }
}
