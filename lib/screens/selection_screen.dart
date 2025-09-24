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
    if (_platforms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one platform")),
      );
      return;
    }

    // === ڈیبگ معلومات ===
    print("=== SELECTION DEBUG INFO ===");
    print("Platforms: $_platforms");
    print("Framework: $_framework");
    print("Animation: $_animation");
    print("Font: $_font");
    print("API Integration: $_apiIntegration");
    print("============================");

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

    // === پروجیکٹ features چیک ===
    print("Project Features: ${project.features}");
    print("API Value in Project: ${project.features['api']}");
    print("Navigation: ${_animation != "none" || _font != "default" ? "UploadScreen" : "ChatScreen"}");

    // اگر کوئی custom feature selected ہے تو UploadScreen پر جائیں
    if (_animation != "none" || _font != "default") {
      Navigator.pushNamed(context, '/upload', arguments: project).then((_) {
        print("Navigation to UploadScreen completed");
      });
    } else {
      // ورنہ براہ راست ChatScreen پر جائیں
      Navigator.pushNamed(context, '/chat', arguments: project).then((_) {
        print("Navigation to ChatScreen completed");
      });
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
              icon: Icons.phone_android,
              children: [
                _buildCheckbox("Android", "Android"),
                _buildCheckbox("iOS", "iOS"),
                _buildCheckbox("Web", "Web"),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Framework Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.code, color: Colors.deepPurple),
                        const SizedBox(width: 10),
                        const Text("Framework", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            ),
            
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
            
            // Current Selection Display
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Current Selection:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text("• Platforms: ${_platforms.isEmpty ? "None" : _platforms.join(", ")}"),
                    Text("• Framework: $_framework"),
                    Text("• Animation: $_animation"),
                    Text("• Font: $_font"),
                    Text("• API: $_apiIntegration"),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Create Project Button
            Container(
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

  Widget _buildSection({required String title, required IconData icon, required List<Widget> children}) {
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
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildRadio(String title, String type, String value, String subtitle) {
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
      case "animation": 
        setState(() => _animation = value);
        break;
      case "font": 
        setState(() => _font = value);
        break;
      case "api": 
        setState(() => _apiIntegration = value);
        break;
    }
    print("Updated $type to: $value");
  }
}
