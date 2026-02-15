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
  // ============= 📝 PROJECT NAME - نیا فیچر =============
  final TextEditingController _projectNameController = TextEditingController();
  
  // choices
  final List<String> _platforms = [];
  String _framework = 'Flutter';
  String _animation = 'none';
  String _font = 'default';
  String _apiIntegration = 'none';
  String _webBuild = 'flutter_web';
  
  // ✅ نیا: AdMob Integration choice
  String _adMobIntegration = 'none';

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
    
    // ✅ Default project name
    _projectNameController.text = 'MyApp_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _projectNameController.dispose();
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
    // ✅ Validate project name
    String projectName = _projectNameController.text.trim();
    if (projectName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('براہ کرم پروجیکٹ کا نام لکھیں')),
      );
      return;
    }

    if (_platforms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one platform')),
      );
      return;
    }

    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: projectName,  // ✅ اب صارف کا لکھا ہوا نام استعمال ہوگا
      framework: _framework,
      platforms: _platforms,
      assets: {},
      features: {
        'animation': _animation,
        'font': _font,
        'api': _apiIntegration,
        'webBuild': _webBuild,
        'adMob': _adMobIntegration,  // ✅ نیا: AdMob feature save
      },
      createdAt: DateTime.now(),
    );

    // ✅ تبدیلی: اب ہمیشہ سیدھا Chat Screen پر جائے، Upload Screen نہیں
    Navigator.pushNamed(context, '/chat', arguments: project);
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
          title: const Text('نیا پروجیکٹ'),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ============= 📝 PROJECT NAME SECTION - نیا =============
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.drive_file_rename_outline, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Text(
                          'پروجیکٹ کا نام',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _projectNameController,
                      decoration: InputDecoration(
                        hintText: '例如: MyFirstApp',
                        prefixIcon: const Icon(Icons.edit, color: Colors.blueAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اپنے پروجیکٹ کا نام لکھیں',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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

              // ✅ نیا: AdMob Integration Section
              const SizedBox(height: 14),

              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.monetization_on, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('AdMob Integration', 
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                    ]),
                    const SizedBox(height: 8),
                    RadioListTile<String>(
                      title: const Text('No Ads'),
                      value: 'none',
                      groupValue: _adMobIntegration,
                      onChanged: (v) => setState(() => _adMobIntegration = v ?? _adMobIntegration),
                    ),
                    RadioListTile<String>(
                      title: const Text('Banner Ads Only'),
                      value: 'banner',
                      groupValue: _adMobIntegration,
                      onChanged: (v) => setState(() => _adMobIntegration = v ?? _adMobIntegration),
                    ),
                    RadioListTile<String>(
                      title: const Text('Banner + Interstitial'),
                      value: 'banner_interstitial',
                      groupValue: _adMobIntegration,
                      onChanged: (v) => setState(() => _adMobIntegration = v ?? _adMobIntegration),
                    ),
                    RadioListTile<String>(
                      title: const Text('All Ad Types (Banner + Interstitial + Rewarded)'),
                      value: 'all',
                      groupValue: _adMobIntegration,
                      onChanged: (v) => setState(() => _adMobIntegration = v ?? _adMobIntegration),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '💡 AdMob IDs بعد میں Chat Screen میں setup کیے جائیں گے',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
