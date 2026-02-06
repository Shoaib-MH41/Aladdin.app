import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';
import '../services/gemini_service.dart';
import '../services/github_service.dart';
import '../services/ad_service.dart'; // ✅ نیا: AdService امپورٹ کریں

class ProjectScreen extends StatefulWidget {
  final GeminiService geminiService;
  final GitHubService githubService;
  final AdService adService; // ✅ نیا: AdService ویری ایبل

  const ProjectScreen({
    super.key,
    required this.geminiService,
    required this.githubService,
    required this.adService, // ✅ نیا: Constructor میں شامل کیا
  });

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
      appBar: AppBar(title: const Text("میرے پروجیکٹس")),
      body: projects.isEmpty
          ? const Center(
              child: Text("ابھی تک کوئی پروجیکٹ نہیں ہے۔ نیا پروجیکٹ بنائیں!"))
          : ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final p = projects[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "فریم ورک: ${p.framework} | پلیٹ فارم: ${p.platforms.join(', ')}"),
                    
                    // ✅ یہاں تبدیلی کی ہے: ایک سے زیادہ بٹن دکھانے کے لیے Row کا استعمال
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, // جگہ بچانے کے لیے
                      children: [
                        // 📢 اشتہار مہم کا بٹن (نیا)
                        IconButton(
                          icon: const Icon(Icons.ads_click, color: Colors.green),
                          tooltip: 'اشتہار مہم شروع کریں',
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/ads',
                              arguments: {
                                'projectName': p.name,
                                'initialBudget': 100.0,
                                'initialAdText': '${p.name} ایپ کو آزمائیں!',
                              },
                            );
                          },
                        ),
                        
                        // 🗑️ ڈیلیٹ کا بٹن (پرانا)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'پروجیکٹ ڈیلیٹ کریں',
                          onPressed: () => _deleteProject(p.id),
                        ),
                      ],
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
