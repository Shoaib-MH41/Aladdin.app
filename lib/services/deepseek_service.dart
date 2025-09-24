import 'termux_service.dart';

class DeepSeekService {
  static Future<String> generateResponse(String prompt) async {
    try {
      // Termux کو DeepSeek command بھیجیں
      final String result = await TermuxService.runCommand('''
      cd /data/data/com.termux/files/home && 
      ./llama.cpp/main -m ./models/deepseek-coder-1.3b.gguf -p "$prompt" --temp 0.7
      ''');
      
      return result;
    } catch (e) {
      throw Exception("DeepSeek generation failed: $e");
    }
  }
  
  static Future<String> generateFlutterCode(String requirements) async {
    final String prompt = """
    Generate complete Flutter code for: $requirements
    Use Material Design, make it responsive.
    Return only Dart code without explanations.
    """;
    
    return await generateResponse(prompt);
  }
}
