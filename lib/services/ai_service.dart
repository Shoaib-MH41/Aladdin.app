import '../models/chat_model.dart';
import 'deepseek_service.dart';

class AIService {
  Future<ChatMessage> sendMessage(String userMessage) async {
    try {
      final String aiResponse = await DeepSeekService.generateResponse(userMessage);
      
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: aiResponse,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // اگر DeepSeek fail ہو تو fallback response
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: "AI service temporary unavailable. Error: $e",
        timestamp: DateTime.now(),
      );
    }
  }
}
