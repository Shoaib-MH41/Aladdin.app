import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const String _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  static bool get isApiKeyValid => _apiKey.isNotEmpty;

  static Future<String> generateFlutterCode(String userPrompt) async {
    if (!isApiKeyValid) {
      return _getFallbackCode(userPrompt);
    }

    try {
      String smartPrompt = """
