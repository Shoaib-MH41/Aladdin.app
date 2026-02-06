import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';
import '../services/gemini_service.dart';
import '../services/github_service.dart';
import '../services/ad_service.dart';

class ProjectScreen extends StatefulWidget {
  final GeminiService geminiService;
  final GitHubService githubService;
  final AdService adService;

  const ProjectScreen({
    super.key,
    required this.geminiService,
    required this.githubService,
    required this.adService,
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
              child: Text("ابھی تک کوئی پروجیکٹ نہیں ہے۔ نیا پروجیکٹ بنائیں!"),
            )
          : ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];

                return Column(
                  children: [
                    /// 🔹 مین پروجیکٹ کارڈ
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(
                          project.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "فریم ورک: ${project.framework} | پلیٹ فارم: ${project.platforms.join(', ')}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /// 📢 اشتہار بٹن
                            IconButton(
                              icon: const Icon(Icons.ads_click, color: Colors.green),
                              tooltip: 'اشتہار مہم شروع کریں',
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/ads',
                                  arguments: {
                                    'projectName': project.name,
                                    'initialBudget': 100.0,
                                    'initialAdText':
                                        '${project.name} ایپ کو آزمائیں!',
                                  },
                                );
                              },
                            ),

                            /// 🗑️ ڈیلیٹ بٹن
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProject(project.id),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/chat', arguments: project);
                        },
                      ),
                    ),

                    /// 📊 اشتہار معلومات کارڈ (شرط کے ساتھ)
                    if (project.hasActiveAds)
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.ads_click, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text(
                                    'اشتہار مہمیں',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'فعال مہمیں: ${project.activeAdCampaigns.length}',
                              ),
                              Text(
                                'کل بجٹ: \$${project.adBudget}',
                              ),
                              Text(
                                'خرچ ہوا: \$${project.totalAdSpent.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
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
