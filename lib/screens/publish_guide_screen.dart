// lib/screens/publish_guide_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/publish_service.dart';  // ✅ Import کریں

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
  final PublishService _publishService = PublishService();  // ✅ Service instance
  bool _isCreatingRepo = false;
  bool _isSavingZip = false;
  String _repoStatus = '';
  String? _savedZipPath;

  @override
  void initState() {
    super.initState();
    _autoSaveZip();  // ✅ خودکار ZIP save
  }

  // ✅ خودکار ZIP فائل محفوظ کریں
  Future<void> _autoSaveZip() async {
    setState(() {
      _isSavingZip = true;
      _repoStatus = '⏳ ZIP فائل بنا رہا ہے...';
    });

    try {
      final zipPath = await _publishService.saveAppAsZip(
        appName: widget.appName,
        generatedCode: widget.generatedCode,
        framework: widget.framework,
      );

      if (zipPath != null) {
        setState(() {
          _savedZipPath = zipPath;
          _repoStatus = '✅ ZIP فائل تیار ہے!';
        });
      } else {
        setState(() {
          _repoStatus = '❌ ZIP فائل نہیں بن سکی';
        });
      }
    } catch (e) {
      setState(() {
        _repoStatus = '❌ خرابی: $e';
      });
    } finally {
      setState(() {
        _isSavingZip = false;
      });
    }
  }

  // ✅ GitHub ریپوزٹری بنائیں (Service استعمال کرتے ہوئے)
  void _createGitHubRepo() async {
    setState(() {
      _isCreatingRepo = true;
      _repoStatus = '⏳ GitHub کھول رہا ہے...';
    });

    try {
      await _publishService.openGithubNewRepoPage();  // ✅ Service method
      
      setState(() {
        _repoStatus = '✅ GitHub کھل گیا ہے۔ اب نیا ریپوزٹری بنائیں۔';
      });
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

  // ✅ GitHub Desktop کھولیں (Service استعمال کرتے ہوئے)
  void _openGitHubDesktop() async {
    try {
      await _publishService.openGithubDesktopPage();  // ✅ Service method
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خرابی: $e')),
      );
    }
  }

  // ✅ ZIP فائل شیئر کریں
  void _shareZipFile() async {
    if (_savedZipPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('پہلے ZIP فائل بنائیں')),
      );
      return;
    }

    try {
      await _publishService.shareZipFile(_savedZipPath!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خرابی: $e')),
      );
    }
  }

  // ✅ پرانی فائل ڈیلیٹ کریں
  Future<void> _deleteSavedFile() async {
    if (_savedZipPath == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصدیق کریں'),
        content: const Text('کیا آپ یہ فائل ڈیلیٹ کرنا چاہتے ہیں؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('نہیں'),
          ),
          TextButton(
            onPressed: () async {
              await _publishService.deleteSavedApp(widget.appName, widget.framework);
              setState(() {
                _savedZipPath = null;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('فائل ڈیلیٹ ہو گئی')),
              );
            },
            child: const Text('ہاں'),
          ),
        ],
      ),
    );
  }

  // ✅ فائل کا سائز چیک کریں
  Future<String> _getFileSize() async {
    if (_savedZipPath == null) return '0 B';
    return await _publishService.getFileSize(_savedZipPath!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🚀 پبلش گائیڈ"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (_savedZipPath != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteSavedFile,
              tooltip: 'فائل ڈیلیٹ کریں',
            ),
        ],
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

            // 📦 ZIP فائل اسٹیٹس
            if (_savedZipPath != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ZIP فائل تیار ہے',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          FutureBuilder<String>(
                            future: _getFileSize(),
                            builder: (context, snapshot) {
                              return Text('سائز: ${snapshot.data ?? '...'}');
                            },
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: _shareZipFile,
                      tooltip: 'شیئر کریں',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 📋 گائیڈ سٹیپس
            _buildStepCard(
              stepNumber: 1,
              title: "ZIP فائل محفوظ کریں",
              description: "آپ کی ایپ کی تمام فائلیں ZIP میں محفوظ ہو جائیں گی",
              buttonText: _isSavingZip ? 'بنا رہا ہے...' : 'ZIP دوبارہ بنائیں',
              onPressed: _autoSaveZip,
              isLoading: _isSavingZip,
            ),

            _buildStepCard(
              stepNumber: 2,
              title: "GitHub پر ریپوزٹری بنائیں",
              description: "نیا ریپوزٹری بنائیں اور کوڈ اپلوڈ کریں",
              buttonText: "ریپوزٹری بنائیں",
              onPressed: _createGitHubRepo,
              isLoading: _isCreatingRepo,
            ),

            _buildStepCard(
              stepNumber: 3,
              title: "کوڈ GitHub پر اپلوڈ کریں",
              description: "اپنے کوڈ کو ریپوزٹری میں اپلوڈ کریں",
              buttonText: "GitHub Desktop ڈاؤنلوڈ کریں",
              onPressed: _openGitHubDesktop,
            ),

            _buildStepCard(
              stepNumber: 4,
              title: "GitHub Actions سے AAB بنائیں",
              description: "GitHub Actions خودکار طور پر AAB فائل بنائے گا",
              buttonText: "AAB بنانے کی ہدایات",
              onPressed: _showAABInstructions,
              isHighlighted: true,
            ),

            _buildStepCard(
              stepNumber: 5,
              title: "AAB فائل ڈاؤنلوڈ کریں",
              description: "GitHub Actions سے تیار شدہ AAB ڈاؤنلوڈ کریں",
              buttonText: "AAB ڈاؤنلوڈ کی ہدایات",
              onPressed: _showDownloadInstructions,
            ),

            _buildStepCard(
              stepNumber: 6,
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

            // 💡 اضافی ٹپس
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (باقی methods وہی رہیں گی)
}
