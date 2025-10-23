import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey;

  GeminiService(this.apiKey);

  // Flutter کوڈ جنریٹ کرنا
  Future<String> generateFlutterCode(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''
                  You are a Flutter expert. Generate COMPLETE, READY-TO-RUN Flutter code for:
                  
                  REQUIREMENT: $prompt
                  
                  IMPORTANT INSTRUCTIONS:
                  1. Return ONLY Dart code without explanations
                  2. Include all necessary imports
                  3. Make it a complete working app
                  4. Use MaterialApp and Scaffold
                  5. Add basic styling and functionality
                  6. Ensure no syntax errors
                  
                  Respond with ONLY the Dart code:
                  '''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.8,
            'maxOutputTokens': 2048,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Gemini API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gemini connection failed: $e');
    }
  }

  // کوڈ ڈیبگ کرنا
  Future<String> debugFlutterCode(String faultyCode, String error) async {
    final response = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': '''
                Debug this Flutter code:
                
                CODE:
                ```dart
                $faultyCode
                ```
                
                ERROR: $error
                
                Fix the code and return ONLY the corrected Dart code without any explanations:
                '''
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.3,
          'maxOutputTokens': 2048,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Debugging failed: ${response.statusCode}');
    }
  }
}
