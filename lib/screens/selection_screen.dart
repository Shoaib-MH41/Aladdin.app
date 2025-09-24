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
  String _webBuild = "flutter_web"; // ✅ Default web build

  void _saveSelection() {
    if (_platforms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one platform")),
      );
      return;
    }

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
        'webBuild': _webBuild, // ✅ save web build type
      },
    );

    // اگر animation یا font custom ہے تو upload پر جائیں
    if (_animation != "none" || _font != "default") {
      Navigator.pushNamed(context, '/upload', arguments: project);
    } else {
      Navigator.pushNamed(context, '/chat', arguments: project);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Project"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Platforms Section
            _buildSection(
              title: "Platforms *",
              icon: Icons.devices,
              children: [
                _buildCheckbox("Android", "Android"),
                _buildCheckbox("iOS", "iOS"),
                _buildCheckbox("Web", "Web"),
              ],
            ),

            if (_platforms.contains("Web")) _buildWebOptions(),

            const SizedBox(height: 20),

            // Framework Section
            _buildFramework(),

            const SizedBox(height: 20),

            // Animation Section
            _buildSection(
              title: "Animation",
              icon: Icons.animation,
              children: [
                _buildRadio("None", "animation", "none", "No animation effects"),
                _buildRadio("Fade In", "animation", "fade", "Fade animation effects"),
                _buildRadio("Slide In", "animation", "slide", "Slide animation effects"),
                _buildRadio("Bounce", "animation", "bounce", "Bounce animation effects"),
              ],
            ),

            const SizedBox(height: 20),

            // Font Section
            _buildSection(
              title: "Font Style",
              icon: Icons.font_download,
              children: [
                _buildRadio("Default", "font", "default", "Use system default font"),
                _buildRadio("Poppins", "font", "poppins", "Modern Poppins font"),
                _buildRadio("Roboto", "font", "roboto", "Google Roboto font"),
                _buildRadio("Custom", "font", "custom", "Upload your own font file"),
              ],
            ),

            const SizedBox(height: 20),

            // API Section
            _buildSection(
              title: "API Integration",
              icon: Icons.cloud,
              children: [
                _buildRadio("None", "api", "none", "No API integration"),
                _buildRadio("REST API", "api", "rest", "Connect to RESTful APIs"),
                _buildRadio("Firebase", "api", "firebase", "Firebase backend services"),
              ],
            ),

            const SizedBox(height: 30),

            // Create Project Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _saveSelection,
                child: const Text(
                  "Create Project",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepPurple),
                const SizedBox(width: 10),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
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

  Widget _buildRadio(
      String title, String type, String value, String subtitle) {
    return RadioListTile<String>(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      value: value,
      groupValue: _getGroupValue(type),
      onChanged: (val) => setState(() => _setGroupValue(type, val!)),
    );
  }

  Widget _buildFramework() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.code, color: Colors.deepPurple),
                SizedBox(width: 10),
                Text("Framework",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _framework,
              isExpanded: true,
              items: ["Flutter", "React Native", "Kotlin", "Swift"]
                  .map((fw) => DropdownMenuItem(value: fw, child: Text(fw)))
                  .toList(),
              onChanged: (val) => setState(() => _framework = val!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.web, color: Colors.deepPurple),
                SizedBox(width: 10),
                Text("Web Build Type",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _webBuild,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: "flutter_web", child: Text("Flutter Web")),
                DropdownMenuItem(value: "pwa", child: Text("PWA (Progressive Web App)")),
                DropdownMenuItem(value: "react_web", child: Text("React Web")),
                DropdownMenuItem(value: "next_js", child: Text("Next.js")),
              ],
              onChanged: (val) => setState(() => _webBuild = val!),
            ),
          ],
        ),
      ),
    );
  }

  String _getGroupValue(String type) {
    switch (type) {
      case "animation":
        return _animation;
      case "font":
        return _font;
      case "api":
        return _apiIntegration;
      default:
        return "none";
    }
  }

  void _setGroupValue(String type, String value) {
    switch (type) {
      case "animation":
        _animation = value;
        break;
      case "font":
        _font = value;
        break;
      case "api":
        _apiIntegration = value;
        break;
    }
  }
}

