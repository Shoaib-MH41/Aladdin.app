import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

/// 🔮 AladdinController —
/// یہ کلاس Gemini AI سے کوڈ جنریٹ کرتی ہے
/// اور GitHub پر اپلوڈ کرتی ہے۔
class AladdinController {
  final _storage = const FlutterSecureStorage();
  static const _githubApi = 'https://api.github.com';

  // 🔐 API کیز حاصل کرنا
  Future<String?> _getApiKey(String keyName) async {
    return await _storage.read(key: keyName);
  }

  /// 💫 Gemini سے ایپ جنریٹ اور GitHub پر اپلوڈ کرنا
  Future<String> generateAndUploadApp({
    required String prompt,
    required String framework,
    required List<String> platforms,
    required String repoName,
  }) async {
    final geminiKey = await _getApiKey('gemini_api_key');
    final githubToken = await _getApiKey('github_token');

    if (geminiKey == null) {
      throw '⚠️ Gemini API Key محفوظ نہیں ہے۔ براہ کرم Settings میں سیٹ کریں۔';
    }

    if (githubToken == null) {
      throw '⚠️ GitHub Token محفوظ نہیں ہے۔ براہ کرم Settings میں سیٹ کریں۔';
    }

    // ✨ Gemini سے کوڈ حاصل کریں
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: geminiKey);
    final content = [
      Content.text(
        "Generate a complete $framework app for: $prompt\n"
        "Platforms: ${platforms.join(', ')}\n"
        "Include full source code with main file and assets if needed.\n"
        "Return only the code without any explanations or markdown formatting."
      ),
    ];

    try {
      final response = await model.generateContent(content);
      final generatedCode = response.text ?? '';

      if (generatedCode.isEmpty) {
        throw '❌ کوڈ جنریٹ نہیں ہو سکا۔ Gemini نے خالی جواب دیا۔';
      }

      // 🗃️ GitHub پر نیا Repo بنائیں
      final repoUrl = await _createGitHubRepo(
        githubToken,
        repoName,
        'Auto-created app from Aladdin System: $prompt',
      );

      // 📦 فائل اپلوڈ کریں (main.dart یا index.html)
      final fileName = framework.toLowerCase().contains('flutter')
          ? 'lib/main.dart'
          : 'index.html';

      await _uploadToGitHub(
        githubToken,
        repoName,
        fileName,
        generatedCode,
        'Initial commit: $prompt',
      );

      return repoUrl;
    } catch (e) {
      throw '❌ Gemini سے کوڈ جنریٹ کرنے میں خرابی: $e';
    }
  }

  // 🔧 GitHub Repo بنانا
  Future<String> _createGitHubRepo(
    String token,
    String repoName,
    String description,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_githubApi/user/repos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': repoName,
          'description': description,
          'private': false,
          'auto_init': true, // README فائل خود بخود بن جائے گی
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['html_url'];
      } else if (response.statusCode == 422) {
        // ریپو پہلے سے موجود ہو تو لنک واپس کریں
        // یوزرنیم حاصل کرنے کے لیے ایک API call کریں
        final userResponse = await http.get(
          Uri.parse('$_githubApi/user'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/vnd.github.v3+json',
          },
        );
        
        if (userResponse.statusCode == 200) {
          final userData = jsonDecode(userResponse.body);
          final username = userData['login'];
          return 'https://github.com/$username/$repoName';
        } else {
          return 'https://github.com/your-username/$repoName';
        }
      } else {
        throw '❌ GitHub Repo بنانے میں ناکامی (${response.statusCode}): ${response.body}';
      }
    } catch (e) {
      throw '❌ GitHub سے رابطہ کرنے میں خرابی: $e';
    }
  }

  // 📤 فائل GitHub پر اپلوڈ کرنا
  Future<void> _uploadToGitHub(
    String token,
    String repoName,
    String filePath,
    String content,
    String commitMessage,
  ) async {
    try {
      // پہلے یوزرنیم حاصل کریں
      final userResponse = await http.get(
        Uri.parse('$_githubApi/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (userResponse.statusCode != 200) {
        throw '❌ GitHub user info حاصل نہیں ہو سکی';
      }

      final userData = jsonDecode(userResponse.body);
      final username = userData['login'];

      final encodedContent = base64Encode(utf8.encode(content));
      
      final response = await http.put(
        Uri.parse('$_githubApi/repos/$username/$repoName/contents/$filePath'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': commitMessage,
          'content': encodedContent,
        }),
      );

      if (response.statusCode != 201) {
        final errorBody = jsonDecode(response.body);
        throw '❌ فائل اپلوڈ نہیں ہو سکی (${response.statusCode}): ${errorBody['message'] ?? response.body}';
      }
    } catch (e) {
      throw '❌ GitHub پر فائل اپلوڈ کرنے میں خرابی: $e';
    }
  }

  /// 🔍 API ڈسکوری کے لیے Gemini سے مدد لینا
  Future<List<Map<String, dynamic>>> discoverApis({
    required String projectDescription,
    required String projectType,
  }) async {
    final geminiKey = await _getApiKey('gemini_api_key');
    
    if (geminiKey == null) {
      throw '⚠️ Gemini API Key محفوظ نہیں ہے۔';
    }

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: geminiKey);
    final content = [
      Content.text(
        "Suggest 5-7 relevant APIs for a $projectType app with this description: $projectDescription\n"
        "Return only a JSON array with this structure for each API:\n"
        "[{\n"
        "  \"name\": \"API Name\",\n"
        "  \"provider\": \"Company Name\",\n"
        "  \"description\": \"Brief description\",\n"
        "  \"url\": \"https://api-docs.com\",\n"
        "  \"category\": \"ai|weather|productivity|authentication|development\",\n"
        "  \"freeTierInfo\": \"Free tier details\",\n"
        "  \"keyRequired\": true/false\n"
        "}]\n"
        "Return only valid JSON, no other text."
      ),
    ];

    try {
      final response = await model.generateContent(content);
      final jsonText = response.text ?? '[]';
      
      // JSON کو صاف کریں (اگر Gemini نے اضافی متن دیا ہو)
      final cleanJson = jsonText.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final List<dynamic> jsonList = jsonDecode(cleanJson);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      throw '❌ APIs ڈسکوری میں خرابی: $e';
    }
  }
}
