import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import '../models/project_model.dart';
import '../models/chat_model.dart';
import '../services/github_service.dart';
import '../services/gemini_service.dart';

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
      // ✅ درست prompt بنائیں
      String smartPrompt = """
آپ ایک Flutter expert ہیں۔ مکمل، چلنے کے قابل Flutter کوڈ بنائیں۔

**ضروریات:**
$text

**ٹیکنیکل تفصیلات:**
- فریم ورک: ${_project.framework}
- پلیٹ فارمز: ${_project.platforms.join(', ')}
- ضروری assets: ${_project.assets.keys.join(', ')}

**ہدایات:**
1. صرف Dart کوڈ لوٹائیں، وضاحت نہیں
2. تمام necessary imports شامل کریں
3. MaterialApp اور Scaffold استعمال کریں
4. کوئی syntax errors نہ ہوں
5. مکمل working app ہو

**صرف کوڈ لوٹائیں:**
""";

      // ✅ Gemini سے کوڈ جنریٹ کریں
      final String generatedCode = await widget.geminiService.generateFlutterCode(smartPrompt);

      // AI message بنائیں
      final aiMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: generatedCode,
        timestamp: DateTime.now(),
        isCode: true, // ✅ یہ کوڈ ہے
      );

      setState(() {
        _messages.add(aiMsg);
        _isAIThinking = false;
      });

      // ✅ GitHub پر automatically save کریں
      if (_isValidFlutterCode(generatedCode)) {
        final repoName = '${_project.name}_${DateTime.now().millisecondsSinceEpoch}';
        final repoUrl = await widget.githubService.createRepository(repoName, generatedCode);
        
        // ✅ کامیابی کا message دکھائیں
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ کوڈ GitHub پر محفوظ ہو گیا!'),
            backgroundColor: Colors.green,
          )
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

  bool _isValidFlutterCode(String code) {
    return code.contains('import') && 
           code.contains('void main') && 
           code.contains('MaterialApp');
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
      }
    );
  }

  void _debugCurrentCode() async {
    if (_messages.isEmpty) return;
    
    final lastAIMessage = _messages.lastWhere(
      (msg) => msg.sender == "ai" && msg.isCode,
    );
    
    if (lastAIMessage.text.contains('//')) return; // اگر کوڈ نہیں ہے
    
    setState(() => _isAIThinking = true);
    
    try {
      final debugPrompt = """
اس Flutter کوڈ میں ممکنہ مسائل ڈھونڈیں اور بہتر بنائیں:

کوڈ:
${lastAIMessage.text}

ہدایات:
1. ممکنہ syntax errors درست کریں
2. performance بہتر بنائیں  
3. best practices استعمال کریں
4. صرف درست شدہ کوڈ لوٹائیں
""";

      final debuggedCode = await widget.geminiService.generateFlutterCode(debugPrompt);
      
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI اسسٹنٹ - ${_project.name}"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // ✅ کوڈ دیکھنے کا بٹن
          IconButton(
            icon: Icon(Icons.code),
            tooltip: 'جنریٹڈ کوڈ دیکھیں',
            onPressed: _isAIThinking ? null : _viewGeneratedCode,
          ),
          // ✅ ڈیبگ کا بٹن
          IconButton(
            icon: Icon(Icons.bug_report),
            tooltip: 'کوڈ ڈیبگ کریں',
            onPressed: _isAIThinking ? null : _debugCurrentCode,
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ پروجیکٹ انفارمیشن
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
          
          // ✅ میسجز list
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
          
          // ✅ thinking indicator
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
          
          // ✅ input area
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

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.sender == "user";
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Card(
          color: isUser ? Colors.blue : Colors.white,
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ sender name
                Text(
                  isUser ? "آپ" : "AI اسسٹنٹ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isUser ? Colors.white : Colors.blue,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                
                // ✅ message content
                if (msg.isCode && !isUser)
                  _buildCodeWidget(msg.text)
                else
                  Text(
                    msg.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                
                // ✅ timestamp
                SizedBox(height: 4),
                Text(
                  "${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(
                    fontSize: 10,
                    color: isUser ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeWidget(String code) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ✅ کوڈ کے لیے special styling
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: HighlightView(
              code.length > 500 ? code.substring(0, 500) + "\n// ... مزید کوڈ" : code,
              language: 'dart',
              theme: githubTheme,
              padding: EdgeInsets.all(8),
              textStyle: TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        SizedBox(height: 8),
        ElevatedButton.icon(
          icon: Icon(Icons.visibility, size: 16),
          label: Text("مکمل کوڈ دیکھیں"),
          onPressed: _viewGeneratedCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade50,
            foregroundColor: Colors.blue,
          ),
        ),
      ],
    );
  }
}
