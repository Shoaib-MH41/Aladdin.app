import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../services/app_publisher.dart';

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
  final AppPublisher _publisher = AppPublisher();
  Map<String, dynamic>? _publishData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPublishData();
  }

  void _loadPublishData() async {
    final data = await _publisher.prepareForPlayStore(
      appName: widget.appName,
      generatedCode: widget.generatedCode,
      framework: widget.framework,
    );
    
    setState(() {
      _publishData = data;
      _isLoading = false;
    });
  }

  void _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('کاپی ہو گیا!'))
    );
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ویب سائٹ نہیں کھل سکی'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("تیار ہو رہا ہے...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = _publishData!;

    return Scaffold(
      appBar: AppBar(
        title: Text("پلے اسٹور گائیڈ"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // App Info Card
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shop, color: Colors.green, size: 24),
                      SizedBox(width: 10),
                      Text(widget.appName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('فریم ورک: ${widget.framework}'),
                  Text('پیکیج نام: ${data['package_name']}'),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Step-by-Step Guide
          Text('مرحلہ وار گائیڈ:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),

          _buildStep(
            '1. پلے کنسول اکاؤنٹ بنائیں',
            'Google Play Console پر جاکر ڈویلپر اکاؤنٹ بنائیں',
            'https://play.google.com/console',
          ),

          _buildStep(
            '2. ایپ کریٹ کریں',
            'نیا ایپ شامل کریں اور پیکیج نام درج کریں',
            '',
            copyText: data['package_name'],
          ),

          _buildStep(
            '3. پرائیویسی پالیسی شامل کریں',
            'اپنی ویب سائٹ پر پرائیویسی پالیسی اپلوڈ کریں',
            '',
            copyText: data['privacy_policy'],
          ),

          _buildStep(
            '4. APK اپلوڈ کریں',
            'نیچے دیے گئے commands سے APK بنا کر اپلوڈ کریں',
            '',
            copyText: _publisher.getBuildCommands(widget.appName),
          ),

          _buildStep(
            '5. اسٹور لسٹنگ مکمل کریں',
            'ایپ کی تفصیل، اسکرین شاٹس اور آئیکن اپلوڈ کریں',
            '',
          ),

          SizedBox(height: 20),

          // Permissions Section
          Card(
            color: Colors.orange[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('درکار permissions:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  if ((data['permissions'] as List).isEmpty)
                    Text('کوئی خاص permission درکار نہیں'),
                  ...(data['permissions'] as List<String>).map((permission) => 
                    Text('• $permission')
                  ).toList(),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // App Icon Suggestions
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('آئیکن تجاویز:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  ...(data['app_icon'] as List<String>).map((suggestion) => 
                    Text('• $suggestion')
                  ).toList(),
                ],
              ),
            ),
          ),

          SizedBox(height: 30),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.download),
                  label: Text('Commands ڈاؤنلوڈ'),
                  onPressed: () => _copyToClipboard(_publisher.getBuildCommands(widget.appName)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.privacy_tip),
                  label: Text('پالیسی کاپی'),
                  onPressed: () => _copyToClipboard(data['privacy_policy']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String description, String url, {String? copyText}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(number, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(description),
            SizedBox(height: 8),
            Row(
              children: [
                if (url.isNotEmpty)
                  ElevatedButton(
                    onPressed: () => _openUrl(url),
                    child: Text('ویب سائٹ کھولیں'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (copyText != null) ...[
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _copyToClipboard(copyText),
                    child: Text('کاپی کریں'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
