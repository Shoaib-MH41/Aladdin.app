// lib/screens/chat/chat_input.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'chat_controller.dart';

/// 📝 Chat Input Widget - WhatsApp/ChatGPT style
class ChatInput extends StatefulWidget {
  final ChatController controller;
  final VoidCallback onSend;
  final Function(String fileName, String? content) onFileUploaded;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onFileUploaded,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔥 + بٹن (اب صرف BottomSheet کھولے گا)
            _buildAttachmentButton(context),
            
            SizedBox(height: 8),
            
            // 📝 Main Input Field
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
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
                            controller: widget.controller.textController,
                            focusNode: _focusNode,
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
                            onSubmitted: (_) => widget.onSend(),
                            maxLines: 5,
                            minLines: 1,
                            textInputAction: TextInputAction.send,
                          ),
                        ),
                        // Clear button
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: widget.controller.textController,
                          builder: (context, value, child) {
                            if (value.text.isNotEmpty) {
                              return IconButton(
                                icon: Icon(Icons.clear, color: Colors.white70, size: 20),
                                onPressed: () => widget.controller.textController.clear(),
                              );
                            }
                            return SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Send Button
                _buildSendButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ➕ Attachment Button - صرف BottomSheet کھولے گا
  Widget _buildAttachmentButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAttachmentMenu(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Color(0xFF8B5CF6), size: 20),
                SizedBox(width: 8),
                Text(
                  'منسلکات',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 📎 Attachment Menu BottomSheet
  Future<void> _showAttachmentMenu(BuildContext context) async {
    // 1. پہلے keyboard بند کریں
    _focusNode.unfocus();
    FocusScope.of(context).unfocus();
    
    // 2. تھوڑا انتظار کریں تاکہ keyboard بند ہو جائے
    await Future.delayed(Duration(milliseconds: 200));
    
    // 3. اب BottomSheet کھولیں
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,  // ✅ Important
      useSafeArea: true,         // ✅ Important
      builder: (context) => _buildAttachmentBottomSheet(context),
    );
  }

  /// 📋 Attachment BottomSheet Content
  Widget _buildAttachmentBottomSheet(BuildContext context) {
    return Container(
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
            'منسلک کریں',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          
          Divider(color: Colors.white.withOpacity(0.1)),
          
          // 📷 Gallery Option
          _buildAttachmentOption(
            icon: Icons.image,
            color: Color(0xFF10B981),
            title: 'گیلری سے تصویر',
            subtitle: 'فون کی گیلری سے منتخب کریں',
            onTap: () {
              Navigator.pop(context);
              _pickImage(context, ImageSource.gallery);
            },
          ),
          
          // 📸 Camera Option
          _buildAttachmentOption(
            icon: Icons.camera_alt,
            color: Color(0xFF0EA5E9),
            title: 'کیمرہ',
            subtitle: 'نئی تصویر کھینچیں',
            onTap: () {
              Navigator.pop(context);
              _pickImage(context, ImageSource.camera);
            },
          ),
          
          // 🎥 Video Option
          _buildAttachmentOption(
            icon: Icons.videocam,
            color: Color(0xFFEF4444),
            title: 'ویڈیو',
            subtitle: 'ویڈیو منتخب کریں',
            onTap: () {
              Navigator.pop(context);
              _pickVideo(context);
            },
          ),
          
          // 📄 File Option
          _buildAttachmentOption(
            icon: Icons.insert_drive_file,
            color: Color(0xFF8B5CF6),
            title: 'فائل',
            subtitle: 'کوئی بھی فائل منتخب کریں',
            onTap: () {
              Navigator.pop(context);
              _pickFile(context);
            },
          ),
          
          // 📋 Paste Option
          _buildAttachmentOption(
            icon: Icons.paste,
            color: Color(0xFFF59E0B),
            title: 'پیسٹ',
            subtitle: 'کلپ بورڈ سے پیسٹ کریں',
            onTap: () {
              Navigator.pop(context);
              _pasteFromClipboard(context);
            },
          ),
          
          SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 🎯 Individual Attachment Option
  Widget _buildAttachmentOption({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.6),
          fontSize: 12,
        ),
      ),
      onTap: onTap,
    );
  }

  /// 📤 Send Button
  Widget _buildSendButton() {
    return Container(
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
          onTap: widget.controller.isAIThinking ? null : widget.onSend,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 48,
            height: 48,
            child: widget.controller.isAIThinking
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  /// 📷 Pick Image
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileName = pickedFile.name;
        
        widget.onFileUploaded(fileName, null);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📷 تصویر منسلک ہو گئی: $fileName'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ تصویر منتخب کرنے میں خرابی: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 🎥 Pick Video
  Future<void> _pickVideo(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: Duration(minutes: 5),
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileName = pickedFile.name;
        
        widget.onFileUploaded(fileName, null);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎥 ویڈیو منسلک ہو گئی: $fileName'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ویڈیو منتخب کرنے میں خرابی: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 📄 Pick File
  Future<void> _pickFile(BuildContext context) async {
    // TODO: Implement file_picker package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📄 فائل پیکر جلد آرہا ہے'),
        backgroundColor: Color(0xFF8B5CF6),
      ),
    );
  }

  /// 📋 Paste from Clipboard
  Future<void> _pasteFromClipboard(BuildContext context) async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        final currentText = widget.controller.textController.text;
        final newText = currentText.isEmpty 
            ? clipboardData!.text! 
            : '$currentText\n${clipboardData!.text}';
        
        widget.controller.textController.text = newText;
        
        widget.controller.textController.selection = TextSelection.fromPosition(
          TextPosition(offset: newText.length),
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📋 پیسٹ ہو گیا!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ پیسٹ ناکام: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
