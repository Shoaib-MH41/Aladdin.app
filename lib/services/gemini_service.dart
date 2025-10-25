import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GeminiService {
  static const String _apiKeyKey = 'gemini_api_key';
  late GenerativeModel _model;
  bool _isInitialized = false;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  GeminiService() {
    _initializeModel();
  }

  /// 🔹 ماڈل initialize کریں (secure storage سے API key حاصل کر کے)
  Future<void> _initializeModel() async {
    try {
      final savedKey = await getSavedApiKey();

      if (savedKey != null && savedKey.isNotEmpty) {
        _model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: savedKey,
        );
        _isInitialized = true;
      } else {
        // fallback: اگر ابھی key محفوظ نہیں
        _isInitialized = false;
        print('⚠️ Gemini API key missing. Please add it in settings.');
      }
    } catch (e) {
      _isInitialized = false;
      print('❌ Gemini initialization failed: $e');
    }
  }

  /// 🔹 محفوظ API Key حاصل کریں (secure storage → fallback)
  Future<String?> getSavedApiKey() async {
    try {
      // secure storage چیک کریں
      String? key = await _secureStorage.read(key: _apiKeyKey);
      if (key != null && key.isNotEmpty) return key;

      // fallback: پرانے ورژن سے migrate
      final prefs = await SharedPreferences.getInstance();
      key = prefs.getString(_apiKeyKey);
      if (key != null) {
        await _secureStorage.write(key: _apiKeyKey, value: key);
        await prefs.remove(_apiKeyKey);
      }
      return key;
    } catch (e) {
      print('⚠️ Error reading API key: $e');
      return null;
    }
  }

  /// 🔹 API Key محفوظ کریں (encrypted form میں)
  Future<void> saveApiKey(String apiKey) async {
    try {
      await _secureStorage.write(key: _apiKeyKey, value: apiKey.trim());
      _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey.trim());
      _isInitialized = true;
      print('✅ Gemini API key securely saved');
    } catch (e) {
      throw Exception('API key save failed: $e');
    }
  }

  /// 🔹 API Key حذف کریں
  Future<void> removeApiKey() async {
    try {
      await _secureStorage.delete(key: _apiKeyKey);
      _isInitialized = false;
      print('🗑️ Gemini API key removed');
    } catch (e) {
      throw Exception('API key removal failed: $e');
    }
  }

  bool isInitialized() => _isInitialized;

  /// 🔹 کوڈ جنریٹ کریں (AI سے)
  Future<String> generateCode({
    required String prompt,
    required String framework,
    required List<String> platforms,
  }) async {
    if (!_isInitialized) {
      throw Exception('Gemini service not initialized. Please set API key.');
    }

    try {
      String frameworkSpecificPrompt =
          _buildFrameworkPrompt(prompt, framework, platforms);

      final content = Content.text(frameworkSpecificPrompt);
      final response = await _model.generateContent([content]);

      String generatedCode = response.text?.trim() ?? '';

      if (generatedCode.isEmpty) {
        throw Exception('AI نے کوئی کوڈ جنریٹ نہیں کیا۔ براہ کرم دوبارہ کوشش کریں۔');
      }

      return _cleanGeneratedCode(generatedCode, framework);
    } catch (e) {
      throw Exception('Code generation failed: $e');
    }
  }

  /// 🔹 ڈی بگ (Debug) فنکشن
  Future<String> debugCode({
    required String faultyCode,
    required String errorDescription,
    required String framework,
    required String originalPrompt,
  }) async {
    if (!_isInitialized) {
      throw Exception('Gemini service not initialized');
    }

    try {
      String debugPrompt = """
Debug and fix this $framework code:

ORIGINAL REQUIREMENT:
$originalPrompt

FAULTY CODE:
$faultyCode

ERROR EXPERIENCED:
$errorDescription

INSTRUCTIONS:
1. Analyze and fix the issue
2. Return ONLY the corrected code
3. No explanations or comments
4. Maintain the original functionality
5. Ensure the fixed code runs without errors

RETURN ONLY THE CORRECTED CODE:
""";

      final content = Content.text(debugPrompt);
      final response = await _model.generateContent([content]);

      String fixedCode = response.text?.trim() ?? faultyCode;
      return _cleanGeneratedCode(fixedCode, framework);
    } catch (e) {
      throw Exception('Debugging failed: $e');
    }
  }

  /// 🔹 کنکشن ٹیسٹ کریں
  Future<bool> testConnection() async {
    if (!_isInitialized) return false;

    try {
      final content = Content.text("Generate a simple 'Hello World' Flutter app");
      final response = await _model.generateContent([content]);
      return response.text != null && response.text!.contains('Hello');
    } catch (e) {
      print('⚠️ Connection test failed: $e');
      return false;
    }
  }

  // ---------- Helper Methods ----------

  String _buildFrameworkPrompt(
    String userPrompt,
    String framework,
    List<String> platforms,
  ) {
    String platformInfo = platforms.join(', ');
    switch (framework.toLowerCase()) {
      case 'react':
        return '''
You are a React.js expert. Generate COMPLETE, READY-TO-RUN React code.

USER REQUIREMENT:
$userPrompt

TECHNICAL SPECIFICATIONS:
- Framework: React.js with functional components
- Platforms: $platformInfo
- Use React Hooks (useState, useEffect)
- Include modern CSS styling
- Make it a complete working component

IMPORTANT INSTRUCTIONS:
1. Return ONLY JavaScript/JSX code
2. No explanations, comments, or markdown
3. Include all necessary imports
4. Ensure no syntax errors
5. The code should run directly

RETURN ONLY THE CODE:
''';

      case 'vue':
        return '''
You are a Vue.js expert. Generate COMPLETE, READY-TO-RUN Vue.js code.

USER REQUIREMENT:
$userPrompt

TECHNICAL SPECIFICATIONS:
- Framework: Vue.js 3 with Composition API
- Platforms: $platformInfo
- Use <template>, <script setup>, <style>
- Include modern CSS styling

RETURN ONLY THE CODE:
''';

      case 'html':
        return '''
You are a web expert. Generate a COMPLETE working webpage.

USER REQUIREMENT:
$userPrompt

TECHNICAL SPECIFICATIONS:
- Framework: HTML/CSS/JS
- Platforms: $platformInfo
- Responsive design
- Include all styling and JS

RETURN ONLY THE CODE:
''';

      default:
        return '''
You are a Flutter expert. Generate COMPLETE Flutter app.

USER REQUIREMENT:
$userPrompt
Platforms: $platformInfo

RETURN ONLY THE CODE:
''';
    }
  }

  String _cleanGeneratedCode(String code, String framework) {
    code = code.replaceAll(RegExp(r'```[a-z]*\n'), '');
    code = code.replaceAll('```', '');
    return code.trim();
  }
}
