import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/api_template_model.dart';

class ApiIntegrationScreen extends StatefulWidget {
  final ApiTemplate apiTemplate;
  final Function(String)? onApiKeySubmitted;

  const ApiIntegrationScreen({
    super.key,
    required this.apiTemplate,
    this.onApiKeySubmitted,
  });

  @override
  State<ApiIntegrationScreen> createState() => _ApiIntegrationScreenState();
}

class _ApiIntegrationScreenState extends State<ApiIntegrationScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isSubmitting = false;

  void _openApiWebsite() async {
    final url = Uri.parse(widget.apiTemplate.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ویب سائٹ نہیں کھل سکی')),
      );
    }
  }

  void _submitApiKey() async {
    if (_apiKeyController.text.trim().isEmpty && widget.apiTemplate.keyRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('براہ کرم API key درج کریں')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // API key کو process کریں
    await Future.delayed(Duration(seconds: 1));

    if (widget.onApiKeySubmitted != null) {
      widget.onApiKeySubmitted!(_apiKeyController.text.trim());
    }

    setState(() => _isSubmitting = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ API key جمع ہو گئی')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("API انٹیگریشن"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API کی معلومات
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.api, color: Colors.blue, size: 24),
                        SizedBox(width: 10),
                        Text(
                          widget.apiTemplate.name,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    _buildInfoRow('پرووائیڈر:', widget.apiTemplate.provider),
                    _buildInfoRow('زمرہ:', widget.apiTemplate.category),
                    _buildInfoRow('Key درکار:', widget.apiTemplate.keyRequired ? 'ہاں' : 'نہیں'),
                    _buildInfoRow('مفت ٹائر:', widget.apiTemplate.freeTierInfo),
                    SizedBox(height: 8),
                    Text(
                      widget.apiTemplate.description,
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // ہدایات
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 ہدایات:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    _buildInstructionStep('1.', 'نیچے "API ویب سائٹ کھولیں" بٹن پر کلک کریں'),
                    _buildInstructionStep('2.', 'مفت account بنائیں (اگر required ہو)'),
                    _buildInstructionStep('3.', 'API key حاصل کریں'),
                    _buildInstructionStep('4.', 'API key کو کاپی کریں'),
                    _buildInstructionStep('5.', 'نیچے والے باکس میں پیسٹ کریں'),
                    if (!widget.apiTemplate.keyRequired)
                      _buildInstructionStep('6.', 'اس API کے لیے key درکار نہیں ہے'),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // API ویب سائٹ بٹن
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.open_in_new),
                label: Text("API ویب سائٹ کھولیں"),
                onPressed: _openApiWebsite,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            SizedBox(height: 20),

            // API Key انپٹ (صرف اگر required ہو)
            if (widget.apiTemplate.keyRequired) ...[
              Text(
                'اپنی API Key درج کریں:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  hintText: 'یہاں اپنی API key پیسٹ کریں...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                obscureText: true,
                maxLines: 1,
              ),
              SizedBox(height: 10),
              Text(
                'نوٹ: آپ کی API key محفوظ رہے گی اور صرف آپ کی بننے والی ایپ میں استعمال ہوگی',
                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],

            Spacer(),

            // جمع کروائیں بٹن
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitApiKey,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.apiTemplate.keyRequired ? 
                        'API Key جمع کروائیں' : 'API انٹیگریشن مکمل کریں',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
