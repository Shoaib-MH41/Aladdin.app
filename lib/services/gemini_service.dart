// lib/services/gemini_service.dart
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
  GenerativeModel? _geminiModel;
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
      
      // Initialize ONLY for Gemini
      if (_currentProvider == AIProvider.gemini && apiKey != null && apiKey.isNotEmpty) {
        _geminiModel = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );
      }
      
      // Service is initialized if credentials exist
      _isInitialized = _hasValidCredentials(apiKey, customUrl);
      
      print('✅ GeminiService initialized with ${_currentProvider.name}');
    } catch (e) {
      _isInitialized = false;
      print('❌ GeminiService initialization failed: $e');
    }
  }
  
  /// 🔹 Check if provider has valid credentials
  bool _hasValidCredentials(String? apiKey, String? customUrl) {
    switch (_currentProvider) {
      case AIProvider.gemini:
      case AIProvider.deepseek:
      case AIProvider.openai:
        return apiKey != null && apiKey.isNotEmpty;
      case AIProvider.local:
        return customUrl != null && customUrl.isNotEmpty;
    }
  }

  /// 🔹 Change AI Provider
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

  /// 🔹 Get Current Provider
  AIProvider get currentProvider => _currentProvider;

  // ==============================================================
  // 🔹 API Key Management
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
      await _initializeFromStorage();
      print('🔐 API key securely saved for ${_currentProvider.name}');
    } catch (e) {
      throw Exception('API key save failed: $e');
    }
  }

  Future<void> removeApiKey() async {
    try {
      await _secureStorage.delete(key: _apiKeyKey);
      _isInitialized = false;
      _geminiModel = null;
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
  // 🚀 CORE AI FUNCTIONS (Universal)
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
      final fullPrompt = _buildUIDesignPrompt(prompt, componentType);
      
      switch (_currentProvider) {
        case AIProvider.gemini:
          if (_geminiModel == null) throw Exception('Gemini model not initialized');
          final response = await _geminiModel!.generateContent([Content.text(fullPrompt)]);
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
      final prompt = _buildFlutterCodePrompt(designJson, includeComments, addDependencies);
      
      if (_currentProvider == AIProvider.gemini) {
        if (_geminiModel == null) throw Exception('Gemini model not initialized');
        final response = await _geminiModel!.generateContent([Content.text(prompt)]);
        return _cleanGeneratedCode(response.text?.trim() ?? '', 'flutter');
      } else {
        return await generateCode(
          prompt: prompt,
          framework: 'flutter',
          platforms: ['android', 'ios'],
        );
      }
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
      final prompt = _buildUIKitPrompt(appTheme, components);
      
      String responseText;
      
      switch (_currentProvider) {
        case AIProvider.gemini:
          if (_geminiModel == null) throw Exception('Gemini model not initialized');
          final response = await _geminiModel!.generateContent([Content.text(prompt)]);
          responseText = response.text?.trim() ?? '[]';
          break;
          
        case AIProvider.deepseek:
        case AIProvider.openai:
        case AIProvider.local:
          responseText = await _generateTextWithOpenAICompatible(prompt);
          break;
      }

      return _parseUIKitResponse(responseText, appTheme, components);
    } catch (e) {
      print('❌ UI Kit Generation Failed: $e');
      return _generateFallbackUIKit(appTheme, components);
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
      final debugPrompt = _buildDebugPrompt(faultyCode, errorDescription, framework, originalPrompt);
      
      return await generateCode(
        prompt: debugPrompt,
        framework: framework,
        platforms: ['all'],
      );
    } catch (e) {
      throw Exception('ڈیبگنگ ناکام: $e');
    }
  }

  /// 🔹 Test Connection (Universal)
  Future<bool> testConnection() async {
    await _initialization;
    if (!_isInitialized) return false;

    try {
      switch (_currentProvider) {
        case AIProvider.gemini:
          if (_geminiModel == null) return false;
          final response = await _geminiModel!.generateContent([Content.text("Say only: OK")]);
          return response.text?.toLowerCase().contains("ok") ?? false;
          
        case AIProvider.deepseek:
        case AIProvider.openai:
          return await _testOpenAICompatibleConnection();
          
        case AIProvider.local:
          return await _testLocalConnection();
      }
    } catch (e) {
      print('⚠️ Connection test failed: $e');
      return false;
    }
  }

  /// 🔹 API Suggestion (Universal)
  Future<Map<String, dynamic>?> getApiSuggestion(String category) async {
    await _initialization;
    
    try {
      final prompt = '''
Generate API suggestion for category: $category
Return JSON with name, url, and note.
''';

      switch (_currentProvider) {
        case AIProvider.gemini:
          if (_geminiModel == null) throw Exception('Gemini model not initialized');
          final response = await _geminiModel!.generateContent([Content.text(prompt)]);
          return _parseApiSuggestion(response.text ?? '{}');
          
        case AIProvider.deepseek:
        case AIProvider.openai:
        case AIProvider.local:
          final response = await _generateTextWithOpenAICompatible(prompt);
          return _parseApiSuggestion(response);
      }
    } catch (e) {
      print('⚠️ API suggestion failed: $e');
      return _getFallbackSuggestion(category);
    }
  }

  // ==============================================================
  // 🔧 PRIVATE HELPER METHODS
  // ==============================================================

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

  // ============= 📝 PROMPT BUILDERS =============

  String _buildFrameworkPrompt(String userPrompt, String framework, List<String> platforms) {
    final platformList = platforms.join(', ');
    
    // ✅ Check if user wants login/authentication
    if (userPrompt.toLowerCase().contains('login') || 
        userPrompt.toLowerCase().contains('sign in') ||
        userPrompt.toLowerCase().contains('authentication') ||
        userPrompt.toLowerCase().contains('auth') ||
        userPrompt.toLowerCase().contains('user account')) {
      
      return '''
Generate COMPLETE $framework code with Firebase Authentication for: $userPrompt

REQUIREMENTS:
- User can login with email and password
- User can sign up with email and password
- User can sign out
- Show appropriate error messages
- Include loading states

PLATFORMS: $platformList

FILES NEEDED (User will upload them separately):
- Android: google-services.json
- iOS: GoogleService-Info.plist

INSTRUCTIONS:
1. Include firebase_core and firebase_auth dependencies
2. Initialize Firebase in main()
3. Create Login screen with email/password
4. Create Sign Up screen
5. Add Sign Out functionality
6. Protect screens (only logged-in users can access)
7. Return COMPLETE working code
8. Add comments explaining Firebase setup

IMPORTANT: Tell user they need to:
- Get google-services.json from Firebase Console
- Get GoogleService-Info.plist from Firebase Console
- Enable Email/Password in Firebase Authentication

CODE:
''';
    }
    
    // Normal code without authentication
    return '''
Generate COMPLETE $framework code for: $userPrompt
Platforms: $platformList
RETURN ONLY CODE. NO EXPLANATIONS.
''';
  }

  String _buildUIDesignPrompt(String prompt, String componentType) {
    final type = componentType.toLowerCase() == 'auto' ? 'UI component' : componentType;
    return '''
You are a UI/UX designer. Create a modern, beautiful $type design for:
$prompt

Return ONLY JSON with this structure:
{
  "componentType": "$componentType",
  "label": "Title",
  "properties": {},
  "style": {
    "backgroundColor": "#HEX",
    "borderRadius": 0,
    "gradient": {}
  }
}
''';
  }

  String _buildFlutterCodePrompt(String designJson, bool comments, bool dependencies) {
    return '''
Convert this UI design JSON into Flutter code:
$designJson

${comments ? 'Add helpful comments' : 'No comments'}
${dependencies ? 'Add imports' : 'Core Flutter only'}

Return ONLY Flutter code:
''';
  }

  String _buildUIKitPrompt(String theme, List<String> components) {
    return '''
Generate UI Kit for $theme app with: ${components.join(', ')}
Return JSON array where each item has componentType, label, and style.
ONLY JSON.
''';
  }

  String _buildDebugPrompt(String code, String error, String framework, String original) {
    return '''
Fix this $framework code:

ORIGINAL: $original

CODE:
$code

ERROR: $error

Return ONLY fixed code:
''';
  }

  // ============= 🤖 AI IMPLEMENTATIONS =============

  Future<String> _generateWithGemini(String prompt) async {
    if (_geminiModel == null) throw Exception('Gemini model not initialized');
    final response = await _geminiModel!.generateContent([Content.text(prompt)]);
    return _cleanGeneratedCode(response.text?.trim() ?? '', 'flutter');
  }
  
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
        'temperature': 0.1,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'].trim();
    }
    throw Exception('DeepSeek API error: ${response.statusCode}');
  }
  
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
        'temperature': 0.1,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'].trim();
    }
    throw Exception('OpenAI API error: ${response.statusCode}');
  }
  
  Future<String> _generateWithLocal(String prompt) async {
    final customUrl = await _secureStorage.read(key: _customUrlKey);
    if (customUrl == null) throw Exception('Local API URL not found');
    
    final response = await http.post(
      Uri.parse('$customUrl/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'model': 'codellama',
        'prompt': prompt,
        'stream': false,
        'temperature': 0.1,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['response'].trim();
    }
    throw Exception('Local API error: ${response.statusCode}');
  }
  
  Future<String> _generateTextWithOpenAICompatible(String prompt) async {
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
          {'role': 'system', 'content': 'You are a helpful assistant. Return only the requested data.'},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.1,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'].trim();
    }
    throw Exception('API error: ${response.statusCode}');
  }
  
  Future<Map<String, dynamic>> _generateUIDesignWithOpenAICompatible(String prompt) async {
    final responseText = await _generateTextWithOpenAICompatible(prompt);
    return _parseDesignResponse(responseText);
  }
  
  // ============= 🔌 CONNECTION TESTS =============
  
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

  // ============= 📊 PARSING METHODS =============

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

  List<Map<String, dynamic>> _parseUIKitResponse(String response, String theme, List<String> components) {
    try {
      String cleaned = response
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      
      final jsonMatch = RegExp(r'\[[^\[\]]*(?:\[[^\[\]]*\][^\[\]]*)*\]').firstMatch(cleaned);
      if (jsonMatch != null) {
        cleaned = jsonMatch.group(0)!;
      }
      
      final List<dynamic> parsed = json.decode(cleaned);
      return parsed.cast<Map<String, dynamic>>();
    } catch (e) {
      return _generateFallbackUIKit(theme, components);
    }
  }

  Map<String, dynamic>? _parseApiSuggestion(String response) {
    try {
      String cleaned = response
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      
      final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(cleaned);
      if (jsonMatch != null) {
        cleaned = jsonMatch.group(0)!;
      }
      
      return json.decode(cleaned);
    } catch (e) {
      return null;
    }
  }

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
      },
      'payment': {
        'name': 'Stripe API',
        'url': 'https://dashboard.stripe.com/apikeys',
        'note': 'Test and live keys available'
      },
      'maps': {
        'name': 'Google Maps Platform',
        'url': 'https://console.cloud.google.com/google/maps-apis',
        'note': 'Enable Maps SDK and get API key'
      },
      'social': {
        'name': 'Facebook Graph API',
        'url': 'https://developers.facebook.com/docs/facebook-login/guides/access-tokens/',
        'note': 'Create Facebook App to get credentials'
      },
      'storage': {
        'name': 'AWS S3',
        'url': 'https://aws.amazon.com/s3/',
        'note': 'Create AWS account and get access keys'
      },
      'email': {
        'name': 'SendGrid API',
        'url': 'https://sendgrid.com/docs/for-developers/sending-email/api-getting-started/',
        'note': 'Sign up for free tier'
      },
      'sms': {
        'name': 'Twilio API',
        'url': 'https://www.twilio.com/docs/usage/api',
        'note': 'Get Account SID and Auth Token'
      }
    };
    
    final key = category.toLowerCase();
    return fallbacks[key] ?? fallbacks['ai'];
  }

  // ============= 🎨 FALLBACK METHODS =============

  Map<String, dynamic> _createFallbackDesign(String prompt, String componentType) {
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
        child: Text(label, style: TextStyle(color: Colors.white)),
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
        'label': '$theme ${component[0].toUpperCase()}${component.substring(1)}',
        'style': {
          'backgroundColor': '#6366F1',
          'borderRadius': 16.0,
          'textColor': '#FFFFFF',
        },
      };
    }).toList();
  }

  String _toPascalCase(String input) {
    if (input.isEmpty) return '';
    final words = input.split(RegExp(r'[_-\s]'));
    return words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join();
  }
}

// ==============================================================
// 🎯 ENUMS (class کے باہر)
// ==============================================================

enum AIProvider {
  gemini('Gemini'),
  deepseek('DeepSeek'),
  openai('OpenAI'),
  local('Local');
  
  final String name;
  const AIProvider(this.name);
}
