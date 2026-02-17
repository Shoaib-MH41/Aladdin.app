// lib/screens/chat/chat_controller.dart
import 'dart:async'; // ✅ نیا: Timer کے لیے
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/project_model.dart';
import '../../models/chat_model.dart';
import '../../models/api_template_model.dart';
import '../../services/gemini_service.dart';
import '../../services/github_service.dart';
import '../../services/ai_api_finder.dart';

// ✅ سکرینز کے imports
import '../build_screen.dart';
import '../api_discovery_screen.dart';
import '../api_integration_screen.dart';

/// 🎯 Chat Controller - تمام logic اور state مینجمنٹ
class ChatController extends ChangeNotifier {
  // ============= 📊 Required Services =============
  final GeminiService geminiService;
  final GitHubService githubService;
  final Project project;
  late AIApiFinder aiApiFinder;

  // ============= 📊 State Variables =============
  final List<ChatMessage> messages = [];
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  
  bool isAIThinking = false;
  bool isConnected = false;
  String connectionMessage = "⚠️ اپنا کنکشن جوڑیں";
  
  // 🎨 UI Design State
  Map<String, dynamic>? latestUIDesign;
  bool showDesignPreview = false;
  List<Map<String, dynamic>> uiKit = [];
  bool isGeneratingUI = false;

  // ============= 🔄 Auto-Save Timer =============
  Timer? _autoSaveTimer;
  
  // ============= 🔄 File Update State =============
  List<Map<String, dynamic>> pendingFileUpdates = [];
  bool showFileUpdateBanner = false;

  // ============= 🏗️ Constructor =============
  ChatController({
    required this.geminiService,
    required this.githubService,
    required this.project,
  }) {
    aiApiFinder = AIApiFinder(geminiService: geminiService);
    _checkConnection();
    _startAutoSave(); // ✅ نیا
    _checkPendingFiles(); // ✅ نیا
  }

  // ============= 📌 Getters =============
  String? get generatedCode {
    try {
      final lastCodeMsg = messages.lastWhere(
        (msg) => msg.sender == "ai" && msg.isCode,
        orElse: () => ChatMessage(
          id: '0',
          sender: 'ai',
          text: '',
          timestamp: DateTime.now(),
        ),
      );
      return lastCodeMsg.text.isNotEmpty ? lastCodeMsg.text : null;
    } catch (e) {
      return null;
    }
  }

  // ============= 🔌 Connection Functions =============
  Future<void> _checkConnection() async {
    try {
      await geminiService.testConnection();
      isConnected = true;
      connectionMessage = "✅ کنکشن کامیاب ہے";
    } catch (e) {
      isConnected = false;
      connectionMessage = "⚠️ اپنا کنکشن جوڑیں";
    }
    notifyListeners();
  }

  // ============= 📜 Scroll Functions =============
  void scrollToBottom() {
    if (scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // ============= 🔄 AUTO-SAVE & RESUME =============

  /// ✅ نیا: Auto-save start کریں (ہر 30 سیکنڈ)
  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _saveCurrentSession();
    });
  }

  /// ✅ نیا: Current session save کریں
  void _saveCurrentSession() {
    if (messages.isEmpty) return;
    
    project.saveSession(
      messages: messages.map((m) => m.toMap()).toList(),
      generatedCode: generatedCode,
      isGenerating: isAIThinking,
      pendingFiles: pendingFileUpdates.isNotEmpty ? pendingFileUpdates : null,
    );
    
    print('💾 Session auto-saved: ${messages.length} messages');
  }

  /// ✅ نیا: Pending files check کریں
  void _checkPendingFiles() {
    if (project.pendingFileUpdates != null && project.pendingFileUpdates!.isNotEmpty) {
      pendingFileUpdates = List.from(project.pendingFileUpdates!);
      showFileUpdateBanner = true;
      notifyListeners();
    }
  }

  /// ✅ نیا: Resume session
  Future<void> resumeSession(BuildContext context) async {
    if (!project.hasIncompleteSession) return;

    try {
      // Messages restore کریں
      if (project.draftMessages != null) {
        messages.clear();
        for (final msgMap in project.draftMessages!) {
          messages.add(ChatMessage.fromMap(msgMap));
        }
      }

      // State restore کریں
      if (project.wasGenerating == true) {
        // اگر AI سوچ رہا تھا تو last message دوبارہ بھیجیں
        final lastUserMsg = messages.lastWhere(
          (m) => m.sender == 'user',
          orElse: () => ChatMessage(
            id: '0',
            sender: 'user',
            text: '',
            timestamp: DateTime.now(),
          ),
        );
        
        if (lastUserMsg.text.isNotEmpty) {
          messages.remove(lastUserMsg); // Duplicate سے بچنے کے لیے
          await sendMessage(lastUserMsg.text);
        }
      }

      notifyListeners();
      scrollToBottom();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔄 Session کامیابی سے بحال ہو گیا'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      print('❌ Resume failed: $e');
    }
  }

  /// ✅ نیا: Session discard کریں
  void discardSession() {
    project.clearSession();
    messages.clear();
    pendingFileUpdates.clear();
    showFileUpdateBanner = false;
    notifyListeners();
    
    print('🗑️ Session discarded');
  }

  // ============= 📁 FILE UPDATE FUNCTIONS =============

  /// ✅ نیا: File update کے لیے queue میں ڈالیں
  void queueFileUpdate(String filePath, String newContent, {String reason = 'modified'}) {
    // پہلے سے موجود ہے؟
    final existingIndex = pendingFileUpdates.indexWhere((f) => f['path'] == filePath);
    
    final update = {
      'path': filePath,
      'content': newContent,
      'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (existingIndex >= 0) {
      pendingFileUpdates[existingIndex] = update;
    } else {
      pendingFileUpdates.add(update);
    }

    showFileUpdateBanner = true;
    _saveCurrentSession(); // فوری save
    notifyListeners();
  }

  /// ✅ نیا: Pending file update کریں
  Future<void> applyFileUpdate(BuildContext context, int index) async {
    if (index < 0 || index >= pendingFileUpdates.length) return;

    final update = pendingFileUpdates[index];
    final filePath = update['path'] as String;
    final content = update['content'] as String;

    try {
      // GitHub پر update کریں
      await githubService.uploadFile(
        repoName: project.name,
        filePath: filePath,
        content: content,
        commitMessage: 'Update $filePath - ${update['reason']}',
      );

      // Queue سے ہٹائیں
      pendingFileUpdates.removeAt(index);
      
      if (pendingFileUpdates.isEmpty) {
        showFileUpdateBanner = false;
      }

      _saveCurrentSession();
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ $filePath اپڈیٹ ہو گیا'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ اپڈیٹ ناکام: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// ✅ نیا: تمام pending files apply کریں
  Future<void> applyAllFileUpdates(BuildContext context) async {
    for (int i = pendingFileUpdates.length - 1; i >= 0; i--) {
      await applyFileUpdate(context, i);
    }
  }

  /// ✅ نیا: File update skip کریں
  void skipFileUpdate(int index) {
    if (index < 0 || index >= pendingFileUpdates.length) return;
    
    pendingFileUpdates.removeAt(index);
    if (pendingFileUpdates.isEmpty) {
      showFileUpdateBanner = false;
    }
    
    _saveCurrentSession();
    notifyListeners();
  }

  /// ✅ نیا: File update banner بند کریں
  void dismissFileUpdateBanner() {
    showFileUpdateBanner = false;
    notifyListeners();
  }

  /// ✅ نیا: Manual save (user کے لیے)
  void manualSave() {
    _saveCurrentSession();
    print('💾 Manual save triggered');
  }

  // ============= 💬 Message Functions =============
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: "user",
      text: text,
      timestamp: DateTime.now(),
    );

    messages.add(userMsg);
    isAIThinking = true;
    showDesignPreview = false;
    textController.clear();
    notifyListeners();
    
    scrollToBottom();

    try {
      String smartPrompt = """
آپ ایک ${project.framework} expert ہیں۔ مکمل، چلنے کے قابل کوڈ بنائیں۔

ضروریات:
$text

ٹیکنیکل تفصیلات:
- فریم ورک: ${project.framework}
- پلیٹ فارمز: ${project.platforms.join(', ')}
- ضروری assets: ${project.assets.keys.join(', ')}

ہدایات:
1. صرف کوڈ لوٹائیں، وضاحت نہیں
2. تمام necessary imports شامل کریں
3. مکمل working app ہو
4. کوئی syntax errors نہ ہوں
5. جدید UI/UX design استعمال کریں

صرف کوڈ لوٹائیں:
""";

      final String generatedCode = await geminiService.generateCode(
        prompt: smartPrompt,
        framework: project.framework,
        platforms: project.platforms,
      );

      final aiMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: generatedCode,
        timestamp: DateTime.now(),
        isCode: true,
      );

      messages.add(aiMsg);
      isAIThinking = false;
      notifyListeners();
      scrollToBottom();

      if (_isValidCode(generatedCode)) {
        await _saveToGitHub(generatedCode);
      }
    } catch (e) {
      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: "❌ خرابی: $e\n\nبراہ کرم دوبارہ کوشش کریں یا مسئلہ واضح کریں۔",
        timestamp: DateTime.now(),
      );

      messages.add(errorMsg);
      isAIThinking = false;
      notifyListeners();
      scrollToBottom();
    }
  }

  void copyMessage(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ متن کاپی ہو گیا!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void deleteMessage(String messageId) {
    messages.removeWhere((msg) => msg.id == messageId);
    notifyListeners();
  }

  void editMessage(String text) {
    textController.text = text;
    notifyListeners();
  }

  // ============= 🎨 UI Design Functions =============
  
  /// ⚠️ **یہ فنکشن غائب تھا - اب شامل کیا**
  Future<void> generateUIDesign() async {
    if (textController.text.trim().isEmpty) return;

    isGeneratingUI = true;
    showDesignPreview = false;
    notifyListeners();

    try {
      final design = await geminiService.generateUIDesign(
        prompt: textController.text,
        componentType: 'auto',
      );

      latestUIDesign = design;
      showDesignPreview = true;
      isGeneratingUI = false;

      final designMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: "🎨 AI نے ایک جدید UI ڈیزائن تیار کیا ہے!",
        timestamp: DateTime.now(),
        isDesign: true,
        designData: design,
      );

      messages.add(designMsg);
      notifyListeners();
      scrollToBottom();

    } catch (e) {
      isGeneratingUI = false;
      notifyListeners();
    }
  }

  /// ⚠️ **یہ فنکشن غائب تھا - اب شامل کیا**
  Future<void> convertDesignToCode(BuildContext context) async {
    if (latestUIDesign == null) return;

    isAIThinking = true;
    notifyListeners();

    try {
      final flutterCode = await geminiService.generateFlutterCode(
        designData: latestUIDesign!,
        includeComments: true,
        addDependencies: true,
      );

      final codeMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: flutterCode,
        timestamp: DateTime.now(),
        isCode: true,
      );

      messages.add(codeMsg);
      isAIThinking = false;
      showDesignPreview = false;
      notifyListeners();
      scrollToBottom();

      await _saveToGitHub(flutterCode);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ کوڈ GitHub پر محفوظ ہو گیا!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      isAIThinking = false;
      notifyListeners();
    }
  }

  /// ⚠️ **یہ فنکشن غائب تھا - اب شامل کیا**
  Future<void> generateUIKit(BuildContext context) async {
    isGeneratingUI = true;
    notifyListeners();

    try {
      uiKit = await geminiService.generateUIKit(
        appTheme: project.name,
        components: const ['button', 'card', 'textfield', 'appbar', 'navbar'],
      );

      isGeneratingUI = false;
      showDesignPreview = true;
      latestUIDesign = uiKit.isNotEmpty ? uiKit.first : null;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎨 UI Kit تیار ہو گیا! ${uiKit.length} کامپوننٹس'),
          backgroundColor: Colors.purple,
        ),
      );

    } catch (e) {
      isGeneratingUI = false;
      notifyListeners();
    }
  }

  /// ⚠️ **یہ فنکشن غائب تھا - اب شامل کیا**
  void hideDesignPreview() {
    showDesignPreview = false;
    notifyListeners();
  }

  // ============= 🔧 Debug Functions =============
  Future<void> debugCurrentCode(BuildContext context) async {
    if (generatedCode == null) {
      _showSnackBar(context, '❌ پہلے کوڈ جنریٹ کریں', Colors.orange);
      return;
    }

    try {
      isAIThinking = true;
      notifyListeners();

      final debugPrompt = """
اس ${project.framework} کوڈ میں ممکنہ مسائل ڈھونڈیں اور بہتر بنائیں:

کوڈ:
${generatedCode!}

ہدایات:
1. ممکنہ syntax errors درست کریں
2. performance بہتر بنائیں  
3. best practices استعمال کریں
4. صرف درست شدہ کوڈ لوٹائیں
5. modern design patterns شامل کریں
""";

      final debuggedCode = await geminiService.generateCode(
        prompt: debugPrompt,
        framework: project.framework,
        platforms: project.platforms,
      );

      final debugMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: debuggedCode,
        timestamp: DateTime.now(),
        isCode: true,
      );

      messages.add(debugMsg);
      isAIThinking = false;
      notifyListeners();
      scrollToBottom();

    } catch (e) {
      isAIThinking = false;
      notifyListeners();
      _showSnackBar(context, 'ڈیبگ ناکام: $e', Colors.red);
    }
  }

  // ============= 🌐 API Functions =============
  Future<void> discoverApis(BuildContext context) async {
    if (isAIThinking) return;

    isAIThinking = true;
    notifyListeners();

    try {
      String appDescription = '';
      if (messages.isNotEmpty) {
        final userMessages = messages.where((msg) => msg.sender == "user");
        if (userMessages.isNotEmpty) {
          appDescription = userMessages.last.text;
        }
      }

      final discoveredApis = await aiApiFinder.findRelevantApis(
        appDescription: appDescription.isNotEmpty ? appDescription : project.name,
        framework: project.framework,
        appName: project.name,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ApiDiscoveryScreen(
            discoveredApis: discoveredApis,
            projectName: project.name,
          ),
        ),
      );

    } catch (e) {
      _showSnackBar(context, 'API ڈسکوری ناکام: $e', Colors.red);
    } finally {
      isAIThinking = false;
      notifyListeners();
    }
  }

  void startApiIntegration(BuildContext context, ApiTemplate apiTemplate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApiIntegrationScreen(
          apiTemplate: apiTemplate,
          onApiKeySubmitted: (apiKey) {
            _handleApiKeySubmission(apiTemplate, apiKey);
          },
        ),
      ),
    );
  }

  void _handleApiKeySubmission(ApiTemplate apiTemplate, String apiKey) {
    String prompt = """
میں نے ${apiTemplate.name} کی API key جمع کرا دی ہے۔
براہ کرم ${apiTemplate.provider} API کے ساتھ مکمل کوڈ بنائیں۔

API Key: $apiKey
API URL: ${apiTemplate.url}

ہدایات:
1. مکمل functional app بنائیں
2. API integration شامل کریں
3. Error handling شامل کریں
4. Modern UI design استعمال کریں
5. صرف کوڈ لوٹائیں
""";

    sendMessage(prompt);
  }

  // ============= 🚀 Navigation Functions =============
  void viewGeneratedCode(BuildContext context) {
    if (generatedCode == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuildScreen(
          generatedCode: generatedCode!,
          projectName: project.name,
          framework: project.framework,
        ),
      ),
    );
  }

  // ============= 🛠️ Helper Functions =============
  bool _isValidCode(String code) {
    switch (project.framework.toLowerCase()) {
      case 'flutter':
        return code.contains('import') && code.contains('void main');
      case 'react':
        return code.contains('import') && (code.contains('function') || code.contains('const'));
      case 'vue':
        return code.contains('<template>') && code.contains('<script>');
      case 'android native':
        return code.contains('package') && code.contains('class');
      case 'html':
        return code.contains('<!DOCTYPE') || code.contains('<html>');
      default:
        return code.isNotEmpty && code.length > 10;
    }
  }

  Future<void> _saveToGitHub(String code) async {
    try {
      final repoName = '${project.name}_${DateTime.now().millisecondsSinceEpoch}';
      await githubService.createRepository(repoName);
    } catch (e) {
      print('GitHub save failed: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============= 🧹 Dispose =============
  @override
  void dispose() {
    _autoSaveTimer?.cancel(); // ✅ نیا
    _saveCurrentSession(); // ✅ نیا: Last time save
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
