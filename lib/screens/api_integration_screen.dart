import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/api_template_model.dart';
import '../services/gemini_service.dart';

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
  String? _suggestedApiName;
  String? _suggestedApiNote;

  // 🔹 Smart Suggestion System (Gemini) - ChatGPT Version
  Future<void> _fetchApiSuggestion() async {
    setState(() => _isFetchingSuggestion = true);

    try {
      final geminiService = GeminiService();
      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 500));
      
      final suggestion = await geminiService.getApiSuggestion(widget.apiTemplate.category);

      if (suggestion != null && suggestion['url'] != null) {
        setState(() {
          _suggestedApiLink = suggestion['url'];
          _suggestedApiName = suggestion['name'];
          _suggestedApiNote = suggestion['note'];
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ AI نے ${suggestion['name']} تجویز کیا'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI لنک تلاش نہیں کر سکا'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ AI سے معلومات حاصل کرنے میں مسئلہ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isFetchingSuggestion = false);
  }

  // 🔹 Open Main API Website
  void _openApiWebsite() async {
    final url = Uri.parse(widget.apiTemplate.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ویب سائٹ نہیں کھل سکی')),
      );
    }
  }

  // 🔹 Open AI Suggested Link
  void _openSuggestedLink() async {
    if (_suggestedApiLink == null) return;
    final url = Uri.parse(_suggestedApiLink!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لنک نہیں کھل سکا')),
      );
    }
  }

  // 🔹 Submit API Key
  void _submitApiKey() async {
    if (_apiKeyController.text.trim().isEmpty &&
        widget.apiTemplate.keyRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('براہ کرم API key درج کریں')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));

    widget.onApiKeySubmitted?.call(_apiKeyController.text.trim());
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ API key جمع ہو گئی'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("API انٹیگریشن"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'ویب سائٹ کھولیں',
            onPressed: _openApiWebsite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔸 API Info Card
            _buildApiInfoCard(),

            const SizedBox(height: 20),

            // 🔹 AI Suggestion Section
            _buildAiSuggestionCard(),

            const SizedBox(height: 20),

            // 🔸 Instructions
            _buildInstructionsCard(),

            const SizedBox(height: 20),

            // 🔸 API Key Input
            if (widget.apiTemplate.keyRequired) ...[
              const Text('اپنی API Key درج کریں:',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  hintText: 'یہاں اپنی API key پیسٹ کریں...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.vpn_key),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
            ],

            const SizedBox(height: 10),

            // 🔹 Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isSubmitting
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : const Icon(Icons.check_circle_outline),
                onPressed: _isSubmitting ? null : _submitApiKey,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                label: Text(widget.apiTemplate.keyRequired
                    ? 'API Key جمع کروائیں'
                    : 'API انٹیگریشن مکمل کریں'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔸 Build API Info Card
  Widget _buildApiInfoCard() => Card(
        elevation: 4,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.api, color: Colors.blue, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.apiTemplate.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildInfoRow('پرووائیڈر:', widget.apiTemplate.provider),
              _buildInfoRow('زمرہ:', widget.apiTemplate.category),
              _buildInfoRow('Key درکار:',
                  widget.apiTemplate.keyRequired ? 'ہاں' : 'نہیں'),
              _buildInfoRow('مفت ٹائر:', widget.apiTemplate.freeTierInfo),
              const SizedBox(height: 8),
              Text(
                widget.apiTemplate.description,
                style: TextStyle(
                    fontStyle: FontStyle.italic, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );

  // 🔹 Build AI Suggestion Card
  Widget _buildAiSuggestionCard() => Card(
        color: Colors.purple[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.purple),
                  SizedBox(width: 8),
                  Text('🤖 AI کی تجویز:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              _isFetchingSuggestion
                  ? const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('AI سوچ رہا ہے...', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    )
                  : _suggestedApiLink == null
                      ? ElevatedButton.icon(
                          icon: const Icon(Icons.lightbulb_outline),
                          label: const Text("AI سے بہترین API لنک لائیں"),
                          onPressed: _fetchApiSuggestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_suggestedApiName != null) ...[
                              Text(
                                '📌 $_suggestedApiName',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                            InkWell(
                              onTap: _openSuggestedLink,
                              child: Text(
                                _suggestedApiLink!,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            if (_suggestedApiNote != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.purple[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline, size: 16),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _suggestedApiNote!,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              '📎 اسے کھول کر API key حاصل کریں اور نیچے پیسٹ کریں۔',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[700]),
                            ),
                          ],
                        ),
            ],
          ),
        ),
      );

  // 🔹 Instructions Card
  Widget _buildInstructionsCard() => Card(
        color: Colors.blue[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.help_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('📋 ہدایات:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              _buildInstructionStep('1.', 'AI سے یا دستی طور پر لنک کھولیں'),
              _buildInstructionStep('2.', 'اکاؤنٹ بنائیں اور API key حاصل کریں'),
              _buildInstructionStep('3.', 'API key نیچے پیسٹ کریں'),
              _buildInstructionStep('4.', 'جمع کروائیں بٹن پر کلک کریں'),
            ],
          ),
        ),
      );

  Widget _buildInfoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label ',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            Expanded(child: Text(value)),
          ],
        ),
      );

  Widget _buildInstructionStep(String number, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(number, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
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
