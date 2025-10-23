import './debug_service.dart';
import './github_service.dart';

class ProjectService {
  final List<Project> _projects = [];
  final DebugService? debugService;
  final GitHubService? githubService;

  ProjectService({this.debugService, this.githubService});

  List<Project> getProjects() => _projects;

  void addProject(Project project) {
    _projects.add(project);
  }

  void deleteProject(String id) {
    _projects.removeWhere((p) => p.id == id);
  }

  // ✅ نیا: Gemini کے ساتھ پروجیکٹ جنریٹ کریں
  Future<Project> generateProjectWithAI({
    required String name,
    required String prompt,
    required String framework,
    required List<String> platforms,
    required Map<String, String> assets,
    Map<String, String> features = const {},
  }) async {
    try {
      final project = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        framework: framework,
        platforms: platforms,
        assets: assets,
        features: features,
        geminiPrompt: prompt,
        status: 'generating',
        createdAt: DateTime.now(),
      );
      
      addProject(project);

      // Gemini سے کوڈ جنریٹ کریں
      if (debugService != null) {
        project.generatedCode = await debugService!.generateCode(prompt);
        project.status = 'generated';
        project.lastUpdated = DateTime.now();
      }

      // GitHub پر اپ لوڈ کریں
      if (githubService != null && project.generatedCode != null) {
        project.githubRepoUrl = await githubService!.createRepository(
          name, 
          project.generatedCode!
        );
        project.status = 'uploaded';
        project.lastUpdated = DateTime.now();
      }

      return project;
    } catch (e) {
      // Error handling
      final errorProject = _projects.firstWhere((p) => p.name == name);
      errorProject.status = 'error';
      errorProject.lastError = e.toString();
      errorProject.lastUpdated = DateTime.now();
      
      throw Exception('پروجیکٹ جنریشن ناکام: $e');
    }
  }

  // ✅ نیا: ڈیبگ کا فنکشن
  Future<void> debugProject(String projectId, String errorDescription) async {
    if (debugService == null) return;

    final project = _projects.firstWhere((p) => p.id == projectId);
    project.status = 'debugging';
    
    try {
      final fixedCode = await debugService!.debugFlutterCode(
        faultyCode: project.generatedCode ?? '',
        errorDescription: errorDescription,
        originalPrompt: project.geminiPrompt ?? '',
      );
      
      project.generatedCode = fixedCode;
      project.status = 'debugged';
      project.lastError = null;
      project.lastUpdated = DateTime.now();

      // GitHub پر اپ ڈیٹ کریں
      if (githubService != null && project.githubRepoUrl != null) {
        await githubService!.updateRepository(
          project.name,
          project.generatedCode!
        );
      }
    } catch (e) {
      project.status = 'error';
      project.lastError = 'Debugging failed: $e';
      project.lastUpdated = DateTime.now();
      rethrow;
    }
  }

  // ✅ پرانے projects کے لیے compatibility
  Project findProjectById(String id) {
    return _projects.firstWhere((p) => p.id == id);
  }
}
