import 'package:flutter/material.dart';
import '../models/project_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<String> _messages = [];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage(String text) {
    setState(() {
      _messages.add("You: $text");
      _messages.add("AI: Generated mock code for '$text'");
    });
    _controller.clear();
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
              itemBuilder: (context, index) => ListTile(
                title: Text(_messages[index]),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration:
                      const InputDecoration(hintText: "Enter your prompt..."),
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

