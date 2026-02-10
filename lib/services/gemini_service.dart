import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
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

/// ✅ Universal AI Service - Gemini, DeepSeek, OpenAI, Local سب کے لیے
class GeminiService {
  // Settings keys
  static const String _providerKey = 'ai_provider';
  static const String _apiKeyKey = 'ai_api_key';
  static const String _customUrlKey = 'ai_custom_url';
  
  // Current state
  AIProvider _currentProvider = AIProvider.gemini;
  late GenerativeModel _geminiModel;
  bool _isInitialized = false;
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late final Future<void> _initialization;

  GeminiService() {
    _initialization = _initializeFromStorage();
  }

  /// 🔹 Factory constructors for different providers
  factory GeminiService.gemini({String? apiKey}) {
    final service = GeminiService();
    service._currentProvider = AIProvider.gemini;
    if (apiKey != null) service._saveApiKeyDirectly(apiKey);
    return service;
  }
  
  factory GeminiService.deepseek({required String apiKey}) {
    final service = GeminiService();
    service._currentProvider = AIProvider.deepseek;
    service._saveApiKeyDirectly(apiKey);
    return service;
  }
  
  factory GeminiService.openai({required String apiKey}) {
    final service = GeminiService();
    service._currentProvider = AIProvider.openai;
    service._saveApiKeyDirectly(apiKey);
    return service;
  }
  
  factory GeminiService.local({required String baseUrl}) {
    final service = GeminiService();
    service._currentProvider = AIProvider.local;
    service._saveCustomUrlDirectly(baseUrl);
    return service;
  }

  /// 🔹 Initialize from saved settings
  Future<void> _initializeFromStorage() async {
    try {
      final savedProvider = await _secureStorage.read(key: _providerKey);
      if (savedProvider != null) {
        _currentProvider = _parseProvider(savedProvider);
      }
      
      final apiKey = await _secureStorage.read(key: _apiKeyKey);
      final customUrl = await _secureStorage.read(key: _customUrlKey);
      
      // Initialize Gemini model if provider is Gemini and API key exists
      if (_currentProvider == AIProvider.gemini && apiKey != null && apiKey.isNotEmpty) {
        _geminiModel = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );
        _isInitialized = true;
        print('✅ GeminiService initialized with ${_currentProvider.name}');
      } else if (apiKey != null && apiKey.isNotEmpty) {
        // Other providers just need API key
        _isInitialized = true;
        print('✅ GeminiService initialized with ${_currentProvider.name}');
      } else if (_currentProvider == AIProvider.local && customUrl != null) {
        // Local provider needs custom URL
        _isInitialized = true;
        print('✅ GeminiService initialized with Local API');
      } else {
        _isInitialized = false;
        print('⚠️ AI Service not initialized - credentials missing');
      }
    } catch (e) {
      _isInitialized = false;
      print('❌ GeminiService initialization failed: $e');
    }
  }

  /// 🔹 Change AI Provider (نیا فیچر)
  Future<void> changeProvider(AIProvider provider, {String? apiKey, String? customUrl}) async {
    _currentProvider = provider;
    
    await _secureStorage.write(key: _providerKey, value: provider.name);
    
    if (apiKey != null) {
      await _secureStorage.write(key: _apiKeyKey, value: apiKey);
    }
    
    if (customUrl != null) {
      await _secureStorage.write(key: _customUrlKey, value: customUrl);
    }
    
    await _initializeFromStorage();
  }

  /// 🔹 Get Current Provider (نیا فیچر)
  AIProvider get currentProvider => _currentProvider;

  // ==============================================================
  // 🔹 آپ کے موجودہ میتھڈز (بالکل ویسے ہی رہیں گے)
  // ==============================================================

  Future<String?> getSavedApiKey() async {
    try {
      return await _secureStorage.read(key: _apiKeyKey);
    } catch (e) {
      print('⚠️ Error reading API key: $e');
      return null;
    }
  }

  Future<void> saveApiKey(String apiKey) async {
    try {
      await _secureStorage.write(key: _apiKeyKey, value: apiKey.trim());
      await _initializeFromStorage(); // Re-initialize
      print('🔐 API key securely saved for ${_currentProvider.name}');
    } catch (e) {
      throw Exception('API key save failed: $e');
    }
  }

  Future<void> removeApiKey() async {
    try {
      await _secureStorage.delete(key: _apiKeyKey);
      _isInitialized = false;
      _geminiModel = null as GenerativeModel;
      print('🗑️ API key removed');
    } catch (e) {
      throw Exception('API key removal failed: $e');
    }
  }

  Future<bool> isInitialized() async {
    await _initialization;
    return _isInitialized;
  }

  // ==============================================================
  // 🚀 CORE AI FUNCTIONS (Universal بنائیں)
  // ==============================================================

  /// 🔹 General Code Generation (Universal)
  Future<String> generateCode({
    required String prompt,
    required String framework,
    required List<String> platforms,
  }) async {
    await _initialization;
    if (!_isInitialized) throw Exception('AI Service not initialized. Set API key first.');

    try {
      String frameworkPrompt = _buildFrameworkPrompt(prompt, framework, platforms);
      
      switch (_currentProvider) {
        case AIProvider.gemini:
          return await _generateWithGemini(frameworkPrompt);
          
        case AIProvider.deepseek:
          return await _generateWithDeepSeek(frameworkPrompt);
          
        case AIProvider.openai:
          return await _generateWithOpenAI(frameworkPrompt);
          
        case AIProvider.local:
          return await _generateWithLocal(frameworkPrompt);
      }
    } catch (e) {
      throw Exception('کوڈ جنریشن ناکام: $e');
    }
  }

  /// 🎨 Generate Modern UI Design from Text Prompt (Universal)
  Future<Map<String, dynamic>> generateUIDesign({
    required String prompt,
    String componentType = 'auto',
  }) async {
    await _initialization;
    if (!_isInitialized) {
      throw Exception('AI Service not initialized. Set API key first.');
    }

    try {
      const systemInstruction = '''
آپ ایک ماہر Modern UI/UX ڈیزائنر ہیں جو Flutter کے لیے ڈیزائن تخلیق کرتے ہیں۔
صرف JSON لوٹائیں، کوئی اضافی متن نہیں۔
''';

      final userPrompt = componentType.toLowerCase() == 'auto'
          ? prompt
          : "Create a modern $componentType for: $prompt";

      final fullPrompt = '''
$systemInstruction

User Request: $userPrompt

Generate a modern, visually appealing UI component.
Return only valid JSON.
''';

      switch (_currentProvider) {
        case AIProvider.gemini:
          final response = await _geminiModel.generateContent([Content.text(fullPrompt)]);
          return _parseDesignResponse(response.text ?? '{}');
          
        case AIProvider.deepseek:
        case AIProvider.openai:
        case AIProvider.local:
          return await _generateUIDesignWithOpenAICompatible(fullPrompt);
      }
    } catch (e) {
      print('❌ UI Design Generation Failed: $e');
      return _createFallbackDesign(prompt, componentType);
    }
  }
  
  /// 🎨 Generate Flutter Code from Design
  Future<String> generateFlutterCode({
    required Map<String, dynamic> designData,
    bool includeComments = true,
    bool addDependencies = true,
  }) async {
    await _initialization;
    if (!_isInitialized) {
      throw Exception('AI Service not initialized.');
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
4. Follow Flutter best practices
5. ${includeComments ? 'Add helpful comments' : 'No comments needed'}
6. ${addDependencies ? 'Add necessary imports' : 'Only core Flutter imports'}

Return ONLY Flutter Dart code:
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

  /// 🎨 Generate UI Kit
  Future<List<Map<String, dynamic>>> generateUIKit({
    required String appTheme,
    List<String> components = const ['button', 'card', 'textfield', 'appbar'],
  }) async {
    await _initialization;
    if (!_isInitialized) {
      throw Exception('AI Service not initialized.');
    }

    try {
      final prompt = '''
Generate a complete UI Kit for a $appTheme themed Flutter app.
Include these components: ${components.join(', ')}.

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

  // Fallback methods
  String _generateFallbackFlutterCode(Map<String, dynamic> design) {
    final type = design['componentType'] ?? 'container';
    final label = design['label'] ?? 'AI Generated';
    
    return '''
import 'package:flutter/material.dart';

class ${_toPascalCase(type)}Widget extends StatelessWidget {
  final String label;
  
  const ${_toPascalCase(type)}Widget({
    Key? key,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(label),
      ),
    );
  }
}
''';
  }

  List<Map<String, dynamic>> _generateFallbackUIKit(String theme, List<String> components) {
    return components.map((component) {
      return {
        'componentType': component,
        'label': '$theme $component',
        'style': {'backgroundColor': '#6366F1', 'borderRadius': 16.0},
      };
    }).toList();
  }

  String _toPascalCase(String input) {
    if (input.isEmpty) return '';
    return input[0].toUpperCase() + input.substring(1);
  }
}
  /// 🔹 Smart Debugging Helper (Universal)
  Future<String> debugCode({
    required String faultyCode,
    required String errorDescription,
    required String framework,
    required String originalPrompt,
  }) async {
    await _initialization;
    if (!_isInitialized) {
      throw Exception('AI Service not initialized.');
    }

    try {
      final debugPrompt = """
You are a senior $framework developer. Fix this code:

ORIGINAL PROMPT: $originalPrompt

FAULTY CODE:
$faultyCode

ERROR: $errorDescription

Return ONLY corrected code:
""";

      return await generateCode(
        prompt: debugPrompt,
        framework: framework,
        platforms: ['all'],
      );
    } catch (e) {
      throw Exception('ڈیبگنگ ناکام: $e');
    }
  }

  /// 🔹 API Suggestion (Universal)
  Future<Map<String, dynamic>?> getApiSuggestion(String category) async {
    // آپ کا موجودہ logic
    return _getFallbackSuggestion(category);
  }

  /// 🔹 Test Connection (Universal)
  Future<bool> testConnection() async {
    await _initialization;
    if (!_isInitialized) return false;

    try {
      switch (_currentProvider) {
        case AIProvider.gemini:
          final response = await _geminiModel.generateContent([Content.text("Say only: OK")]);
          return response.text?.toLowerCase().contains("ok") ?? false;
          
        case AIProvider.deepseek:
        case AIProvider.openai:
          // Simple test for OpenAI-compatible APIs
          return await _testOpenAICompatibleConnection();
          
        case AIProvider.local:
          // Test local connection
          return await _testLocalConnection();
      }
    } catch (e) {
      print('⚠️ Connection test failed: $e');
      return false;
    }
  }

  // ==============================================================
  // 🔧 PRIVATE HELPER METHODS
  // ==============================================================

  // Gemini implementation
  Future<String> _generateWithGemini(String prompt) async {
    final response = await _geminiModel.generateContent([Content.text(prompt)]);
    return _cleanGeneratedCode(response.text?.trim() ?? '', 'flutter');
  }
  
  // DeepSeek implementation
  Future<String> _generateWithDeepSeek(String prompt) async {
    final apiKey = await getSavedApiKey();
    if (apiKey == null) throw Exception('DeepSeek API key not found');
    
    final response = await http.post(
      Uri.parse('https://api.deepseek.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'model': 'deepseek-coder',
        'messages': [
          {'role': 'system', 'content': 'You are a coding assistant. Return only code.'},
          {'role': 'user', 'content': prompt},
        ],
      }),
    );
    
    final data = json.decode(response.body);
    return data['choices'][0]['message']['content'].trim();
  }
  
  // OpenAI implementation
  Future<String> _generateWithOpenAI(String prompt) async {
    final apiKey = await getSavedApiKey();
    if (apiKey == null) throw Exception('OpenAI API key not found');
    
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'You are a coding assistant. Return only code.'},
          {'role': 'user', 'content': prompt},
        ],
      }),
    );
    
    final data = json.decode(response.body);
    return data['choices'][0]['message']['content'].trim();
  }
  
  // Local (Ollama) implementation
  Future<String> _generateWithLocal(String prompt) async {
    final customUrl = await _secureStorage.read(key: _customUrlKey);
    if (customUrl == null) throw Exception('Local API URL not found');
    
    final response = await http.post(
      Uri.parse('$customUrl/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'model': 'llama3',
        'prompt': 'You are a coding assistant. Return only code.\n\n$prompt',
        'stream': false,
      }),
    );
    
    final data = json.decode(response.body);
    return data['response'].trim();
  }
  
  // OpenAI-compatible UI Design
  Future<Map<String, dynamic>> _generateUIDesignWithOpenAICompatible(String prompt) async {
    final apiKey = await getSavedApiKey();
    String baseUrl = 'https://api.openai.com/v1';
    String model = 'gpt-3.5-turbo';
    
    if (_currentProvider == AIProvider.deepseek) {
      baseUrl = 'https://api.deepseek.com/v1';
      model = 'deepseek-chat';
    } else if (_currentProvider == AIProvider.local) {
      final customUrl = await _secureStorage.read(key: _customUrlKey);
      if (customUrl == null) throw Exception('Local API URL not found');
      baseUrl = customUrl;
      model = 'llama3';
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        if (_currentProvider != AIProvider.local) 'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'model': model,
        'messages': [
          {'role': 'system', 'content': 'You are a UI/UX designer. Return only JSON.'},
          {'role': 'user', 'content': prompt},
        ],
      }),
    );
    
    final data = json.decode(response.body);
    final content = data['choices'][0]['message']['content'];
    return _parseDesignResponse(content);
  }
  
  // Connection tests
  Future<bool> _testOpenAICompatibleConnection() async {
    final apiKey = await getSavedApiKey();
    if (apiKey == null) return false;
    
    try {
      String baseUrl = 'https://api.openai.com/v1';
      if (_currentProvider == AIProvider.deepseek) {
        baseUrl = 'https://api.deepseek.com/v1';
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': _currentProvider == AIProvider.deepseek ? 'deepseek-chat' : 'gpt-3.5-turbo',
          'messages': [{'role': 'user', 'content': 'Say OK'}],
          'max_tokens': 5,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> _testLocalConnection() async {
    final customUrl = await _secureStorage.read(key: _customUrlKey);
    if (customUrl == null) return false;
    
    try {
      final response = await http.get(Uri.parse(customUrl));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // باقی آپ کے helper methods ویسے ہی رہیں گے
  String _buildFrameworkPrompt(String userPrompt, String framework, List<String> platforms) {
    final platformList = platforms.join(', ');
    return '''
Generate COMPLETE $framework code for: $userPrompt
Platforms: $platformList
RETURN ONLY CODE.
''';
  }

  String _cleanGeneratedCode(String code, String framework) {
    code = code.replaceAll(RegExp(r'```[a-z]*\n'), '');
    code = code.replaceAll('```', '');
    return code.trim();
  }

  Map<String, dynamic> _parseDesignResponse(String rawResponse) {
    try {
      String cleaned = rawResponse
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      
      final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(cleaned);
      if (jsonMatch != null) {
        cleaned = jsonMatch.group(0)!;
      }
      
      return json.decode(cleaned);
    } catch (e) {
      return _createFallbackDesign('Parsing failed', 'container');
    }
  }

  Map<String, dynamic> _createFallbackDesign(String prompt, String componentType) {
    // آپ کا موجودہ fallback design
    return {
      'componentType': componentType == 'auto' ? 'container' : componentType,
      'label': prompt.length > 20 ? '${prompt.substring(0, 20)}...' : prompt,
      'properties': {'padding': {'top': 16, 'right': 16, 'bottom': 16, 'left': 16}},
      'style': {
        'backgroundColor': '#6366F1',
        'borderRadius': 16.0,
        'gradient': {'colors': ['#6366F1', '#8B5CF6']},
      },
    };
  }

  Map<String, dynamic>? _getFallbackSuggestion(String category) {
    // آپ کا موجودہ fallback
    return {
      'ai': {'name': 'Google Gemini', 'url': 'https://makersuite.google.com/app/apikey'},
    }[category.toLowerCase()];
  }

  Future<String> getFirebaseAuthGuide() async {
    await _initialization;
    final response = await _geminiModel.generateContent([Content.text("Firebase Auth guide")]);
    return response.text ?? 'Guide unavailable.';
  }

  Future<String> getFirebaseDatabaseGuide() async {
    await _initialization;
    final response = await _geminiModel.generateContent([Content.text("Firebase Firestore guide")]);
    return response.text ?? 'Guide unavailable.';
  }

  Future<String> generateGeminiLink(String topic, {bool open = false}) async {
    final key = await getSavedApiKey();
    if (key == null || key.isEmpty) throw Exception('API key not found.');
    final link = "https://aistudio.google.com/app/prompts/new?prompt=${Uri.encodeComponent(topic)}";
    if (open) await LinkHelper.openLink(link);
    return link;
  }

  // Helper methods
  void _saveApiKeyDirectly(String apiKey) {
    _secureStorage.write(key: _apiKeyKey, value: apiKey);
  }
  
  void _saveCustomUrlDirectly(String url) {
    _secureStorage.write(key: _customUrlKey, value: url);
  }
  
  AIProvider _parseProvider(String provider) {
    switch (provider.toLowerCase()) {
      case 'deepseek': return AIProvider.deepseek;
      case 'openai': return AIProvider.openai;
      case 'local': return AIProvider.local;
      default: return AIProvider.gemini;
    }
  }

  // باقی آپ کے methods (generateFlutterCode, generateUIKit, etc.) ویسے ہی رہیں گے
  // میں نے صرف اوپر کے methods لکھے ہیں، باقی آپ کے کوڈ میں موجود ہیں
}

// ==============================================================
// 🎯 ENUMS
// ==============================================================

enum AIProvider {
  gemini('Gemini'),
  deepseek('DeepSeek'),
  openai('OpenAI'),
  local('Local');
  
  final String name;
  const AIProvider(this.name);
}
