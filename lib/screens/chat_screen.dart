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
    });

    _controller.clear();

    // AI کا جواب لیں
    final aiMsg = await _aiService.sendMessage(text);

    setState(() {
      _messages.add(aiMsg);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Project project =
        ModalRoute.of(context)!.settings.arguments as Project;

    return Scaffold(
      appBar: AppBar(title: Text("Chat - ${project.name}")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return ListTile(
                  title: Align(
                    alignment: msg.sender == "user"
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: msg.sender == "user"
                            ? Colors.deepPurple[100]
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg.text),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration:
                      const InputDecoration(hintText: "Enter your message..."),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _sendMessage(_controller.text),
              )
            ],
          )
        ],
      ),
    );
  }
}

