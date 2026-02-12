// lib/screens/chat/chat_main_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/project_model.dart';
import '../../services/gemini_service.dart';
import '../../services/github_service.dart';

// ✅ تمام 6 فائلوں کے imports
import 'chat_controller.dart';
import 'chat_input.dart';
import 'chat_message.dart';
import 'chat_ad_manager.dart';      // ✅ نیا
import 'chat_file_manager.dart';    // ✅ نیا
import 'ui_design_preview.dart';    // ✅ نیا

/// 🏠 Main Chat Screen - صرف UI اور Scaffold
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
  
  // ✅ نئے managers
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
    
    // ✅ managers initialize کریں
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
          backgroundColor: Color(0xFF0F172A),
          appBar: _buildAppBar(),
          body: Column(
            children: [
              // Project Info Header
              _buildProjectHeader(),
              
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
              
              // ✅ File Upload Section (اب کام کرے گا)
              _fileManager.buildFileUploadButtons(context),
              
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
        // Magic Design
        IconButton(
          icon: Icon(Icons.palette),
          tooltip: 'Magic Design',
          onPressed: _controller.textController.text.isNotEmpty 
              ? _controller.generateUIDesign 
              : null,
        ),
        // Search APIs
        IconButton(
          icon: Icon(Icons.search),
          tooltip: 'AI سے APIs ڈھونڈیں',
          onPressed: _controller.isAIThinking ? null : () => _controller.discoverApis(context),
        ),
        // More Options
        _buildPopupMenu(),
      ],
    );
  }

  /// 📋 Popup Menu
  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
      color: Color(0xFF1E293B),
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
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'code',
          child: Row(
            children: [
              Icon(Icons.code, color: Color(0xFF8B5CF6), size: 20),
              SizedBox(width: 8),
              Text('کوڈ دیکھیں', style: GoogleFonts.poppins(color: Colors.white)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'debug',
          child: Row(
            children: [
              Icon(Icons.bug_report, color: Color(0xFF10B981), size: 20),
              SizedBox(width: 8),
              Text('ڈیبگ کریں', style: GoogleFonts.poppins(color: Colors.white)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'uikit',
          child: Row(
            children: [
              Icon(Icons.widgets, color: Color(0xFFEC4899), size: 20),
              SizedBox(width: 8),
              Text('UI Kit بنائیں', style: GoogleFonts.poppins(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  /// 📊 Project Header
  Widget _buildProjectHeader() {
    return Container(
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
              _buildTag(widget.project.framework, Color(0xFF8B5CF6)),
              SizedBox(width: 8),
              _buildTag(widget.project.platforms.join(', '), Color(0xFF0EA5E9)),
              Spacer(),
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFF334155),
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _controller.isConnected ? Color(0xFF10B981) : Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            _controller.isConnected ? Icons.check_circle : Icons.warning,
            size: 12,
            color: Colors.white,
          ),
          SizedBox(width: 6),
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

  /// ✨ Magic Design Button
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
                  onTap: _controller.isGeneratingUI ? null : _controller.generateUIDesign,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_controller.isGeneratingUI)
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
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _controller.generateUIKit(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Icon(Icons.widgets, color: Color(0xFF8B5CF6)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎨 Design Preview Panel - ✅ UIDesignPreview استعمال کریں
  Widget _buildDesignPreview() {
    return Container(
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
                onPressed: _controller.hideDesignPreview,
              ),
            ],
          ),
          SizedBox(height: 12),
          // ✅ UIDesignPreview استعمال کریں
          UIDesignPreview(designData: _controller.latestUIDesign!),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _controller.convertDesignToCode(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 48),
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
        ],
      ),
    );
  }

  /// 💬 Messages List
  Widget _buildMessagesList() {
    return Container(
      color: Color(0xFF0F172A),
      child: ListView.builder(
        controller: _controller.scrollController,
        padding: EdgeInsets.only(top: 16, bottom: 16),
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
      padding: EdgeInsets.all(16),
      color: Color(0xFF1E293B),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
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
    );
  }
}
