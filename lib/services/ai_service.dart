import '../models/chat_model.dart';

class AIService {
  Future<ChatMessage> sendMessage(String userMessage) async {
    // Future میں delay دے کر pretend کر رہے ہیں کہ API call ہوئی
    await Future.delayed(const Duration(seconds: 1));

    // AI کا mock response
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: "ai",
      text: "This is a mock AI response for: $userMessage",
      timestamp: DateTime.now(),
    );
  }
}
