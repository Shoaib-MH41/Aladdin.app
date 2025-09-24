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
  String _animation = "none";
  String _font = "default";
  String _apiIntegration = "none";

  void _saveSelection() {
    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: "Project_${DateTime.now().millisecondsSinceEpoch}",
      framework: _framework,
      platforms: _platforms,
      assets: {},
      features: {
        'animation': _animation,
        'font': _font,
        'api': _apiIntegration,
      },
    );
    Navigator.pop(context, project);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Options")),
      body: ListView(
        children: [
          // موجودہ platforms selection
          _buildSection("Platforms", [
            _buildCheckbox("Android", "Android"),
            _buildCheckbox("iOS", "iOS"),
            _buildCheckbox("Web", "Web"),
          ]),
          
          // Framework selection
          ListTile(
            title: const Text("Framework"),
            trailing: DropdownButton<String>(
              value: _framework,
              items: ["Flutter", "React Native", "Kotlin"]
                  .map((fw) => DropdownMenuItem(value: fw, child: Text(fw)))
                  .toList(),
              onChanged: (val) => setState(() => _framework = val!),
            ),
          ),
          
          // نئے فیچرز
          _buildSection("Animation", [
            _buildRadio("None", "animation", "none"),
            _buildRadio("Fade", "animation", "fade"),
            _buildRadio("Slide", "animation", "slide"),
          ]),
          
          _buildSection("Font", [
            _buildRadio("Default", "font", "default"),
            _buildRadio("Poppins", "font", "poppins"),
            _buildRadio("Roboto", "font", "roboto"),
          ]),
          
          _buildSection("API Integration", [
            _buildRadio("None", "api", "none"),
            _buildRadio("REST API", "api", "rest"),
            _buildRadio("Firebase", "api", "firebase"),
          ]),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _platforms.isEmpty ? null : _saveSelection,
              child: const Text("Create Project"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...children,
      ],
    );
  }

  Widget _buildCheckbox(String title, String value) {
    return CheckboxListTile(
      title: Text(title),
      value: _platforms.contains(value),
      onChanged: (val) => setState(() {
        val == true ? _platforms.add(value) : _platforms.remove(value);
      }),
    );
  }

  Widget _buildRadio(String title, String type, String value) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: _getGroupValue(type),
      onChanged: (val) => setState(() => _setGroupValue(type, val!)),
    );
  }

  String _getGroupValue(String type) {
    switch (type) {
      case "animation": return _animation;
      case "font": return _font;
      case "api": return _apiIntegration;
      default: return "none";
    }
  }

  void _setGroupValue(String type, String value) {
    switch (type) {
      case "animation": _animation = value; break;
      case "font": _font = value; break;
      case "api": _apiIntegration = value; break;
    }
  }
}
