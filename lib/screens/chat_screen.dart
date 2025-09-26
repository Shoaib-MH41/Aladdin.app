import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../models/chat_model.dart';
import '../services/gemini_service.dart'; // 🌟 نیا Gemini Service
import '../services/termux_service.dart';  // 🌟 Termux Service شامل کریں

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final GeminiService _geminiService = GeminiService(); // 🌟 DeepSeek کی جگہ Gemini
  bool _isAIThinking = false;
  bool _isBuildingAPK = false; // 🌟 نیا flag for APK building

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // User message add کریں
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
      final Project project = ModalRoute.of(context)!.settings.arguments as Project;
      
      // Intelligent prompt بنائیں - Gemini کے لیے optimize کریں
      String smartPrompt = """
      Create a complete Flutter app for: $text
      
      Project Requirements:
      - Framework: ${project.framework}
      - Platforms: ${project.platforms.join(', ')}
      - Features: ${project.features}
      - API: ${project.features['api'] ?? 'none'}
      - Animation: ${project.features['animation'] ?? 'none'}
      - Font: ${project.features['font'] ?? 'default'}
      
      Return ONLY the complete runnable Flutter Dart code for main.dart.
      Do not include explanations or markdown code blocks.
      Make sure the code is error-free and can compile directly.
      """;
      
      // 🌟 DeepSeek کی جگہ Gemini service call
      final String aiResponse = await _geminiService.generateCode(smartPrompt);
      
      final aiMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: aiResponse,
        timestamp: DateTime.now(),
      );
      
      setState(() {
        _messages.add(aiMsg);
        _isAIThinking = false;
      });
    } catch (e) {
      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: "Error: $e",
        timestamp: DateTime.now(),
      );
      setState(() {
        _messages.add(errorMsg);
        _isAIThinking = false;
      });
    }
  }

  // 🌟 نیا method: براہ راست APK بنانے کے لیے
  void _buildAPKDirectly() async {
    final Project project = ModalRoute.of(context)!.settings.arguments as Project;
    
    // AI کے آخری message میں سے کوڈ نکالیں
    final aiMessages = _messages.where((msg) => msg.sender == "ai").toList();
    
    if (aiMessages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("پہلے AI سے کوڈ جنریٹ کریں")),
      );
      return;
    }
    
    final lastAIMessage = aiMessages.last;
    
    setState(() {
      _isBuildingAPK = true;
    });

    try {
      // 🌟 Termux service کو call کریں - صرف APK بنانے کے وقت
      final String buildResult = await TermuxService.buildAPK(
        project.name, 
        lastAIMessage.text
      );

      // Build result کو messages میں شامل کریں
      final buildMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "system",
        text: "🔨 APK Build Result:\n$buildResult",
        timestamp: DateTime.now(),
      );
      
      setState(() {
        _messages.add(buildMsg);
        _isBuildingAPK = false;
      });

      // Success case میں snackbar دکھائیں
      if (buildResult.contains("✅")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("APK بن گئی!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "system",
        text: "❌ APK Build Failed: $e",
        timestamp: DateTime.now(),
      );
      
      setState(() {
        _messages.add(errorMsg);
        _isBuildingAPK = false;
      });
    }
  }

  void _openBuildScreen() {
    final Project project = ModalRoute.of(context)!.settings.arguments as Project;
    
    final aiMessages = _messages.where((msg) => msg.sender == "ai").toList();
    
    if (aiMessages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("پہلے AI سے کوڈ جنریٹ کریں")),
      );
      return;
    }
    
    final lastAIMessage = aiMessages.last;
    
    Navigator.pushNamed(
      context, 
      '/build',
      arguments: {
        'code': lastAIMessage.text,
        'projectName': project.name,
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final Project project = ModalRoute.of(context)!.settings.arguments as Project;

    return Scaffold(
      appBar: AppBar(
        title: Text("Gemini AI چیٹ - ${project.name}"), // 🌟 نام تبدیل کیا
        backgroundColor: Colors.blue, // 🌟 Gemini کے رنگوں میں
        actions: [
          // 🌟 Direct APK Build بٹن
          IconButton(
            icon: _isBuildingAPK 
                ? CircularProgressIndicator(color: Colors.white)
                : Icon(Icons.android, color: Colors.white),
            onPressed: _isBuildingAPK ? null : _buildAPKDirectly,
            tooltip: "براہ راست APK بنائیں",
          ),
          // موجودہ Build بٹن
          IconButton(
            icon: const Icon(Icons.build, color: Colors.white),
            onPressed: _openBuildScreen,
            tooltip: "APK بنائیں",
          ),
        ],
      ),
      body: Column(
        children: [
          // Project features summary
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "پروجیکٹ کی تفصیلات:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("📱 پلیٹفارم: ${project.platforms.join(', ')}"),
                  Text("⚙️ فریم ورک: ${project.framework}"),
                  Text("🎬 اینی میشن: ${project.features['animation'] ?? 'none'}"),
                  Text("🔤 فونٹ: ${project.features['font'] ?? 'default'}"),
                  Text("🌐 API: ${project.features['api'] ?? 'none'}"),
                  // 🌟 Gemini AI کا اشارہ
                  const SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text("🤖 Powered by Gemini AI", 
                      style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          
          // AI Thinking Indicator
          if (_isAIThinking)
            const LinearProgressIndicator(
              backgroundColor: Colors.blue,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          
          // APK Building Indicator
          if (_isBuildingAPK)
            LinearProgressIndicator(
              backgroundColor: Colors.green[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          
          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          
          // Input Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "اپنی ایپ کی تفصیل لکھیں...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue, // 🌟 رنگ تبدیل کیا
                  child: IconButton(
                    icon: _isAIThinking
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed: _isAIThinking ? null : () => _sendMessage(_controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Floating Action Button for Quick Build
      floatingActionButton: _messages.isNotEmpty && 
                          _messages.any((msg) => msg.sender == "ai") &&
                          !_isBuildingAPK
          ? FloatingActionButton(
              onPressed: _buildAPKDirectly,
              backgroundColor: Colors.green, // 🌟 APK building کے لیے الگ رنگ
              child: _isBuildingAPK 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Icon(Icons.android, color: Colors.white),
              tooltip: "براہ راست APK بنائیں",
            )
          : null,
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.sender == "user";
    final isSystem = msg.sender == "system";
    
    Color bubbleColor;
    Color textColor;
    IconData icon;
    
    if (isUser) {
      bubbleColor = Colors.blue;
      textColor = Colors.white;
      icon = Icons.person;
    } else if (isSystem) {
      bubbleColor = Colors.green;
      textColor = Colors.white;
      icon = Icons.build;
    } else {
      bubbleColor = Colors.grey[200]!;
      textColor = Colors.black87;
      icon = Icons.auto_awesome;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser && !isSystem) 
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Icon(icon, size: 16, color: Colors.white),
            ),
          
          if (isSystem)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: Icon(icon, size: 16, color: Colors.white),
            ),
          
          const SizedBox(width: 8),
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUser ? "آپ" : isSystem ? "سسٹم" : "Gemini AI", // 🌟 نام تبدیل کیا
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg.text,
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          if (isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: Icon(icon, size: 16, color: Colors.white),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
