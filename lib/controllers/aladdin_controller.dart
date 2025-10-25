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

    if (geminiKey == null || githubToken == null) {
      throw '⚠️ Gemini یا GitHub API Key محفوظ نہیں ہے۔ براہ کرم Settings میں سیٹ کریں۔';
    }

    // ✨ Gemini سے کوڈ حاصل کریں
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: geminiKey);
    final content = [
      Content.text(
        "Generate a complete $framework app for: $prompt\n"
        "Platforms: ${platforms.join(', ')}\n"
        "Include full source code with main file and assets if needed."
      ),
    ];

    final response = await model.generateContent(content);
    final generatedCode = response.text ?? '';

    if (generatedCode.isEmpty) throw '❌ کوڈ جنریٹ نہیں ہو سکا۔';

    // 🗃️ GitHub پر نیا Repo بنائیں
    final repoUrl = await _createGitHubRepo(
      githubToken,
      repoName,
      'Auto-created app from Aladdin System',
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
    );

    return repoUrl;
  }

  // 🔧 GitHub Repo بنانا
  Future<String> _createGitHubRepo(
    String token,
    String repoName,
    String description,
  ) async {
    final response = await http.post(
      Uri.parse('$_githubApi/user/repos'),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github+json',
      },
      body: jsonEncode({
        'name': repoName,
        'description': description,
        'private': false,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['html_url'];
    } else if (response.statusCode == 422) {
      // ریپو پہلے سے موجود ہو تو لنک واپس کریں
      return 'https://github.com/your-username/$repoName';
    } else {
      throw '❌ GitHub Repo بنانے میں ناکامی (${response.statusCode}): ${response.body}';
    }
  }

  // 📤 فائل GitHub پر اپلوڈ کرنا
  Future<void> _uploadToGitHub(
    String token,
    String repoName,
    String filePath,
    String content,
  ) async {
    final encoded = base64Encode(utf8.encode(content));
    final response = await http.put(
      Uri.parse('$_githubApi/repos/your-username/$repoName/contents/$filePath'),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github+json',
      },
      body: jsonEncode({
        'message': 'Upload from Aladdin System',
        'content': encoded,
      }),
    );

    if (response.statusCode != 201) {
      throw '❌ فائل اپلوڈ نہیں ہو سکی (${response.statusCode}): ${response.body}';
    }
  }
}
