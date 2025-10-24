import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

// نئی فائلیں شامل کریں
import '../services/app_publisher.dart';
import '../screens/publish_guide_screen.dart';

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
  bool _isCopying = false;
  String _copyResult = '';

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

      // 3 سیکنڈ بعد میسج غائب ہو جائے
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _copyResult = '';
          });
        }
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
        const SnackBar(content: Text('Termux انسٹال نہیں ہے۔ پہلے Termux انسٹال کریں۔')),
      );
    }
  }

  // ✅ پلے اسٹور کے لیے تیار کرنے کا فنکشن
  void _prepareForPlayStore() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PublishGuideScreen(
      appName: widget.projectName,
      generatedCode: widget.generatedCode,
      framework: widget.framework ?? 'Flutter',
    )));
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
          _buildStep('1. نیا index.html فائل بنائیں', ''),
          _buildStep('2. کوڈ پیسٹ کریں', ''),
          _buildStep('3. براؤزر میں کھولیں', 'دوبارہ کلک کریں index.html پر'),
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
        title: Text('کوڈ - ${widget.projectName}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📋 ہدایات کا کارڈ
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
                        SizedBox(width: 8),
                        Chip(
                          label: Text(widget.framework ?? 'Flutter'),
                          backgroundColor: Colors.blue[100],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ..._getFrameworkInstructions(),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // 📋 جنریٹ شدہ کوڈ
            Row(
              children: [
                Text(
                  'جنریٹ شدہ کوڈ:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Chip(
                  label: Text('${widget.generatedCode.split('\n').length} لائنیں'),
                  backgroundColor: Colors.grey[300],
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    widget.generatedCode,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // 🔧 پہلے دو بٹن (کاپی اور Termux)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: _isCopying 
                        ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(Icons.content_copy),
                    label: Text(_isCopying ? 'کاپی ہو رہا...' : 'کوڈ کاپی کریں'),
                    onPressed: _isCopying ? null : _copyCodeToClipboard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                if (widget.framework == 'Flutter')
                  ElevatedButton.icon(
                    icon: Icon(Icons.terminal),
                    label: Text('Termux کھولیں'),
                    onPressed: _openTermux,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: 10),

            // 🏪 پلے اسٹور بٹن (نیا شامل کیا گیا)
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.shop, size: 24),
                label: Text("پلے اسٹور کے لیے تیار کریں", style: TextStyle(fontSize: 16)),
                onPressed: _prepareForPlayStore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            
            SizedBox(height: 10),
            
            // 📝 نتیجہ کا میسج
            if (_copyResult.isNotEmpty)
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _copyResult.contains('✅') ? Colors.green[50] : Colors.red[50],
                  border: Border.all(
                    color: _copyResult.contains('✅') ? Colors.green : Colors.red,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _copyResult.contains('✅') ? Icons.check_circle : Icons.error,
                      color: _copyResult.contains('✅') ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Expanded(child: Text(_copyResult)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 🌟 ہر قدم کو بنانے کا طریقہ
  Widget _buildStep(String step, String command) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step),
                if (command.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 2),
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SelectableText(
                      command,
                      style: TextStyle(fontFamily: 'monospace', fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
