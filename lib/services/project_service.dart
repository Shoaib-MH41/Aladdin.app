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
        generatedCode: '',
        createdAt: DateTime.now(),
      );
      
      addProject(project);

      if (geminiService != null) {
        try {
          final isInitialized = await geminiService!.isInitialized();
          if (isInitialized) {
            // 📌 framework کے حساب سے prompt بنائیں
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

      // ✅ مرحلہ 1: ریپوزٹری بنائیں
      final repoUrl = await githubService!.createRepository(
        project.name,
        description: 'AI-generated ${project.framework} app created with Aladdin AI App Factory',
        private: false,
      );

      // ✅ مرحلہ 2: فائلیں تیار کریں
      final files = _prepareProjectFiles(project, repoUrl);
      
      // ✅ مرحلہ 3: تمام فائلیں اپ لوڈ کریں
      for (final entry in files.entries) {
        print('⬆️ Uploading ${entry.key}...');
        await githubService!.uploadFile(
          repoName: project.name,
          filePath: entry.key,
          content: entry.value,
          commitMessage: 'Add ${entry.key}',
        );
      }

      // ✅ مرحلہ 4: GitHub Actions (صرف Flutter کے لیے)
      if (project.framework.toLowerCase() == 'flutter') {
        try {
          await githubService!.createBuildWorkflow(
            repoName: project.name,
            framework: project.framework,
          );
        } catch (e) {
          print('⚠️ GitHub Actions skipped: $e');
        }
      }

      // ✅ مرحلہ 5: پروجیکٹ اپڈیٹ کریں
      project.githubRepoUrl = repoUrl;
      updateProject(project);

      return {
        'success': true,
        'repoUrl': repoUrl,
        'message': '${project.framework} پروجیکٹ کامیابی سے اپ لوڈ ہو گیا',
        'files': files.length,
      };

    } catch (e) {
      print('❌ GitHub upload failed: $e');
      throw Exception('GitHub اپ لوڈ ناکام: $e');
    }
  }

  /// 🔹 Framework کے حساب سے فائلیں تیار کریں
  Map<String, String> _prepareProjectFiles(Project project, String repoUrl) {
    final files = <String, String>{};
    final cleanName = project.name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_');

    switch (project.framework.toLowerCase()) {
      case 'flutter':
        files['lib/main.dart'] = project.generatedCode ?? _getFlutterPlaceholder(project);
        files['pubspec.yaml'] = _getFlutterPubspec(cleanName, project);
        files['README.md'] = _getReadme(project, repoUrl, cleanName);
        files['android/app/google-services.json'] = _getFirebasePlaceholder('android');
        files['ios/Runner/GoogleService-Info.plist'] = _getFirebasePlaceholder('ios');
        break;

      case 'react':
        files['src/App.js'] = project.generatedCode ?? _getReactPlaceholder(project);
        files['package.json'] = _getReactPackageJson(cleanName, project);
        files['README.md'] = _getReadme(project, repoUrl, cleanName);
        files['public/index.html'] = _getReactHtml(project);
        break;

      case 'vue':
        files['src/App.vue'] = project.generatedCode ?? _getVuePlaceholder(project);
        files['package.json'] = _getVuePackageJson(cleanName, project);
        files['README.md'] = _getReadme(project, repoUrl, cleanName);
        files['public/index.html'] = _getVueHtml(project);
        break;

      case 'android native':
        files['app/src/main/java/com/example/app/MainActivity.kt'] = 
            project.generatedCode ?? _getAndroidPlaceholder(project);
        files['app/build.gradle'] = _getAndroidGradle(cleanName, project);
        files['README.md'] = _getReadme(project, repoUrl, cleanName);
        files['app/google-services.json'] = _getFirebasePlaceholder('android');
        break;

      case 'html/css/js':
        files['index.html'] = project.generatedCode ?? _getHtmlPlaceholder(project);
        files['style.css'] = _getCssPlaceholder(project);
        files['script.js'] = _getJsPlaceholder(project);
        files['README.md'] = _getReadme(project, repoUrl, cleanName);
        break;
    }

    return files;
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

  String _getFlutterPubspec(String cleanName, Project project) => '''
name: $cleanName
description: AI Generated Flutter app
version: 1.0.0

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  ${_getFeatures(project)}

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
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

  String _getReactPackageJson(String cleanName, Project project) => '''
{
  "name": "$cleanName",
  "version": "1.0.0",
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build"
  }
}
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
}
</style>
''';

  String _getVuePackageJson(String cleanName, Project project) => '''
{
  "name": "$cleanName",
  "version": "1.0.0",
  "dependencies": {
    "vue": "^3.3.0"
  },
  "scripts": {
    "serve": "vue-cli-service serve",
    "build": "vue-cli-service build"
  }
}
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

  String _getAndroidGradle(String cleanName, Project project) => '''
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
}

android {
    namespace 'com.example.$cleanName'
    compileSdk 34

    defaultConfig {
        applicationId "com.example.$cleanName"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }
}

dependencies {
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    ${_getAndroidFeatures(project)}
}
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
}

h1 {
    color: #333;
    margin-bottom: 1rem;
}

p {
    color: #666;
}
''';

  String _getJsPlaceholder(Project project) => '''
// Main JavaScript file for ${project.name}
console.log('${project.name} loaded!');

// Add your JavaScript code here
document.addEventListener('DOMContentLoaded', () => {
    // Initialize app
});
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

  String _getReadme(Project project, String repoUrl, String cleanName) => '''
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
- ${_getPrerequisites(project.framework)}

### Installation

1. **Clone the repository**
   
   git clone $repoUrl
   cd $cleanName
   

2. **Install dependencies**
   
   ${_getInstallCommand(project.framework)}
   

3. **Run the app**
   
   ${_getRunCommand(project.framework)}
   

## 📂 Project Structure
${_getStructure(project.framework)}

## 📦 Build
${_getBuildCommand(project.framework)}

---
⭐ Created with [Aladdin AI App Factory](https://github.com)
''';

  String _getFirebasePlaceholder(String platform) => '''
⚠️ IMPORTANT: Download ${platform == 'android' ? 'google-services.json' : 'GoogleService-Info.plist'} from Firebase Console
and place it in the ${platform == 'android' ? 'android/app/' : 'ios/Runner/'} directory
''';

  String _getFeatures(Project project) {
    final features = [];
    if (project.features?['api'] == 'firebase') {
      features.add('firebase_core: ^2.24.2');
      features.add('firebase_auth: ^4.16.0');
    }
    if (project.features?['adMob'] != 'none') {
      features.add('google_mobile_ads: ^3.1.0');
    }
    return features.join('\n  ');
  }

  String _getAndroidFeatures(Project project) {
    final features = [];
    if (project.features?['api'] == 'firebase') {
      features.add("implementation 'com.google.firebase:firebase-auth-ktx:22.3.0'");
    }
    return features.join('\n    ');
  }

  String _getPrerequisites(String framework) {
    switch (framework.toLowerCase()) {
      case 'flutter': return 'Flutter SDK (latest version)';
      case 'react': return 'Node.js and npm';
      case 'vue': return 'Node.js and npm';
      case 'android native': return 'Android Studio and JDK';
      case 'html/css/js': return 'Any web browser';
      default: return 'Development environment';
    }
  }

  String _getInstallCommand(String framework) {
    switch (framework.toLowerCase()) {
      case 'flutter': return 'flutter pub get';
      case 'react': return 'npm install';
      case 'vue': return 'npm install';
      case 'android native': return 'Build with Android Studio';
      case 'html/css/js': return 'No dependencies';
      default: return 'Install dependencies';
    }
  }

  String _getRunCommand(String framework) {
    switch (framework.toLowerCase()) {
      case 'flutter': return 'flutter run';
      case 'react': return 'npm start';
      case 'vue': return 'npm run serve';
      case 'android native': return 'Run from Android Studio';
      case 'html/css/js': return 'Open index.html in browser';
      default: return 'Run the app';
    }
  }

  String _getBuildCommand(String framework) {
    switch (framework.toLowerCase()) {
      case 'flutter': return 'flutter build apk';
      case 'react': return 'npm run build';
      case 'vue': return 'npm run build';
      case 'android native': return './gradlew assembleRelease';
      case 'html/css/js': return 'Ready to deploy';
      default: return 'Build the app';
    }
  }

  String _getStructure(String framework) {
    switch (framework.toLowerCase()) {
      case 'flutter':
        return '''
