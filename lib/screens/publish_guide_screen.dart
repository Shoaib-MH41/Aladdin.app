// lib/screens/publish_guide_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PublishGuideScreen extends StatefulWidget {
  final String appName;
  final String generatedCode;
  final String framework;

  const PublishGuideScreen({
    super.key,
    required this.appName,
    required this.generatedCode,
    required this.framework,
  });

  @override
  State<PublishGuideScreen> createState() => _PublishGuideScreenState();
}

class _PublishGuideScreenState extends State<PublishGuideScreen> {
  bool _isCreatingRepo = false;
  String _repoStatus = '';

  // ✅ GitHub پر نیا ریپوزٹری بنانے کا لنک کھولیں
  void _createGitHubRepo() async {
    setState(() {
      _isCreatingRepo = true;
      _repoStatus = '⏳ GitHub کھول رہا ہے...';
    });

    try {
      const githubUrl = 'https://github.com/new';
      
      if (await canLaunchUrl(Uri.parse(githubUrl))) {
        await launchUrl(
          Uri.parse(githubUrl),
          mode: LaunchMode.externalApplication,
        );
        
        setState(() {
          _repoStatus = '✅ GitHub کھل گیا ہے۔ اب نیا ریپوزٹری بنائیں۔';
        });
      } else {
        setState(() {
          _repoStatus = '❌ GitHub نہیں کھل سکا۔';
        });
      }
    } catch (e) {
      setState(() {
        _repoStatus = '❌ خرابی: $e';
      });
    } finally {
      setState(() {
        _isCreatingRepo = false;
      });
    }
  }

  // ✅ GitHub ڈیسکٹاپ کھولیں
  void _openGitHubDesktop() async {
    const githubDesktopUrl = 'https://desktop.github.com/';
    
    if (await canLaunchUrl(Uri.parse(githubDesktopUrl))) {
      await launchUrl(
        Uri.parse(githubDesktopUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  // ✅ پلے اسٹور ڈویلپر اکاؤنٹ کھولیں
  void _openPlayStoreConsole() async {
    const playStoreUrl = 'https://play.google.com/console/';
    
    if (await canLaunchUrl(Uri.parse(playStoreUrl))) {
      await launchUrl(
        Uri.parse(playStoreUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🚀 پبلش گائیڈ"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // 📱 ایپ انفو کارڈ
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.appName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("فریم ورک: ${widget.framework}"),
                    const SizedBox(height: 8),
                    const Text(
                      "آپ کی ایپ تیار ہو چکی ہے! اب اسے پبلش کریں۔",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📋 گائیڈ سٹیپس - اب AAB کے ساتھ
            _buildStepCard(
              stepNumber: 1,
              title: "GitHub پر ریپوزٹری بنائیں",
              description: "نیا ریپوزٹری بنائیں اور کوڈ اپلوڈ کریں",
              buttonText: "ریپوزٹری بنائیں",
              onPressed: _createGitHubRepo,
              isLoading: _isCreatingRepo,
            ),

            _buildStepCard(
              stepNumber: 2,
              title: "کوڈ GitHub پر اپلوڈ کریں",
              description: "اپنے کوڈ کو ریپوزٹری میں اپلوڈ کریں",
              buttonText: "GitHub Desktop ڈاؤنلوڈ کریں",
              onPressed: _openGitHubDesktop,
            ),

            _buildStepCard(
              stepNumber: 3,
              title: "GitHub Actions سے AAB بنائیں",
              description: "GitHub Actions خودکار طور پر AAB فائل بنائے گا",
              buttonText: "AAB بنانے کی ہدایات",
              onPressed: _showAABInstructions,
              isHighlighted: true,
            ),

            _buildStepCard(
              stepNumber: 4,
              title: "AAB فائل ڈاؤنلوڈ کریں",
              description: "GitHub Actions سے تیار شدہ AAB ڈاؤنلوڈ کریں",
              buttonText: "AAB ڈاؤنلوڈ کی ہدایات",
              onPressed: _showDownloadInstructions,
            ),

            _buildStepCard(
              stepNumber: 5,
              title: "پلے اسٹور پر اپلوڈ کریں",
              description: "AAB فائل پلے اسٹور کنسول پر اپلوڈ کریں",
              buttonText: "پلے اسٹور کنسول کھولیں",
              onPressed: _openPlayStoreConsole,
            ),

            const SizedBox(height: 20),

            // 📝 اسٹیٹس
            if (_repoStatus.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _repoStatus.contains('✅') 
                      ? Colors.green[50] 
                      : _repoStatus.contains('❌')
                          ? Colors.red[50]
                          : Colors.blue[50],
                  border: Border.all(
                    color: _repoStatus.contains('✅') 
                        ? Colors.green 
                        : _repoStatus.contains('❌')
                            ? Colors.red
                            : Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_repoStatus),
              ),

            const SizedBox(height: 20),

            // 💡 اضافی ٹپس - AAB کے ساتھ
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "💡 اہم تجاویز - پلے اسٹور کے لیے",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTip("⚠️ **نوٹ:** پلے اسٹور APK قبول نہیں کرتا، صرف AAB چلتا ہے!"),
                    _buildTip("📦 AAB فائل APK سے 30% چھوٹی ہوتی ہے"),
                    _buildTip("🔑 Signing key ضروری ہے - اسے محفوظ رکھیں"),
                    _buildTip("📸 اسکرین شاٹس (2-8) تیار کریں"),
                    _buildTip("📄 پرائیویسی پالیسی ویب سائٹ پر اپلوڈ کریں"),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "🎯 GitHub Actions سے AAB بنانے کا طریقہ:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text("1. Build Screen پر جائیں"),
                          Text("2. 'GitHub Actions سے بلڈ کریں' بٹن دبائیں"),
                          Text("3. 5-10 منٹ انتظار کریں"),
                          Text("4. 'APK ڈاؤنلوڈ کریں' کے ساتھ AAB بھی ملے گا"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 ہر سٹیپ کا کارڈ - اب AAB والا نمایاں
  Widget _buildStepCard({
    required int stepNumber,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isHighlighted = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isHighlighted ? Colors.blue[50] : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isHighlighted ? Colors.blue : Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      stepNumber.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isHighlighted ? Colors.blue[800] : null,
                    ),
                  ),
                ),
                if (isHighlighted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "IMPORTANT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isHighlighted ? Colors.blue : Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💡 ٹپ آئٹم
  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 13),
                children: _parseTipText(text),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _parseTipText(String text) {
    if (text.contains('**')) {
      final parts = text.split('**');
      return parts.asMap().entries.map((entry) {
        final isBold = entry.key.isOdd;
        return TextSpan(
          text: entry.value,
          style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
        );
      }).toList();
    }
    return [TextSpan(text: text)];
  }

  // 📱 AAB بنانے کی ہدایات
  void _showAABInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("📦 AAB فائل بنانے کی ہدایات"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text(
                "پلے اسٹور کے لیے AAB (Android App Bundle) ضروری ہے:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildInstructionStep("1️⃣ Build Screen کھولیں"),
              _buildInstructionStep("2️⃣ 'GitHub Actions سے بلڈ کریں' بٹن دبائیں"),
              _buildInstructionStep("3️⃣ 5-10 منٹ انتظار کریں"),
              _buildInstructionStep("4️⃣ 'AAB ڈاؤنلوڈ کریں' بٹن دبائیں"),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "✅ AAB کے فوائد:",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    SizedBox(height: 8),
                    Text("• APK سے 30% چھوٹی فائل"),
                    Text("• Google Play آپٹمائزڈ APKs بناتا ہے"),
                    Text("• صارفین کو کم ڈیٹا استعمال ہوتا ہے"),
                    Text("• 150MB سے بڑی ایپس اپلوڈ کر سکتے ہیں"),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // 📥 ڈاؤنلوڈ ہدایات
  void _showDownloadInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("📥 AAB فائل ڈاؤنلوڈ کریں"),
        content: const Text(
          "GitHub Actions سے AAB ڈاؤنلوڈ کرنے کا طریقہ:\n\n"
          "1. Build Screen پر جائیں\n"
          "2. بلڈ مکمل ہونے کے بعد 'APK ڈاؤنلوڈ کریں' کے بٹن کے ساتھ\n"
          "   'AAB ڈاؤنلوڈ کریں' کا بٹن بھی ہوگا\n"
          "3. اس بٹن کو دبائیں\n"
          "4. GitHub Actions کے artifacts صفحہ کھل جائے گا\n"
          "5. 'release-aab.zip' ڈاؤنلوڈ کریں\n"
          "6. ZIP فائل کو Extract کریں، AAB فائل مل جائے گی",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // 📝 ہدایت کا سٹیپ
  Widget _buildInstructionStep(String step) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(step)),
        ],
      ),
    );
  }
}
