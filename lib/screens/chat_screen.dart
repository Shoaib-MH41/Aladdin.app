import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../models/chat_model.dart';
import '../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final AIService _aiService = AIService();
  bool _isAIThinking = false;

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
      
      // Intelligent prompt بنائیں
      String smartPrompt = """
      Create a ${project.framework} app for: $text
      Platforms: ${project.platforms.join(', ')}
      Features: ${project.features}
      API Integration: ${project.features['api'] ?? 'none'}
      Return complete runnable Flutter code.
      """;
      
      final aiMsg = await _aiService.sendMessage(smartPrompt);
      
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

  void _openBuildScreen() {
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
        title: Text("AI چیٹ - ${project.name}"),
        backgroundColor: Colors.deepPurple,
        actions: [
          // ✅ BUILD بٹن شامل کریں
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
                ],
              ),
            ),
          ),
          
          // AI Thinking Indicator
          if (_isAIThinking)
            const LinearProgressIndicator(
              backgroundColor: Colors.deepPurple,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                  backgroundColor: Colors.deepPurple,
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
                          _messages.any((msg) => msg.sender == "ai")
          ? FloatingActionButton(
              onPressed: _openBuildScreen,
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.build, color: Colors.white),
              tooltip: "APK بنائیں",
            )
          : null,
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.sender == "user";
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) 
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.auto_awesome, size: 16, color: Colors.white),
            ),
          
          const SizedBox(width: 8),
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: isUser ? Colors.deepPurple : Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUser ? "آپ" : "AI",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isUser ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          if (isUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, size: 16, color: Colors.white),
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
