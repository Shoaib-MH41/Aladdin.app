import 'package:flutter/material.dart';

class ProjectScreen extends StatelessWidget {
  const ProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Projects"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "New Project",
            onPressed: () {
              Navigator.pushNamed(context, '/chat');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "No projects yet.\nTap + to create one.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
