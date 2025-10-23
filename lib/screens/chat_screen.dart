import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../models/chat_model.dart';
import '../services/github_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isAIThinking = false;

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
      final Project project = ModalRoute.of(context)!.settings.arguments as Project;

      String smartPrompt = """
Create Flutter app for: $text
Framework: ${project.framework}
Platforms: ${project.platforms.join(', ')}
""";

      final String aiResponse = await GithubService.generateFlutterCode(smartPrompt);

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

  @override
  Widget build(BuildContext context) {
    final Project project = ModalRoute.of(context)!.settings.arguments as Project;

    return Scaffold(
      appBar: AppBar(
        title: Text("GitHub AI - ${project.name}"),
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: [
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
          if (_isAIThinking)
            const LinearProgressIndicator(),
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
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.black,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
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
    Color bubbleColor = isUser ? Colors.black : Colors.grey[200]!;
    Color textColor = isUser ? Colors.white : Colors.black87;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(msg.text, style: TextStyle(color: textColor)),
      ),
    );
  }
}
