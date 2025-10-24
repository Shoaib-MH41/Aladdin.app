import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import '../models/project_model.dart';
import '../models/chat_model.dart';
import '../services/github_service.dart';
import '../services/gemini_service.dart';

// API ٹیمپلیٹ ماڈل
class ApiTemplate {
  final String name;
  final String provider;
  final String url;

  ApiTemplate({required this.name, required this.provider, required this.url});
}

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _project = ModalRoute.of(context)!.settings.arguments as Project;
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
        final repoUrl = await widget.githubService.createRepository(repoName, generatedCode);

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
    if (_messages.isEmpty) return;

    try {
      final lastAIMessage = _messages.lastWhere(
        (msg) => msg.sender == "ai" && msg.isCode,
      );

      if (lastAIMessage.text.trim().isEmpty || lastAIMessage.text.startsWith('// ابھی تک')) return;

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

  // API انٹیگریشن فنکشنز
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI اسسٹنٹ - ${_project.name}"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
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
                    _startApiIntegration(ApiTemplate(
                      name: 'Sample API',
                      provider: 'Sample Provider',
                      url: 'https://api.sample.com',
                    ));
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Text(
                  "فریم ورک: ${_project.framework} | پلیٹ فارم: ${_project.platforms.join(', ')}",
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
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
                    icon: Icon(Icons.send, color: Colors.white).Fatal error: Failed to write to connection!
