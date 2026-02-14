// lib/screens/chat/chat_main_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/project_model.dart';
import '../../services/gemini_service.dart';
import '../../services/github_service.dart';

// ✅ تمام imports
import 'chat_controller.dart';
import 'chat_input.dart';
import 'chat_message.dart';
import 'chat_ad_manager.dart';
import 'chat_file_manager.dart';
import 'ui_design_preview.dart';

// ✅ API Integration Screen کا import
import '../api_integration_screen.dart';
import '../../models/api_template_model.dart';

// ✅ نئے imports - Build اور Publish Guide
import '../build_screen.dart';
import '../publish_guide_screen.dart';

// ✅ نیا: Upload Screen کا import (یہ شامل کریں)
import '../upload_screen.dart';

// ✅ نیا: AdMob Integration Screen کا import (یہ شامل کریں)
import '../admob_integration_screen.dart';

/// 🏠 Main Chat Screen
class ChatMainScreen extends StatefulWidget {
  final GeminiService geminiService;
  final GitHubService githubService;
  final Project project;

  const ChatMainScreen({
    super.key,
    required this.geminiService,
    required this.githubService,
    required this.project,
  });

  @override
  State<ChatMainScreen> createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen> {
  late ChatController _controller;
  late ChatAdManager _adManager;
  late ChatFileManager _fileManager;

  @override
  void initState() {
    super.initState();
    _controller = ChatController(
      geminiService: widget.geminiService,
      githubService: widget.githubService,
      project: widget.project,
    );
    _controller.addListener(_onControllerUpdate);
    
    _adManager = ChatAdManager(
      geminiService: widget.geminiService,
      project: widget.project,
      onCampaignCreated: (campaign) {
        widget.project.addAdCampaign(campaign);
      },
    );
    
    _fileManager = ChatFileManager(
      geminiService: widget.geminiService,
      project: widget.project,
      onFileUploaded: (fileName, content) {
        final prompt = "فائل منسلک: $fileName\n${content ?? ''}";
        _controller.textController.text = prompt;
      },
    );
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: _buildAppBar(),
          body: Column(
            children: [
              // Project Info Header
              _buildProjectHeader(),
              
              // ✅ نیا: Build & Publish Buttons Row
              _buildBuildPublishButtons(),
              
              // Magic Design Button
              _buildMagicDesignButton(),
              
              // Design Preview (if active)
              if (_controller.showDesignPreview && _controller.latestUIDesign != null)
                _buildDesignPreview(),
              
              // Messages List
              Expanded(
                child: _buildMessagesList(),
              ),
              
              // AI Thinking Indicator
              if (_controller.isAIThinking)
                _buildThinkingIndicator(),
              
              // Chat Input with Gallery
              ChatInput(
                controller: _controller,
                onSend: () => _controller.sendMessage(_controller.textController.text),
                onFileUploaded: (fileName, content) {
                  final prompt = "فائل منسلک: $fileName\n${content ?? ''}";
                  _controller.textController.text = prompt;
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 📱 App Bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        "AI Assistant",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFF1E293B),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      actions: [
        // ✅ نیا: Upload Button (AppBar میں)
        IconButton(
          icon: const Icon(Icons.upload_file, color: Color(0xFFFFA726)),
          tooltip: 'فائلیں اپلوڈ کریں',
          onPressed: () => _openUploadScreen(context),
        ),
        
        // ✅ نیا: AdMob Button (AppBar میں)
        IconButton(
          icon: const Icon(Icons.monetization_on, color: Colors.orange),
          tooltip: 'AdMob Integration',
          onPressed: () => _openAdMobIntegration(context),
        ),
        
        // API Integration Button
        IconButton(
          icon: const Icon(Icons.api, color: Color(0xFF8B5CF6)),
          tooltip: 'API انٹیگریشن',
          onPressed: _controller.isAIThinking ? null : () => _openApiIntegration(context),
        ),
        
        // Magic Design
        IconButton(
          icon: const Icon(Icons.palette),
          tooltip: 'Magic Design',
          onPressed: _controller.textController.text.isNotEmpty 
              ? _controller.generateUIDesign 
              : null,
        ),
        
        // Search APIs
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'AI سے APIs ڈھونڈیں',
          onPressed: _controller.isAIThinking ? null : () => _controller.discoverApis(context),
        ),
        
        // More Options
        _buildPopupMenu(),
      ],
    );
  }

  /// ✅ نیا: Upload Screen کھولنے کا فنکشن
  void _openUploadScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadScreen(
          project: widget.project,
        ),
      ),
    );
  }

  /// ✅ نیا: AdMob Integration Screen کھولنے کا فنکشن
  void _openAdMobIntegration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdMobIntegrationScreen(
          onAdMobSubmitted: (appId, adUnitIds) {
            print('✅ App ID: $appId');
            print('✅ Ad Units: $adUnitIds');
            
            // Project میں save کریں
            widget.project.adMobAppId = appId;
            widget.project.adMobAdUnitIds = adUnitIds;
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ AdMob کامیابی سے integrate ہو گیا'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  /// ✅ نیا: Build & Publish Buttons (اہم ترین تبدیلی)
  Widget _buildBuildPublishButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // ⚡ Build Button
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openBuildScreen(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.build, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '⚡ بلڈ کریں',
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
          
          const SizedBox(width: 12),
          
          // 🚀 Publish Guide Button
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0EA5E9).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openPublishGuide(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.rocket_launch, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '🚀 پبلش کریں',
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
        ],
      ),
    );
  }

  /// ⚡ Build Screen کھولیں (نیا فنکشن)
  void _openBuildScreen(BuildContext context) {
    // چیک کریں کہ کوڈ موجود ہے یا نہیں
    final generatedCode = _controller.generatedCode ?? '';
    
    if (generatedCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ پہلے کوڈ جنریٹ کریں! "کوڈ دیکھیں" پر کلک کریں۔'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuildScreen(
          generatedCode: generatedCode,
          projectName: widget.project.name,
          framework: widget.project.framework,
          repoUrl: widget.project.repoUrl, // اگر موجود ہو
        ),
      ),
    );
  }

  /// 🚀 Publish Guide Screen کھولیں (نیا فنکشن)
  void _openPublishGuide(BuildContext context) {
    final generatedCode = _controller.generatedCode ?? '';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PublishGuideScreen(
          appName: widget.project.name,
          generatedCode: generatedCode.isNotEmpty ? generatedCode : '// کوڈ موجود نہیں',
          framework: widget.project.framework,
        ),
      ),
    );
  }

  /// 🔌 API Integration Screen کھولیں
  void _openApiIntegration(BuildContext context) {
    final apiTemplate = ApiTemplate(
      id: 'openai_api_001',
      name: 'OpenAI API',
      provider: 'OpenAI',
      category: 'AI/ML',
      description: 'AI chat اور text generation کے لیے',
      url: 'https://platform.openai.com',
      keyRequired: true,
      freeTierInfo: 'مفت ٹائر دستیاب ہے',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApiIntegrationScreen(
          apiTemplate: apiTemplate,
          onApiKeySubmitted: (apiKey) {
            print('API Key موصول: $apiKey');
            final prompt = "API Key شامل کی گئی: ${apiTemplate.name}\nKey: ${apiKey.isNotEmpty ? '***' : 'خالی'}";
            _controller.textController.text = prompt;
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ API Key کامیابی سے شامل ہو گئی'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  /// 📋 Popup Menu
  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      color: const Color(0xFF1E293B),
      onSelected: (value) {
        switch (value) {
          case 'code':
            _controller.viewGeneratedCode(context);
            break;
          case 'debug':
            _controller.debugCurrentCode(context);
            break;
          case 'uikit':
            _controller.generateUIKit(context);
            break;
          case 'build':
            _openBuildScreen(context);
            break;
          case 'publish':
            _openPublishGuide(context);
            break;
          case 'upload':  // ✅ نیا: Upload option
            _openUploadScreen(context);
            break;
          case 'admob':  // ✅ نیا: AdMob option
            _openAdMobIntegration(context);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'code',
          child: Row(
            children: [
              const Icon(Icons.code, color: Color(0xFF8B5CF6), size: 20),
              const SizedBox(width: 8),
              Text('کوڈ دیکھیں', style: GoogleFonts.poppins(color: Colors.white)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'debug',
          child: Row(
            children: [
              const Icon(Icons.bug_report, color: Color(0xFF10B981), size: 20),
              const SizedBox(width: 8),
              Text('ڈیبگ کریں', style: GoogleFonts.poppins(color: Colors.white)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'uikit',
          child: Row(
            children: [
              const Icon(Icons.widgets, color: Color(0xFFEC4899), size: 20),
              const SizedBox(width: 8),
              Text('UI Kit بنائیں', style: GoogleFonts.poppins(color: Colors.white)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        // ✅ نیا: Upload option
        PopupMenuItem(
          value: 'upload',
          child: Row(
            children: [
              const Icon(Icons.upload_file, color: Color(0xFFFFA726), size: 20),
              const SizedBox(width: 8),
              Text('📁 فائلیں اپلوڈ کریں', style: GoogleFonts.poppins(color: Colors.white)),
            ],
          ),
        ),
        // ✅ نیا: AdMob option
        PopupMenuItem(
          value: 'admob',
          child: Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text('💰 AdMob سیٹ اپ', style: GoogleFonts.poppins(color: Colors.white)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'build',
          child: Row(
            children: [
              const Icon(Icons.build, color: Color(0xFF10B981), size: 20),
              const SizedBox(width: 8),
              Text('⚡ بلڈ کریں', style: GoogleFonts.poppins(color: Colors.white)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'publish',
          child: Row(
            children: [
              const Icon(Icons.rocket_launch, color: Color(0xFF0EA5E9), size: 20),
              const SizedBox(width: 8),
              Text('🚀 پبلش کریں', style: GoogleFonts.poppins(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  /// 📊 Project Header (ویسے ہی)
  Widget _buildProjectHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
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
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTag(widget.project.framework, const Color(0xFF8B5CF6)),
              const SizedBox(width: 8),
              _buildTag(widget.project.platforms.join(', '), const Color(0xFF0EA5E9)),
              const Spacer(),
              _buildConnectionStatus(),
            ],
          ),
        ],
      ),
    );
  }

  /// 🏷️ Tag Widget
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: color,
        ),
      ),
    );
  }

  /// 🔌 Connection Status
  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _controller.isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            _controller.isConnected ? Icons.check_circle : Icons.warning,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            _controller.connectionMessage.split(' ').first,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// ✨ Magic Design Button (ویسے ہی)
  Widget _buildMagicDesignButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _controller.isGeneratingUI ? null : _controller.generateUIDesign,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_controller.isGeneratingUI)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        else
                          const Icon(Icons.auto_awesome, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          _controller.isGeneratingUI ? 'ڈیزائن بن رہا ہے...' : '🎨 Magic Design',
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
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _controller.generateUIKit(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: const Icon(Icons.widgets, color: Color(0xFF8B5CF6)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎨 Design Preview Panel
  Widget _buildDesignPreview() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
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
                icon: const Icon(Icons.close, size: 18, color: Colors.white70),
                onPressed: _controller.hideDesignPreview,
              ),
            ],
          ),
          const SizedBox(height: 12),
          UIDesignPreview(designData: _controller.latestUIDesign!),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _controller.convertDesignToCode(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.code, size: 18),
                const SizedBox(width: 8),
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
        ],
      ),
    );
  }

  /// 💬 Messages List
  Widget _buildMessagesList() {
    return Container(
      color: const Color(0xFF0F172A),
      child: ListView.builder(
        controller: _controller.scrollController,
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        itemCount: _controller.messages.length,
        itemBuilder: (context, index) {
          final message = _controller.messages[index];
          return ChatMessageWidget(
            message: message,
            controller: _controller,
            framework: widget.project.framework,
          );
        },
      ),
    );
  }

  /// 🤔 AI Thinking Indicator
  Widget _buildThinkingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1E293B),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "AI سوچ رہا ہے...",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
