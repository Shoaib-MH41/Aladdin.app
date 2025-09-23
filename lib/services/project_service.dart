import '../models/project_model.dart';

class ProjectService {
  final List<Project> _projects = [];

  List<Project> getProjects() => _projects;

  void addProject(Project project) {
    _projects.add(project);
  }

  void deleteProject(String id) {
    _projects.removeWhere((p) => p.id == id);
  }
}
