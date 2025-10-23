import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/gemini_service.dart'; // ✅ شامل کریں
import '../services/github_service.dart'; // ✅ شامل کریں

class SelectionScreen extends StatefulWidget {
  final GeminiService geminiService; // ✅ شامل کریں
  final GitHubService githubService; // ✅ شامل کریں

  const SelectionScreen({
    super.key,
    required this.geminiService, // ✅ شامل کریں
    required this.githubService, // ✅ شامل کریں
  });

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  final List<String> _platforms = [];
  String _framework = "Flutter";
  String _animation = "none";
  String _font = "default";
  String _apiIntegration = "none";
  String _webBuild = "flutter_web";

  void _saveSelection() {
    if (_platforms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("براہ کرم کم از کم ایک پلیٹ فارم منتخب کریں")),
      );
      return;
    }

    final project = Project(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  name: "پروجیکٹ_${DateTime.now().millisecondsSinceEpoch}",
  framework: _framework,
  platforms: _platforms,
  assets: {},
  features: {
    'animation': _animation,
    'font': _font,
    'api': _apiIntegration,
    'webBuild': _webBuild,
  },
  createdAt: DateTime.now(), // ✅ required parameter
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
        title: const Text("نیا پروجیکٹ بنائیں"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Platforms Section
            _buildSection(
              title: "پلیٹ فارمز *",
              icon: Icons.devices,
              children: [
                _buildCheckbox("Android", "Android"),
                _buildCheckbox("iOS", "iOS"),
                _buildCheckbox("Web", "Web"),
                _buildCheckbox("Desktop", "Desktop"), // ✅ نیا option
              ],
            ),

            if (_platforms.contains("Web")) _buildWebOptions(),

            const SizedBox(height: 20),

            // Framework Section
            _buildFramework(),

            const SizedBox(height: 20),

            // Animation Section
            _buildSection(
              title: "اینی میشن",
              icon: Icons.animation,
              children: [
                _buildRadio("کوئی نہیں", "animation", "none", "کوئی اینی میشن نہیں"),
                _buildRadio("فید ان", "animation", "fade", "فید اینی میشن اثرات"),
                _buildRadio("سلائیڈ ان", "animation", "slide", "سلائیڈ اینی میشن اثرات"),
                _buildRadio("باؤنس", "animation", "bounce", "باؤنس اینی میشن اثرات"),
              ],
            ),

            const SizedBox(height: 20),

            // Font Section
            _buildSection(
              title: "فونٹ سٹائل",
              icon: Icons.font_download,
              children: [
                _buildRadio("ڈیفالٹ", "font", "default", "سسٹم ڈیفالٹ فونٹ استعمال کریں"),
                _buildRadio("پوپنز", "font", "poppins", "جدید پوپنز فونٹ"),
                _buildRadio("روبوتو", "font", "roboto", "گوگل روبوتو فونٹ"),
                _buildRadio("اپنا فونٹ", "font", "custom", "اپنا فونٹ فائل اپ لوڈ کریں"),
              ],
            ),

            const SizedBox(height: 20),

            // API Section
            _buildSection(
              title: "API انٹیگریشن",
              icon: Icons.cloud,
              children: [
                _buildRadio("کوئی نہیں", "api", "none", "کوئی API انٹیگریشن نہیں"),
                _buildRadio("REST API", "api", "rest", "RESTful APIs سے جڑیں"),
                _buildRadio("فائر بیس", "api", "firebase", "فائر بیس بیکنڈ سروسز"),
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
                  "پروجیکٹ بنائیں",
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
                Text("فریم ورک",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _framework,
              isExpanded: true,
              items: [
                "Flutter", 
                "React", 
                "Vue", 
                "Android Native", 
                "HTML/CSS/JS" // ✅ نئے options
              ].map((fw) => DropdownMenuItem(value: fw, child: Text(fw)))
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
                Text("ویب بلڈ قسم",
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
