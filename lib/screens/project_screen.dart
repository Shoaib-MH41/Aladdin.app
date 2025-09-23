import 'package:flutter/material.dart';
import '../services/project_service.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final ProjectService _service = ProjectService();

  void _createNewProject() async {
    // empty project map
    final newProject = {
      'id': 'p_${DateTime.now().millisecondsSinceEpoch}',
      'name': 'New Project',
      'platforms': [],
      'framework': 'Flutter',
      'assets': {},
    };

    // step 1: selection screen
    final selected = await Navigator.pushNamed(context, '/selection', arguments: newProject);

    if (selected != null && selected is Map<String, dynamic>) {
      // step 2: upload screen
      final uploaded = await Navigator.pushNamed(context, '/upload', arguments: selected);

      if (uploaded != null && uploaded is Map<String, dynamic>) {
        // step 3: save to service
        _service.addProject(uploaded);
        setState(() {}); // refresh UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Project '${uploaded['name']}' saved successfully")),
        );
      }
    }
  }

  void _deleteProject(String id) {
    _service.deleteProject(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final projects = _service.getProjects();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewProject,
          )
        ],
      ),
      body: projects.isEmpty
          ? const Center(child: Text('No projects yet. Tap + to create one.'))
          : ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final p = projects[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(p['name'] ?? 'Unnamed'),
                    subtitle: Text("Framework: ${p['framework']} | Platforms: ${p['platforms'].join(', ')}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProject(p['id']),
                    ),
                    onTap: () {
                      // future: open detail screen
                    },
                  ),
                );
              },
            ),
    );
  }
}
