import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/debug_model.dart';

class DebugService {
  final String apiKey;
  final String baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  DebugService(this.apiKey);

  Future<DebugResponse> debugFlutterCode(DebugRequest request) async {
    try {
      final prompt = _buildDebugPrompt(request);
      
      final response = await http.post(
        Uri.parse('$baseUrl/models/gemini-pro:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.1,
            'topK': 32,
            'topP': 0.8,
            'maxOutputTokens': 2048,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText = data['candidates'][0]['content']['parts'][0]['text'];
        
        return _parseGeminiResponse(generatedText, request.faultyCode);
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      return DebugResponse(
        fixedCode: request.faultyCode,
        explanation: 'Debugging failed: $e',
        rootCause: 'Unknown',
        preventionTips: [],
        success: false,
      );
    }
  }

  String _buildDebugPrompt(DebugRequest request) {
    return """
**FLUTTER CODE DEBUGGING REQUEST**

**ORIGINAL REQUIREMENTS:**
${request.originalPrompt}

**FAULTY CODE:**
```dart
${request.faultyCode}
