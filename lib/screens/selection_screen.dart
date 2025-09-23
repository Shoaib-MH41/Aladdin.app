import 'package:flutter/material.dart';
import '../models/project_model.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  final List<String> _platforms = [];
  String _framework = "Flutter";

  void _saveSelection() {
    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: "New Project",
      framework: _framework,
      platforms: _platforms,
      assets: {},
    );
    Navigator.pop(context, project);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Platforms")),
      body: Column(
        children: [
          CheckboxListTile(
            title: const Text("Android"),
            value: _platforms.contains("Android"),
            onChanged: (val) {
              setState(() {
                val == true
                    ? _platforms.add("Android")
                    : _platforms.remove("Android");
              });
            },
          ),
          CheckboxListTile(
            title: const Text("iOS"),
            value: _platforms.contains("iOS"),
            onChanged: (val) {
              setState(() {
                val == true ? _platforms.add("iOS") : _platforms.remove("iOS");
              });
            },
          ),
          CheckboxListTile(
            title: const Text("Web"),
            value: _platforms.contains("Web"),
            onChanged: (val) {
              setState(() {
                val == true ? _platforms.add("Web") : _platforms.remove("Web");
              });
            },
          ),
          ListTile(
            title: const Text("Framework"),
            trailing: DropdownButton<String>(
              value: _framework,
              items: ["Flutter", "React"]
                  .map((fw) => DropdownMenuItem(value: fw, child: Text(fw)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _framework = val!;
                });
              },
            ),
          ),
          ElevatedButton(
            onPressed: _saveSelection,
            child: const Text("Save & Continue"),
          )
        ],
      ),
    );
  }
}
