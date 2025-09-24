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
        SnackBar(content: Text("Please select at least one platform")),
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
      },
    );
    
    // اگر کوئی custom feature selected ہے تو UploadScreen پر جائیں
    if (_animation != "none" || _font != "default") {
      Navigator.pushNamed(context, '/upload', arguments: project);
    } else {
      // ورنہ براہ راست ChatScreen پر جائیں
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
              icon: Icons.phone_android,
              children: [
                _buildCheckbox("Android", "Android"),
                _buildCheckbox("iOS", "iOS"),
                _buildCheckbox("Web", "Web"),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Framework Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.code, color: Colors.deepPurple),
                        SizedBox(width: 10),
                        Text("Framework", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 10),
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
            
            SizedBox(height: 20),
            
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
            
            SizedBox(height: 20),
            
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
            
            SizedBox(height: 20),
            
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
            
            SizedBox(height: 30),
            
            // Create Project Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _saveSelection,
                child: Text(
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
                SizedBox(width: 10),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
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
          Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey)),
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
      case "animation": _animation = value; break;
      case "font": _font = value; break;
      case "api": _apiIntegration = value; break;
    }
  }
}
