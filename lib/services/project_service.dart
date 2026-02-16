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
            project.generatedCode = '// ⚠️ Gemini API key سیٹ نہیں ہے۔ Settings میں API key شامل کریں۔';
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
        description: 'AI-generated ${project.framework} app created with Aladdin AI App Factory',
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

      // README.md فائل
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
   ```bash
   git clone $repoUrl
   cd ${cleanName}
