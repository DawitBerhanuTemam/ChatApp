import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:techi_chat_bot/screens/chat_screen.dart';
import 'package:techi_chat_bot/screens/payment_screen.dart';
import 'package:techi_chat_bot/services/stripe_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Stripe
  await StripeService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AbyssiniaBot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/payment': (context) => const PaymentScreen(),
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F8F8),
              Color(0xFFFFE8D6),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),

                // Chat app illustration
                Center(
                  child: Container(
                    width: 340,
                    height: 340,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCE4F7),
                      borderRadius: BorderRadius.circular(170),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(170),
                      child: Image.asset(
                        'assets/images/chatApp.webp',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // Title
                const Center(
                  child: Text(
                    'Let’s Talk with AI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Subtitle
                const Center(
                  child: Text(
                    'Chat with the smartest AI - Experience\nthe power of AI with us',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Page indicators
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIndicator(false),
                      const SizedBox(width: 8),
                      _buildIndicator(false),
                      const SizedBox(width: 8),
                      _buildIndicator(true),
                      const SizedBox(width: 8),
                      _buildIndicator(false),
                    ],
                  ),
                ),

                const Spacer(),

                // Get Started Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/chat');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Start Chat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return Container(
      width: isActive ? 10 : 8,
      height: isActive ? 10 : 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4A90E2) : Colors.grey[300],
        shape: BoxShape.circle,
      ),
    );
  }
}
