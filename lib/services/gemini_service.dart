import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // ✅ API key environment سے لی جاتی ہے (security purpose)
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  static bool get isApiKeyValid => _apiKey.isNotEmpty;

  /// Generate complete Flutter app code from user prompt
  static Future<String> generateFlutterCode(String userPrompt) async {
    if (!isApiKeyValid) return _fallbackCode(userPrompt);

    final prompt = """
You are a senior Flutter developer.
Write a COMPLETE Flutter app for this idea: "$userPrompt"

- Use Material 3 design
- Make it responsive
- Include all imports
- Output ONLY runnable Flutter code (no explanation)
""";

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.6,
            "topK": 40,
            "topP": 0.9,
            "maxOutputTokens": 2048
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (text != null && text.isNotEmpty) {
          return _extractCode(text);
        }
      }

      print('⚠️ Gemini error: ${response.statusCode} → ${response.body}');
      return _fallbackCode(userPrompt);
    } catch (e) {
      print('❌ Error generating code: $e');
      return _fallbackCode(userPrompt);
    }
  }

  /// Extract pure Dart code from Gemini response
  static String _extractCode(String raw) {
    raw = raw.trim();
    if (raw.contains('```dart')) {
      return raw.split('```dart')[1].split('```')[0].trim();
    } else if (raw.contains('```')) {
      return raw.split('```')[1].split('```')[0].trim();
    }
    return raw;
  }

  /// Fallback code if Gemini fails
  static String _fallbackCode(String prompt) => """
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: const Text('AI Generated App')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, size: 60, color: Colors.blue),
              const SizedBox(height: 20),
              Text('For idea: "$prompt"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
""";
}
