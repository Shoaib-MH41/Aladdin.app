import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

/// 🔗 Link Helper - ویب سائٹ کھولنے کیلئے
class LinkHelper {
  static Future<void> openLink(String url) async {
    try {
      final Uri uri = Uri.parse(url.trim());

      if (!await canLaunchUrl(uri)) {
        throw 'Cannot launch URL: $url';
      }

      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('⚠️ Error opening link: $e');
    }
  }
}

class GeminiService {
  static const String _apiKeyKey = 'gemini_api_key';
  late GenerativeModel _model;
  bool _isInitialized = false;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  GeminiService() {
    _initializeModel();
  }

  /// 🔹 Initialize Gemini model
  Future<void> _initializeModel() async {
    try {
      final savedKey = await getSavedApiKey();

      if (savedKey != null && savedKey.isNotEmpty) {
        _model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: savedKey,
        );
        _isInitialized = true;
        print('✅ Gemini model initialized successfully');
      } else {
        _isInitialized = false;
        print('⚠️ Gemini API key not found. Please set it in Settings.');
      }
    } catch (e) {
      _isInitialized = false;
      print('❌ Gemini initialization failed: $e');
    }
  }

  /// 🔹 Get Saved API Key
  Future<String?> getSavedApiKey() async {
    try {
      String? key = await _secureStorage.read(key: _apiKeyKey);
      if (key != null && key.isNotEmpty) return key;

      final prefs = await SharedPreferences.getInstance();
      key = prefs.getString(_apiKeyKey);
      if (key != null && key.isNotEmpty) {
        await _secureStorage.write(key: _apiKeyKey, value: key);
        await prefs.remove(_apiKeyKey);
      }
      return key;
    } catch (e) {
      print('⚠️ Error reading API key: $e');
      return null;
    }
  }

  /// 🔹 Save API Key
  Future<void> saveApiKey(String apiKey) async {
    try {
      await _secureStorage.write(key: _apiKeyKey, value: apiKey.trim());
      _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey.trim());
      _isInitialized = true;
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

  bool isInitialized() => _isInitialized;

  // ==============================================================
  // 🚀 CORE FUNCTIONALITY
  // ==============================================================

  /// 🔹 Generate Code using Gemini
  Future<String> generateCode({
    required String prompt,
    required String framework,
    required List<String> platforms,
  }) async {
    if (!_isInitialized) {
      throw Exception('Gemini service not initialized. Please set your API key.');
    }

    try {
      String frameworkPrompt = _buildFrameworkPrompt(prompt, framework, platforms);
      final content = Content.text(frameworkPrompt);
      final response = await _model.generateContent([content]);
      String generatedCode = response.text?.trim() ?? '';

      if (generatedCode.isEmpty) {
        throw Exception('AI نے کوئی کوڈ واپس نہیں کیا، دوبارہ کوشش کریں۔');
      }

      return _cleanGeneratedCode(generatedCode, framework);
    } catch (e) {
      throw Exception('Code generation failed: $e');
    }
  }

  /// 🔹 Debug & Fix Code using AI
  Future<String> debugCode({
    required String faultyCode,
    required String errorDescription,
    required String framework,
    required String originalPrompt,
  }) async {
    if (!_isInitialized) {
      throw Exception('Gemini service not initialized.');
    }

    try {
      final debugPrompt = """
You are an expert $framework developer.
Fix the code based on the following details:

ORIGINAL PROMPT:
$originalPrompt

CODE:
$faultyCode

ERROR:
$errorDescription

RULES:
- Fix the bug
- Return ONLY the corrected code
- No explanations or markdown
- Maintain structure and logic
""";

      final response = await _model.generateContent([Content.text(debugPrompt)]);
      String fixedCode = response.text?.trim() ?? faultyCode;
      return _cleanGeneratedCode(fixedCode, framework);
    } catch (e) {
      throw Exception('Debugging failed: $e');
    }
  }

  /// 🔹 Test API Connection
  Future<bool> testConnection() async {
    if (!_isInitialized) return false;

    try {
      final test = Content.text("Say only 'Hello World'");
      final response = await _model.generateContent([test]);
      final text = response.text ?? '';
      return text.toLowerCase().contains('hello');
    } catch (e) {
      print('⚠️ Gemini connection test failed: $e');
      return false;
    }
  }

  // ==============================================================
  // 🔗 Gemini Link (For User’s Generated Code)
  // ==============================================================

  /// 🔹 Generate a shareable Gemini link and optionally open it
  Future<String> generateGeminiLink(String prompt, {bool open = false}) async {
    final key = await getSavedApiKey();
    if (key == null || key.isEmpty) {
      throw Exception('Gemini API key not found.');
    }

    final encodedPrompt = Uri.encodeComponent(prompt);
    final link = "https://aistudio.google.com/app/prompts/new?prompt=$encodedPrompt";

    if (open) {
      await LinkHelper.openLink(link);
    }

    return link;
  }

  // ==============================================================
  // 🧠 Helper Methods
  // ==============================================================

  String _buildFrameworkPrompt(
    String userPrompt,
    String framework,
    List<String> platforms,
  ) {
    final platformList = platforms.join(', ');

    switch (framework.toLowerCase()) {
      case 'react':
        return '''
You are a React.js expert. Generate COMPLETE React code.

USER REQUIREMENT:
$userPrompt

SPECIFICATIONS:
- Framework: React.js (functional components)
- Platforms: $platformList
- Use Hooks, modern UI, responsive layout
- Include imports, and ensure no syntax errors

RETURN ONLY CODE:
''';

      case 'vue':
        return '''
You are a Vue.js 3 expert. Generate COMPLETE Vue code.

USER REQUIREMENT:
$userPrompt
Platforms: $platformList

Use <template>, <script setup>, <style> blocks.
RETURN ONLY CODE:
''';

      case 'html':
        return '''
You are a web expert. Generate COMPLETE HTML/JS/CSS webpage.

USER REQUIREMENT:
$userPrompt
Platforms: $platformList

RETURN ONLY THE CODE:
''';

      default:
        return '''
You are a Flutter expert. Generate COMPLETE Flutter code.

USER REQUIREMENT:
$userPrompt
Platforms: $platformList

RETURN ONLY THE CODE:
''';
    }
  }

  /// 🔹 Remove markdown or unnecessary wrappers
  String _cleanGeneratedCode(String code, String framework) {
    code = code.replaceAll(RegExp(r'```[a-z]*\n'), '');
    code = code.replaceAll('```', '');
    return code.trim();
  }
}
