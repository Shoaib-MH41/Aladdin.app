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
  // 🎨 AI DESIGNER - NEW FEATURE
  // ==============================================================

  /// 🎨 Generate Modern UI Design from Text Prompt
  Future<Map<String, dynamic>> generateUIDesign({
    required String prompt,
    String componentType = 'auto',
  }) async {
    await _initialization;
    if (!_isInitialized) {
      throw Exception('Gemini not initialized. Set API key first.');
    }

    try {
      const systemInstruction = '''
آپ ایک ماہر Modern UI/UX ڈیزائنر ہیں جو Flutter کے لیے ڈیزائن تخلیق کرتے ہیں۔

قوانین:
1. صرف JSON جواب دیں، کوئی اضافی متن نہیں
2. ہمیشہ جدید ڈیزائن ٹرینڈز استعمال کریں:
   - Gradients (linear/radial)
   - Rounded corners (borderRadius: 12-30)
   - Shadows (small/medium/large)
   - Modern color palettes
   - Smooth animations
3. responsive design ضرور شامل کریں
4. accessibility کو مدنظر رکھیں

JSON Structure:
{
  "componentType": "button|card|container|textfield|list|grid|appbar|navbar",
  "label": "Component label",
  "properties": {
    "width": number|null,
    "height": number|null,
    "padding": {"top": number, "right": number, "bottom": number, "left": number},
    "margin": {"top": number, "right": number, "bottom": number, "left": number},
    "alignment": "center|start|end|stretch",
    "flex": number|null
  },
  "style": {
    "backgroundColor": "hex color|gradient",
    "borderRadius": number,
    "border": {"color": "hex color", "width": number},
    "shadow": {
      "type": "small|medium|large|custom",
      "color": "hex color",
      "blurRadius": number,
      "offsetX": number,
      "offsetY": number
    },
    "gradient": {
      "type": "linear|radial",
      "colors": ["hex1", "hex2"],
      "stops": [0.0, 1.0],
      "angle": number,
      "center": {"x": 0.5, "y": 0.5}
    },
    "textStyle": {
      "color": "hex color",
      "fontSize": number,
      "fontWeight": "normal|bold|w600|w700",
      "fontFamily": "string|null",
      "letterSpacing": number
    }
  },
  "animation": {
    "type": "fade|slide|scale|bounce",
    "duration": number,
    "curve": "easeOut|easeInOut|bounceOut|elasticOut",
    "delay": number
  },
  "children": [array of child components if any],
  "interaction": {
    "hoverEffect": "scale|elevate|colorChange",
    "onTap": "function|null",
    "feedback": "vibrate|sound|null"
  },
  "metadata": {
    "generatedAt": "timestamp",
    "version": "1.0",
    "promptUsed": "user prompt"
  }
}

Modern Design Guidelines:
- Colors: Use #6366F1 (Indigo), #8B5CF6 (Violet), #10B981 (Emerald), #F59E0B (Amber)
- Border Radius: 12, 16, 20, 24, 30 (modern rounded)
- Shadows: medium for cards, large for modals
- Gradients: Linear from top-left to bottom-right
- Animations: 300ms duration with easeOut curve
''';

      final userPrompt = componentType.toLowerCase() == 'auto'
          ? prompt
          : "Create a modern $componentType for: $prompt";

      final fullPrompt = '''
$systemInstruction

User Request: $userPrompt

Generate a modern, visually appealing UI component based on the above request.
Return only valid JSON.
''';

      final response = await _model.generateContent([Content.text(fullPrompt)]);
      String rawResponse = response.text?.trim() ?? '{}';

      // Clean the response
      String cleanJson = rawResponse
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // Try to extract JSON if wrapped in text
      final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(cleanJson);
      if (jsonMatch != null) {
        cleanJson = jsonMatch.group(0)!;
      }

      // Parse JSON
      Map<String, dynamic> designData;
      try {
        designData = json.decode(cleanJson) as Map<String, dynamic>;
      } catch (e) {
        print('⚠️ JSON parsing failed, using fallback: $e');
        designData = _createFallbackDesign(prompt, componentType);
      }

      // Add metadata
      designData['metadata'] = {
        'generatedAt': DateTime.now().toIso8601String(),
        'version': '1.0',
        'promptUsed': prompt,
        'componentType': componentType,
        'isAIGenerated': true,
      };

      print('🎨 UI Design Generated: ${designData['componentType']}');
      return designData;

    } catch (e) {
      print('❌ UI Design Generation Failed: $e');
      return _createFallbackDesign(prompt, componentType);
    }
  }

  /// 🎨 Generate Complete Flutter Widget Code from Design
  Future<String> generateFlutterCode({
    required Map<String, dynamic> designData,
    bool includeComments = true,
    bool addDependencies = true,
  }) async {
    await _initialization;
    if (!_isInitialized) {
      throw Exception('Gemini not initialized.');
    }

    try {
      final designJson = json.encode(designData);
      
      final prompt = '''
You are a senior Flutter developer. Convert this UI design JSON into complete, working Flutter code.

DESIGN DATA:
$designJson

REQUIREMENTS:
1. Generate COMPLETE, COMPILABLE Flutter code
2. Use StatelessWidget for simple components
3. Use StatefulWidget if interaction is needed
4. Follow Flutter best practices and conventions
5. ${includeComments ? 'Add helpful comments' : 'No comments needed'}
6. ${addDependencies ? 'Add necessary imports' : 'Only core Flutter imports'}

SPECIAL INSTRUCTIONS:
- Use BoxDecoration for styling
- Implement gradients if specified
- Add animations if defined
- Make it responsive with MediaQuery
- Add null safety

OUTPUT FORMAT:
Return ONLY the Flutter Dart code.
Start with imports, then class definition.
No markdown, no explanations.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      String generatedCode = response.text?.trim() ?? '';

      if (generatedCode.isEmpty) {
        throw Exception('AI نے کوئی کوڈ واپس نہیں کیا');
      }

      // Clean the code
      generatedCode = generatedCode
          .replaceAll(RegExp(r'```[a-z]*\n'), '')
          .replaceAll('```', '')
          .trim();

      return generatedCode;

    } catch (e) {
      print('❌ Flutter Code Generation Failed: $e');
      return _generateFallbackFlutterCode(designData);
    }
  }

  /// 🎨 Batch Generate Multiple UI Components
  Future<List<Map<String, dynamic>>> generateUIKit({
    required String appTheme,
    List<String> components = const ['button', 'card', 'textfield', 'appbar'],
  }) async {
    await _initialization;
    if (!_isInitialized) {
      throw Exception('Gemini not initialized.');
    }

    try {
      final prompt = '''
Generate a complete UI Kit for a $appTheme themed Flutter app.
Include these components: ${components.join(', ')}.

Requirements:
1. Consistent color scheme
2. Modern design patterns
3. Each component should be independent
4. Include light/dark mode support
5. Responsive design

Return a JSON array where each element is a UI component design.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      String rawResponse = response.text?.trim() ?? '[]';

      // Clean JSON
      String cleanJson = rawResponse
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      List<Map<String, dynamic>> componentsList;
      try {
        final List<dynamic> parsed = json.decode(cleanJson);
        componentsList = parsed.cast<Map<String, dynamic>>();
      } catch (e) {
        print('⚠️ Failed to parse UI Kit, using fallback');
        componentsList = _generateFallbackUIKit(appTheme, components);
      }

      print('🎨 Generated UI Kit with ${componentsList.length} components');
      return componentsList;

    } catch (e) {
      print('❌ UI Kit Generation Failed: $e');
      return _generateFallbackUIKit(appTheme, components);
    }
  }

  // ==============================================================
  // 🎨 FALLBACK DESIGNS (اگر AI فیل ہو جائے)
  // ==============================================================

  Map<String, dynamic> _createFallbackDesign(String prompt, String componentType) {
    final now = DateTime.now();
    
    return {
      'componentType': componentType == 'auto' ? 'container' : componentType,
      'label': prompt.length > 20 ? '${prompt.substring(0, 20)}...' : prompt,
      'properties': {
        'width': null,
        'height': null,
        'padding': {'top': 16, 'right': 16, 'bottom': 16, 'left': 16},
        'margin': {'top': 8, 'right': 8, 'bottom': 8, 'left': 8},
        'alignment': 'center',
        'flex': null,
      },
      'style': {
        'backgroundColor': '#6366F1',
        'borderRadius': 16,
        'border': {'color': '#8B5CF6', 'width': 2},
        'shadow': {
          'type': 'medium',
          'color': '#000000',
          'blurRadius': 10,
          'offsetX': 0,
          'offsetY': 4,
        },
        'gradient': {
          'type': 'linear',
          'colors': ['#6366F1', '#8B5CF6'],
          'stops': [0.0, 1.0],
          'angle': 135,
          'center': {'x': 0.5, 'y': 0.5},
        },
        'textStyle': {
          'color': '#FFFFFF',
          'fontSize': 16,
          'fontWeight': 'bold',
          'fontFamily': null,
          'letterSpacing': 0.5,
        },
      },
      'animation': {
        'type': 'fade',
        'duration': 300,
        'curve': 'easeOut',
        'delay': 0,
      },
      'children': [],
      'interaction': {
        'hoverEffect': 'scale',
        'onTap': 'navigate',
        'feedback': 'vibrate',
      },
      'metadata': {
        'generatedAt': now.toIso8601String(),
        'version': '1.0',
        'promptUsed': prompt,
        'componentType': componentType,
        'isAIGenerated': true,
        'isFallback': true,
      },
    };
  }

  String _generateFallbackFlutterCode(Map<String, dynamic> design) {
    final type = design['componentType'] ?? 'container';
    final label = design['label'] ?? 'AI Generated';
    
    return '''
import 'package:flutter/material.dart';

class ${_toPascalCase(type)}Widget extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  
  const ${_toPascalCase(type)}Widget({
    Key? key,
    required this.label,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Color(0xFF8B5CF6),
          width: 2,
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// Usage example:
// ${_toPascalCase(type)}Widget(label: "$label")
''';
  }

  List<Map<String, dynamic>> _generateFallbackUIKit(String theme, List<String> components) {
    List<Map<String, dynamic>> kit = [];
    
    for (final component in components) {
      kit.add(_createFallbackDesign('$theme $component', component));
    }
    
    return kit;
  }

  String _toPascalCase(String input) {
    if (input.isEmpty) return '';
    return input[0].toUpperCase() + input.substring(1).replaceAllMapped(
      RegExp(r'[ _-]([a-z])'),
      (match) => match.group(1)!.toUpperCase(),
    );
  }

  // ==============================================================
  // 🚀 CORE AI FUNCTIONS (EXISTING - UNCHANGED)
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
