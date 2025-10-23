import 'dart:convert';
import 'package:http/http.dart' as http;

class DebugService {
  final String apiKey;

  DebugService(this.apiKey);

  // ✅ کوڈ جنریٹ کرنا
  Future<String> generateCode({
    required String prompt,
    required String framework,
    required List<String> platforms,
  }) async {
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
                  Generate $framework code for: $prompt
                  Platforms: ${platforms.join(', ')}
                  Return only code without explanations:
                  '''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2048,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ?? '// کوڈ نہیں ملا';
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('کوڈ جنریٹ کرنے میں ناکامی: $e');
    }
  }

  // ✅ کوڈ ڈیبگ کرنا
  Future<String> debugFlutterCode({
    required String faultyCode,
    required String errorDescription,
    required String originalPrompt,
  }) async {
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
                  Debug this code:
                  $faultyCode
                  
                  Error: $errorDescription
                  
                  Original: $originalPrompt
                  
                  Return only fixed code:
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
        return data['candidates'][0]['content']['parts'][0]['text'] ?? faultyCode;
      } else {
        return faultyCode;
      }
    } catch (e) {
      return faultyCode;
    }
  }
}
