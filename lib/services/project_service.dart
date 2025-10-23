import '../models/project_model.dart';
import 'debug_service.dart';
import 'github_service.dart';

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
    _projects.removeWhere((p) => p.id == id); // ✅ درست
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

      // Gemini سے کوڈ جنریٹ کریں
      if (debugService != null) {
        try {
          project.generatedCode = await debugService!.generateCode(
            prompt: prompt,
            framework: framework,
            platforms: project.platforms,
          );
        } catch (e) {
          project.generatedCode = '// کوڈ جنریٹ نہیں ہوا: $e';
        }
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
        generatedCode: '',
        createdAt: DateTime.now(),
      );
      addProject(errorProject);
      
      throw Exception('پروجیکٹ بنانے میں ناکامی: $e');
    }
  }

  // ✅ پروجیکٹ ڈھونڈنے کے لیے helper method
  Project findProjectById(String id) {
    return _projects.firstWhere((p) => p.id == id);
  }
}
