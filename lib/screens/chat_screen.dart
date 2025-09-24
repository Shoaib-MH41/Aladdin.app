import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../models/chat_model.dart';
import '../services/ai_service.dart';
import '../services/deepseek_service.dart';
import '../services/termux_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final AIService _aiService = AIService();
  bool _isBuilding = false;

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: "user",
      text: text,
      timestamp: DateTime.now(),
    );

    setState(() => _messages.add(userMsg));
    _controller.clear();

    try {
      final Project project = ModalRoute.of(context)!.settings.arguments as Project;
      
      // Intelligent prompt بنائیں
      String smartPrompt = """
      Create a ${project.framework} app for: $text
      Platforms: ${project.platforms.join(', ')}
      Features: ${project.features}
      Return complete runnable code.
      """;
      
      final aiMsg = await _aiService.sendMessage(smartPrompt);
      setState(() => _messages.add(aiMsg));
      
      // اگر user نے code generation کی درخواست کی ہے تو APK بنائیں
      if (text.toLowerCase().contains('build') || text.toLowerCase().contains('create')) {
        _buildAPK(project, aiMsg.text);
      }
    } catch (e) {
      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: "Error: $e",
        timestamp: DateTime.now(),
      );
      setState(() => _messages.add(errorMsg));
    }
  }

  void _buildAPK(Project project, String code) async {
    setState(() => _isBuilding = true);
    
    try {
      final String result = await TermuxService.buildAPK(project.name, code);
      
      final buildMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai", 
        text: "✅ APK Built Successfully!\n$result",
        timestamp: DateTime.now(),
      );
      
      setState(() {
        _messages.add(buildMsg);
        _isBuilding = false;
      });
    } catch (e) {
      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: "❌ APK Build Failed: $e",
        timestamp: DateTime.now(),
      );
      setState(() {
        _messages.add(errorMsg);
        _isBuilding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Project project = ModalRoute.of(context)!.settings.arguments as Project;

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat - ${project.name}"),
        actions: [
          if (_isBuilding) 
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Project features summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Framework: ${project.framework}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("Platforms: ${project.platforms.join(', ')}"),
                  Text("Features: ${project.features}"),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Align(
                    alignment: msg.sender == "user" ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: msg.sender == "user" ? Colors.blue[100] : Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg.text),
                    ),
                  ),
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Describe your app...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isBuilding ? const CircularProgressIndicator() : const Icon(Icons.send),
                  onPressed: _isBuilding ? null : () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
