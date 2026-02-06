import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/github_service.dart';
import '../services/ad_service.dart'; // ✅ نیا: AdService کی فائل امپورٹ کریں

class HomeScreen extends StatelessWidget {
  final GeminiService geminiService;
  final GitHubService githubService;
  final AdService adService; // ✅ نیا: AdService کا ویری ایبل

  const HomeScreen({
    super.key,
    required this.geminiService,
    required this.githubService,
    required this.adService, // ✅ نیا: Constructor میں شامل کیا
  });

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aladdin App'),
        backgroundColor: Colors.deepPurple,
        actions: [
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
            child: SingleChildScrollView( // چھوٹی اسکرینز کے لیے سکرول شامل کیا
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
                  
                  // ✅ نیا: اشتہار مہم والا بٹن (Card اسٹائل میں)
                  _buildCard(
                    context,
                    title: 'میری اشتہار مہمیں',
                    subtitle: 'اشتہارات کی کارکردگی دیکھیں',
                    icon: Icons.campaign, // 📢 مہم کا آئیکن
                    color: Colors.teal,   // الگ رنگ
                    routeName: '/ad-campaigns',
                    arguments: { // ڈیٹا جو اگلی اسکرین پر جائے گا
                      'projectId': 'current_project_id', // نوٹ: یہاں صحیح آئی ڈی آنی چاہیے
                      'projectName': 'میرے پروجیکٹس',
                    },
                  ),

                  const SizedBox(height: 20),
                  _buildCard(
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
      ),
    );
  }

  // کارڈ بنانے والا فنکشن (اپ ڈیٹ شدہ)
  Widget _buildCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required String routeName,
      Object? arguments}) { // ✅ نیا: Arguments قبول کرنے کی صلاحیت
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context, 
        routeName, 
        arguments: arguments // ✅ نیا: Arguments پاس کیے جا رہے ہیں
      ),
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
