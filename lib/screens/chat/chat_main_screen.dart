// lib/screens/chat/chat_main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ Clipboard کے لیے ضروری
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';

import '../../models/project_model.dart';
import '../../models/chat_model.dart';
import '../../models/api_template_model.dart';
import '../../models/ad_model.dart';

import '../../services/github_service.dart';
import '../../services/gemini_service.dart';
import '../../services/ai_api_finder.dart';

import '../../screens/api_integration_screen.dart';
import '../../screens/api_discovery_screen.dart';

// فائل مینیجر ایمپورٹ
import 'chat_file_manager.dart';
import 'chat_ad_manager.dart';

class ChatMainScreen extends StatefulWidget {
  final GeminiService geminiService;
  final GitHubService githubService;
  final Project project;

  const ChatMainScreen({
    super.key,
    required this.geminiService,
    required this.githubService,
    required this.project,
  });

  @override
  State<ChatMainScreen> createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isAIThinking = false;
  late AIApiFinder aiApiFinder;
  
  bool _isConnected = false;
  String _connectionMessage = "⚠️ اپنا کنکشن جوڑیں";

  @override
  void initState() {
    super.initState();
    aiApiFinder = AIApiFinder(geminiService: widget.geminiService);
    _checkConnection();
  }

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
آپ ایک ${widget.project.framework} expert ہیں۔ مکمل، چلنے کے قابل کوڈ بنائیں۔

ضروریات:
$text

ٹیکنیکل تفصیلات:
- فریم ورک: ${widget.project.framework}
- پلیٹ فارمز: ${widget.project.platforms.join(', ')}
- ضروری assets: ${widget.project.assets.keys.join(', ')}

ہدایات:
1. صرف کوڈ لوٹائیں، وضاحت نہیں
2. تمام necessary imports شامل کریں
3. مکمل working app ہو
4. کوئی syntax errors نہ ہوں

صرف کوڈ لوٹائیں:
""";

      final String generatedCode = await widget.geminiService.generateCode(
        prompt: smartPrompt,
        framework: widget.project.framework,
        platforms: widget.project.platforms,
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

      if (_isValidCode(generatedCode, widget.project.framework)) {
        final repoName = '${widget.project.name}_${DateTime.now().millisecondsSinceEpoch}';
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
        'projectName': widget.project.name,
        'framework': widget.project.framework,
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
اس ${widget.project.framework} کوڈ میں ممکنہ مسائل ڈھونڈیں اور بہتر بنائیں:

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
        framework: widget.project.framework,
        platforms: widget.project.platforms,
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
        appDescription: appDescription.isNotEmpty ? appDescription : widget.project.name,
        framework: widget.project.framework,
        appName: widget.project.name,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ApiDiscoveryScreen(
            discoveredApis: discoveredApis,
            projectName: widget.project.name,
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
                              language: widget.project.framework.toLowerCase(),
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

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ متن کاپی ہو گیا!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileManager = ChatFileManager(
      geminiService: widget.geminiService,
      project: widget.project,
      onFileUploaded: (String fileName, String? content) {
        String prompt = """
میں نے ایک فائل اپ لوڈ کی ہے۔ براہ کرم اس کے مطابق کوڈ بنائیں۔

فائل کا نام: $fileName
${content != null ? "فائل کا مواد: $content" : "فائل اپ لوڈ ہو گئی ہے۔"}

فریم ورک: ${widget.project.framework}
پلیٹ فارمز: ${widget.project.platforms.join(', ')}
""";
        _controller.text = prompt;
      },
    );

    final adManager = ChatAdManager(
      geminiService: widget.geminiService,
      project: widget.project,
      onCampaignCreated: (AdCampaign campaign) {
        // اشتہار مہم پروجیکٹ میں محفوظ کریں
        widget.project.addAdCampaign(campaign);
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("AI اسسٹنٹ - ${widget.project.name}"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
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
                      "فریم ورک: ${widget.project.framework} | پلیٹ فارم: ${widget.project.platforms.join(', ')}",
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
          
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: fileManager.buildFileUploadButtons(context),
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
