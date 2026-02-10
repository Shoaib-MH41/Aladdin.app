// lib/screens/chat/chat_input.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'chat_controller.dart';

/// 📝 Chat Input Widget - گلیری سمیت مکمل input سیکشن
class ChatInput extends StatelessWidget {
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
            // 🔥 گلیری اور ٹولز کا row
            _buildToolsRow(context),
            
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
                            controller: controller.textController,
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
                            onSubmitted: (_) => onSend(),
                            maxLines: 5,
                            minLines: 1,
                            textInputAction: TextInputAction.send,
                          ),
                        ),
                        // Clear button
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: controller.textController,
                          builder: (context, value, child) {
                            if (value.text.isNotEmpty) {
                              return IconButton(
                                icon: Icon(Icons.clear, color: Colors.white70, size: 20),
                                onPressed: () => controller.textController.clear(),
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

  /// 🔧 Tools Row - گلیری، کیمرہ، فائل
  Widget _buildToolsRow(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 📷 Gallery / Image
          _buildToolButton(
            icon: Icons.image,
            color: Color(0xFF10B981),
            onTap: () => _pickImage(context, ImageSource.gallery),
            tooltip: 'گیلری سے تصویر',
          ),
          
          // 📸 Camera
          _buildToolButton(
            icon: Icons.camera_alt,
            color: Color(0xFF0EA5E9),
            onTap: () => _pickImage(context, ImageSource.camera),
            tooltip: 'کیمرہ',
          ),
          
          // 📎 File Attachment
          _buildToolButton(
            icon: Icons.attach_file,
            color: Color(0xFF8B5CF6),
            onTap: () => _attachFile(context),
            tooltip: 'فائل منسلک کریں',
          ),
          
          // 📋 Paste
          _buildToolButton(
            icon: Icons.paste,
            color: Color(0xFFF59E0B),
            onTap: () => _pasteFromClipboard(context),
            tooltip: 'پیسٹ',
          ),
          
          // 🎨 Magic Design (اگر text موجود ہو)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.textController,
            builder: (context, value, child) {
              if (value.text.isNotEmpty) {
                return _buildToolButton(
                  icon: Icons.auto_awesome,
                  color: Color(0xFFEC4899),
                  onTap: controller.isGeneratingUI ? null : controller.generateUIDesign,
                  tooltip: 'Magic Design',
                  isLoading: controller.isGeneratingUI,
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  /// 🔘 Individual Tool Button
  Widget _buildToolButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    required String tooltip,
    bool isLoading = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                      ),
                    ),
                  )
                : Icon(icon, color: color, size: 20),
          ),
        ),
      ),
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
          onTap: controller.isAIThinking ? null : onSend,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 48,
            height: 48,
            child: controller.isAIThinking
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

  /// 📷 Pick Image from Gallery/Camera
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
        
        // Show preview in chat
        onFileUploaded(fileName, null);
        
        // You can also read image bytes if needed
        // final bytes = await file.readAsBytes();
        
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

  /// 📎 Attach File
  void _attachFile(BuildContext context) {
    // Implement file picker
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
            ListTile(
              leading: Icon(Icons.image, color: Color(0xFF10B981)),
              title: Text('تصویر', style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.videocam, color: Color(0xFFEF4444)),
              title: Text('ویڈیو', style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Video picker
              },
            ),
            ListTile(
              leading: Icon(Icons.insert_drive_file, color: Color(0xFF8B5CF6)),
              title: Text('فائل', style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // File picker
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 📋 Paste from Clipboard
  Future<void> _pasteFromClipboard(BuildContext context) async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        final currentText = controller.textController.text;
        final newText = currentText.isEmpty 
            ? clipboardData!.text! 
            : '$currentText\n${clipboardData!.text}';
        
        controller.textController.text = newText;
        
        // Move cursor to end
        controller.textController.selection = TextSelection.fromPosition(
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
