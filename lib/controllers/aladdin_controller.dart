import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

/// 🔮 AladdinController - Gemini AI سے کوڈ جنریٹ اور GitHub پر اپلوڈ
class AladdinController {
  final _storage = const FlutterSecureStorage();
  static const _githubApi = 'https://api.github.com';

  // 🔐 API کیز حاصل کرنا
  Future<String?> _getApiKey(String keyName) async {
    return await _storage.read(key: keyName);
  }

  /// 💫 Gemini سے ایپ جنریٹ اور GitHub پر اپلوڈ کرنا
  Future<Map<String, dynamic>> generateAndUploadApp({
    required String prompt,
    required String framework,
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

    try {
      // ✨ Gemini سے کوڈ حاصل کریں
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: geminiKey);
      final content = [
        Content.text(
          "Generate a complete $framework app for: $prompt\n"
          "Return only the main code file without any explanations or markdown formatting."
        ),
      ];

      final response = await model.generateContent(content);
      final generatedCode = response.text ?? '';

      if (generatedCode.isEmpty) {
        throw '❌ کوڈ جنریٹ نہیں ہو سکا۔ Gemini نے خالی جواب دیا۔';
      }

      // 🗃️ GitHub پر نیا Repo بنائیں
      final repoUrl = await _createGitHubRepo(
        githubToken,
        repoName,
        'Auto-created $framework app from Aladdin System: $prompt',
      );

      // 📦 مین فائل اپلوڈ کریں
      final fileName = _getMainFileName(framework);
      await _uploadToGitHub(
        githubToken,
        repoName,
        fileName,
        generatedCode,
        'Initial commit: $prompt',
      );

      // 📁 اضافی فائلیں بنائیں (framework کے مطابق)
      await _createAdditionalFiles(githubToken, repoName, framework, prompt);

      return {
        'success': true,
        'repoUrl': repoUrl,
        'message': '✅ ایپ GitHub پر اپلوڈ ہو گئی!',
        'code': generatedCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': '❌ خرابی: $e',
        'repoUrl': null,
      };
    }
  }

  // 🔧 مین فائل کا نام طے کرنا
  String _getMainFileName(String framework) {
    switch (framework.toLowerCase()) {
      case 'flutter':
        return 'lib/main.dart';
      case 'react':
        return 'src/App.js';
      case 'vue':
        return 'src/App.vue';
      case 'html':
        return 'index.html';
      default:
        return 'main.dart';
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
          'auto_init': true,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['html_url'];
      } else if (response.statusCode == 422) {
        // ریپو پہلے سے موجود ہو تو لنک واپس کریں
        final username = await _getGitHubUsername(token);
        return 'https://github.com/$username/$repoName';
      } else {
        throw '❌ GitHub Repo بنانے میں ناکامی (${response.statusCode})';
      }
    } catch (e) {
      throw '❌ GitHub سے رابطہ کرنے میں خرابی: $e';
    }
  }

  // 👤 GitHub username حاصل کرنا
  Future<String> _getGitHubUsername(String token) async {
    final response = await http.get(
      Uri.parse('$_githubApi/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      return userData['login'];
    } else {
      return 'your-username';
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
      final username = await _getGitHubUsername(token);
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
        throw '❌ فائل اپلوڈ نہیں ہو سکی (${response.statusCode})';
      }
    } catch (e) {
      throw '❌ GitHub پر فائل اپلوڈ کرنے میں خرابی: $e';
    }
  }

  // 📁 اضافی فائلیں بنانا
  Future<void> _createAdditionalFiles(
    String token,
    String repoName,
    String framework,
    String prompt,
  ) async {
    try {
      final username = await _getGitHubUsername(token);
      
      // README.md فائل
      final readmeContent = '''
# $repoName

$framework ایپ جو Aladdin System کے ذریعے خودکار بنائی گئی۔

## تفصیل
$prompt

## انسٹالیشن
\`\`\`bash
git clone https://github.com/$username/$repoName.git
cd $repoName
\`\`\'

## چلانے کا طریقہ
${_getRunInstructions(framework)}
''';

      await _uploadToGitHub(
        token,
        repoName,
        'README.md',
        readmeContent,
        'Add README.md',
      );

      // Flutter کے لیے pubspec.yaml
      if (framework.toLowerCase() == 'flutter') {
        final pubspecContent = '''
name: $repoName
description: A Flutter app generated by Aladdin System.
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
''';

        await _uploadToGitHub(
          token,
          repoName,
          'pubspec.yaml',
          pubspecContent,
          'Add pubspec.yaml',
        );
      }

    } catch (e) {
      // اضافی فائلیں نہ بن سکیں تو صرف ignore کریں
      print('⚠️ اضافی فائلیں نہیں بن سکیں: $e');
    }
  }

  // 🏃‍♂️ چلانے کی ہدایات
  String _getRunInstructions(String framework) {
    switch (framework.toLowerCase()) {
      case 'flutter':
        return 'flutter pub get && flutter run';
      case 'react':
        return 'npm install && npm start';
      case 'vue':
        return 'npm install && npm run dev';
      case 'html':
        return 'براؤزر میں index.html کھولیں';
      default:
        return 'دیکھیں README.md';
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
      
      final cleanJson = jsonText.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final List<dynamic> jsonList = jsonDecode(cleanJson);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      throw '❌ APIs ڈسکوری میں خرابی: $e';
    }
  }
}
