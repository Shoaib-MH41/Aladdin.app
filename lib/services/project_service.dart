// lib/services/project_service.dart
import '../models/project_model.dart';
import 'gemini_service.dart';  // ✅ GeminiService استعمال کریں
import 'github_service.dart';

class ProjectService {
  final List<Project> _projects = [];
  final GeminiService? geminiService;  // ✅ DebugService -> GeminiService
  final GitHubService? githubService;

  ProjectService({this.geminiService, this.githubService});  // ✅ نام درست کیا

  List<Project> getProjects() => _projects;

  void addProject(Project project) {
    _projects.add(project);
  }

  void deleteProject(String id) {
    _projects.removeWhere((p) => p.id == id);
  }

  // ✅ Gemini کے ساتھ پروجیکٹ بنانا
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

      // ✅ GeminiService سے کوڈ جنریٹ کریں
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
      // Error handling
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

  // ✅ پروجیکٹ ڈھونڈنے کے لیے helper method
  Project findProjectById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (e) {
      throw Exception('پروجیکٹ نہیں ملا: $id');
    }
  }

  // ✅ پروجیکٹ اپڈیٹ کریں
  void updateProject(Project updatedProject) {
    final index = _projects.indexWhere((p) => p.id == updatedProject.id);
    if (index != -1) {
      _projects[index] = updatedProject;
    }
  }

  // ✅ GitHub پر پروجیکٹ اپلوڈ کریں
  Future<String?> uploadToGitHub(Project project) async {
    if (githubService == null) {
      throw Exception('GitHubService دستیاب نہیں ہے');
    }

    try {
      // پہلے repo بنائیں
      final repoUrl = await githubService.createRepository(
        project.name,
        description: 'AI-generated app: ${project.name}',
        private: false,
      );

      // پروجیکٹ اپڈیٹ کریں
      project.githubRepoUrl = repoUrl;
      updateProject(project);

      return repoUrl;
    } catch (e) {
      throw Exception('GitHub اپلوڈ ناکام: $e');
    }
  }
}
