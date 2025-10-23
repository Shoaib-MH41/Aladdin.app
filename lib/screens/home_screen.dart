import 'package:flutter/material.dart';
import '../services/gemini_service.dart'; // ✅ شامل کریں
import '../services/github_service.dart'; // ✅ شامل کریں

class HomeScreen extends StatelessWidget {
  final GeminiService geminiService; // ✅ شامل کریں
  final GitHubService githubService; // ✅ شامل کریں

  const HomeScreen({
    super.key,
    required this.geminiService, // ✅ شامل کریں
    required this.githubService, // ✅ شامل کریں
  });

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aladdin App'),
        backgroundColor: Colors.deepPurple,
        actions: [
          // ✅ Settings button شامل کریں
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: 'ترتیبات',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.deepPurple.shade900, Colors.black]
                : [Colors.deepPurple.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCard(
                  context,
                  title: 'میرے پروجیکٹس',
                  subtitle: 'محفوظ شدہ پروجیکٹس کھولیں',
                  icon: Icons.folder_open,
                  color: Colors.indigo,
                  routeName: '/projects',
                ),
                const SizedBox(height: 20),
                _buildCard(
                  context,
                  title: 'نیا پروجیکٹ',
                  subtitle: 'پرومپٹ سے نئی ایپ بنائیں',
                  icon: Icons.add_circle_outline,
                  color: Colors.green,
                  routeName: '/select',
                ),
                const SizedBox(height: 20),
                _buildCard( // ✅ نیا card شامل کریں
                  context,
                  title: 'ترتیبات',
                  subtitle: 'API Keys اور سیٹنگز',
                  icon: Icons.settings,
                  color: Colors.orange,
                  routeName: '/settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required String routeName}) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, routeName),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: color,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 36, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 6),
                    Text(subtitle,
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
