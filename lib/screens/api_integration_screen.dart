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
  bool _isValidatingApi = false;
  String? _suggestedApiLink;
  String? _suggestedApiName;
  String? _suggestedApiNote;
  String _validationMessage = '';
  bool _isApiValid = false;

  @override
  void initState() {
    super.initState();
    _apiKeyController.addListener(() {
      setState(() {
        _validationMessage = '';
        _isApiValid = false;
      });
    });
  }

  // 🔹 API Key کو validate کرنے کا فنکشن
  Future<bool> _validateApiKey(String apiKey) async {
    setState(() {
      _isValidatingApi = true;
      _validationMessage = 'API key کی جانچ ہو رہی ہے...';
    });

    try {
      // 🔄 یہاں آپ کا actual API validation logic آئے گا
      await Future.delayed(const Duration(seconds: 2));
      
      // ✅ Simulate validation - آپ کو اپنی API کے مطابق بدلنا ہوگا
      bool isValid = apiKey.length >= 10 && apiKey.contains('_');
      
      setState(() {
        _isApiValid = isValid;
        _validationMessage = isValid 
            ? '✅ API key درست ہے' 
            : '❌ API key غلط ہے۔ براہ کرم درست key درج کریں';
      });
      
      return isValid;
    } catch (e) {
      setState(() {
        _validationMessage = '❌ API validation میں مسئلہ: $e';
        _isApiValid = false;
      });
      return false;
    } finally {
      setState(() {
        _isValidatingApi = false;
      });
    }
  }

  // 🔹 Smart Suggestion System (Gemini)
  Future<void> _fetchApiSuggestion() async {
    setState(() => _isFetchingSuggestion = true);
    try {
      final geminiService = GeminiService();
      await Future.delayed(const Duration(milliseconds: 500));

      final suggestion =
          await geminiService.getApiSuggestion(widget.apiTemplate.category);

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

  // 🔹 Open Suggested Link
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

  // 🔹 Validate API Key
  void _validateApi() async {
    if (_apiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ براہ کرم پہلے API key درج کریں'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await _validateApiKey(_apiKeyController.text.trim());
  }

  // 🔹 Submit API Key - مکمل اپگریڈ
  void _submitApiKey() async {
    // ✅ پہلے چیک کریں کہ API key درکار ہے اور خالی تو نہیں
    if (widget.apiTemplate.keyRequired && _apiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ براہ کرم پہلے API key درج کریں'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ اگر API key درکار ہے تو validate کریں
    if (widget.apiTemplate.keyRequired && _apiKeyController.text.trim().isNotEmpty) {
      if (!_isApiValid) {
        bool? shouldValidate = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('API Key کی تصدیق'),
            content: const Text('API key کی تصدیق نہیں ہوئی ہے۔ کیا آپ بغیر تصدیق کے محفوظ کرنا چاہتے ہیں؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('تصدیق کریں'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('بغیر تصدیق کے محفوظ کریں'),
              ),
            ],
          ),
        );

        if (shouldValidate == false) {
          await _validateApi();
          return;
        }
      }
    }

    // ✅ کنفرمیشن ڈائیلاگ
    bool? shouldSave = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Key محفوظ کریں'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('کیا آپ واقعی یہ API key محفوظ کرنا چاہتے ہیں؟'),
            if (_isApiValid) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 6),
                    Text('API key درست ہے', style: TextStyle(color: Colors.green)),
                  ],
                ),
              ),
            ]
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('منسوخ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isApiValid ? Colors.green : Colors.orange,
            ),
            child: Text(_isApiValid ? 'محفوظ کریں' : 'بغیر تصدیق کے محفوظ کریں'),
          ),
        ],
      ),
    );

    if (shouldSave == true) {
      setState(() => _isSubmitting = true);
      await Future.delayed(const Duration(seconds: 1));

      widget.onApiKeySubmitted?.call(_apiKeyController.text.trim());
      setState(() => _isSubmitting = false);

      // ✅ کامیابی کا پیغام
      if (!widget.apiTemplate.keyRequired) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ℹ️ اس API کو key کی ضرورت نہیں تھی، محفوظ کر لیا گیا۔'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isApiValid 
                ? '✅ API key کامیابی سے محفوظ ہو گئی' 
                : '⚠️ API key محفوظ ہو گئی (تصدیق نہیں ہوئی)'),
            backgroundColor: _isApiValid ? Colors.green : Colors.orange,
          ),
        );
      }

      Navigator.pop(context);
    }
  }

  // 🔹 Delete API Key - مکمل اپگریڈ
  void _deleteApiKey() async {
    if (_apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ حذف کرنے کے لیے پہلے API key درج کریں'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool? shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Key حذف کریں'),
        content: const Text('کیا آپ واقعی یہ API key حذف کرنا چاہتے ہیں؟ یہ عمل واپس نہیں ہو سکتا۔'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('منسوخ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف کریں'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() => _isSubmitting = true);
      await Future.delayed(const Duration(seconds: 1));

      _apiKeyController.clear();
      widget.onApiKeySubmitted?.call('');
      setState(() {
        _isSubmitting = false;
        _isApiValid = false;
        _validationMessage = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ API key کامیابی سے حذف ہو گئی'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'API Key حذف کریں',
            onPressed: _apiKeyController.text.isNotEmpty ? _deleteApiKey : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildApiInfoCard(),
            const SizedBox(height: 20),
            _buildAiSuggestionCard(),
            const SizedBox(height: 20),
            _buildInstructionsCard(),
            const SizedBox(height: 20),

            if (widget.apiTemplate.keyRequired) ...[
              const Text(
                'اپنی API Key درج کریں:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              // API Key Input with Validation
              TextField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  hintText: 'یہاں اپنی API key پیسٹ کریں...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.vpn_key),
                  suffixIcon: _apiKeyController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(_isApiValid ? Icons.check_circle : Icons.error),
                          color: _isApiValid ? Colors.green : Colors.orange,
                          onPressed: _validateApi,
                        )
                      : null,
                ),
                obscureText: true,
              ),
              
              // Validation Message
              if (_validationMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isApiValid ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isApiValid ? Colors.green : Colors.orange,
                    ),
                  ),
                  child: Row(
                    children: [
                      _isValidatingApi
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _isApiValid ? Icons.check_circle : Icons.warning,
                              color: _isApiValid ? Colors.green : Colors.orange,
                              size: 16,
                            ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _validationMessage,
                          style: TextStyle(
                            color: _isApiValid ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Validate Button
              if (_apiKeyController.text.isNotEmpty && !_isValidatingApi)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.verified_user),
                    label: const Text('API Key کی تصدیق کریں'),
                    onPressed: _validateApi,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              
              const SizedBox(height: 10),
            ],

            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isSubmitting
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : const Icon(Icons.check_circle_outline),
                onPressed: _isSubmitting ? null : _submitApiKey,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isApiValid ? Colors.green : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                label: Text(
                  widget.apiTemplate.keyRequired
                      ? (_isApiValid ? 'API Key محفوظ کریں' : 'API Key جمع کروائیں')
                      : 'API انٹیگریشن مکمل کریں',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔸 Build Cards (info, suggestion, instructions)
  Widget _buildApiInfoCard() => Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              _buildInfoRow(
                  'Key درکار:', widget.apiTemplate.keyRequired ? 'ہاں' : 'نہیں'),
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              _buildInstructionStep('1.', 'AI سے یا دستی طور پر لنک کھولیں'),
              _buildInstructionStep('2.', 'اکاؤنٹ بنائیں اور API key حاصل کریں'),
              _buildInstructionStep('3.', 'API key نیچے پیسٹ کریں'),
              _buildInstructionStep('4.', 'API key کی تصدیق کریں (اختیاری)'),
              _buildInstructionStep('5.', 'جمع کروائیں بٹن پر کلک کریں'),
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
