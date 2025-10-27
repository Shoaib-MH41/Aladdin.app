import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:archive/archive.dart';

class PublishService {
  /// 🔹 جنریٹ شدہ کوڈ کو ZIP فائل میں محفوظ کریں
  Future<String?> saveAppAsZip({
    required String appName,
    required String generatedCode,
    required String framework,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final zipFilePath = '${dir.path}/${appName}_${framework}_project.zip';
      
      // 📁 ZIP فائل بنائیں
      final archive = Archive();
      
      // 🎯 مین فائل شامل کریں
      final mainFileName = _getMainFileName(framework);
      final mainFileData = utf8.encode(generatedCode);
      archive.addFile(ArchiveFile(mainFileName, mainFileData.length, mainFileData));
      
      // 📝 README.md فائل شامل کریں
      final readmeContent = _generateReadmeContent(appName, framework, generatedCode);
      final readmeData = utf8.encode(readmeContent);
      archive.addFile(ArchiveFile('README.md', readmeData.length, readmeData));
      
      // 🔧 فریم ورک کے مطابق اضافی فائلیں شامل کریں
      await _addFrameworkSpecificFiles(archive, framework, appName);
      
      // 💾 ZIP فائل سیو کریں
      final zipData = ZipEncoder().encode(archive);
      if (zipData != null) {
        final file = File(zipFilePath);
        await file.writeAsBytes(zipData);
        debugPrint('✅ ZIP فائل محفوظ ہو گئی: $zipFilePath');
        return zipFilePath;
      } else {
        throw 'ZIP فائل بنانے میں ناکامی';
      }
    } catch (e) {
      debugPrint('❌ فائل محفوظ کرنے میں خرابی: $e');
      return null;
    }
  }

  /// 🔹 مین فائل کا نام طے کرنا
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
      case 'android native':
        return 'app/src/main/java/com/example/MainActivity.kt';
      default:
        return 'main.dart';
    }
  }

  /// 🔹 README.md مواد بنانا
  String _generateReadmeContent(String appName, String framework, String code) {
    return '''
# $appName

$framework ایپ جو Aladdin System کے ذریعے خودکار بنائی گئی۔

## 🚀 فوری شروع

یہ پروجیکٹ خودکار طریقے سے جنریٹ کیا گیا ہے۔

### 📋 تقاضے
${_getRequirements(framework)}

### 🔧 انسٹالیشن
\`\`\`bash
${_getInstallationCommands(framework, appName)}
\`\`\`

### 🏃‍♂️ چلانے کا طریقہ
\`\`\`bash
${_getRunCommands(framework)}
\`\`\`

### 📦 فائل ڈھانچہ
\`\`\`
${_getFileStructure(framework)}
\`\`\`

## 📞 رابطہ
اگر کوئی مسئلہ ہو تو براہ کرم رابطہ کریں۔

---
*خودکار طریقے سے جنریٹ شدہ - Aladdin System*
''';
  }

  /// 🔹 تقاضے حاصل کرنا
  String _getRequirements(String framework) {
    switch (framework.toLowerCase()) {
      case 'flutter':
        return '- Flutter SDK 3.0+\n- Dart 3.0+\n- Android Studio یا VS Code';
      case 'react':
        return '- Node.js 16+\n- npm یا yarn';
      case 'vue':
        return '- Node.js 16+\n- npm یا yarn';
      case 'android native':
        return '- Android Studio\n- Java/Kotlin\n- Android SDK';
      default:
        return '- مربوط ڈویلپمنٹ ماحول';
    }
  }

  /// 🔹 انسٹالیشن کمانڈز
  String _getInstallationCommands(String framework, String appName) {
    switch (framework.toLowerCase()) {
      case 'flutter':
        return 'flutter pub get';
      case 'react':
        return 'npm install';
      case 'vue':
        return 'npm install';
      case 'android native':
        return 'Android Studio میں پروجیکٹ کھولیں اور sync کریں';
      default:
        return 'دیکھیں README.md';
    }
  }

  /// 🔹 چلانے کی کمانڈز
  String _getRunCommands(String framework) {
    switch (framework.toLowerCase()) {
      case 'flutter':
        return 'flutter run';
      case 'react':
        return 'npm start';
      case 'vue':
        return 'npm run dev';
      case 'android native':
        return 'Android Studio میں Run بٹن دبائیں';
      default:
        return 'دیکھیں README.md';
    }
  }

  /// 🔹 فائل ڈھانچہ
  String _getFileStructure(String framework) {
    switch (framework.toLowerCase()) {
      case 'flutter':
        return '''
${_getMainFileName(framework)}
pubspec.yaml
README.md
''';
      case 'react':
        return '''
${_getMainFileName(framework)}
package.json
README.md
''';
      case 'vue':
        return '''
${_getMainFileName(framework)}
package.json
README.md
''';
      default:
        return '''
${_getMainFileName(framework)}
README.md
''';
    }
  }

  /// 🔹 فریم ورک کے مطابق اضافی فائلیں شامل کریں
  Future<void> _addFrameworkSpecificFiles(Archive archive, String framework, String appName) async {
    try {
      switch (framework.toLowerCase()) {
        case 'flutter':
          // 📄 pubspec.yaml فائل
          final pubspecContent = '''
name: $appName
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
          final pubspecData = utf8.encode(pubspecContent);
          archive.addFile(ArchiveFile('pubspec.yaml', pubspecData.length, pubspecData));
          break;

        case 'react':
          // 📄 package.json فائل
          final packageJsonContent = '''
{
  "name": "$appName",
  "version": "1.0.0",
  "description": "A React app generated by Aladdin System",
  "main": "src/App.js",
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1"
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
''';
          final packageJsonData = utf8.encode(packageJsonContent);
          archive.addFile(ArchiveFile('package.json', packageJsonData.length, packageJsonData));
          break;

        case 'vue':
          // 📄 package.json فائل
          final packageJsonContent = '''
{
  "name": "$appName",
  "version": "1.0.0",
  "description": "A Vue app generated by Aladdin System",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "vue": "^3.3.0"
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^4.0.0",
    "vite": "^4.0.0"
  }
}
''';
          final packageJsonData = utf8.encode(packageJsonContent);
          archive.addFile(ArchiveFile('package.json', packageJsonData.length, packageJsonData));
          break;
      }
    } catch (e) {
      debugPrint('⚠️ اضافی فائلیں شامل کرنے میں خرابی: $e');
    }
  }

  /// 🔹 ZIP فائل شیئر کریں
  Future<void> shareZipFile(String filePath) async {
    try {
      if (await File(filePath).exists()) {
        await Share.shareFiles(
          [filePath],
          text: '📦 میری ${_getFrameworkNameFromPath(filePath)} ایپ - Aladdin System کے ذریعے بنائی گئی 🚀',
        );
        debugPrint('✅ فائل شیئر ہو گئی: $filePath');
      } else {
        debugPrint('❌ فائل موجود نہیں: $filePath');
        throw 'فائل موجود نہیں ہے۔ پہلے فائل محفوظ کریں۔';
      }
    } catch (e) {
      debugPrint('❌ فائل شیئر کرنے میں خرابی: $e');
      throw 'فائل شیئر نہیں ہو سکی: $e';
    }
  }

  /// 🔹 فائل پاتھ سے فریم ورک کا نام حاصل کریں
  String _getFrameworkNameFromPath(String filePath) {
    if (filePath.contains('flutter')) return 'Flutter';
    if (filePath.contains('react')) return 'React';
    if (filePath.contains('vue')) return 'Vue';
    if (filePath.contains('html')) return 'HTML';
    return 'ایپ';
  }

  /// 🔹 GitHub پر نیا ریپوزٹری بنانے کا صفحہ کھولیں
  Future<void> openGithubNewRepoPage() async {
    const githubUrl = 'https://github.com/new';
    
    try {
      if (await canLaunchUrl(Uri.parse(githubUrl))) {
        await launchUrl(
          Uri.parse(githubUrl),
          mode: LaunchMode.externalApplication,
        );
        debugPrint('🌐 GitHub ریپوزٹری صفحہ کھل گیا');
      } else {
        throw 'GitHub نہیں کھل سکا';
      }
    } catch (e) {
      debugPrint('❌ GitHub کھولنے میں خرابی: $e');
      throw 'GitHub نہیں کھل سکا: $e';
    }
  }

  /// 🔹 GitHub ڈیسکٹاپ ڈاؤنلوڈ صفحہ کھولیں
  Future<void> openGithubDesktopPage() async {
    const githubDesktopUrl = 'https://desktop.github.com/';
    
    try {
      if (await canLaunchUrl(Uri.parse(githubDesktopUrl))) {
        await launchUrl(
          Uri.parse(githubDesktopUrl),
          mode: LaunchMode.externalApplication,
        );
        debugPrint('🖥️ GitHub Desktop صفحہ کھل گیا');
      } else {
        throw 'GitHub Desktop صفحہ نہیں کھل سکا';
      }
    } catch (e) {
      debugPrint('❌ GitHub Desktop کھولنے میں خرابی: $e');
      throw 'GitHub Desktop نہیں کھل سکا: $e';
    }
  }

  /// 🔹 ایپ ڈائرکٹری پاتھ حاصل کریں (ڈیبگنگ کے لیے)
  Future<String> getAppDirectoryPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  /// 🔹 پرانی فائلیں ڈیلیٹ کریں (کلین اپ)
  Future<void> deleteSavedApp(String appName, String framework) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${appName}_${framework}_project.zip');

      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ فائل ڈیلیٹ ہو گئی: ${file.path}');
      } else {
        debugPrint('⚠️ ڈیلیٹ کے لیے فائل موجود نہیں');
      }
    } catch (e) {
      debugPrint('❌ فائل ڈیلیٹ کرنے میں خرابی: $e');
    }
  }

  /// 🔹 فائل کا سائز چیک کریں
  Future<String> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final size = await file.length();
        if (size < 1024) {
          return '$size B';
        } else if (size < 1024 * 1024) {
          return '${(size / 1024).toStringAsFixed(1)} KB';
        } else {
          return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
        }
      }
      return '0 B';
    } catch (e) {
      return 'نامعلوم';
    }
  }
}
