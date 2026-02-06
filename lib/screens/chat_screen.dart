import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/ad_model.dart'; // ✅ یہ لازمی ہے
import '../models/project_model.dart';
import '../models/chat_model.dart';
import '../models/api_template_model.dart';

import '../services/github_service.dart';
import '../services/gemini_service.dart';
import '../services/ai_api_finder.dart';
import '../screens/api_integration_screen.dart';
import '../screens/api_discovery_screen.dart';
import '../screens/ads_screen.dart'; // ✅ نیا امپورٹ - اشتہار اسکرین

class ChatScreen extends StatefulWidget {
  final GeminiService geminiService;
  final GitHubService githubService;

  const ChatScreen({
    super.key,
    required this.geminiService,
    required this.githubService,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isAIThinking = false;
  late Project _project;
  late AIApiFinder aiApiFinder;
  
  // ✅ نیا: فائل اپ لوڈ ویری ایبلز
  File? _selectedFile;
  String? _fileName;
  String? _fileContent;
  bool _isUploadingFile = false;
  
  // ✅ نیا: کاپی/پیسٹ ویری ایبلز
  bool _hasCopiedText = false;
  String? _copiedText;
  
  // ✅ نیا: اشتہار ویری ایبلز
  bool _showAdsPanel = false;
  double _adBudget = 100.0;
  String _adText = "میرے ایپ کو آزمائیں!";
  
  // ✅ کنکشن چیک ویری ایبلز
  bool _isConnected = false;
  String _connectionMessage = "⚠️ اپنا کنکشن جوڑیں";

  @override
  void initState() {
    super.initState();
    aiApiFinder = AIApiFinder(geminiService: widget.geminiService);
    _checkConnection();
  }

  // ✅ کنکشن چیک کرنے والا فنکشن
  Future<void> _checkConnection() async {
    try {
      await widget.geminiService.testConnection();
      setState(() {
        _isConnected = true;
        _connectionMessage = "✅ کنکشن کامیاب ہے";
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _connectionMessage = "⚠️ اپنا کنکشن جوڑیں";
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _project = ModalRoute.of(context)!.settings.arguments as Project;
  }

  // ✅ نیا: فائل منتخب کرنے کا فنکشن
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'txt'],
      allowMultiple: false,
    );
    
    if (result != null) {
      setState(() {
        _isUploadingFile = true;
      });
      
      try {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
        
        // فائل کا مواد پڑھیں (صرف txt فائلوں کے لیے)
        if (_fileName!.toLowerCase().endsWith('.txt')) {
          _fileContent = await _selectedFile!.readAsString();
        } else {
          _fileContent = "فائل اپ لوڈ ہو گئی: $_fileName";
        }
        
        // AI کو فائل کی معلومات بھیجیں
        _sendFileToAI();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ فائل اپ لوڈ ہو گئی: $_fileName'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ فائل اپ لوڈ ناکام: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isUploadingFile = false;
        });
      }
    }
  }

  // ✅ نیا: تصویر/اسکرین شاٹ منتخب کرنے کا فنکشن
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _isUploadingFile = true;
      });
      
      try {
        _selectedFile = File(pickedFile.path);
        _fileName = pickedFile.name;
        _fileContent = "اسکرین شاٹ اپ لوڈ ہو گئی: $_fileName";
        
        // AI کو تصویر کی معلومات بھیجیں
        _sendImageToAI();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ اسکرین شاٹ اپ لوڈ ہو گئی: $_fileName'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ تصویر اپ لوڈ ناکام: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isUploadingFile = false;
        });
      }
    }
  }

  // ✅ نیا: AI کو فائل کی معلومات بھیجنے کا فنکشن
  void _sendFileToAI() {
    if (_fileContent == null) return;
    
    String prompt = """
میں نے ایک فائل اپ لوڈ کی ہے۔ براہ کرم اس کے مطابق کوڈ بنائیں۔

فائل کا نام: $_fileName
فائل کا مواد: $_fileContent

فریم ورک: ${_project.framework}
پلیٹ فارمز: ${_project.platforms.join(', ')}
""";

    _controller.text = prompt;
    _sendMessage(prompt);
  }

  // ✅ نیا: AI کو تصویر کی معلومات بھیجنے کا فنکشن
  void _sendImageToAI() {
    String prompt = """
میں نے ایک اسکرین شاٹ اپ لوڈ کی ہے۔ براہ کرم اس کے مطابق UI کوڈ بنائیں۔

تصویر کا نام: $_fileName
تصویر کی تفصیل: یہ ایک UI اسکرین شاٹ ہے۔

فریم ورک: ${_project.framework}
پلیٹ فارمز: ${_project.platforms.join(', ')}
""";

    _controller.text = prompt;
    _sendMessage(prompt);
  }

  // ✅ نیا: متن کاپی کرنے کا فنکشن
  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() {
      _hasCopiedText = true;
      _copiedText = text;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ متن کاپی ہو گیا!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    
    // 3 سیکنڈ بعد ری سیٹ کریں
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _hasCopiedText = false;
        });
      }
    });
  }

  // ✅ نیا: کاپی شدہ متن پیسٹ کرنے کا فنکشن
  void _pasteText() {
    if (_copiedText != null && _copiedText!.isNotEmpty) {
      _controller.text = _copiedText!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ متن پیسٹ ہو گیا!'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ کاپی کرنے کے لیے پہلے کوئی متن کاپی کریں'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

void _startAdCampaign() async {
  // ادائیگی کی آئی ڈی بنائیں
  final String paymentId = 'pay_${DateTime.now().millisecondsSinceEpoch}';
  
  // نئی اشتہار مہم بنائیں
  final newCampaign = AdCampaign(
    id: 'campaign_${DateTime.now().millisecondsSinceEpoch}',
    projectId: _project.id,
    projectName: _project.name,
    name: '${_project.name} لانچ مہم',
    description: '${_project.name} ایپ کی مارکیٹنگ مہم',
    type: AdCampaignType.socialMedia,
    dailyBudget: _adBudget,
    totalBudget: _adBudget * 10,
    adText: _adText,
    targetAudience: '18-45 سال کے صارفین',
    keywords: [_project.name, 'ایپ', 'مفت', 'لانچ'],
    platforms: ['Facebook', 'Instagram', 'Google'],
    startDate: DateTime.now(),
    endDate: DateTime.now().add(Duration(days: 30)),
    status: AdCampaignStatus.draft,
    paymentMethod: PaymentMethod.creditCard,
    paymentId: paymentId,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    metrics: {
      'impressions': 0,
      'clicks': 0,
      'totalSpent': 0.0,
      'conversions': 0,
    },
    settings: {
      'autoOptimize': true,
      'dailyLimit': _adBudget,
      'targeting': {
        'age': '18-45',
        'gender': 'all',
        'interests': ['technology', 'mobile apps'],
      },
    },
  );

  // AdsScreen پر جائیں
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AdsScreen(
        projectName: _project.name,
        initialBudget: _adBudget,
        initialAdText: _adText,
        initialCampaign: newCampaign,
      ),
    ),
  );

  // نتیجہ پروسیس کریں
  if (result != null && result is Map) {
    setState(() {
      _adBudget = result['budget'] ?? _adBudget;
      _adText = result['adText'] ?? _adText;
    });

    // ادائیگی کی معلومات بنائیں
    final paymentInfo = PaymentInfo(
      id: paymentId,
      campaignId: newCampaign.id,
      method: PaymentMethod.creditCard,
      amount: result['budget'] ?? _adBudget,
      transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      paymentDate: DateTime.now(),
      status: 'completed',
      details: {
        'project': _project.name,
        'userEmail': 'user@example.com',
      },
    );

 // اشتہار مہم کو اپ ڈیٹ کریں
newCampaign.updateStatus(AdCampaignStatus.active);
newCampaign.updateBudget(_adBudget);

try {
  // ✅ نیا: اشتہار مہم پروجیکٹ میں محفوظ کریں
  _saveCampaignToProject(newCampaign);
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('✅ اشتہار مہم کامیابی سے شروع ہو گئی!'),
          SizedBox(height: 4),
          Text(
            'روزانہ بجٹ: \$$_adBudget',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: 'دیکھیں',
            onPressed: () {
              _showCampaignDetails(newCampaign);
            },
          ),
        ),
      );

      // AI سے اشتہار بہتر بنانے کی تجویز
      _suggestAdOptimization(newCampaign);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ اشتہار مہم محفوظ ہوئی لیکن API کنکشن ناکام: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}


// ✅ اشتہار مہم کی تفصیل دکھانے کا طریقہ
void _showCampaignDetails(AdCampaign campaign) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('اشتہار مہم کی تفصیل'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.campaign, color: campaign.statusColor),
                title: Text(campaign.name),
                subtitle: Text('ID: ${campaign.id}'),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.attach_money),
                title: Text('روزانہ بجٹ'),
                trailing: Text('\$${campaign.dailyBudget}'),
              ),
              ListTile(
                leading: Icon(Icons.text_fields),
                title: Text('اشتہاری متن'),
                subtitle: Text(campaign.adText),
              ),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('تاریخ'),
                subtitle: Text('${campaign.startDate.day}/${campaign.startDate.month}/${campaign.startDate.year}'),
              ),
              ListTile(
                leading: Icon(Icons.bar_chart),
                title: Text('حیثیت'),
                trailing: Chip(
                  label: Text(campaign.statusText),
                  backgroundColor: campaign.statusColor,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('بند کریں'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // اشتہار مہم اپ ڈیٹ اسکرین پر جائیں
            },
            child: Text('ترمیم کریں'),
          ),
        ],
      );
    },
  );
}

// ✅ AI سے اشتہار بہتر بنانے کی تجویز
void _suggestAdOptimization(AdCampaign campaign) async {
  try {
    String optimizationPrompt = """
میں نے ایک اشتہار مہم بنائی ہے۔ براہ کرم اسے بہتر بنانے کی تجاویز دیں۔

اشتہار مہم کی تفصیل:
- نام: ${campaign.name}
- ایپ: ${campaign.projectName}
- اشتہاری متن: ${campaign.adText}
- بجٹ: \$${campaign.dailyBudget} روزانہ
- ہدف سامعین: ${campaign.targetAudience}

براہ کرم مجھے 3 تجاویز دیں:
1. اشتہاری متن کو بہتر بنانے کے لیے
2. بجٹ کو بہترین طریقے سے استعمال کرنے کے لیے
3. ہدف سامعین تک بہتر پہنچنے کے لیے

مختصر اور عملی تجاویز دیں۔
""";

    final String aiSuggestions = await widget.geminiService.generateCode(
      prompt: optimizationPrompt,
      framework: 'marketing',
      platforms: ['all'],
    );

    // تجاویز صارف کو دکھائیں
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('🤖 AI کی تجاویز'),
          content: SingleChildScrollView(
            child: Text(aiSuggestions),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ٹھیک ہے'),
            ),
          ],
        );
      },
    );
  } catch (e) {
    // AI تجاویز ناکام ہونے پر کچھ نہ کریں
    print('AI suggestions failed: $e');
  }
}

  // ✅ نیا: اشتہار پینل ٹوگل کرنے کا فنکشن
  void _toggleAdsPanel() {
    setState(() {
      _showAdsPanel = !_showAdsPanel;
    });
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: "user",
      text: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isAIThinking = true;
    });
    _controller.clear();

    try {
      String smartPrompt = """
آپ ایک ${_project.framework} expert ہیں۔ مکمل، چلنے کے قابل کوڈ بنائیں۔

ضروریات:
$text

ٹیکنیکل تفصیلات:
- فریم ورک: ${_project.framework}
- پلیٹ فارمز: ${_project.platforms.join(', ')}
- ضروری assets: ${_project.assets.keys.join(', ')}

ہدایات:
1. صرف کوڈ لوٹائیں، وضاحت نہیں
2. تمام necessary imports شامل کریں
3. مکمل working app ہو
4. کوئی syntax errors نہ ہوں

صرف کوڈ لوٹائیں:
""";

      final String generatedCode = await widget.geminiService.generateCode(
        prompt: smartPrompt,
        framework: _project.framework,
        platforms: _project.platforms,
      );

      final aiMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: generatedCode,
        timestamp: DateTime.now(),
        isCode: true,
      );

      setState(() {
        _messages.add(aiMsg);
        _isAIThinking = false;
      });

      if (_isValidCode(generatedCode, _project.framework)) {
        final repoName = '${_project.name}_${DateTime.now().millisecondsSinceEpoch}';
        await widget.githubService.createRepository(repoName);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ کوڈ GitHub پر محفوظ ہو گیا!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: "❌ خرابی: $e\n\nبراہ کرم دوبارہ کوشش کریں یا مسئلہ واضح کریں۔",
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(errorMsg);
        _isAIThinking = false;
      });
    }
  }

  bool _isValidCode(String code, String framework) {
    switch (framework.toLowerCase()) {
      case 'flutter':
        return code.contains('import') && code.contains('void main');
      case 'react':
        return code.contains('import') && (code.contains('function') || code.contains('const'));
      case 'vue':
        return code.contains('<template>') && code.contains('<script>');
      case 'android native':
        return code.contains('package') && code.contains('class');
      case 'html':
        return code.contains('<!DOCTYPE') || code.contains('<html>');
      default:
        return code.isNotEmpty && code.length > 10;
    }
  }

  void _viewGeneratedCode() {
    if (_messages.isEmpty) return;

    final lastAIMessage = _messages.lastWhere(
      (msg) => msg.sender == "ai" && msg.isCode,
      orElse: () => ChatMessage(
        id: '0',
        sender: 'ai',
        text: '// ابھی تک کوئی کوڈ جنریٹ نہیں ہوا\n// براہ کرم پہلے ایپ کی تفصیل لکھیں',
        timestamp: DateTime.now(),
        isCode: true,
      ),
    );

    Navigator.pushNamed(
      context,
      '/build',
      arguments: {
        'code': lastAIMessage.text,
        'projectName': _project.name,
        'framework': _project.framework,
      },
    );
  }

  void _debugCurrentCode() async {
    if (_messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ پہلے کوڈ جنریٹ کریں'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final lastAIMessage = _messages.lastWhere(
        (msg) => msg.sender == "ai" && msg.isCode,
      );

      if (lastAIMessage.text.trim().isEmpty || lastAIMessage.text.startsWith('// ابھی تک')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ پہلے کوڈ جنریٹ کریں'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      setState(() => _isAIThinking = true);

      final debugPrompt = """
اس ${_project.framework} کوڈ میں ممکنہ مسائل ڈھونڈیں اور بہتر بنائیں:

کوڈ:
${lastAIMessage.text}

ہدایات:
1. ممکنہ syntax errors درست کریں
2. performance بہتر بنائیں  
3. best practices استعمال کریں
4. صرف درست شدہ کوڈ لوٹائیں
""";

      final debuggedCode = await widget.geminiService.generateCode(
        prompt: debugPrompt,
        framework: _project.framework,
        platforms: _project.platforms,
      );

      final debugMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: debuggedCode,
        timestamp: DateTime.now(),
        isCode: true,
      );

      setState(() {
        _messages.add(debugMsg);
        _isAIThinking = false;
      });
    } catch (e) {
      setState(() => _isAIThinking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ڈیبگ ناکام: $e')),
      );
    }
  }

  void _discoverApisWithAI() async {
    if (_isAIThinking) return;

    setState(() => _isAIThinking = true);

    try {
      String appDescription = '';
      if (_messages.isNotEmpty) {
        final userMessages = _messages.where((msg) => msg.sender == "user");
        if (userMessages.isNotEmpty) {
          appDescription = userMessages.last.text;
        }
      }

      final List<ApiTemplate> discoveredApis = await aiApiFinder.findRelevantApis(
        appDescription: appDescription.isNotEmpty ? appDescription : _project.name,
        framework: _project.framework,
        appName: _project.name,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ApiDiscoveryScreen(
            discoveredApis: discoveredApis,
            projectName: _project.name,
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API ڈسکوری ناکام: $e')),
      );
    } finally {
      setState(() => _isAIThinking = false);
    }
  }

  void _startApiIntegration(ApiTemplate apiTemplate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApiIntegrationScreen(
          apiTemplate: apiTemplate,
          onApiKeySubmitted: (apiKey) {
            _handleApiKeySubmission(apiTemplate, apiKey);
          },
        ),
      ),
    );
  }

  void _handleApiKeySubmission(ApiTemplate apiTemplate, String apiKey) {
    String prompt = """
میں نے ${apiTemplate.name} کی API key جمع کرا دی ہے۔
براہ کرم ${apiTemplate.provider} API کے ساتھ مکمل کوڈ بنائیں۔

API Key: $apiKey
API URL: ${apiTemplate.url}

ہدایات:
1. مکمل functional app بنائیں
2. API integration شامل کریں
3. Error handling شامل کریں
4. صرف کوڈ لوٹائیں
""";

    _sendMessage(prompt);
  }

  // ✅ نیا: میسج بلب میں کاپی کا آپشن شامل کریں
  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.sender == "user";

    return GestureDetector(
      onLongPress: () {
        if (msg.text.isNotEmpty && !msg.isCode) {
          _showCopyOptions(context, msg.text);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser)
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue,
                child: Icon(Icons.auto_awesome, size: 16, color: Colors.white),
              ),
            SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUser ? Colors.blue.shade100 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: msg.isCode
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.code, size: 16),
                                  SizedBox(width: 4),
                                  Text('کوڈ', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              // ✅ نیا: کوڈ کاپی کا آپشن
                              IconButton(
                                icon: Icon(Icons.content_copy, size: 16),
                                onPressed: () => _copyText(msg.text),
                                tooltip: 'کوڈ کاپی کریں',
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: HighlightView(
                              msg.text,
                              language: _project.framework.toLowerCase(),
                              theme: githubTheme,
                              padding: EdgeInsets.all(8),
                              textStyle: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(msg.text, style: TextStyle(fontSize: 14)),
                          // ✅ نیا: کاپی کا چھوٹا بٹن
                          if (msg.text.length > 20)
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(Icons.content_copy, size: 14),
                                onPressed: () => _copyText(msg.text),
                                tooltip: 'متن کاپی کریں',
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            if (isUser)
              SizedBox(width: 8),
            if (isUser)
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.green,
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  // ✅ نیا: کاپی آپشنز مینو
  void _showCopyOptions(BuildContext context, String text) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.content_copy),
                title: Text('متن کاپی کریں'),
                onTap: () {
                  _copyText(text);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.paste),
                title: Text('یہاں پیسٹ کریں'),
                onTap: () {
                  _controller.text = text;
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ نیا: فائل اپ لوڈ بٹنز والا ویجٹ
  Widget _buildFileUploadButtons() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // فائل اپ لوڈ بٹن
          IconButton(
            icon: _isUploadingFile 
                ? CircularProgressIndicator(strokeWidth: 2)
                : Icon(Icons.attach_file, size: 22),
            onPressed: _isUploadingFile ? null : _pickFile,
            tooltip: 'فائل اپ لوڈ کریں',
            color: Colors.blue,
          ),
          
          // تصویر اپ لوڈ بٹن
          IconButton(
            icon: Icon(Icons.image, size: 22),
            onPressed: _isUploadingFile ? null : _pickImage,
            tooltip: 'اسکرین شاٹ اپ لوڈ کریں',
            color: Colors.green,
          ),
          
          // ✅ کاپی/پیسٹ بٹنز
          if (_hasCopiedText)
            IconButton(
              icon: Icon(Icons.check, size: 18),
              onPressed: null,
              tooltip: 'متن کاپی ہو گیا',
              color: Colors.green,
            ),
          
          IconButton(
            icon: Icon(Icons.content_copy, size: 20),
            onPressed: _copiedText == null ? null : () => _copyText(_copiedText!),
            tooltip: 'کاپی شدہ متن دوبارہ کاپی کریں',
            color: _copiedText == null ? Colors.grey : Colors.blue,
          ),
          
          IconButton(
            icon: Icon(Icons.paste, size: 20),
            onPressed: _pasteText,
            tooltip: 'کاپی شدہ متن پیسٹ کریں',
            color: Colors.purple,
          ),
          
          // اشتہار مہم بٹن
          IconButton(
            icon: Icon(Icons.ads_click, size: 22),
            onPressed: _startAdCampaign,
            tooltip: 'اشتہار مہم شروع کریں',
            color: Colors.orange,
          ),
          
          // اگر فائل منتخب ہو تو نام دکھائیں
          if (_fileName != null && _fileName!.length < 15)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _fileName!,
                style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ نیا: اشتہار پینل ویجٹ
  Widget _buildAdsPanel() {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📢 اشتہار مہم',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 18),
                onPressed: _toggleAdsPanel,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('بجٹ: \$$_adBudget'),
          SizedBox(height: 4),
          Text('اشتہاری متن: "$_adText"'),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: _startAdCampaign,
            child: Text('اشتہار مہم شروع کریں'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI اسسٹنٹ - ${_project.name}"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // ✅ نیا: اشتہار پینل ٹوگل بٹن
          IconButton(
            icon: Icon(_showAdsPanel ? Icons.close : Icons.ads_click),
            tooltip: _showAdsPanel ? 'اشتہار پینل چھپائیں' : 'اشتہار پینل دکھائیں',
            onPressed: _toggleAdsPanel,
          ),
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'AI سے APIs ڈھونڈیں',
            onPressed: _isAIThinking ? null : _discoverApisWithAI,
          ),
          IconButton(
            icon: Icon(Icons.code),
            tooltip: 'جنریٹڈ کوڈ دیکھیں',
            onPressed: _isAIThinking ? null : _viewGeneratedCode,
          ),
          IconButton(
            icon: Icon(Icons.bug_report),
            tooltip: 'کوڈ ڈیبگ کریں',
            onPressed: _isAIThinking ? null : _debugCurrentCode,
          ),
          IconButton(
            icon: Icon(Icons.api),
            tooltip: 'API انٹیگریشن',
            onPressed: _isAIThinking
                ? null
                : () {
                    _startApiIntegration(
                      ApiTemplate(
                        id: 'sample_${DateTime.now().millisecondsSinceEpoch}',
                        name: 'Google Gemini AI',
                        provider: 'Google',
                        url: 'https://makersuite.google.com/app/apikey',
                        description: 'مفت Gemini AI API key حاصل کریں',
                        keyRequired: true,
                        freeTierInfo: 'روزانہ 60 requests مفت',
                        category: 'AI',
                      ),
                    );
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          // فریم ورک + کنکشن اسٹیٹس
          Container(
            padding: EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Text(
                      "فریم ورک: ${_project.framework} | پلیٹ فارم: ${_project.platforms.join(', ')}",
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.check_circle : Icons.warning,
                      color: _isConnected ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      _connectionMessage,
                      style: TextStyle(
                        fontSize: 12,
                        color: _isConnected ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ✅ اشتہار پینل
          if (_showAdsPanel) _buildAdsPanel(),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          if (_isAIThinking)
            Container(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: 16),
                  Text(
                    "AI کوڈ جنریٹ کر رہا ہے...",
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          // ✅ نیا: فائل اپ لوڈ بٹنز بار
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: _buildFileUploadButtons(),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "اپنی ایپ کی تفصیل لکھیں... مثال: 'ٹوڈو ایپ بنائیں'",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: _sendMessage,
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _isAIThinking ? null : () => _sendMessage(_controller.text),
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
