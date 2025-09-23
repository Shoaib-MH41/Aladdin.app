import 'package:flutter/material.dart';
import '../models/project_model.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Project project =
        ModalRoute.of(context)!.settings.arguments as Project;

    return Scaffold(
      appBar: AppBar(title: const Text("Upload Assets")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Mock upload
              project.assets['font'] = "poppins.ttf";
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Font uploaded!")));
            },
            child: const Text("Upload Font"),
          ),
          ElevatedButton(
            onPressed: () {
              project.assets['icon'] = "app_icon.png";
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Icon uploaded!")));
            },
            child: const Text("Upload Icon"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, project);
            },
            child: const Text("Save & Continue"),
          ),
        ],
      ),
    );
  }
}

