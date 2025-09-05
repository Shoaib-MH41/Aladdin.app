
import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

void main() => runApp(const AppMaker());
class AppMaker extends StatelessWidget {
  const AppMaker({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    home: const ChatScreen(),
    debugShowCheckedModeBanner: false,
  );
}
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _messages = [];
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() => _messages.add(_controller.text));
      _controller.clear();
    }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("App Maker")),
    body: Column(
      children: [
        Expanded(child: ListView.builder(
          itemCount: _messages.length,
          itemBuilder: (_, i) => BubbleNormal(
            text: _messages[i], isSender: true, color: Colors.blue.shade100,
          ),
        )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(child: TextField(controller: _controller,
                decoration: const InputDecoration(hintText: "Enter prompt..."),
              )),
              IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
            ],
          ),
        ),
      ],
    ),
  );
}
