import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  GeminiService() {
    _initializeModel();
  }

  /// 🔹 Initialize Gemini model
  Future<void> _initializeModel() async {
    try {
      final savedKey = await getSavedApiKey();

      if (savedKey != null && savedKey.isNotEmpty) {
        _model = GenerativeModel(model: 'gemini-pro', apiKey: savedKey);
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

  /// 🔹 Save API Key securely
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
  // 🚀 CORE AI FUNCTIONS
  // ==============================================================

  /// 🔹 General Code Generation
  Future<String> generateCode({
    required String prompt,
    required String framework,
    required List<String> platforms,
  }) async {
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
      throw Exception('Code generation failed: $e');
    }
  }

  /// 🔹 Smart Debugging Helper (Enhanced)
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
You are a senior $framework developer and debugging assistant.
Your task is to fix the given code strictly based on the context and error details.

======================
🧩 ORIGINAL PROMPT:
$originalPrompt
======================
📄 FAULTY CODE:
$faultyCode
======================
⚠️ ERROR / ISSUE:
$errorDescription
======================

🎯 OBJECTIVE:
- Correct the error and make the code functional.
- Preserve all existing logic, structure, and comments.
- Use proper $framework best practices.
- Do NOT simplify, remove or re-architect anything unnecessarily.

📜 OUTPUT RULES:
- Return ONLY the corrected code (no markdown, no explanation, no comments outside code).
- Ensure the code compiles successfully.
- Do not include backticks or JSON wrappers.
""";

      final response = await _model.generateContent([Content.text(debugPrompt)]);
      String fixedCode = response.text?.trim() ?? faultyCode;
      return _cleanGeneratedCode(fixedCode, framework);
    } catch (e) {
      throw Exception('Debugging failed: $e');
    }
  }



  // ==============================================================
  // 🧠 GUIDE SYSTEM (AI Knowledge)
  // ==============================================================

  /// 🔹 Suggest best API with links and setup guide
  Future<String> getApiSuggestion(String category) async {
    final prompt = """
You are an API expert.
Suggest top APIs for "$category" use case.

Provide in this format:
🔹 API Name:
🔹 Website Link:
🔹 Free/Paid Info:
🔹 How to get API Key:
""";
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? 'No suggestion available.';
  }

  /// 🔹 Firebase Authentication Guide
  Future<String> getFirebaseAuthGuide() async {
    final prompt = """
Explain step-by-step how to add Firebase Authentication to a Flutter app.
Include:
1️⃣ How to open Firebase Console.
2️⃣ How to register Android App.
3️⃣ Where to place google-services.json.
4️⃣ Which dependencies to use (firebase_auth, firebase_core).
5️⃣ Simple example code for Email/Password login.

If credit card is needed, mention that user must handle it manually.
""";
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? 'Guide unavailable.';
  }

  /// 🔹 Firebase Firestore Database Guide
  Future<String> getFirebaseDatabaseGuide() async {
    final prompt = """
Explain step-by-step how to connect Firebase Firestore in Flutter.
Include:
1️⃣ Enabling Firestore in Firebase Console.
2️⃣ Dependencies to add.
3️⃣ Example of Add & Read Data in Flutter.
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
You are a React.js expert.
Generate COMPLETE React code for:
$userPrompt
Platforms: $platformList
Use hooks and responsive layout.
RETURN ONLY CODE.
""";
      case 'vue':
        return """
You are a Vue.js 3 expert.
Generate COMPLETE Vue code for:
$userPrompt
Platforms: $platformList
RETURN ONLY CODE.
""";
      case 'html':
        return """
You are a web expert.
Generate COMPLETE HTML/JS/CSS webpage for:
$userPrompt
Platforms: $platformList
RETURN ONLY CODE.
""";
      default:
        return """
You are a Flutter expert.
Generate COMPLETE Flutter code for:
$userPrompt
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
