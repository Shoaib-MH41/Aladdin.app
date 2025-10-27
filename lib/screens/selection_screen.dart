import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/gemini_service.dart';
import '../services/github_service.dart';

class SelectionScreen extends StatefulWidget {
  final GeminiService geminiService;
  final GitHubService githubService;

  const SelectionScreen({
    super.key,
    required this.geminiService,
    required this.githubService,
  });

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen>
    with SingleTickerProviderStateMixin {
  // choices
  final List<String> _platforms = [];
  String _framework = 'Flutter';
  String _animation = 'none';
  String _font = 'default';
  String _apiIntegration = 'none';
  String _webBuild = 'flutter_web';

  // animation controller for subtle UI transitions
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _togglePlatform(String value, bool? enabled) {
    setState(() {
      if (enabled == true) {
        if (!_platforms.contains(value)) _platforms.add(value);
      } else {
        _platforms.remove(value);
      }
    });
  }

  void _saveSelection() {
    if (_platforms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one platform')),
      );
      return;
    }

    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'project_${DateTime.now().millisecondsSinceEpoch}',
      framework: _framework,
      platforms: _platforms,
      assets: {},
      features: {
        'animation': _animation,
        'font': _font,
        'api': _apiIntegration,
        'webBuild': _webBuild,
      },
      createdAt: DateTime.now(),
    );

    // If user needs to upload fonts/icons/animations, go to UploadScreen
    if (_animation != 'none' || _font == 'custom') {
      Navigator.pushNamed(context, '/upload', arguments: project);
    } else {
      Navigator.pushNamed(context, '/chat', arguments: project);
    }
  }

  Widget _sectionCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(padding: const EdgeInsets.all(14.0), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Project'),
          backgroundColor: Colors.blueAccent,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.devices, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Text('Platforms', style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: -8,
                      children: [
                        FilterChip(
                          label: const Text('Android'),
                          selected: _platforms.contains('Android'),
                          onSelected: (s) => _togglePlatform('Android', s),
                        ),
                        FilterChip(
                          label: const Text('iOS'),
                          selected: _platforms.contains('iOS'),
                          onSelected: (s) => _togglePlatform('iOS', s),
                        ),
                        FilterChip(
                          label: const Text('Web'),
                          selected: _platforms.contains('Web'),
                          onSelected: (s) => _togglePlatform('Web', s),
                        ),
                        FilterChip(
                          label: const Text('Desktop'),
                          selected: _platforms.contains('Desktop'),
                          onSelected: (s) => _togglePlatform('Desktop', s),
                        ),
                      ],
                    ),
                    if (_platforms.contains('Web')) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _webBuild,
                        decoration: const InputDecoration(labelText: 'Web build type'),
                        items: const [
                          DropdownMenuItem(value: 'flutter_web', child: Text('Flutter Web')),
                          DropdownMenuItem(value: 'pwa', child: Text('PWA')),
                          DropdownMenuItem(value: 'react_web', child: Text('React / SPA')),
                          DropdownMenuItem(value: 'next_js', child: Text('Next.js')),
                        ],
                        onChanged: (v) => setState(() => _webBuild = v ?? _webBuild),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 14),

              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.code, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Text('Framework', style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _framework,
                      items: [
                        'Flutter',
                        'React',
                        'Vue',
                        'Android Native',
                        'HTML/CSS/JS'
                      ].map((fw) => DropdownMenuItem(value: fw, child: Text(fw))).toList(),
                      onChanged: (v) => setState(() => _framework = v ?? _framework),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.animation, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Text('Animation', style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 8),
                    RadioListTile<String>(
                      title: const Text('None'),
                      value: 'none',
                      groupValue: _animation,
                      onChanged: (v) => setState(() => _animation = v ?? _animation),
                    ),
                    RadioListTile<String>(
                      title: const Text('Fade'),
                      value: 'fade',
                      groupValue: _animation,
                      onChanged: (v) => setState(() => _animation = v ?? _animation),
                    ),
                    RadioListTile<String>(
                      title: const Text('Slide'),
                      value: 'slide',
                      groupValue: _animation,
                      onChanged: (v) => setState(() => _animation = v ?? _animation),
                    ),
                    RadioListTile<String>(
                      title: const Text('Bounce'),
                      value: 'bounce',
                      groupValue: _animation,
                      onChanged: (v) => setState(() => _animation = v ?? _animation),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.font_download, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Text('Font', style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 8),
                    RadioListTile<String>(
                      title: const Text('Default'),
                      value: 'default',
                      groupValue: _font,
                      onChanged: (v) => setState(() => _font = v ?? _font),
                    ),
                    RadioListTile<String>(
                      title: const Text('Poppins'),
                      value: 'poppins',
                      groupValue: _font,
                      onChanged: (v) => setState(() => _font = v ?? _font),
                    ),
                    RadioListTile<String>(
                      title: const Text('Roboto'),
                      value: 'roboto',
                      groupValue: _font,
                      onChanged: (v) => setState(() => _font = v ?? _font),
                    ),
                    RadioListTile<String>(
                      title: const Text('Custom (upload)'),
                      value: 'custom',
                      groupValue: _font,
                      onChanged: (v) => setState(() => _font = v ?? _font),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.cloud, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Text('API Integration', style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 8),
                    RadioListTile<String>(
                      title: const Text('None'),
                      value: 'none',
                      groupValue: _apiIntegration,
                      onChanged: (v) => setState(() => _apiIntegration = v ?? _apiIntegration),
                    ),
                    RadioListTile<String>(
                      title: const Text('REST API'),
                      value: 'rest',
                      groupValue: _apiIntegration,
                      onChanged: (v) => setState(() => _apiIntegration = v ?? _apiIntegration),
                    ),
                    RadioListTile<String>(
                      title: const Text('Firebase'),
                      value: 'firebase',
                      groupValue: _apiIntegration,
                      onChanged: (v) => setState(() => _apiIntegration = v ?? _apiIntegration),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _saveSelection,
                child: const Text('Create Project', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
