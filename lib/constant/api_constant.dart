import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiContant {
  static String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=";
}
