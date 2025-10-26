import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/api_template_model.dart';
import '../services/gemini_service.dart'; // 👈 نیا امپورٹ (AI helper)

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
  bool _isFetchingSuggestion = false;
  String? _suggestedApiLink;

  // 🔹 Smart Suggestion System (Gemini)
  Future<void> _fetchApiSuggestion() async {
    setState(() => _isFetchingSuggestion = true);

    try {
      final suggestion = await GeminiService().getApiSuggestion(widget.apiTemplate.category);

      if (suggestion != null && suggestion['url'] != null) {
        setState(() {
          _suggestedApiLink = suggestion['url'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI لنک تلاش نہیں کر سکا')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ AI سے معلومات حاصل کرنے میں مسئلہ آیا')),
      );
    }

    setState(() => _isFetchingSuggestion = false);
  }

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

  void _openSuggestedLink() async {
    if (_suggestedApiLink == null) return;
    final url = Uri.parse(_suggestedApiLink!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لنک نہیں کھل سکا')),
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
    await Future.delayed(Duration(seconds: 1));

    widget.onApiKeySubmitted?.call(_apiKeyController.text.trim());

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
            // 🔸 API معلومات کارڈ
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

            // 🔹 AI Suggestion سیکشن
            Card(
              color: Colors.purple[50],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🤖 AI کی تجویز:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    _isFetchingSuggestion
                        ? Center(child: CircularProgressIndicator())
                        : _suggestedApiLink == null
                            ? ElevatedButton.icon(
                                icon: Icon(Icons.lightbulb),
                                label: Text("AI سے بہترین API لنک لائیں"),
                                onPressed: _fetchApiSuggestion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('AI نے مندرجہ ذیل API تجویز کی ہے:'),
                                  SizedBox(height: 6),
                                  InkWell(
                                    onTap: _openSuggestedLink,
                                    child: Text(
                                      _suggestedApiLink!,
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '📎 اسے کھول کر API key حاصل کریں اور نیچے پیسٹ کریں۔',
                                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // 🔸 ہدایات کارڈ
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📋 ہدایات:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    _buildInstructionStep('1.', 'AI سے یا دستی طور پر لنک کھولیں'),
                    _buildInstructionStep('2.', 'اکاؤنٹ بنائیں اور API key حاصل کریں'),
                    _buildInstructionStep('3.', 'API key نیچے پیسٹ کریں'),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // 🔸 API Key Input
            if (widget.apiTemplate.keyRequired) ...[
              Text('اپنی API Key درج کریں:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  hintText: 'یہاں اپنی API key پیسٹ کریں...',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 10),
            ],

            Spacer(),

            // 🔹 Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitApiKey,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(widget.apiTemplate.keyRequired
                        ? 'API Key جمع کروائیں'
                        : 'API انٹیگریشن مکمل کریں'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) => Padding(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label ', style: TextStyle(fontWeight: FontWeight.w500)),
            Expanded(child: Text(value)),
          ],
        ),
      );

  Widget _buildInstructionStep(String number, String text) => Padding(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text(number, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      );

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
