
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    _loadSavedApiKey();
  }

  Future<void> _loadSavedApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString('saved_api_key_${widget.apiTemplate.name}');
    if (savedKey != null && savedKey.isNotEmpty) {
      setState(() {
        _apiKeyController.text = savedKey;
        _isApiValid = true;
        _validationMessage = '✅ محفوظ شدہ API key لوڈ ہو گئی';
      });
    }
  }

  Future<bool> _validateApiKey(String apiKey) async {
    setState(() {
      _isValidatingApi = true;
      _validationMessage = 'API key کی جانچ ہو رہی ہے...';
    });

    await Future.delayed(const Duration(seconds: 2));
    bool isValid = apiKey.length >= 10 && apiKey.contains('_');

    setState(() {
      _isApiValid = isValid;
      _validationMessage =
          isValid ? '✅ API key درست ہے' : '❌ API key غلط ہے۔ براہ کرم درست key درج کریں';
      _isValidatingApi = false;
    });
    return isValid;
  }

  Future<void> _fetchApiSuggestion() async {
    setState(() => _isFetchingSuggestion = true);
    try {
      final geminiService = GeminiService();
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

  Future<bool> _validateApi() async {
    if (_apiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ براہ کرم پہلے API key درج کریں'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return await _validateApiKey(_apiKeyController.text.trim());
  }

  void _showSuccessBottomSheet(String message, {bool isError = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isError ? Colors.red[50] : Colors.green[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.red : Colors.green,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isError ? Colors.red[700] : Colors.green[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitApiKey() async {
    if (widget.apiTemplate.keyRequired && _apiKeyController.text.trim().isEmpty) {
      _showSuccessBottomSheet('❌ براہ کرم پہلے API key درج کریں', isError: true);
      return;
    }

    if (widget.apiTemplate.keyRequired && _apiKeyController.text.trim().isNotEmpty && !_isApiValid) {
      bool? shouldValidate = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('API Key کی تصدیق'),
          content: const Text('API key کی تصدیق نہیں ہوئی۔ کیا آپ بغیر تصدیق کے محفوظ کرنا چاہتے ہیں؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('تصدیق کریں'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('محفوظ کریں'),
            ),
          ],
        ),
      );

      if (shouldValidate == false) {
        bool isValid = await _validateApi();
        if (!isValid) return;
      }
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_api_key_${widget.apiTemplate.name}', _apiKeyController.text.trim());

    widget.onApiKeySubmitted?.call(_apiKeyController.text.trim());
    setState(() => _isSubmitting = false);

    _showSuccessBottomSheet(_isApiValid
        ? '✅ API key کامیابی سے محفوظ ہو گئی'
        : '⚠️ API key محفوظ ہو گئی (تصدیق نہیں ہوئی)');
  }

  void _deleteApiKey() async {
    if (_apiKeyController.text.isEmpty) {
      _showSuccessBottomSheet('❌ حذف کرنے کے لیے پہلے API key درج کریں', isError: true);
      return;
    }

    bool? shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Key حذف کریں'),
        content: const Text('کیا آپ واقعی یہ API key حذف کرنا چاہتے ہیں؟'),
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_api_key_${widget.apiTemplate.name}');

      setState(() {
        _apiKeyController.clear();
        _isApiValid = false;
        _validationMessage = '';
      });

      _showSuccessBottomSheet('✅ API key کامیابی سے حذف ہو گئی');
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
          IconButton(icon: const Icon(Icons.open_in_browser), onPressed: _openApiWebsite),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _apiKeyController.text.isNotEmpty ? _deleteApiKey : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'اپنی API Key درج کریں',
                prefixIcon: Icon(Icons.vpn_key),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_validationMessage.isNotEmpty)
              Text(_validationMessage, style: TextStyle(color: _isApiValid ? Colors.green : Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : const Icon(Icons.check_circle_outline),
              onPressed: _isSubmitting ? null : _submitApiKey,
              label: Text(_isApiValid ? 'محفوظ کریں' : 'جمع کروائیں'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isApiValid ? Colors.green : Colors.blue,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
