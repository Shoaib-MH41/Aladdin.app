import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

/// 🔗 Link Helper - ویب سائٹ یا کنسول لنک کھولنے کیلئے
class LinkHelper {
  static Future<void> openLink(String url) async {
    try {
      final Uri uri = Uri.parse(url.trim());
      if (!await canLaunchUrl(uri)) throw 'Cannot launch URL: $url';
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('⚠️ Error opening link: $e');
    }
  }
}

class GeminiService {
  static const String _apiKeyKey = 'gemini_api_key';
  late GenerativeModel _model;
  bool _isInitialized = false;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorageStorage();
  late final Future<void> _initialization;

  GeminiService() {
    _initialization = _initializeModel();
  }

  /// 🔹 Initialize Gemini model
  Future<void> _initializeModel() async {
    try {
      final savedKey = await getSavedApiKey();

      if (savedKey != null && savedKey.isNotEmpty) {
        _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: savedKey);
        _isInitialized = true;
        print('✅ Gemini model initialized successfully');
      } else {
        _isInitialized = false;
        print('⚠️ Gemini API key not found.');
      }
    } catch (e) {
      _isInitialized = false;
      print('❌ Gemini initialization failed: $e');
    }
  }

  /// 🔹 Get Saved API Key
  Future<String?> getSavedApiKey() async {
    try {
      return await _secureStorage.read(key: _apiKeyKey);
    } catch (e) {
      print('⚠️ Error reading API key: $e');
      return null;
    }
  }

  /// 🔹 Save API Key securely
  Future<void> saveApiKey(String apiKey) async {
    try {
      await _secureStorage.write(key: _apiKeyKey, value: apiKey.trim());
      await _initializeModel(); // Re-initialize with new key
      print('🔐 Gemini API key securely saved.');
    } catch (e) {
      throw Exception('API key save failed: $e');
    }
  }

  /// 🔹 Remove API Key
  Future<void> removeApiKey() async {
    try {
      await _secureStorage.delete(key: _apiKeyKey);
      _isInitialized = false;
      print('🗑️ Gemini API key removed.');
    } catch (e) {
      throw Exception('API key removal failed: $e');
    }
  }

  Future<bool> isInitialized() async {
    await _initialization;
    return _isInitialized;
  }

  // ==============================================================
  // 🚀 CORE AI FUNCTIONS
  // ==============================================================

  /// 🔹 General Code Generation
  Future<String> generateCode({
    required String prompt,
    required String framework,
    required List<String> platforms,
  }) async {
    await _initialization;
    if (!_isInitialized) throw Exception('Gemini not initialized. Set API key first.');

    try {
      String frameworkPrompt = _buildFrameworkPrompt(prompt, framework, platforms);
      final response = await _model.generateContent([Content.text(frameworkPrompt)]);
      String generatedCode = response.text?.trim() ?? '';

      if (generatedCode.isEmpty) {
        throw Exception('AI نے کوئی کوڈ واپس نہیں کیا، دوبارہ کوشش کریں۔');
      }

      return _cleanGeneratedCode(generatedCode, framework);
    } catch (e) {
      throw Exception('کوڈ جنریشن ناکام: $e');
    }
  }

  /// 🔹 Smart Debugging Helper
  Future<String> debugCode({
    required String faultyCode,
    required String errorDescription,
    required String framework,
    required String originalPrompt,
  }) async {
    await _initialization;
    if (!_isInitialized) {
      throw Exception('Gemini service not initialized.');
    }

    try {
      final debugPrompt = """
You are a senior $framework developer and debugging assistant.
Your task is to fix the given code strictly based on the context and error details.

ORIGINAL PROMPT: $originalPrompt

FAULTY CODE:
$faultyCode

ERROR / ISSUE:
$errorDescription

OBJECTIVE:
- Correct the error and make the code functional.
- Preserve all existing logic, structure, and comments.
- Use proper $framework best practices.

OUTPUT RULES:
- Return ONLY the corrected code (no markdown, no explanation).
- Ensure the code compiles successfully.
- Do not include backticks or JSON wrappers.
""";

      final response = await _model.generateContent([Content.text(debugPrompt)]);
      String fixedCode = response.text?.trim() ?? faultyCode;
      return _cleanGeneratedCode(fixedCode, framework);
    } catch (e) {
      throw Exception('ڈیبگنگ ناکام: $e');
    }
  }

  // ==============================================================
  // 🔍 SMART API SUGGESTION SYSTEM
  // ==============================================================

  /// 🔹 Get AI-based API Suggestion
  Future<Map<String, dynamic>?> getApiSuggestion(String category) async {
    await _initialization;
    if (!_isInitialized) {
      throw Exception('Gemini service not initialized. Please set your API key.');
    }

    try {
      final prompt = """
You are an AI assistant that suggests API websites for app developers.
Given the category: "$category"
Find a suitable API service provider or console that offers APIs in this category.

Return only one result in JSON format:
{
  "name": "Provider or Platform Name",
  "url": "https://example.com",
  "note": "Short instruction for how to get API key or use it."
}

Return only valid JSON, no additional text.
""";

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      
      // بہتر JSON parsing
      String cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
      
      // JSON extract کریں
      try {
        final data = json.decode(cleanText) as Map<String, dynamic>;
        print('✅ AI Suggested API: ${data['name']}');
        return data;
      } catch (e) {
        // اگر JSON نہیں ملا تو text سے extract کریں
        final jsonMatch = RegExp(r'\{[^{}]*\}').firstMatch(cleanText);
        if (jsonMatch != null) {
          final data = json.decode(jsonMatch.group(0)!) as Map<String, dynamic>;
          return data;
        }
        throw Exception('AI نے صحیح JSON نہیں دیا');
      }
    } catch (e) {
      print('⚠️ Error in getApiSuggestion: $e');
      return _getFallbackSuggestion(category);
    }
  }

  /// 🔹 Fallback suggestions if AI fails
  Map<String, dynamic>? _getFallbackSuggestion(String category) {
    final fallbacks = {
      'ai': {
        'name': 'OpenAI API',
        'url': 'https://platform.openai.com/api-keys',
        'note': 'Create account and generate API key'
      },
      'firebase': {
        'name': 'Google Firebase',
        'url': 'https://console.firebase.google.com',
        'note': 'Create project and enable APIs'
      },
      'weather': {
        'name': 'OpenWeather Map',
        'url': 'https://openweathermap.org/api',
        'note': 'Free tier available with signup'
      },
      'authentication': {
        'name': 'Firebase Auth',
        'url': 'https://console.firebase.google.com',
        'note': 'Enable Authentication in Firebase Console'
      },
      'database': {
        'name': 'Firebase Firestore',
        'url': 'https://console.firebase.google.com',
        'note': 'Enable Firestore in Firebase Console'
      }
    };
    
    final key = category.toLowerCase();
    return fallbacks[key] ?? fallbacks['ai'];
  }

  // ==============================================================
  // 🧠 GUIDE SYSTEM
  // ==============================================================

  /// 🔹 Firebase Authentication Guide
  Future<String> getFirebaseAuthGuide() async {
    await _initialization;
    final prompt = """
Explain step-by-step how to add Firebase Authentication to a Flutter app.
Include:
1. How to open Firebase Console
2. How to register Android App
3. Where to place google-services.json
4. Which dependencies to use
5. Simple example code for Email/Password login
""";
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? 'Guide unavailable.';
  }

  /// 🔹 Firebase Firestore Database Guide
  Future<String> getFirebaseDatabaseGuide() async {
    await _initialization;
    final prompt = """
Explain step-by-step how to connect Firebase Firestore in Flutter.
Include:
1. Enabling Firestore in Firebase Console
2. Dependencies to add
3. Example of Add & Read Data in Flutter
""";
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? 'Guide unavailable.';
  }

  // ==============================================================
  // 🔗 Gemini Link Generator
  // ==============================================================

  Future<String> generateGeminiLink(String topic, {bool open = false}) async {
    final key = await getSavedApiKey();
    if (key == null || key.isEmpty) throw Exception('Gemini API key not found.');

    final encodedPrompt = Uri.encodeComponent(topic);
    final link = "https://aistudio.google.com/app/prompts/new?prompt=$encodedPrompt";

    if (open) await LinkHelper.openLink(link);
    return link;
  }

  // ==============================================================
  // 🔍 Connection Test
  // ==============================================================

  Future<bool> testConnection() async {
    await _initialization;
    if (!_isInitialized) return false;

    try {
      final response = await _model.generateContent([Content.text("Say only: OK")]);
      return response.text?.toLowerCase().contains("ok") ?? false;
    } catch (e) {
      print('⚠️ Gemini connection test failed: $e');
      return false;
    }
  }

  // ==============================================================
  // 🧩 Helpers
  // ==============================================================

  String _buildFrameworkPrompt(String userPrompt, String framework, List<String> platforms) {
    final platformList = platforms.join(', ');

    switch (framework.toLowerCase()) {
      case 'react':
        return """
Generate COMPLETE React code for: $userPrompt
Platforms: $platformList
Use hooks and responsive layout.
RETURN ONLY CODE.
""";
      case 'vue':
        return """
Generate COMPLETE Vue code for: $userPrompt
Platforms: $platformList
RETURN ONLY CODE.
""";
      case 'html':
        return """
Generate COMPLETE HTML/JS/CSS webpage for: $userPrompt
Platforms: $platformList
RETURN ONLY CODE.
""";
      default:
        return """
Generate COMPLETE Flutter code for: $userPrompt
Platforms: $platformList
RETURN ONLY CODE.
""";
    }
  }

  String _cleanGeneratedCode(String code, String framework) {
    code = code.replaceAll(RegExp(r'```[a-z]*\n'), '');
    code = code.replaceAll('```', '');
    return code.trim();
  }
}
