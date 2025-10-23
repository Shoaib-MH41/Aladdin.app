import '../models/project_model.dart';
import 'debug_service.dart';
import 'github_service.dart';

class ProjectService {
  final List<Project> _projects = [];
  final DebugService _debugService;
  final GitHubService _githubService;

  ProjectService(this._debugService, this._githubService);

  List<Project> getProjects() => _projects;

  void addProject(Project project) {
    _projects.add(project);
  }

  void deleteProject(String id) {
    _projects.removeWhere((p) => p.id == id);
  }

  // ✅ نیا: Gemini کے ساتھ پروجیکٹ بنانا
  Future<Project> createProjectWithAI({
    required String name,
    required String prompt,
    required String framework,
  }) async {
    try {
      // Gemini سے کوڈ جنریٹ کریں
      final generatedCode = await _debugService.generateCode(prompt);
      
      // GitHub پر repo بنائیں
      final repoUrl = await _githubService.createRepository(name, generatedCode);
      
      final project = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        framework: framework,
        platforms: ['Android', 'iOS'],
        generatedCode: generatedCode,
        githubUrl: repoUrl,
        createdAt: DateTime.now(),
      );
      
      addProject(project);
      return project;
    } catch (e) {
      throw Exception('پروجیکٹ بنانے میں ناکامی: $e');
    }
  }

  // ✅ نیا: ڈیبگ کا فنکشن
  Future<String> debugProject(String projectId, String errorDescription) async {
    final project = _projects.firstWhere((p) => p.id == projectId);
    final fixedCode = await _debugService.debugFlutterCode(
      faultyCode: project.generatedCode,
      errorDescription: errorDescription,
      originalPrompt: project.requirements,
    );
    
    // پروجیکٹ کو اپڈیٹ کریں
    project.generatedCode = fixedCode;
    project.updatedAt = DateTime.now();
    
    return fixedCode;
  }
}
