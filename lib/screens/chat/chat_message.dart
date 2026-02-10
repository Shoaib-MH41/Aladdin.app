// lib/screens/chat/chat_message.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/chat_model.dart';
import 'chat_controller.dart';

/// 💬 Chat Message Widget - مکمل message bubble کاپی/ڈیلیٹ سمیت
class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final ChatController controller;
  final String framework;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.controller,
    required this.framework,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == "user";
    final isDesign = message.isDesign;
    final isCode = message.isCode;

    return GestureDetector(
      onLongPress: () => _showMessageOptions(context),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Avatar
            if (!isUser)
              _buildAvatar(isAI: true),
            
            SizedBox(width: 8),
            
            // Message Bubble
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.78,
                ),
                padding: EdgeInsets.all(isCode ? 12 : 14),
                decoration: BoxDecoration(
                  color: _getBubbleColor(isUser, isDesign),
                  borderRadius: BorderRadius.only(
                    topLeft: isUser ? Radius.circular(20) : Radius.circular(4),
                    topRight: isUser ? Radius.circular(4) : Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: isDesign
                    ? _buildDesignPreview(context)
                    : isCode
                        ? _buildCodeView(context)
                        : _buildTextMessage(context, isUser),
              ),
            ),
            
            SizedBox(width: 8),
            
            // User Avatar
            if (isUser)
              _buildAvatar(isAI: false),
          ],
        ),
      ),
    );
  }

  /// 👤 Avatar Widget
  Widget _buildAvatar({required bool isAI}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAI 
              ? [Color(0xFF6366F1), Color(0xFF8B5CF6)]
              : [Color(0xFF10B981), Color(0xFF34D399)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isAI ? Icons.auto_awesome : Icons.person,
        size: 16,
        color: Colors.white,
      ),
    );
  }

  /// 📝 Text Message
  Widget _buildTextMessage(BuildContext context, bool isUser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message.text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white,
            height: 1.5,
          ),
        ),
        SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              _formatTime(message.timestamp),
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            if (isUser) ...[
              SizedBox(width: 4),
              Icon(Icons.done_all, size: 12, color: Colors.white.withOpacity(0.6)),
            ],
          ],
        ),
      ],
    );
  }

  /// 💻 Code View
  Widget _buildCodeView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
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
                _buildActionButton(
                  icon: Icons.content_copy,
                  onTap: () => _copyToClipboard(context, message.text),
                  tooltip: 'کاپی',
                ),
                _buildActionButton(
                  icon: Icons.play_arrow,
                  onTap: () => controller.viewGeneratedCode(context),
                  tooltip: 'چلائیں',
                ),
                _buildActionButton(
                  icon: Icons.share,
                  onTap: () => _shareCode(context),
                  tooltip: 'شیئر',
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
        // Code Block
        Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: 250),
          decoration: BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SingleChildScrollView(
              child: HighlightView(
                message.text,
                language: framework.toLowerCase(),
                theme: atomOneDarkTheme,
                padding: EdgeInsets.all(12),
                textStyle: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 6),
        Text(
          _formatTime(message.timestamp),
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  /// 🎨 Design Preview
  Widget _buildDesignPreview(BuildContext context) {
    final designData = message.designData!;
    final componentType = designData['componentType'] ?? 'container';
    final label = designData['label'] ?? 'AI Design';

    return GestureDetector(
      onTap: () {
        controller.latestUIDesign = designData;
        controller.showDesignPreview = true;
        controller.notifyListeners();
      },
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
                  fontSize: 13,
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
                Icon(Icons.design_services, size: 40, color: Colors.white),
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
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    componentType.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'ٹیپ کریں کوڈ میں تبدیل کرنے کے لیے',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 4),
          Text(
            _formatTime(message.timestamp),
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔘 Action Button
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.all(6),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// 📋 Show Message Options (Copy/Delete/Edit)
  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            
            Text(
              'میسج آپشنز',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            
            Divider(color: Colors.white.withOpacity(0.1)),
            
            // Copy
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF8B5CF6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.content_copy, color: Color(0xFF8B5CF6)),
              ),
              title: Text(
                'کاپی کریں',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              subtitle: Text(
                'متن کلپ بورڈ پر کاپی کریں',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              onTap: () {
                _copyToClipboard(context, message.text);
                Navigator.pop(context);
              },
            ),
            
            // Edit (only for user messages)
            if (message.sender == "user")
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF0EA5E9).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.edit, color: Color(0xFF0EA5E9)),
                ),
                title: Text(
                  'ایڈٹ کریں',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                subtitle: Text(
                  'ان پٹ باکس میں لے جائیں',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  controller.editMessage(message.text);
                  Navigator.pop(context);
                },
              ),
            
            // Delete
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFEF4444).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.delete, color: Color(0xFFEF4444)),
              ),
              title: Text(
                'ڈیلیٹ کریں',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              subtitle: Text(
                'یہ میسج ہٹا دیں',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              onTap: () {
                controller.deleteMessage(message.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🗑️ میسج ڈیلیٹ ہو گیا'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// 📋 Copy to Clipboard
  void _copyToClipboard(BuildContext context, String text) {
    controller.copyMessage(text, context);
  }

  /// 📤 Share Code
  void _shareCode(BuildContext context) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📤 شیئر کرنے کا فیچر جلد آرہا ہے'),
        backgroundColor: Color(0xFF0EA5E9),
      ),
    );
  }

  /// 🎨 Get Bubble Color
  Color _getBubbleColor(bool isUser, bool isDesign) {
    if (isUser) return Color(0xFF0EA5E9);
    if (isDesign) return Color(0xFF8B5CF6);
    return Color(0xFF1E293B);
  }

  /// 🕐 Format Time
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
