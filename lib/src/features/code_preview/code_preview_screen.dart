import 'package:flutter/material.dart';

class CodePreviewScreen extends StatelessWidget {
  const CodePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generated Code Preview")),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SelectableText(
          "Here will be the generated code using OpenAI API...",
          style: TextStyle(fontSize: 16, fontFamily: "monospace"),
        ),
      ),
    );
  }
}
