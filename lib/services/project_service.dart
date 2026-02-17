// lib/services/project_service.dart
import '../models/project_model.dart';
import 'gemini_service.dart';
import 'github_service.dart';

class ProjectService {
  final List<Project> _projects = [];
  final GeminiService? geminiService;
  final GitHubService? githubService;

  ProjectService({this.geminiService, this.githubService});

  List<Project> getProjects() => _projects;

  void addProject(Project project) {
    _projects.add(project);
  }

  void deleteProject(String id) {
    _projects.removeWhere((p) => p.id == id);
  }

  /// 🔹 AI کے ساتھ پروجیکٹ بنائیں (تمام frameworks)
  Future<Project> createProjectWithAI({
    required String name,
    required String prompt,
    required String framework,
    required List<String> platforms,
    Map<String, dynamic>? features,
  }) async {
    try {
      final project = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        framework: framework,
        platforms: platforms,
        assets: {},
        features: features ?? {},
        createdAt: DateTime.now(),
      );
      
      addProject(project);

      if (geminiService != null) {
        try {
          final isInitialized = await geminiService!.isInitialized();
          if (isInitialized) {
            final enhancedPrompt = _buildFrameworkPrompt(
              prompt: prompt,
              framework: framework,
              platforms: platforms,
              features: features,
            );
            
            project.generatedCode = await geminiService!.generateCode(
              prompt: enhancedPrompt,
              framework: framework,
              platforms: platforms,
            );
          } else {
            project.generatedCode = _getErrorMessage(framework, 'API key not set');
          }
        } catch (e) {
          project.generatedCode = _getErrorMessage(framework, e.toString());
        }
      } else {
        project.generatedCode = _getErrorMessage(framework, 'Service not available');
      }

      return project;
    } catch (e) {
      final errorProject = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        framework: framework,
        platforms: platforms,
        assets: {},
        features: features ?? {},
        generatedCode: '// ❌ پروجیکٹ بنانے میں ناکامی: $e',
        createdAt: DateTime.now(),
      );
      addProject(errorProject);
      
      throw Exception('پروجیکٹ بنانے میں ناکامی: $e');
    }
  }

  /// 🔹 Framework کے حساب سے prompt بنائیں
  String _buildFrameworkPrompt({
    required String prompt,
    required String framework,
    required List<String> platforms,
    Map<String, dynamic>? features,
  }) {
    final featureText = _getFeatureText(features);
    
    switch (framework.toLowerCase()) {
      case 'flutter':
        return '''
Generate COMPLETE Flutter code for: $prompt

Platforms: ${platforms.join(', ')}
Features: $featureText

Requirements:
- Use Material Design
- Include all necessary imports
- Add comments
- Return ONLY the code
''';

      case 'react':
        return '''
Generate COMPLETE React code for: $prompt

Platforms: ${platforms.join(', ')}
Features: $featureText

Requirements:
- Use functional components with hooks
- Include all necessary imports
- Add comments
- Return ONLY the code
''';

      case 'vue':
        return '''
Generate COMPLETE Vue.js code for: $prompt

Platforms: ${platforms.join(', ')}
Features: $featureText

Requirements:
- Use Composition API
- Include all necessary imports
- Add comments
- Return ONLY the code
''';

      case 'android native':
        return '''
Generate COMPLETE Android Native (Kotlin) code for: $prompt

Platforms: Android
Features: $featureText

Requirements:
- Use Kotlin
- Include all necessary imports
- Add comments
- Return ONLY the code
''';

      case 'html/css/js':
        return '''
Generate COMPLETE HTML/CSS/JavaScript code for: $prompt

Platforms: Web
Features: $featureText

Requirements:
- Responsive design
- Modern CSS (Flexbox/Grid)
- Clean JavaScript
- Include all necessary tags
- Return ONLY the code
''';

      default:
        return prompt;
    }
  }

  /// 🔹 Features کو متن میں تبدیل کریں
  String _getFeatureText(Map<String, dynamic>? features) {
    if (features == null || features.isEmpty) return 'None';
    
    final List<String> featureList = [];
    
    if (features['animation'] != null && features['animation'] != 'none') {
      featureList.add('Animation: ${features['animation']}');
    }
    
    if (features['font'] != null && features['font'] != 'default') {
      featureList.add('Font: ${features['font']}');
    }
    
    if (features['api'] != null && features['api'] != 'none') {
      featureList.add('API Integration: ${features['api']}');
    }
    
    if (features['adMob'] != null && features['adMob'] != 'none') {
      featureList.add('AdMob: ${features['adMob']}');
    }
    
    return featureList.isNotEmpty ? featureList.join(', ') : 'None';
  }

  /// 🔹 Error message بنائیں
  String _getErrorMessage(String framework, String error) {
    return '''
// ⚠️ Error: $error
//
// Please check:
// 1. API key is set in Settings
// 2. Internet connection is working
// 3. Selected framework ($framework) is supported
''';
  }

  /// 🔹 پروجیکٹ ڈھونڈیں
  Project findProjectById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (e) {
      throw Exception('پروجیکٹ نہیں ملا: $id');
    }
  }

  /// 🔹 پروجیکٹ اپڈیٹ کریں
  void updateProject(Project updatedProject) {
    final index = _projects.indexWhere((p) => p.id == updatedProject.id);
    if (index != -1) {
      _projects[index] = updatedProject;
    }
  }

  /// 🔹 GitHub پر پروجیکٹ اپ لوڈ کریں (تمام frameworks)
  Future<Map<String, dynamic>> uploadToGitHub(Project project) async {
    if (githubService == null) {
      throw Exception('GitHubService دستیاب نہیں ہے');
    }

    try {
      print('🚀 Starting GitHub upload for ${project.framework} project: ${project.name}');

      // ✅ مرحلہ 1: repoName safe بنائیں
      final repoName = project.name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9_\-]'), '-')
          .replaceAll(RegExp(r'-+'), '-')
          .replaceAll(RegExp(r'^\-|\-$'), '');

      if (repoName.isEmpty) {
        throw Exception('Invalid repository name');
      }

      // ✅ مرحلہ 2: ریپوزٹری بنائیں
      final repoUrl = await githubService!.createRepository(
        repoName,
        description: 'AI-generated ${project.framework} app created with Aladdin AI App Factory',
        private: false,
      );

      // ✅ مرحلہ 3: فائلیں تیار کریں
      final files = _prepareProjectFiles(project, repoUrl, repoName);
      
      // ✅ مرحلہ 4: تمام فائلیں اپ لوڈ کریں (ہر فائل کا try-catch)
      int successCount = 0;
      int failCount = 0;
      List<String> failedFiles = [];
      
      for (final entry in files.entries) {
        try {
          print('⬆️ Uploading ${entry.key}...');
          await githubService!.uploadFile(
            repoName: repoName,
            filePath: entry.key,
            content: entry.value,
            commitMessage: 'Add ${entry.key}',
          );
          successCount++;
          print('✅ ${entry.key} uploaded');
        } catch (e) {
          failCount++;
          failedFiles.add(entry.key);
          print('❌ ${entry.key} failed: $e');
        }
        
        // Rate limit سے بچنے کے لیے وقفہ
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // ✅ مرحلہ 5: GitHub Actions (صرف Flutter کے لیے)
      if (project.framework.toLowerCase() == 'flutter') {
        try {
          print('🤖 Setting up GitHub Actions...');
          await githubService!.createBuildWorkflow(
            repoName: repoName,
            framework: project.framework,
          );
          print('✅ GitHub Actions workflow added');
        } catch (e) {
          print('⚠️ GitHub Actions skipped: $e');
        }
      }

      // ✅ مرحلہ 6: پروجیکٹ اپڈیٹ کریں
      project.setGitHubRepoUrl(repoUrl);
      updateProject(project);

      return {
        'success': failCount == 0,
        'repoUrl': repoUrl,
        'message': failCount == 0 
            ? '${project.framework} پروجیکٹ کامیابی سے اپ لوڈ ہو گیا'
            : '${project.framework} پروجیکٹ اپ لوڈ ہو گیا ($failCount فائلیں ناکام)',
        'files': files.length,
        'successCount': successCount,
        'failCount': failCount,
        'failedFiles': failedFiles,
      };

    } catch (e) {
      print('❌ GitHub upload failed: $e');
      throw Exception('GitHub اپ لوڈ ناکام: $e');
    }
  }

  /// 🔹 Framework کے حساب سے فائلیں تیار کریں
  Map<String, String> _prepareProjectFiles(Project project, String repoUrl, String repoName) {
    final files = <String, String>{};

    switch (project.framework.toLowerCase()) {
      case 'flutter':
        files['lib/main.dart'] = _getSafeGeneratedCode(project, _getFlutterPlaceholder);
        files['pubspec.yaml'] = _getSafeFlutterPubspec(repoName, project);
        files['README.md'] = _getReadme(project, repoUrl, repoName);
        files['android/app/google-services.json'] = _getFirebasePlaceholder('android');
        files['ios/Runner/GoogleService-Info.plist'] = _getFirebasePlaceholder('ios');
        files['.gitignore'] = _getFlutterGitignore();
        files['analysis_options.yaml'] = _getFlutterAnalysisOptions();
        break;

      case 'react':
        files['src/App.js'] = _getSafeGeneratedCode(project, _getReactPlaceholder);
        files['package.json'] = _getReactPackageJson(repoName, project);
        files['README.md'] = _getReadme(project, repoUrl, repoName);
        files['public/index.html'] = _getReactHtml(project);
        files['.gitignore'] = _getReactGitignore();
        break;

      case 'vue':
        files['src/App.vue'] = _getSafeGeneratedCode(project, _getVuePlaceholder);
        files['package.json'] = _getVuePackageJson(repoName, project);
        files['README.md'] = _getReadme(project, repoUrl, repoName);
        files['public/index.html'] = _getVueHtml(project);
        files['.gitignore'] = _getVueGitignore();
        break;

      case 'android native':
        files['app/src/main/java/com/example/app/MainActivity.kt'] = _getSafeGeneratedCode(project, _getAndroidPlaceholder);
        files['app/build.gradle'] = _getAndroidGradle(repoName, project);
        files['README.md'] = _getReadme(project, repoUrl, repoName);
        files['app/google-services.json'] = _getFirebasePlaceholder('android');
        files['.gitignore'] = _getAndroidGitignore();
        break;

      case 'html/css/js':
        files['index.html'] = _getSafeGeneratedCode(project, _getHtmlPlaceholder);
        files['style.css'] = _getCssPlaceholder(project);
        files['script.js'] = _getJsPlaceholder(project);
        files['README.md'] = _getReadme(project, repoUrl, repoName);
        files['.gitignore'] = _getWebGitignore();
        break;
    }

    return files;
  }

  /// 🔹 Safe generated code getter
  String _getSafeGeneratedCode(Project project, String Function(Project) placeholder) {
    final code = project.generatedCode;
    if (code != null && code.trim().isNotEmpty) {
      return code;
    }
    return placeholder(project);
  }

  // ============= 📝 MISSING METHODS ADDED BELOW =============

  /// 🔹 Firebase placeholder content
  String _getFirebasePlaceholder(String platform) {
    if (platform == 'android') {
      return '''
{
  "project_info": {
    "project_number": "YOUR_PROJECT_NUMBER",
    "firebase_url": "https://your-project.firebaseio.com",
    "project_id": "your-project-id",
    "storage_bucket": "your-project.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "YOUR_APP_ID",
        "android_client_info": {
          "package_name": "com.example.app"
        }
      },
      "oauth_client": [],
      "api_key": [
        {
          "current_key": "YOUR_API_KEY"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
''';
    } else {
      return '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CLIENT_ID</key>
    <string>YOUR_CLIENT_ID</string>
    <key>REVERSED_CLIENT_ID</key>
    <string>YOUR_REVERSED_CLIENT_ID</string>
    <key>API_KEY</key>
    <string>YOUR_API_KEY</string>
    <key>GCM_SENDER_ID</key>
    <string>YOUR_SENDER_ID</string>
    <key>PLIST_VERSION</key>
    <string>1</string>
    <key>BUNDLE_ID</key>
    <string>com.example.app</string>
    <key>PROJECT_ID</key>
    <string>your-project-id</string>
    <key>STORAGE_BUCKET</key>
    <string>your-project.appspot.com</string>
    <key>IS_ADS_ENABLED</key>
    <false></false>
    <key>IS_ANALYTICS_ENABLED</key>
    <false></false>
    <key>IS_APPINVITE_ENABLED</key>
    <true></true>
    <key>IS_GCM_ENABLED</key>
    <true></true>
    <key>IS_SIGNIN_ENABLED</key>
    <true></true>
    <key>GOOGLE_APP_ID</key>
    <string>YOUR_APP_ID</string>
</dict>
</plist>
''';
    }
  }

  /// 🔹 Get features dependencies
  String _getFeatures(Project project) {
    final features = project.features;
    if (features == null || features.isEmpty) return '';
    
    final List<String> deps = [];
    
    if (features['firebase'] == true) {
      deps.add('  firebase_core: ^2.24.2');
      deps.add('  cloud_firestore: ^4.14.0');
    }
    
    if (features['adMob'] == true) {
      deps.add('  google_mobile_ads: ^4.0.0');
    }
    
    if (features['animation'] == 'advanced') {
      deps.add('  lottie: ^3.0.0');
      deps.add('  flutter_animate: ^4.5.0');
    }
    
    return deps.join('\n');
  }

  /// 🔹 Get Android features dependencies
  String _getAndroidFeatures(Project project) {
    final features = project.features;
    if (features == null || features.isEmpty) return '';
    
    final List<String> deps = [];
    
    if (features['firebase'] == true) {
      deps.add("    implementation platform('com.google.firebase:firebase-bom:32.7.0')");
      deps.add("    implementation 'com.google.firebase:firebase-analytics-ktx'");
    }
    
    if (features['adMob'] == true) {
      deps.add("    implementation 'com.google.android.gms:play-services-ads:22.6.0'");
    }
    
    return deps.join('\n');
  }

  /// 🔹 Get prerequisites for README
  String _getPrerequisites(String framework) {
    switch (framework.toLowerCase()) {
      case 'flutter':
        return '''
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code
- Emulator or physical device''';
      
      case 'react':
        return '''
- Node.js (>=16.0.0)
- npm or yarn
- Code editor (VS Code recommended)''';
      
      case 'vue':
        return '''
- Node.js (>=16.0.0)
- npm or yarn
- Vue CLI or Vite''';
      
      case 'android native':
        return '''
- Android Studio
- JDK 17
- Android SDK
- Emulator or physical device''';
      
      case 'html/css/js':
        return '''
- Modern web browser
- Code editor
- Live server (optional)''';
      
      default:
        return '- Check framework documentation';
    }
  }

  // ============= 📝 PLACEHOLDER GENERATORS =============

  String _getFlutterPlaceholder(Project project) => '''
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${project.name}',
      home: Scaffold(
        appBar: AppBar(title: Text('${project.name}')),
        body: const Center(
          child: Text('AI Generated Flutter App'),
        ),
      ),
    );
  }
}
''';

  String _getSafeFlutterPubspec(String repoName, Project project) {
    final featureDeps = _getFeatures(project);
    
    return '''
name: $repoName
description: AI Generated Flutter app
version: 1.0.0

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
$featureDeps

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
''';
  }

  String _getFlutterGitignore() => '''
# Flutter/Dart
.dart_tool/
.packages
build/
ios/Flutter/.last_build_id
flutter_*.log
pubspec.lock
''';

  String _getFlutterAnalysisOptions() => '''
include: package:flutter_lints/flutter.yaml

analyzer:
  errors:
    unused_import: warning
    deprecated_member_use: info
''';

  String _getReactPlaceholder(Project project) => '''
import React from 'react';
import './App.css';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <h1>${project.name}</h1>
        <p>AI Generated React App</p>
      </header>
    </div>
  );
}

export default App;
''';

  String _getReactPackageJson(String repoName, Project project) => '''
{
  "name": "$repoName",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": ["react-app"]
  },
  "browserslist": {
    "production": [">0.2%", "not dead", "not op_mini all"],
    "development": ["last 1 chrome version", "last 1 firefox version", "last 1 safari version"]
  }
}
''';

  String _getReactGitignore() => '''
# Dependencies
node_modules/
package-lock.json
yarn.lock

# Build
build/
dist/

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
''';

  String _getReactHtml(Project project) => '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>${project.name}</title>
</head>
<body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
</body>
</html>
''';

  String _getVuePlaceholder(Project project) => '''
<template>
  <div id="app">
    <h1>{{ title }}</h1>
    <p>AI Generated Vue App</p>
  </div>
</template>

<script>
export default {
  name: 'App',
  data() {
    return {
      title: '${project.name}'
    }
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
''';

  String _getVuePackageJson(String repoName, Project project) => '''
{
  "name": "$repoName",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "serve": "vue-cli-service serve",
    "build": "vue-cli-service build",
    "lint": "vue-cli-service lint"
  },
  "dependencies": {
    "vue": "^3.3.0"
  },
  "devDependencies": {
    "@vue/cli-service": "^5.0.0"
  }
}
''';

  String _getVueGitignore() => '''
# Dependencies
node_modules/
package-lock.json
yarn.lock

# Build
dist/
dist-ssr/

# Environment
.env
.env.local
.env.*.local
''';

  String _getVueHtml(Project project) => '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>${project.name}</title>
</head>
<body>
    <noscript>
        <strong>We're sorry but ${project.name} doesn't work properly without JavaScript enabled. Please enable it to continue.</strong>
    </noscript>
    <div id="app"></div>
</body>
</html>
''';

  String _getAndroidPlaceholder(Project project) => '''
package com.example.app

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.TextView

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        val textView = findViewById<TextView>(R.id.textView)
        textView.text = "${project.name}"
    }
}
''';

  String _getAndroidGradle(String repoName, Project project) => '''
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
}

android {
    namespace 'com.example.$repoName'
    compileSdk 34

    defaultConfig {
        applicationId "com.example.$repoName"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.10.0'
${_getAndroidFeatures(project)}
}
''';

  String _getAndroidGitignore() => '''
# Android
*.iml
.gradle/
local.properties
.idea/
.DS_Store
build/
captures/
.externalNativeBuild
.cxx/
*.apk
*.aab
''';

  String _getHtmlPlaceholder(Project project) => '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${project.name}</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h1>${project.name}</h1>
        <p>AI Generated HTML/CSS/JS App</p>
    </div>
    <script src="script.js"></script>
</body>
</html>
''';

  String _getCssPlaceholder(Project project) => '''
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
}

.container {
    background: white;
    padding: 2rem;
    border-radius: 10px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.2);
    text-align: center;
    max-width: 400px;
    width: 90%;
}

h1 {
    color: #333;
    margin-bottom: 1rem;
    font-size: 1.8rem;
}

p {
    color: #666;
    line-height: 1.6;
}
''';

  String _getJsPlaceholder(Project project) => '''
// Main JavaScript file for ${project.name}
console.log('${project.name} loaded!');

// Wait for DOM to be ready
document.addEventListener('DOMContentLoaded', () => {
    console.log('App initialized');
    
    // Add any interactive features here
    const container = document.querySelector('.container');
    if (container) {
        container.style.transition = 'all 0.3s ease';
    }
});
''';

  String _getWebGitignore() => '''
# Dependencies
node_modules/
package-lock.json

# Build
dist/
build/

# Environment
.env
.env.local
''';

  String _getReadme(Project project, String repoUrl, String repoName) => '''
# ${project.name}

🤖 **AI-Generated ${project.framework} App** using **Aladdin AI App Factory**

## 📱 About
This app was automatically generated by AI based on your requirements.

### ✨ Features
- Framework: **${project.framework}**
- Platforms: ${project.platforms.join(', ')}
- ${_getFeatureText(project.features)}

## 🚀 Getting Started

### Prerequisites
${_getPrerequisites(project.framework)}

### Installation

1. **Clone the repository**
   ```bash
   git clone $repoUrl
   cd $repoName
   flutter pub get
   flutter run
'''
