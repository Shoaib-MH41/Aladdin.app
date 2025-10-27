
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

  // ✅ GitHub ڈیسکٹاپ کھولیں (فائل اپلوڈ کے لیے)
  void _openGitHubDesktop() async {
    const githubDesktopUrl = 'https://desktop.github.com/';
    
    if (await canLaunchUrl(Uri.parse(githubDesktopUrl))) {
      await launchUrl(
        Uri.parse(githubDesktopUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ GitHub Desktop ڈاؤنلوڈ پیج نہیں کھل سکا')),
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ پلے اسٹور کنسول نہیں کھل سکا')),
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

            // 📋 گائیڈ سٹیپس
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
              title: "APK فائل بنائیں",
              description: "اپنے فریم ورک کے مطابق ریلیز APK بنائیں",
              buttonText: "APK بنانے کی ہدایات",
              onPressed: _showApkInstructions,
            ),

            _buildStepCard(
              stepNumber: 4,
              title: "پلے اسٹور پر اپلوڈ کریں",
              description: "APK فائل پلے اسٹور کنسول پر اپلوڈ کریں",
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
                child: Text(
                  _repoStatus,
                  style: const TextStyle(fontSize: 14),
                ),
              ),

            const SizedBox(height: 20),

            // 💡 اضافی ٹپس
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "💡 اہم تجاویز",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTip("ریپوزٹری کا نام آسان اور واضح رکھیں"),
                    _buildTip("README.md فائل میں ایپ کی تفصیل لکھیں"),
                    _buildTip("APK بناتے وقت signing key استعمال کریں"),
                    _buildTip("پلے اسٹور کے لیے ایپ کی اسکرین شاٹس تیار کریں"),
                    _buildTip("پرائیویسی پالیسی شامل کرنا نہ بھولیں"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 ہر سٹیپ کا کارڈ
  Widget _buildStepCard({
    required int stepNumber,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                  decoration: const BoxDecoration(
                    color: Colors.deepPurple,
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
                    style: const TextStyle(
                      fontSize: 16,
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
                  backgroundColor: Colors.deepPurple,
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
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  // 📱 APK بنانے کی ہدایات
  void _showApkInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("📱 APK بنانے کی ہدایات"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildFrameworkInstructions(),
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

  // 🔧 فریم ورک کے مطابق ہدایات
  Widget _buildFrameworkInstructions() {
    switch (widget.framework.toLowerCase()) {
      case 'flutter':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstructionStep("1. Termux یا کمانڈ لائن کھولیں"),
            _buildInstructionStep("2. پروجیکٹ ڈائرکٹری میں جائیں", "cd ${widget.appName}"),
            _buildInstructionStep("3. APK بنائیں", "flutter build apk --release"),
            _buildInstructionStep("4. APK فائل ملے گی", "build/app/outputs/flutter-apk/app-release.apk"),
          ],
        );
      
      case 'react':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstructionStep("1. کمانڈ لائن کھولیں"),
            _buildInstructionStep("2. پروجیکٹ ڈائرکٹری میں جائیں", "cd ${widget.appName}"),
            _buildInstructionStep("3. Build بنائیں", "npm run build"),
            _buildInstructionStep("4. build/ فولڈر میں فائلیں ملیں گی"),
          ],
        );
      
      case 'android native':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstructionStep("1. Android Studio کھولیں"),
            _buildInstructionStep("2. پروجیکٹ ایمپورٹ کریں"),
            _buildInstructionStep("3. Build > Generate Signed Bundle/APK"),
            _buildInstructionStep("4. signing key بنائیں اور APK جنریٹ کریں"),
          ],
        );
      
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstructionStep("1. اپنے فریم ورک کے مطابق build کمانڈ استعمال کریں"),
            _buildInstructionStep("2. production build بنائیں"),
            _buildInstructionStep("3. output فولڈر میں فائلیں چیک کریں"),
          ],
        );
    }
  }

  // 📝 ہدایت کا سٹیپ
  Widget _buildInstructionStep(String step, [String? command]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(step),
          if (command != null)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                command,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
