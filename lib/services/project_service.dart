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

  /// 🔹 Gemini کے ساتھ پروجیکٹ بنائیں
  Future<Project> createProjectWithAI({
    required String name,
    required String prompt,
    required String framework,
  }) async {
    try {
      final project = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        framework: framework,
        platforms: ['Android', 'iOS'],
        assets: {},
        generatedCode: '',
        createdAt: DateTime.now(),
      );

      addProject(project);

      if (geminiService != null) {
        try {
          final isInitialized = await geminiService!.isInitialized();
          if (isInitialized) {
            project.generatedCode = await geminiService!.generateCode(
              prompt: prompt,
              framework: framework,
              platforms: project.platforms,
            );
          } else {
            project.generatedCode =
                '// ⚠️ Gemini API key سیٹ نہیں ہے۔ Settings میں API key شامل کریں۔';
          }
        } catch (e) {
          project.generatedCode = '// ❌ کوڈ جنریٹ نہیں ہوا: $e';
        }
      } else {
        project.generatedCode = '// ⚠️ GeminiService دستیاب نہیں ہے';
      }

      return project;
    } catch (e) {
      final errorProject = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        framework: framework,
        platforms: ['Android', 'iOS'],
        assets: {},
        generatedCode: '// ❌ پروجیکٹ بنانے میں ناکامی: $e',
        createdAt: DateTime.now(),
      );
      addProject(errorProject);

      throw Exception('پروجیکٹ بنانے میں ناکامی: $e');
    }
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

  /// 🔹 GitHub پر پروجیکٹ اپ لوڈ کریں (مکمل)
  Future<Map<String, dynamic>> uploadToGitHub(Project project) async {
    if (githubService == null) {
      throw Exception('GitHubService دستیاب نہیں ہے');
    }

    try {
      print('🚀 Starting GitHub upload for project: ${project.name}');

      // ✅ مرحلہ 1: ریپوزٹری بنائیں
      print('📁 Creating repository...');
      final repoUrl = await githubService!.createRepository(
        project.name,
        description:
            'AI-generated ${project.framework} app created with Aladdin AI App Factory',
        private: false,
      );
      print('✅ Repository created: $repoUrl');

      // ✅ مرحلہ 2: فائلیں تیار کریں
      print('📄 Preparing project files...');

      // پروجیکٹ کا نام صاف کریں (pubspec.yaml کے لیے)
      final cleanName = project.name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
          .replaceAll(RegExp(r'_+'), '_');

      // Main.dart فائل
      final mainContent = project.generatedCode?.isNotEmpty == true
          ? project.generatedCode!
          : '''
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
        body: Center(
          child: Text('AI Generated App'),
        ),
      ),
    );
  }
}
''';

      // Pubspec.yaml فائل
      final pubspecContent = '''
name: $cleanName
description: AI Generated ${project.framework} app
version: 1.0.0

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  
  # Firebase dependencies
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.15.5
  
  # UI dependencies
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
''';

      // README.md فائل (مکمل - بیکٹکس کے بغیر)
      final readmeContent = '''
# ${project.name}

🤖 **AI-Generated App** using **Aladdin AI App Factory**

## 📱 About
This app was automatically generated by AI based on your requirements.

### ✨ Features
- Framework: **${project.framework}**
- Platforms: ${project.platforms.join(', ')}
- Generated on: ${DateTime.now().toLocal().toString().split('.').first}

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest version)
- Firebase account (for backend features)

### Installation

1. **Clone the repository**
   
   git clone $repoUrl
   cd $cleanName
   

2. **Install dependencies**
   
   flutter pub get
   

3. **Firebase Setup**
   
   **Android:**
   - Download google-services.json from Firebase Console
   - Place it in android/app/
   
   **iOS:**
   - Download GoogleService-Info.plist from Firebase Console
   - Place it in ios/Runner/
   

4. **Run the app**
   
   flutter run
   

## 📂 Project Structure

lib/
├── main.dart           # Main application file
├── screens/            # UI screens
├── widgets/            # Reusable widgets
├── models/             # Data models
├── services/           # Business logic
└── utils/              # Helper functions


## 🔧 Configuration
- Firebase services are pre-configured
- Authentication ready to use
- Firestore database ready

## 📦 Build APK

flutter build apk --release


## 🤝 Contributing
This is an AI-generated project. Feel free to customize it!

## 📝 License
MIT License

---
⭐ Created with [Aladdin AI App Factory](https://github.com)
''';

      // Android Firebase config placeholder
      final androidFirebaseConfig = '''
⚠️ IMPORTANT: Download google-services.json from Firebase Console and place it in android/app/ directory
''';

      // iOS Firebase config placeholder
      final iosFirebaseConfig = '''
⚠️ IMPORTANT: Download GoogleService-Info.plist from Firebase Console and place it in ios/Runner/ directory
''';

      // ✅ مرحلہ 3: ساری فائلیں اپ لوڈ کریں
      print('⬆️ Uploading main.dart...');
      await githubService!.uploadFile(
        repoName: project.name,
        filePath: 'lib/main.dart',
        content: mainContent,
        commitMessage: 'Add main.dart with AI-generated code',
      );

      print('⬆️ Uploading pubspec.yaml...');
      await githubService!.uploadFile(
        repoName: project.name,
        filePath: 'pubspec.yaml',
        content: pubspecContent,
        commitMessage: 'Add pubspec.yaml with dependencies',
      );

      print('⬆️ Uploading README.md...');
      await githubService!.uploadFile(
        repoName: project.name,
        filePath: 'README.md',
        content: readmeContent,
        commitMessage: 'Add comprehensive README.md',
      );

      // Firebase config instructions
      print('⬆️ Adding Firebase config placeholders...');
      await githubService!.uploadFile(
        repoName: project.name,
        filePath: 'android/app/google-services.json',
        content: androidFirebaseConfig,
        commitMessage: 'Add Firebase config placeholder for Android',
      );

      await githubService!.uploadFile(
        repoName: project.name,
        filePath: 'ios/Runner/GoogleService-Info.plist',
        content: iosFirebaseConfig,
        commitMessage: 'Add Firebase config placeholder for iOS',
      );

      // ✅ مرحلہ 4: GitHub Actions workflow (اختیاری)
      try {
        print('🤖 Setting up GitHub Actions...');
        await githubService!.createBuildWorkflow(
          repoName: project.name,
          framework: project.framework,
        );
        print('✅ GitHub Actions workflow added');
      } catch (e) {
        print('⚠️ GitHub Actions setup skipped: $e');
      }

      // ✅ مرحلہ 5: پروجیکٹ اپڈیٹ کریں
      project.githubRepoUrl = repoUrl;
      updateProject(project);

      print('✅ Project successfully uploaded to GitHub!');

      // ✅ مرحلہ 6: نتیجہ واپس کریں
      return {
        'success': true,
        'repoUrl': repoUrl,
        'message': 'پروجیکٹ کامیابی سے اپ لوڈ ہو گیا',
        'files': 5,
      };
    } catch (e) {
      print('❌ GitHub upload failed: $e');
      throw Exception('GitHub اپ لوڈ ناکام: $e');
    }
  }

  /// 🔹 GitHub Actions بلڈ اسٹیٹس چیک کریں
  Future<Map<String, dynamic>> checkBuildStatus(Project project) async {
    if (githubService == null || project.githubRepoUrl == null) {
      throw Exception('پروجیکٹ GitHub پر نہیں ہے');
    }

    try {
      final status = await githubService!.checkBuildStatus(
        repoName: project.name,
      );
      return status;
    } catch (e) {
      throw Exception('Build status check failed: $e');
    }
  }

  /// 🔹 GitHub Actions صفحہ کھولیں
  Future<void> openActionsPage(Project project) async {
    if (githubService == null || project.githubRepoUrl == null) {
      throw Exception('پروجیکٹ GitHub پر نہیں ہے');
    }

    try {
      await githubService!.openActionsPage(
        repoName: project.name,
      );
    } catch (e) {
      throw Exception('Cannot open Actions page: $e');
    }
  }

  /// 🔹 تمام پروجیکٹس حذف کریں
  void clearAllProjects() {
    _projects.clear();
    print('🗑️ All projects cleared');
  }
}
