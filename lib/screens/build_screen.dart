import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

// 🔹 درست import
import '../controllers/aladdin_controller.dart';
import 'publish_guide_screen.dart';

class BuildScreen extends StatefulWidget {
  final String generatedCode;
  final String projectName;
  final String? framework;

  const BuildScreen({
    super.key,
    required this.generatedCode,
    required this.projectName,
    this.framework = 'Flutter',
  });

  @override
  State<BuildScreen> createState() => _BuildScreenState();
}

class _BuildScreenState extends State<BuildScreen> {
  final _controller = AladdinController();

  bool _isCopying = false;
  bool _isBuilding = false;
  String _copyResult = '';
  String _buildMessage = '';

  // ✅ کوڈ کاپی کرنے کا فنکشن
  void _copyCodeToClipboard() async {
    setState(() {
      _isCopying = true;
      _copyResult = '';
    });

    try {
      await Clipboard.setData(ClipboardData(text: widget.generatedCode));
      setState(() {
        _isCopying = false;
        _copyResult = '✅ کوڈ کاپی ہو گیا! اب آپ اسے اپنے پروجیکٹ میں پیسٹ کر سکتے ہیں۔';
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _copyResult = '');
      });
    } catch (e) {
      setState(() {
        _isCopying = false;
        _copyResult = '❌ کاپی کرنے میں ناکامی: $e';
      });
    }
  }

  // ✅ Termux کھولنے کا فنکشن
  void _openTermux() async {
    const url = 'termux://';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Termux انسٹال نہیں ہے۔ پہلے Termux انسٹال کریں۔')),
      );
    }
  }

  // ✅ پلے اسٹور کے لیے تیار کرنے کا فنکشن
  void _prepareForPlayStore() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PublishGuideScreen(
          appName: widget.projectName,
          generatedCode: widget.generatedCode,
          framework: widget.framework ?? 'Flutter',
        ),
      ),
    );
  }

  // ✅ GitHub پر اپلوڈ فنکشن (درست)
  void _buildAndUploadApp() async {
    setState(() {
      _isBuilding = true;
      _buildMessage = '⏳ ایپ تیار کی جا رہی ہے اور GitHub پر اپلوڈ ہو رہی ہے...';
    });

    try {
      // ✅ درست فنکشن کال
      final result = await _controller.generateAndUploadApp(
        prompt: 'Auto-generated app for ${widget.projectName}',
        framework: widget.framework ?? 'Flutter',
        repoName: widget.projectName,
      );

      if (result['success'] == true) {
        setState(() {
          _buildMessage = '✅ ${result['message']}\n🔗 ${result['repoUrl']}';
          _isBuilding = false;
        });
      } else {
        setState(() {
          _buildMessage = '❌ ${result['error']}';
          _isBuilding = false;
        });
      }
    } catch (e) {
      setState(() {
        _buildMessage = '❌ خرابی: $e';
        _isBuilding = false;
      });
    }
  }

  // ✅ فریم ورک کے مطابق ہدایات
  List<Widget> _getFrameworkInstructions() {
    switch (widget.framework?.toLowerCase()) {
      case 'react':
        return [
          _buildStep('1. نیا React پروجیکٹ بنائیں', 'npx create-react-app ${widget.projectName}'),
          _buildStep('2. src/App.js میں کوڈ پیسٹ کریں', ''),
          _buildStep('3. ایپ چلائیں', 'npm start'),
          _buildStep('4. Build بنائیں', 'npm run build'),
        ];
      case 'vue':
        return [
          _buildStep('1. نیا Vue پروجیکٹ بنائیں', 'npm create vue@latest ${widget.projectName}'),
          _buildStep('2. src/components/ میں کوڈ پیسٹ کریں', ''),
          _buildStep('3. ایپ چلائیں', 'npm run dev'),
          _buildStep('4. Build بنائیں', 'npm run build'),
        ];
      case 'android native':
        return [
          _buildStep('1. Android Studio میں نیا پروجیکٹ بنائیں', ''),
          _buildStep('2. MainActivity.kt میں کوڈ پیسٹ کریں', ''),
          _buildStep('3. APK بنائیں', 'Build > Generate Signed Bundle / APK'),
        ];
      case 'html':
        return [
          _buildStep('1. index.html فائل بنائیں', ''),
          _buildStep('2. کوڈ پیسٹ کریں', ''),
          _buildStep('3. براؤزر میں کھولیں', 'index.html'),
        ];
      case 'flutter':
      default:
        return [
          _buildStep('1. Termux کھولیں', 'termux://'),
          _buildStep('2. نیا Flutter پروجیکٹ بنائیں', 'flutter create ${widget.projectName}'),
          _buildStep('3. lib/main.dart میں کوڈ پیسٹ کریں', ''),
          _buildStep('4. APK بنائیں', 'flutter build apk --release'),
          _buildStep('5. APK ملے گی', 'build/app/outputs/flutter-apk/app-release.apk'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🚀 ${widget.projectName} Build'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📘 ہدایات کارڈ
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '📱 ${widget.framework} ایپ بنانے کے لیے:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(widget.framework ?? 'Flutter'),
                          backgroundColor: Colors.blue[100],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._getFrameworkInstructions(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📋 کوڈ کا حصہ
            Row(
              children: [
                const Text('جنریٹ شدہ کوڈ:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Chip(
                  label: Text('${widget.generatedCode.split('\n').length} لائنیں'),
                  backgroundColor: Colors.grey[300],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    widget.generatedCode,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔘 بٹن
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: _isCopying
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.copy),
                    label: Text(_isCopying ? 'کاپی ہو رہا ہے...' : 'کوڈ کاپی کریں'),
                    onPressed: _isCopying ? null : _copyCodeToClipboard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (widget.framework == 'Flutter')
                  ElevatedButton.icon(
                    icon: const Icon(Icons.terminal),
                    label: const Text('Termux کھولیں'),
                    onPressed: _openTermux,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // 🏪 Play Store اور GitHub بٹن
            Column(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.shop),
                  label: const Text("پلے اسٹور کے لیے تیار کریں"),
                  onPressed: _prepareForPlayStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: _isBuilding
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: Text(_isBuilding ? "اپلوڈ ہو رہا ہے..." : "GitHub پر اپلوڈ کریں"),
                  onPressed: _isBuilding ? null : _buildAndUploadApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 📝 نتائج
            if (_copyResult.isNotEmpty)
              _statusCard(_copyResult),
            if (_buildMessage.isNotEmpty)
              _statusCard(_buildMessage),
          ],
        ),
      ),
    );
  }

  // 🌟 ہر قدم بنانے کا فنکشن
  Widget _buildStep(String step, String command) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step),
                if (command.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SelectableText(
                      command,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(String message) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: message.contains('✅') ? Colors.green[50] : Colors.red[50],
        border: Border.all(color: message.contains('✅') ? Colors.green : Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        message,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
