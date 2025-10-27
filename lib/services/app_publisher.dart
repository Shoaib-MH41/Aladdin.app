import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class PublishService {
  /// 🔹 Save generated app code (as ZIP or text file) in local storage
  Future<String?> saveAppLocally({
    required String appName,
    required String generatedCode,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${appName}_release.zip';
      final file = File(filePath);

      await file.writeAsString(generatedCode);
      debugPrint('✅ File saved at: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('❌ Error saving file: $e');
      return null;
    }
  }

  /// 🔹 Share locally saved file (for quick export or backup)
  Future<void> shareAppFile(String filePath) async {
    try {
      if (await File(filePath).exists()) {
        await Share.shareFiles([filePath],
            text: 'Check out my generated Flutter App 🚀');
      } else {
        debugPrint('❌ File does not exist: $filePath');
      }
    } catch (e) {
      debugPrint('❌ Error sharing file: $e');
    }
  }

  /// 🔹 Open GitHub new repository page to manually upload file
  Future<void> openGithubUploadPage() async {
    const githubUrl = 'https://github.com/new';
    final Uri url = Uri.parse(githubUrl);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        debugPrint('🌐 Opening GitHub repository creation page');
      } else {
        throw 'GitHub cannot be opened';
      }
    } catch (e) {
      debugPrint('❌ Error launching GitHub: $e');
    }
  }

  /// 🔹 (Optional) Future Upgrade: Automatic GitHub Upload via API
  ///
  /// You can later integrate with GitHub’s REST API to publish automatically.
  /// That would require user’s GitHub Personal Access Token.
  /// Example method for future use (disabled for now):
  ///
  /// Future<void> uploadToGithub(String token, String repoName, File file) async {
  ///   // Using `http` package, send file as base64 to GitHub API
  ///   // POST https://api.github.com/repos/{user}/{repo}/contents/{path}
  ///   // Headers: Authorization: token {token}
  ///   // Body: { message, content (base64 encoded) }
  /// }

  /// 🔹 Utility: Get app directory (helpful for debugging)
  Future<String> getAppDirectoryPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  /// 🔹 Delete previously saved app (cleanup option)
  Future<void> deleteSavedApp(String appName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${appName}_release.zip');

    if (await file.exists()) {
      await file.delete();
      debugPrint('🗑️ Deleted file: ${file.path}');
    } else {
      debugPrint('⚠️ File not found for deletion');
    }
  }
}
