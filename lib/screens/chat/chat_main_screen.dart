// lib/screens/chat/chat_main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/project_model.dart';
import '../../models/chat_model.dart';
import '../../models/api_template_model.dart';
import '../../models/ad_model.dart';
import '../../models/ui_design_model.dart'; // ✅ نیا ماڈل

import '../../services/github_service.dart';
import '../../services/gemini_service.dart';
import '../../services/ai_api_finder.dart';

import '../../screens/api_integration_screen.dart';
import '../../screens/api_discovery_screen.dart';

// فائل مینیجر ایمپورٹ
import 'chat_file_manager.dart';
import 'chat_ad_manager.dart';

// نیا: ڈیزائن پریویو ویجیٹ
import 'ui_design_preview.dart';

class ChatMainScreen extends StatefulWidget {
  final aiService aiService;
  final GitHubService githubService;
  final Project project;

  const ChatMainScreen({
    super.key,
    required this.aiService,
    required this.githubService,
    required this.project,
  });

  @override
  State<ChatMainScreen> createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isAIThinking = false;
  late AIApiFinder aiApiFinder;
  
  bool _isConnected = false;
  String _connectionMessage = "⚠️ اپنا کنکشن جوڑیں";
  
  // 🎨 نئے AI ڈیزائنر فیچرز
  Map<String, dynamic>? _latestUIDesign;
  bool _showDesignPreview = false;
  List<Map<String, dynamic>> _uiKit = [];
  bool _isGeneratingUI = false;

  @override
  void initState() {
    super.initState();
    aiApiFinder = AIApiFinder(geminiService: widget.geminiService);
    _checkConnection();
    _loadRecentMessages();
  }

  Future<void> _checkConnection() async {
    try {
      await widget.geminiService.testConnection();
      setState(() {
        _isConnected = true;
        _connectionMessage = "✅ کنکشن کامیاب ہے";
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _connectionMessage = "⚠️ اپنا کنکشن جوڑیں";
      });
    }
  }

  void _loadRecentMessages() async {
    // حالیہ چیٹس لوڈ کریں (اگر کوئی ہوں)
    await Future.delayed(Duration(milliseconds: 300));
  }

  // 🎨 نیا: Generative UI فیچر
  Future<void> _generateUIDesign() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('براہ کرم ڈیزائن کی تفصیل لکھیں'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingUI = true;
      _showDesignPreview = false;
    });

    try {
      final design = await widget.geminiService.generateUIDesign(
        prompt: _controller.text,
        componentType: 'auto',
      );

      setState(() {
        _latestUIDesign = design;
        _showDesignPreview = true;
        _isGeneratingUI = false;
      });

      // AI ڈیزائن میسج بھی شامل کریں
      final designMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: "🎨 AI نے ایک جدید UI ڈیزائن تیار کیا ہے!",
        timestamp: DateTime.now(),
        isDesign: true,
        designData: design,
      );

      setState(() {
        _messages.add(designMsg);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎨 UI ڈیزائن تیار ہو گیا!'),
          backgroundColor: Colors.purple,
        ),
      );

    } catch (e) {
      setState(() => _isGeneratingUI = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ڈیزائن جنریشن ناکام: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🎨 نیا: Flutter کوڈ میں تبدیل کریں
  Future<void> _convertDesignToCode() async {
    if (_latestUIDesign == null) return;

    setState(() => _isAIThinking = true);

    try {
      final flutterCode = await widget.geminiService.generateFlutterCode(
        designData: _latestUIDesign!,
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

      setState(() {
        _messages.add(codeMsg);
        _isAIThinking = false;
        _showDesignPreview = false;
      });

      // GitHub پر محفوظ کریں
      final repoName = '${widget.project.name}_ui_${DateTime.now().millisecondsSinceEpoch}';
      await widget.githubService.createRepository(repoName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ کوڈ GitHub پر محفوظ ہو گیا!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      setState(() => _isAIThinking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('کوڈ جنریشن ناکام: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🎨 نیا: مکمل UI Kit بنائیں
  Future<void> _generateCompleteUIKit() async {
    setState(() => _isGeneratingUI = true);

    try {
      _uiKit = await widget.geminiService.generateUIKit(
        appTheme: widget.project.name,
        components: ['button', 'card', 'textfield', 'appbar', 'navbar'],
      );

      setState(() {
        _isGeneratingUI = false;
        _showDesignPreview = true;
        _latestUIDesign = _uiKit.isNotEmpty ? _uiKit.first : null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎨 UI Kit تیار ہو گیا! ${_uiKit.length} کامپوننٹس'),
          backgroundColor: Colors.purple,
        ),
      );

    } catch (e) {
      setState(() => _isGeneratingUI = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('UI Kit جنریشن ناکام: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: "user",
      text: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isAIThinking = true;
      _showDesignPreview = false;
    });
    _controller.clear();

    try {
      String smartPrompt = """
آپ ایک ${widget.project.framework} expert ہیں۔ مکمل، چلنے کے قابل کوڈ بنائیں۔

ضروریات:
$text

ٹیکنیکل تفصیلات:
- فریم ورک: ${widget.project.framework}
- پلیٹ فارمز: ${widget.project.platforms.join(', ')}
- ضروری assets: ${widget.project.assets.keys.join(', ')}

ہدایات:
1. صرف کوڈ لوٹائیں، وضاحت نہیں
2. تمام necessary imports شامل کریں
3. مکمل working app ہو
4. کوئی syntax errors نہ ہوں
5. جدید UI/UX design استعمال کریں

صرف کوڈ لوٹائیں:
""";

      final String generatedCode = await widget.geminiService.generateCode(
        prompt: smartPrompt,
        framework: widget.project.framework,
        platforms: widget.project.platforms,
      );

      final aiMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: generatedCode,
        timestamp: DateTime.now(),
        isCode: true,
      );

      setState(() {
        _messages.add(aiMsg);
        _isAIThinking = false;
      });

      if (_isValidCode(generatedCode, widget.project.framework)) {
        final repoName = '${widget.project.name}_${DateTime.now().millisecondsSinceEpoch}';
        await widget.githubService.createRepository(repoName);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ کوڈ GitHub پر محفوظ ہو گیا!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: "❌ خرابی: $e\n\nبراہ کرم دوبارہ کوشش کریں یا مسئلہ واضح کریں۔",
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(errorMsg);
        _isAIThinking = false;
      });
    }
  }

  bool _isValidCode(String code, String framework) {
    switch (framework.toLowerCase()) {
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

  void _viewGeneratedCode() {
    if (_messages.isEmpty) return;

    final lastAIMessage = _messages.lastWhere(
      (msg) => msg.sender == "ai" && msg.isCode,
      orElse: () => ChatMessage(
        id: '0',
        sender: 'ai',
        text: '// ابھی تک کوئی کوڈ جنریٹ نہیں ہوا\n// براہ کرم پہلے ایپ کی تفصیل لکھیں',
        timestamp: DateTime.now(),
        isCode: true,
      ),
    );

    Navigator.pushNamed(
      context,
      '/build',
      arguments: {
        'code': lastAIMessage.text,
        'projectName': widget.project.name,
        'framework': widget.project.framework,
      },
    );
  }

  void _debugCurrentCode() async {
    if (_messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ پہلے کوڈ جنریٹ کریں'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final lastAIMessage = _messages.lastWhere(
        (msg) => msg.sender == "ai" && msg.isCode,
      );

      if (lastAIMessage.text.trim().isEmpty || lastAIMessage.text.startsWith('// ابھی تک')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ پہلے کوڈ جنریٹ کریں'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      setState(() => _isAIThinking = true);

      final debugPrompt = """
اس ${widget.project.framework} کوڈ میں ممکنہ مسائل ڈھونڈیں اور بہتر بنائیں:

کوڈ:
${lastAIMessage.text}

ہدایات:
1. ممکنہ syntax errors درست کریں
2. performance بہتر بنائیں  
3. best practices استعمال کریں
4. صرف درست شدہ کوڈ لوٹائیں
5. modern design patterns شامل کریں
""";

      final debuggedCode = await widget.geminiService.generateCode(
        prompt: debugPrompt,
        framework: widget.project.framework,
        platforms: widget.project.platforms,
      );

      final debugMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: "ai",
        text: debuggedCode,
        timestamp: DateTime.now(),
        isCode: true,
      );

      setState(() {
        _messages.add(debugMsg);
        _isAIThinking = false;
      });
    } catch (e) {
      setState(() => _isAIThinking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ڈیبگ ناکام: $e')),
      );
    }
  }

  void _discoverApisWithAI() async {
    if (_isAIThinking) return;

    setState(() => _isAIThinking = true);

    try {
      String appDescription = '';
      if (_messages.isNotEmpty) {
        final userMessages = _messages.where((msg) => msg.sender == "user");
        if (userMessages.isNotEmpty) {
          appDescription = userMessages.last.text;
        }
      }

      final List<ApiTemplate> discoveredApis = await aiApiFinder.findRelevantApis(
        appDescription: appDescription.isNotEmpty ? appDescription : widget.project.name,
        framework: widget.project.framework,
        appName: widget.project.name,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ApiDiscoveryScreen(
            discoveredApis: discoveredApis,
            projectName: widget.project.name,
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API ڈسکوری ناکام: $e')),
      );
    } finally {
      setState(() => _isAIThinking = false);
    }
  }

  void _startApiIntegration(ApiTemplate apiTemplate) {
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

    _sendMessage(prompt);
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.sender == "user";
    final isDesign = msg.designData != null;

    return GestureDetector(
      onLongPress: () {
        if (msg.text.isNotEmpty && !msg.isCode) {
          _showCopyOptions(context, msg.text);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser && !isDesign)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome, size: 16, color: Colors.white),
              ),
            
            SizedBox(width: 12),
            
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isUser 
                    ? Color(0xFF0EA5E9) 
                    : isDesign 
                      ? Color(0xFF8B5CF6)
                      : Color(0xFF1E293B),
                  borderRadius: BorderRadius.only(
                    topLeft: isUser ? Radius.circular(20) : Radius.circular(8),
                    topRight: isUser ? Radius.circular(8) : Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: isDesign
                    ? _buildDesignPreview(msg)
                    : msg.isCode
                        ? _buildCodeView(msg)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.text,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: isUser ? Colors.white : Colors.white,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
              ),
            ),
            
            if (isUser)
              SizedBox(width: 12),
            
            if (isUser)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF34D399)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesignPreview(ChatMessage msg) {
    final designData = msg.designData!;
    final componentType = designData['componentType'] ?? 'container';
    final label = designData['label'] ?? 'AI Design';

    return GestureDetector(
      onTap: () {
        setState(() {
          _latestUIDesign = designData;
          _showDesignPreview = true;
        });
      },
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  '🎨 AI Generated Design',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.design_services, size: 32, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    componentType.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'ٹیپ کریں کوڈ میں تبدیل کرنے کے لیے',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeView(ChatMessage msg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.code, size: 16, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Generated Code',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.content_copy, size: 16, color: Colors.white),
                  onPressed: () => _copyText(msg.text),
                  tooltip: 'کوڈ کاپی کریں',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                IconButton(
                  icon: Icon(Icons.play_arrow, size: 16, color: Colors.white),
                  onPressed: _viewGeneratedCode,
                  tooltip: 'کوڈ چلائیں',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: 200),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: HighlightView(
                msg.text,
                language: widget.project.framework.toLowerCase(),
                theme: atomOneDarkTheme,
                padding: EdgeInsets.all(0),
                textStyle: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  void _showCopyOptions(BuildContext context, String text) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              Text(
                'آپشنز',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Divider(color: Colors.white.withOpacity(0.1)),
              ListTile(
                leading: Icon(Icons.content_copy, color: Color(0xFF8B5CF6)),
                title: Text(
                  'متن کاپی کریں',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                onTap: () {
                  _copyText(text);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.paste, color: Color(0xFF0EA5E9)),
                title: Text(
                  'یہاں پیسٹ کریں',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                onTap: () {
                  _controller.text = text;
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ متن کاپی ہو گیا!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildMagicDesignButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF8B5CF6).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isGeneratingUI ? null : _generateUIDesign,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isGeneratingUI)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        else
                          Icon(Icons.auto_awesome, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          _isGeneratingUI ? 'ڈیزائن بن رہا ہے...' : '🎨 Magic Design',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _generateCompleteUIKit,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Icon(
                    Icons.widgets,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileManager = ChatFileManager(
      geminiService: widget.geminiService,
      project: widget.project,
      onFileUploaded: (String fileName, String? content) {
        String prompt = """
میں نے ایک فائل اپ لوڈ کی ہے۔ براہ کرم اس کے مطابق کوڈ بنائیں۔

فائل کا نام: $fileName
${content != null ? "فائل کا مواد: $content" : "فائل اپ لوڈ ہو گئی ہے۔"}

فریم ورک: ${widget.project.framework}
پلیٹ فارمز: ${widget.project.platforms.join(', ')}
""";
        _controller.text = prompt;
      },
    );

    final adManager = ChatAdManager(
      geminiService: widget.geminiService,
      project: widget.project,
      onCampaignCreated: (AdCampaign campaign) {
        widget.project.addAdCampaign(campaign);
      },
    );

    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          "AI Assistant",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.palette),
            tooltip: 'Magic Design',
            onPressed: _controller.text.isNotEmpty ? _generateUIDesign : null,
          ),
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'AI سے APIs ڈھونڈیں',
            onPressed: _isAIThinking ? null : _discoverApisWithAI,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            color: Color(0xFF1E293B),
            onSelected: (value) {
              switch (value) {
                case 'code':
                  _viewGeneratedCode();
                  break;
                case 'debug':
                  _debugCurrentCode();
                  break;
                case 'api':
                  _startApiIntegration(
                    ApiTemplate(
                      id: 'sample_${DateTime.now().millisecondsSinceEpoch}',
                      name: 'Google Gemini AI',
                      provider: 'Google',
                      url: 'https://makersuite.google.com/app/apikey',
                      description: 'مفت Gemini AI API key حاصل کریں',
                      keyRequired: true,
                      freeTierInfo: 'روزانہ 60 requests مفت',
                      category: 'AI',
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'code',
                child: Row(
                  children: [
                    Icon(Icons.code, color: Color(0xFF8B5CF6), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'کوڈ دیکھیں',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'debug',
                child: Row(
                  children: [
                    Icon(Icons.bug_report, color: Color(0xFF10B981), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'ڈیبگ کریں',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'api',
                child: Row(
                  children: [
                    Icon(Icons.api, color: Color(0xFF0EA5E9), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'API انٹیگریٹ',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Project Info & Status
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.project.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF334155),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.project.framework,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF334155),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.project.platforms.join(', '),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Color(0xFF0EA5E9),
                        ),
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isConnected ? Color(0xFF10B981) : Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isConnected ? Icons.check_circle : Icons.warning,
                            size: 12,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            _connectionMessage.split(' ').first,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Magic Design Button
          _buildMagicDesignButton(),

          // Design Preview (اگر موجود ہو)
          if (_showDesignPreview && _latestUIDesign != null)
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(0xFF8B5CF6).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '🎨 ڈیزائن پریویو',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 18, color: Colors.white70),
                        onPressed: () {
                          setState(() => _showDesignPreview = false);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // ڈیزائن پریویو ویجیٹ
                  UIDesignPreview(designData: _latestUIDesign!),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _convertDesignToCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8B5CF6),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.code, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'کوڈ میں تبدیل کریں',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Messages List
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF0F172A),
              ),
              child: ListView.builder(
                padding: EdgeInsets.only(top: 16),
                itemCount: _messages.length,
                reverse: false,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),
          ),

          // AI Thinking Indicator
          if (_isAIThinking)
            Container(
              padding: EdgeInsets.all(16),
              color: Color(0xFF1E293B),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    "AI سوچ رہا ہے...",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // File Upload Section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Color(0xFF1E293B),
            child: fileManager.buildFileUploadButtons(context),
          ),

          // Input Section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF1E293B),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF334155),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: "اپنی ایپ کی تفصیل لکھیں...",
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            onSubmitted: _sendMessage,
                            maxLines: 3,
                            minLines: 1,
                          ),
                        ),
                        if (_controller.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear, color: Colors.white70),
                            onPressed: () => _controller.clear(),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0EA5E9), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF0EA5E9).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isAIThinking ? null : () => _sendMessage(_controller.text),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 48,
                        height: 48,
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🎨 نیا: UI Design Preview Widget
class UIDesignPreview extends StatelessWidget {
  final Map<String, dynamic> designData;

  const UIDesignPreview({super.key, required this.designData});

  @override
  Widget build(BuildContext context) {
    final componentType = designData['componentType'] ?? 'container';
    final style = designData['style'] ?? {};
    final properties = designData['properties'] ?? {};

    final bgColor = _parseColor(style['backgroundColor'] ?? '#6366F1');
    final borderRadius = (style['borderRadius'] ?? 16.0).toDouble();
    final hasGradient = style['gradient'] != null;

    List<Color> gradientColors = [bgColor, bgColor];
    if (hasGradient) {
      final gradient = style['gradient'];
      final colors = gradient['colors'] ?? ['#6366F1', '#8B5CF6'];
      gradientColors = colors.map((c) => _parseColor(c)).toList();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: hasGradient
            ? LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: hasGradient ? null : bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                componentType.toUpperCase(),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'AI Generated',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // ڈیزائن کی visual نمائش
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(borderRadius / 2),
            ),
            child: Center(
              child: Icon(
                _getIconForComponent(componentType),
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildDesignFeature('Border Radius', '$borderRadius'),
              SizedBox(width: 12),
              _buildDesignFeature('Gradient', hasGradient ? 'Yes' : 'No'),
              SizedBox(width: 12),
              _buildDesignFeature('Shadow', 'Medium'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesignFeature(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.7),
              fontSize: 9,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      String hex = colorString.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Color(0xFF6366F1);
    }
  }

  IconData _getIconForComponent(String type) {
    switch (type.toLowerCase()) {
      case 'button':
        return Icons.touch_app;
      case 'card':
        return Icons.dashboard;
      case 'textfield':
        return Icons.text_fields;
      case 'appbar':
        return Icons.web_asset;
      case 'navbar':
        return Icons.navigation;
      default:
        return Icons.widgets;
    }
  }
}
