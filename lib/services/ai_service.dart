import '../models/chat_model.dart';
import 'gemini_service.dart'; // ✅ DeepSeek کی جگہ Gemini

class AIService {
  Future<ChatMessage> sendMessage(String userMessage) async {
    try {
      print("🤖 AI Service called with: $userMessage");
      
      // ✅ Gemini API call
      final String aiResponse = await GeminiService.generateFlutterCode(userMessage);

      // ✅ اگر response خالی ہو تو fallback
      final safeResponse = aiResponse.isNotEmpty
          ? aiResponse
          : "// ⚠️ Gemini returned an empty response. Please try again.";

      print("✅ AI Response received");

      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: safeResponse,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print("❌ AI Service error: $e");
      
      // ✅ Better error message with fallback UI
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: """
// ⚙️ Gemini AI Service Initializing...

// Your request: "$userMessage"

// Temporary response while Gemini connects

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('AI App Factory'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(
          child: Text(
            'Hello! Your app for: "$userMessage"',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

💡 Tip: Gemini API integration is in progress...
""",
        timestamp: DateTime.now(),
      );
    }
  }
}
