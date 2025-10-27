import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:techi_chat_bot/services/stripe_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _amountController = TextEditingController();
  final StripeService _stripeService = StripeService();
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    // Validate amount
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showMessage('Please enter an amount', isError: true);
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showMessage('Please enter a valid amount greater than 0', isError: true);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      if (kIsWeb) {
        // Use Stripe Checkout for web
        await _handleWebCheckout(amount);
      } else {
        // Use Payment Sheet for mobile/desktop
        await _stripeService.makePayment(amount: amount);

        if (mounted) {
          _showMessage(
              'Payment successful! Amount: \$${amount.toStringAsFixed(2)}');
          _amountController.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString(), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _handleWebCheckout(double amount) async {
    try {
      // Create checkout session
      final session =
          await _stripeService.createCheckoutSession(amount: amount);
      final checkoutUrl = session['url'];

      if (checkoutUrl == null) {
        throw Exception('Failed to get checkout URL');
      }

      // Launch Stripe Checkout page
      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (mounted) {
          _showMessage('Redirecting to Stripe Checkout...');
          _amountController.clear();
        }
      } else {
        throw Exception('Could not launch checkout URL');
      }
    } catch (e) {
      throw Exception('Checkout error: $e');
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Support',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // Card Visual
            _buildCardVisual(),
            const SizedBox(height: 40),

            // Support Description
            const Text(
              'Support Our App',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              'Your contribution helps us improve and bring you better features. Every support counts!',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            // Amount Label
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ENTER AMOUNT',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black45,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Amount Input
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '\$',
                  style: TextStyle(
                    fontSize: 56,
                    color: Colors.black,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontSize: 56,
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Quick Amount Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAmountButton(10),
                _buildQuickAmountButton(20),
                _buildQuickAmountButton(50),
                _buildQuickAmountButton(100),
                _buildQuickAmountButton(500),
              ],
            ),
            const SizedBox(height: 50),

            // Support Button
            SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Support →',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(int amount) {
    return Expanded(
      child: OutlinedButton(
        onPressed: _isProcessing
            ? null
            : () {
                _amountController.text = amount.toString();
                // Focus the text field to show the value
              },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: const BorderSide(color: Colors.black26, width: 1),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          '\$$amount',
          style: const TextStyle(
            fontFamily: 'Anderson',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildCardVisual() {
    return Center(
      child: SizedBox(
        height: 280,
        width: 360,
        child: Stack(
          children: [
            // Back card (blue)
            Positioned(
              left: 0,
              top: 80,
              child: Transform.rotate(
                angle: -0.1,
                child: Container(
                  width: 320,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF4A90E2),
                        Color(0xFF357ABD),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.credit_card,
                                color: Colors.white.withOpacity(0.8), size: 32),
                            Icon(Icons.contactless,
                                color: Colors.white.withOpacity(0.8), size: 28),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Debit Card',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '•••• 0958',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: const [
                                Text(
                                  'VISA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Front card (gradient teal/green)
            Positioned(
              left: 40,
              top: 0,
              child: Transform.rotate(
                angle: 0.05,
                child: Container(
                  width: 320,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF4ECCA3),
                        Color(0xFF3DBEA0),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.credit_card,
                                color: Colors.white.withOpacity(0.9), size: 32),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.contactless,
                                  color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Debit Card',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '•••• 4568',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
