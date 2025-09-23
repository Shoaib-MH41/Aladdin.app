import 'package:flutter/material.dart';
import '../services/project_service.dart';
import '../models/project_model.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final ProjectService _service = ProjectService();

  void _createNewProject() {
    Navigator.pushNamed(context, '/select').then((value) {
      if (value is Project) {
        setState(() {
          _service.addProject(value);
        });
      }
    });
  }

  void _deleteProject(String id) {
    setState(() {
      _service.deleteProject(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final projects = _service.getProjects();

    return Scaffold(
      appBar: AppBar(title: const Text("My Projects")),
      body: projects.isEmpty
          ? const Center(child: Text("No projects yet. Create one!"))
          : ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final p = projects[index];
                return Card(
                  child: ListTile(
                    title: Text(p.name),
                    subtitle: Text(
                        "Framework: ${p.framework} | Platforms: ${p.platforms.join(', ')}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProject(p.id),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/chat', arguments: p);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewProject,
        child: const Icon(Icons.add),
      ),
    );
  }
}
