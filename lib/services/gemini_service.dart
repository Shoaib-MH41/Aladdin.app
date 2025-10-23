import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  static const String _apiKeyKey = 'gemini_api_key';
  late GenerativeModel _model;

  GeminiService() {
    _initializeModel();
  }

  void _initializeModel() {
    // Default API key - user بعد میں بدل سکتا ہے
    const String defaultApiKey = 'AIzaSyBxxxxxxxxxxxxxxxxxxx'; // یہاں اپنی key ڈالیں
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: defaultApiKey,
    );
  }

  // API key کو save/retrieve کرنے کے لیے
  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
    _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  }

  Future<String?> getSavedApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  // Flutter کوڈ جنریٹ کرنا
  Future<String> generateFlutterCode(String prompt) async {
    try {
      final content = Content.text(prompt);
      final response = await _model.generateContent(content);
      
      return response.text ?? '// کوڈ جنریٹ نہیں ہوا۔ براہ کرم دوبارہ کوشش کریں۔';
    } catch (e) {
      throw Exception('Gemini API Error: $e');
    }
  }

  // کوڈ ڈیبگ کرنا
  Future<String> debugFlutterCode(String faultyCode, String error) async {
    final prompt = """
اس Flutter کوڈ میں مسئلہ درست کریں:

**غلط کوڈ:**
```dart
$faultyCode
