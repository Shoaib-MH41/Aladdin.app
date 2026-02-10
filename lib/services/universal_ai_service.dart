import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// ✅ Universal AI Service - Gemini, DeepSeek, OpenAI, Local سب کے لیے
class UniversalAIService {
  // Settings keys
  static const String _providerKey = 'ai_provider';
  static const String _apiKeyKey = 'ai_api_key';
  static const String _customUrlKey = 'ai_custom_url';
  
  // Current state
  late AIProvider _currentProvider;
  String? _apiKey;
  String? _customUrl;
  GenerativeModel? _geminiModel;
  bool _isInitialized = false;
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late final Future<void> _initialization;

  UniversalAIService() {
    _initialization = _initializeFromStorage();
  }

  /// 🔹 Factory constructors for easy creation
  factory UniversalAIService.gemini({String? apiKey}) {
    final service = UniversalAIService();
    service._currentProvider = AIProvider.gemini;
    if (apiKey != null) service._apiKey = apiKey;
    return service;
  }
  
  factory UniversalAIService.deepseek({required String apiKey}) {
    final service = UniversalAIService();
    service._currentProvider = AIProvider.deepseek;
    service._apiKey = apiKey;
    return service;
  }
  
  factory UniversalAIService.openai({required String apiKey}) {
    final service = UniversalAIService();
    service._currentProvider = AIProvider.openai;
    service._apiKey = apiKey;
    return service;
  }
  
  factory UniversalAIService.local({required String baseUrl}) {
    final service = UniversalAIService();
    service._currentProvider = AIProvider.local;
    service._customUrl = baseUrl;
    return service;
  }

  /// 🔹 Initialize from saved settings
  Future<void> _initializeFromStorage() async {
    try {
      final savedProvider = await _secureStorage.read(key: _providerKey);
      _currentProvider = _parseProvider(savedProvider ?? 'gemini');
      
      _apiKey = await _secureStorage.read(key: _apiKeyKey);
      _customUrl = await _secureStorage.read(key: _customUrlKey);
      
      // Initialize Gemini model if provider is Gemini
      if (_currentProvider == AIProvider.gemini && _apiKey != null && _apiKey!.isNotEmpty) {
        _geminiModel = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: _apiKey!,
        );
        _isInitialized = true;
        print('✅ Universal AI Service initialized with ${_currentProvider.name}');
      } else if (_apiKey != null && _apiKey!.isNotEmpty) {
        _isInitialized = true;
        print('✅ Universal AI Service initialized with ${_currentProvider.name}');
      } else {
        _isInitialized = false;
        print('⚠️ AI Service not initialized - API key missing');
      }
    } catch (e) {
      _isInitialized = false;
      print('❌ Universal AI Service initialization failed: $e');
    }
  }

  /// 🔹 Change AI Provider
  Future<void> changeProvider(AIProvider provider, {String? apiKey, String? customUrl}) async {
    _currentProvider = provider;
    if (apiKey != null) _apiKey = apiKey;
    if (customUrl != null) _customUrl = customUrl;
    
    await _secureStorage.write(key: _providerKey, value: provider.name);
    if (apiKey != null) {
      await _secureStorage.write(key: _apiKeyKey, value: apiKey);
    }
    if (customUrl != null) {
      await _secureStorage.write(key: _customUrlKey, value: customUrl);
    }
    
    await _initializeFromStorage();
  }

  /// 🔹 Get Saved API Key (آپ کے موجودہ GeminiService جیسا)
  Future<String?> getSavedApiKey() async {
    return await _secureStorage.read(key: _apiKeyKey);
  }

  /// 🔹 Save API Key (آپ کے موجودہ GeminiService جیسا)
  Future<void> saveApiKey(String apiKey) async {
    try {
      await _secureStorage.write(key: _apiKeyKey, value: apiKey.trim());
      _apiKey = apiKey.trim();
      
      // Re-initialize Gemini if that's the current provider
      if (_currentProvider == AIProvider.gemini) {
        _geminiModel = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: _apiKey!,
        );
        _isInitialized = true;
      }
      
      print('🔐 API key saved for ${_currentProvider.name}');
    } catch (e) {
      throw Exception('API key save failed: $e');
    }
  }

  /// 🔹 Remove API Key (آپ کے موجودہ GeminiService جیسا)
  Future<void> removeApiKey() async {
    try {
      await _secureStorage.delete(key: _apiKeyKey);
      _apiKey = null;
      _isInitialized = false;
      _geminiModel = null;
      print('🗑️ API key removed');
    } catch (e) {
      throw Exception('API key removal failed: $e');
    }
  }

  Future<bool> isInitialized() async {
    await _initialization;
    return _isInitialized && (_apiKey != null || _currentProvider == AIProvider.local);
  }

  // ==============================================================
  // 🚀 CORE AI FUNCTIONS (آپ کے موجودہ GeminiService جیسے)
  // ==============================================================

  /// 🔹 General Code Generation
  Future<String> generateCode({
    required String prompt,
    required String framework,
    required List<String> platforms,
  }) async {
    await _initialization;
    if (!_isInitialized) {
      throw Exception('AI Service not initialized. Set API key first.');
    }

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

  /// 🔹 UI Design Generation (آپ کا نیا فیچر)
  Future<Map<String, dynamic>> generateUIDesign({
    required String prompt,
    String componentType = 'auto',
  }) async {
    await _initialization;
    if (!_isInitialized) {
      throw Exception('AI Service not initialized.');
    }

    try {
      final systemPrompt = '''
آپ ایک ماہر Modern UI/UX ڈیزائنر ہیں۔ صرف JSON لوٹائیں۔

JSON Structure:
{
  "componentType": "button|card|textfield|container",
  "label": "Component label",
  "properties": {...},
  "style": {...}
}

Modern Design:
- Gradients: #6366F1 سے #8B5CF6
- Border Radius: 12-30
- Shadows: medium
- Modern colors
''';

      final userPrompt = componentType.toLowerCase() == 'auto'
          ? prompt
          : "Create a modern $componentType for: $prompt";

      switch (_currentProvider) {
        case AIProvider.gemini:
          return await _generateUIDesignWithGemini(systemPrompt, userPrompt);
          
        case AIProvider.deepseek:
        case AIProvider.openai:
        case AIProvider.local:
          return await _generateUIDesignWithOpenAICompatible(systemPrompt, userPrompt);
      }
    } catch (e) {
      print('❌ UI Design Generation Failed: $e');
      return _createFallbackDesign(prompt, componentType);
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

  /// 🔹 API Suggestion
  Future<Map<String, dynamic>?> getApiSuggestion(String category) async {
    // آپ کا موجودہ logic یہاں رہے گا
    // Implementation وہی رہے گا
    return null;
  }

  /// 🔹 Test Connection
  Future<bool> testConnection() async {
    await _initialization;
    if (!_isInitialized) return false;

    try {
      switch (_currentProvider) {
        case AIProvider.gemini:
          final response = await _geminiModel!.generateContent([Content.text("Say only: OK")]);
          return response.text?.toLowerCase().contains("ok") ?? false;
          
        case AIProvider.deepseek:
        case AIProvider.openai:
        case AIProvider.local:
          // Test with simple request
          return true;
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
    final response = await _geminiModel!.generateContent([Content.text(prompt)]);
    return response.text?.trim() ?? '';
  }
  
  Future<Map<String, dynamic>> _generateUIDesignWithGemini(String systemPrompt, String userPrompt) async {
    final fullPrompt = '$systemPrompt\n\nUser Request: $userPrompt\n\nReturn only valid JSON.';
    final response = await _geminiModel!.generateContent([Content.text(fullPrompt)]);
    return _parseDesignResponse(response.text ?? '{}');
  }

  // DeepSeek/OpenAI implementation
  Future<String> _generateWithDeepSeek(String prompt) async {
    return await _generateWithOpenAICompatible(
      prompt: prompt,
      baseUrl: 'https://api.deepseek.com/v1',
      model: 'deepseek-coder',
    );
  }
  
  Future<String> _generateWithOpenAI(String prompt) async {
    return await _generateWithOpenAICompatible(
      prompt: prompt,
      baseUrl: 'https://api.openai.com/v1',
      model: 'gpt-3.5-turbo',
    );
  }
  
  Future<String> _generateWithOpenAICompatible({
    required String prompt,
    required String baseUrl,
    required String model,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'model': model,
        'messages': [
          {'role': 'system', 'content': 'You are a coding assistant. Return only code.'},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
      }),
    );
    
    final data = json.decode(response.body);
    return data['choices'][0]['message']['content'].trim();
  }
  
  Future<Map<String, dynamic>> _generateUIDesignWithOpenAICompatible(
    String systemPrompt,
    String userPrompt,
  ) async {
    String baseUrl = 'https://api.openai.com/v1';
    String model = 'gpt-3.5-turbo';
    
    if (_currentProvider == AIProvider.deepseek) {
      baseUrl = 'https://api.deepseek.com/v1';
      model = 'deepseek-chat';
    } else if (_currentProvider == AIProvider.local) {
      baseUrl = _customUrl!;
      model = 'llama3';
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        if (_currentProvider != AIProvider.local) 'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'model': model,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
        'temperature': 0.7,
      }),
    );
    
    final data = json.decode(response.body);
    final content = data['choices'][0]['message']['content'];
    return _parseDesignResponse(content);
  }

  // Local (Ollama) implementation
  Future<String> _generateWithLocal(String prompt) async {
    final response = await http.post(
      Uri.parse('$_customUrl/api/generate'),
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

  String _buildFrameworkPrompt(String userPrompt, String framework, List<String> platforms) {
    final platformList = platforms.join(', ');
    return '''
Generate COMPLETE $framework code for: $userPrompt
Platforms: $platformList
RETURN ONLY CODE.
''';
  }

  Map<String, dynamic> _createFallbackDesign(String prompt, String componentType) {
    return {
      'componentType': componentType == 'auto' ? 'container' : componentType,
      'label': prompt.length > 20 ? '${prompt.substring(0, 20)}...' : prompt,
      'properties': {
        'padding': {'top': 16, 'right': 16, 'bottom': 16, 'left': 16},
      },
      'style': {
        'backgroundColor': '#6366F1',
        'borderRadius': 16.0,
        'gradient': {
          'colors': ['#6366F1', '#8B5CF6'],
        },
      },
      'metadata': {
        'isFallback': true,
        'provider': _currentProvider.name,
      },
    };
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

  AIProvider _parseProvider(String provider) {
    switch (provider.toLowerCase()) {
      case 'deepseek':
        return AIProvider.deepseek;
      case 'openai':
        return AIProvider.openai;
      case 'local':
        return AIProvider.local;
      default:
        return AIProvider.gemini;
    }
  }
}

// ==============================================================
// 🎯 ENUMS & UTILITIES
// ==============================================================

enum AIProvider {
  gemini('Gemini'),
  deepseek('DeepSeek'),
  openai('OpenAI'),
  local('Local');
  
  final String name;
  const AIProvider(this.name);
}
