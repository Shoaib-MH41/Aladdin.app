
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
You are a Flutter expert. Create complete, runnable Flutter code for: $userPrompt

Requirements:
- Use Material Design
- Make it responsive
- Add proper imports
- Return only Dart code without explanations
- The code should compile successfully

Return the code in a single code block.
""";

      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": smartPrompt}
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.7,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 2048,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final generatedText = data['candidates'][0]['content']['parts'][0]['text'];
          return _extractCode(generatedText);
        } else {
          return _getFallbackCode(userPrompt);
        }
      } else {
        print('Gemini API error: ${response.statusCode} - ${response.body}');
        return _getFallbackCode(userPrompt);
      }
    } catch (e) {
      print('Error generating code: $e');
      return _getFallbackCode(userPrompt);
    }
  }

  static String _extractCode(String generatedText) {
    generatedText = generatedText.trim();
    if (generatedText.contains('```dart')) {
      return generatedText.split('```dart')[1].split('```')[0].trim();
    } else if (generatedText.contains('```')) {
      return generatedText.split('```')[1].split('```')[0].trim();
    } else if (generatedText.startsWith('import ') || generatedText.contains('void main()')) {
      return generatedText;
    }
    return _getFallbackCode('Generic Flutter App');
  }

  static String _getFallbackCode(String prompt) {
    return """
import 'package:flutter/material.dart';

void main() {
runApp(MyApp());
}

class MyApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'AI Generated App',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
    ),
    home: MyHomePage(prompt: '$prompt'),
  );
}
}

class MyHomePage extends StatelessWidget {
final String prompt;

MyHomePage({required this.prompt});

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Your AI App'),
      backgroundColor: Colors.deepPurple,
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 50, color: Colors.deepPurple),
          SizedBox(height: 20),
          Text(
            'AI App Factory',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'For: $prompt',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text('Get Started'),
          ),
        ],
      ),
    ),
  );
}
}
""";
  }
}
