import '../models/api_template_model.dart';
import 'gemini_service.dart'; // ✅ یہ امپورٹ شامل کریں

class AIApiFinder {
  final GeminiService geminiService;

  AIApiFinder({required this.geminiService});

  Future<List<ApiTemplate>> findRelevantApis({
    required String appDescription,
    required String framework,
    required String appName,
  }) async {
    try {
      String prompt = """
میں "$appName" ایپ بنا رہا ہوں۔ 
مجھے متعلقہ APIs کے بارے میں بتائیں۔

ایپ کی تفصیل: $appDescription
فریم ورک: $framework

براہ کرم درج ذیل فارمیٹ میں جواب دیں۔ ہر API الگ لائن پر:
API_NAME|PROVIDER|URL|DESCRIPTION|CATEGORY|KEY_REQUIRED|FREE_TIER

مثالیں:
Google Tasks API|Google|https://developers.google.com/tasks|ٹاسک مینجمنٹ کے لیے|Productivity|true|1000 requests/day
Firebase Auth|Google|https://firebase.google.com/docs/auth|صارف authentication کے لیے|Authentication|true|10000 users free
WeatherAPI|WeatherAPI|https://www.weatherapi.com|موسمی کی معلومات کے لیے|Weather|true|1000000 calls/month

صرف APIs کی لسٹ لوٹائیں، کوئی اضافی متن نہیں۔
""";

      final String response = await geminiService.generateCode(
        prompt: prompt,
        framework: framework,
        platforms: ['Android', 'iOS'],
      );

      return _parseApiResponse(response);
    } catch (e) {
      print('API discovery error: $e');
      return _getDefaultApis(); // Fallback APIs
    }
  }

  List<ApiTemplate> _parseApiResponse(String response) {
    final List<ApiTemplate> apis = [];
    final lines = response.split('\n');

    for (String line in lines) {
      try {
        final parts = line.split('|');
        if (parts.length >= 7) {
          final api = ApiTemplate(
            id: 'ai_${DateTime.now().millisecondsSinceEpoch}_${apis.length}',
            name: parts[0].trim(),
            provider: parts[1].trim(),
            url: parts[2].trim(),
            description: parts[3].trim(),
            category: parts[4].trim(),
            keyRequired: parts[5].trim().toLowerCase() == 'true',
            freeTierInfo: parts[6].trim(),
          );
          apis.add(api);
        }
      } catch (e) {
        print('Error parsing API line: $line');
      }
    }

    return apis.isNotEmpty ? apis : _getDefaultApis();
  }

  List<ApiTemplate> _getDefaultApis() {
    // ڈیفالٹ APIs اگر AI response نہ ملے
    return [
      ApiTemplate(
        id: 'default_gemini',
        name: 'Google Gemini AI',
        provider: 'Google',
        url: 'https://makersuite.google.com/app/apikey',
        description: 'AI چیٹ اور کوڈ جنریشن کے لیے',
        category: 'AI',
        keyRequired: true,
        freeTierInfo: 'روزانہ 60 requests مفت',
      ),
      ApiTemplate(
        id: 'default_github',
        name: 'GitHub API',
        provider: 'GitHub',
        url: 'https://github.com/settings/tokens',
        description: 'Repositories بنانے کے لیے',
        category: 'Development',
        keyRequired: true,
        freeTierInfo: 'لا محدود repositories',
      ),
    ];
  }
}
