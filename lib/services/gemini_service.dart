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
  late GenerativeModel _designerModel; // 🎨 Special Model for UI
  bool _isInitialized = false;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late final Future<void> _initialization;

  GeminiService() {
    _initialization = _initializeModel();
  }

  /// 🔹 Initialize Gemini model
  Future<void> _initializeModel() async {
    try {
      final savedKey = await getSavedApiKey();

      if (savedKey != null && savedKey.isNotEmpty) {
        // 1. General Chat Model
        _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: savedKey);

        // 2. 🎨 Expert UI Designer Model (With System Instructions)
        _designerModel = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: savedKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json', // Force JSON Output
            temperature: 0.7, // تھوڑی تخلیقی صلاحیت کے لیے
          ),
          systemInstruction: Content.system(_uiSystemPrompt),
        );

        _isInitialized = true;
        print('✅ Gemini AI & Designer Models initialized successfully');
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
  // 🎨 GENERATIVE UI SYSTEM (The Magic Part)
  // ==============================================================

  static const String _uiSystemPrompt = """
    You are an expert Flutter UI/UX Designer and Frontend Architect.
    Your Goal: Generate modern, premium, and aesthetically pleasing UI component data based on user input.
    
    DESIGN RULES:
    1. Modernity: Always use modern trends like Glassmorphism, Neumorphism, or Soft UI.
    2. Shapes: Prefer rounded corners (BorderRadius 20-30px).
    3. Colors: Use gradients (LinearGradient) instead of flat colors where possible.
    4. Shadows: Use soft, diffused box shadows (elevation).
    5. Typography: Select readable and modern font weights.
    
    OUTPUT FORMAT:
    You must return a SINGLE JSON object. Do not wrap in markdown blocks.
    Structure:
    {
      "type": "The type of widget (e.g., ModernButton, InfoCard, GradientContainer)",
      "data": {
        "label": "Text content",
        "icon": "Icon name (e.g., arrow_forward, home, star)",
        "subLabel": "Secondary text if needed"
      },
      "style": {
        "primaryColor": "Hex Code (e.g., #FF512F)",
        "secondaryColor": "Hex Code (e.g., #DD2476)",
        "borderRadius": 25.0,
        "elevation": 8.0,
        "isGlass": true/false (if glassmorphism is needed)
      }
    }
  """;

  /// 🔹 Generate Magic UI Design
  Future<Map<String, dynamic>> generateModernUi(String userRequest) async {
    await _initialization;
    if (!_isInitialized) throw Exception('Gemini not initialized.');

    try {
      final prompt = "Create a modern UI design for: $userRequest";
      final response = await _designerModel.generateContent([Content.text(prompt)]);
      
      final jsonString = response.text ?? "{}";
      
      // JSON Cleaning (just in case model adds markdown)
      final cleanJson = jsonString.replaceAll('```json', '').replaceAll('```', '').trim();
      
      return json.decode(cleanJson) as Map<String, dynamic>;
    } catch (e) {
      print('❌ UI Generation Error: $e');
      // Fallback UI in case of error
      return {
        "type": "ErrorCard",
        "data": {"label": "Error generating UI", "subLabel": e.toString()},
        "style": {"primaryColor": "#FF0000", "borderRadius": 12.0}
      };
    }
  }

  // ==============================================================
  // 🚀 CORE AI FUNCTIONS (Existing Logic)
  // ==============================================================

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
      return _cleanGeneratedCode(generatedCode, framework);
    } catch (e) {
      throw Exception('Code generation failed: $e');
    }
  }

  Future<String> debugCode({
    required String faultyCode,
    required String errorDescription,
    required String framework,
    required String originalPrompt,
  }) async {
    await _initialization;
    if (!_isInitialized) throw Exception('Gemini service not initialized.');

    try {
      final debugPrompt = "Fix this code ($framework): \n$faultyCode\n Error: $errorDescription";
      final response = await _model.generateContent([Content.text(debugPrompt)]);
      return _cleanGeneratedCode(response.text?.trim() ?? faultyCode, framework);
    } catch (e) {
      throw Exception('Debugging failed: $e');
    }
  }

  // ==============================================================
  // 🧩 Helpers
  // ==============================================================

  String _buildFrameworkPrompt(String userPrompt, String framework, List<String> platforms) {
    return "Generate $framework code for: $userPrompt. Platforms: ${platforms.join(', ')}. Return ONLY code.";
  }

  String _cleanGeneratedCode(String code, String framework) {
    code = code.replaceAll(RegExp(r'```[a-z]*\n'), '');
    code = code.replaceAll('```', '');
    return code.trim();
  }
}
