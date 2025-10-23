import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  static const String _apiKeyKey = 'gemini_api_key';
  late GenerativeModel _model;
  bool _isInitialized = false;

  GeminiService() {
    _initializeModel();
  }

  // ✅ API key کے بغیر بھی کام چل سکے
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
        // ✅ Default demo key - user بعد میں اپنی key ڈال سکتا ہے
        _model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: 'AIzaSyB0OXLqeOY4e19eYr3xXQwOD yahan apni key daalen', // Replace with your key
        );
        _isInitialized = true;
      }
    } catch (e) {
      _isInitialized = false;
      print('Gemini initialization failed: $e');
    }
  }

  // ✅ API key کو save/retrieve کرنے کے لیے
  Future<void> saveApiKey(String apiKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_apiKeyKey, apiKey.trim());
      
      _model = GenerativeModel(
        model: 'gemini-pro', 
        apiKey: apiKey.trim()
      );
      _isInitialized = true;
    } catch (e) {
      throw Exception('API key save failed: $e');
    }
  }

  Future<String?> getSavedApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_apiKeyKey);
    } catch (e) {
      return null;
    }
  }

  // ✅ API key کو remove کرنے کے لیے
  Future<void> removeApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_apiKeyKey);
      _isInitialized = false;
    } catch (e) {
      throw Exception('API key removal failed: $e');
    }
  }

  // ✅ Service کی status چیک کرنے کے لیے
  bool isInitialized() => _isInitialized;

  // ✅ Universal code generation - کسی بھی فریم ورک کے لیے
  Future<String> generateCode({
    required String prompt,
    required String framework,
    required List<String> platforms,
  }) async {
    if (!_isInitialized) {
      throw Exception('Gemini service not initialized. Please set API key.');
    }

    try {
      String frameworkSpecificPrompt = _buildFrameworkPrompt(
        prompt, 
        framework, 
        platforms
      );

      final content = Content.text(frameworkSpecificPrompt);
      final response = await _model.generateContent(content);
      
      String generatedCode = response.text?.trim() ?? '';
      
      // ✅ اگر response خالی ہے تو error throw کریں
      if (generatedCode.isEmpty) {
        throw Exception('AI نے کوئی کوڈ جنریٹ نہیں کیا۔ براہ کرم دوبارہ کوشش کریں۔');
      }

      return _cleanGeneratedCode(generatedCode, framework);
    } catch (e) {
      throw Exception('Code generation failed: $e');
    }
  }

  // ✅ ہر فریم ورک کے لیے الگ prompt بنانا
  String _buildFrameworkPrompt(
    String userPrompt, 
    String framework, 
    List<String> platforms
  ) {
    String platformInfo = platforms.join(', ');
    
    switch (framework.toLowerCase()) {
      case 'react':
        return """
You are a React.js expert. Generate COMPLETE, READY-TO-RUN React code.

**USER REQUIREMENT:**
$userPrompt

**TECHNICAL SPECIFICATIONS:**
- Framework: React.js with functional components
- Platforms: $platformInfo
- Use React Hooks (useState, useEffect)
- Include modern CSS styling
- Make it a complete working component

**IMPORTANT INSTRUCTIONS:**
1. Return ONLY JavaScript/JSX code
2. No explanations, comments, or markdown
3. Include all necessary imports
4. Ensure no syntax errors
5. The code should run directly

**RETURN ONLY THE CODE:**
""";

      case 'vue':
        return """
You are a Vue.js expert. Generate COMPLETE, READY-TO-RUN Vue.js code.

**USER REQUIREMENT:**
$userPrompt

**TECHNICAL SPECIFICATIONS:**
- Framework: Vue.js 3 with Composition API
- Platforms: $platformInfo
- Use <template>, <script setup>, <style>
- Include modern CSS styling
- Make it a complete working component

**IMPORTANT INSTRUCTIONS:**
1. Return ONLY Vue.js code
2. No explanations, comments, or markdown
3. Include complete single-file component
4. Ensure no syntax errors
5. The code should run directly

**RETURN ONLY THE CODE:**
""";

      case 'android native':
        return """
You are an Android Kotlin expert. Generate COMPLETE, READY-TO-RUN Android code.

**USER REQUIREMENT:**
$userPrompt

**TECHNICAL SPECIFICATIONS:**
- Framework: Android Native with Kotlin
- Platforms: $platformInfo
- Use MainActivity.kt and XML layouts
- Follow Material Design guidelines
- Make it a complete working app

**IMPORTANT INSTRUCTIONS:**
1. Return ONLY Kotlin and XML code
2. No explanations, comments, or markdown
3. Include complete file structure
4. Ensure no syntax errors
5. The code should run directly

**RETURN ONLY THE CODE:**
""";

      case 'html':
        return """
You are a web development expert. Generate COMPLETE, READY-TO-RUN HTML/CSS/JS code.

**USER REQUIREMENT:**
$userPrompt

**TECHNICAL SPECIFICATIONS:**
- Framework: HTML5, CSS3, JavaScript
- Platforms: $platformInfo
- Use modern responsive design
- Include complete styling
- Make it a complete working webpage

**IMPORTANT INSTRUCTIONS:**
1. Return ONLY HTML/CSS/JS code
2. No explanations, comments, or markdown
3. Include complete file in one response
4. Ensure no syntax errors
5. The webpage should run directly in browser

**RETURN ONLY THE CODE:**
""";

      case 'flutter':
      default:
        return """
You are a Flutter expert. Generate COMPLETE, READY-TO-RUN Flutter code.

**USER REQUIREMENT:**
$userPrompt

**TECHNICAL SPECIFICATIONS:**
- Framework: Flutter/Dart
- Platforms: $platformInfo
- Use MaterialApp and Scaffold
- Include all necessary imports
- Make it a complete working app

**IMPORTANT INSTRUCTIONS:**
1. Return ONLY Dart code
2. No explanations, comments, or markdown
3. Include void main() and runApp()
4. Ensure no syntax errors
5. The code should run directly with "flutter run"

**RETURN ONLY THE CODE:**
""";
    }
  }

  // ✅ جنریٹڈ کوڈ کو صاف کرنا
  String _cleanGeneratedCode(String code, String framework) {
    // ✅ Markdown code blocks کو remove کریں
    code = code.replaceAll(RegExp(r'```[a-z]*\n'), '');
    code = code.replaceAll('```', '');
    
    // ✅ Excess whitespace کو remove کریں
    code = code.trim();
    
    // ✅ Framework-specific validation
    switch (framework.toLowerCase()) {
      case 'flutter':
        if (!code.contains('import') || !code.contains('void main')) {
          throw Exception('غیر معقول Flutter کوڈ۔ براہ کرم دوبارہ کوشش کریں۔');
        }
        break;
      case 'react':
        if (!code.contains('import') || !code.contains('function') && !code.contains('const')) {
          throw Exception('غیر معقول React کوڈ۔ براہ کرم دوبارہ کوشش کریں۔');
        }
        break;
      case 'vue':
        if (!code.contains('<template>') || !code.contains('<script>')) {
          throw Exception('غیر معقول Vue کوڈ۔ براہ کرم دوبارہ کوشش کریں۔');
        }
        break;
    }
    
    return code;
  }

  // ✅ کوڈ ڈیبگ کرنا
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

**ORIGINAL REQUIREMENT:**
$originalPrompt

**FAULTY CODE:**
