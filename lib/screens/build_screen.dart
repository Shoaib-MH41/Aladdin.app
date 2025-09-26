import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BuildScreen extends StatefulWidget {
  final String generatedCode;
  final String projectName; // 🌟 نیا parameter
  
  const BuildScreen({
    super.key, 
    required this.generatedCode,
    this.projectName = 'MyApp'
  });

  @override
  State<BuildScreen> createState() => _BuildScreenState();
}

class _BuildScreenState extends State<BuildScreen> {
  bool _isCopying = false;
  String _copyResult = '';

  // 🌟 APK نہیں بنائیں گے، بلکہ instructions دیں گے
  void _copyCodeToClipboard() async {
    setState(() {
      _isCopying = true;
      _copyResult = '';
    });

    try {
      // کوڈ کو clipboard میں کاپی کریں
      // await Clipboard.setData(ClipboardData(text: widget.generatedCode));
      
      setState(() {
        _isCopying = false;
        _copyResult = '✅ کوڈ کاپی ہو گیا!';
      });
    } catch (e) {
      setState(() {
        _isCopying = false;
        _copyResult = '❌ کاپی کرنے میں ناکامی: $e';
      });
    }
  }

  // 🌟 Termux کھولنے کے لیے
  void _openTermux() async {
    const url = 'termux://';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Termux انسٹال نہیں ہے')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('APK بنائیں - ${widget.projectName}'),
        backgroundColor: Colors.blue, // 🌟 Gemini theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📋 Instructions
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📱 APK بنانے کے لیے:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildStep('1. Termux کھولیں', 'termux://'),
                    _buildStep('2. نیا پروجیکٹ بنائیں', 'flutter create ${widget.projectName}'),
                    _buildStep('3. lib/main.dart میں کوڈ پیسٹ کریں', ''),
                    _buildStep('4. APK بنائیں', 'flutter build apk --release'),
                    _buildStep('5. APK ملے گی', 'build/app/outputs/flutter-apk/'),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // 📋 Generated Code Preview
            const Text(
              'جنریٹ شدہ کوڈ:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  child: SelectableText( // 🌟 SelectableText استعمال کریں
                    widget.generatedCode,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // 🔧 Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.content_copy),
                    label: Text(_isCopying ? 'کاپی ہو رہا...' : 'کوڈ کاپی کریں'),
                    onPressed: _isCopying ? null : _copyCodeToClipboard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: Icon(Icons.terminal),
                  label: Text('Termux کھولیں'),
                  onPressed: _openTermux,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 10),
            
            // 📝 Result Message
            if (_copyResult.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _copyResult.contains('✅') ? Colors.green[50] : Colors.red[50],
                  border: Border.all(
                    color: _copyResult.contains('✅') ? Colors.green : Colors.red,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_copyResult),
              ),
          ],
        ),
      ),
    );
  }

  // 🌟 Step builder method
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
