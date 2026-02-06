// lib/screens/chat/chat_file_manager.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

import '../../services/gemini_service.dart';  // ✅ ریلٹیو پیٹھ
import '../../models/project_model.dart';     // ✅ ریلٹیو پیٹھ

class ChatFileManager {
  final GeminiService geminiService;
  final Project project;
  final Function(String, String?) onFileUploaded;
  
  File? _selectedFile;
  String? _fileName;
  bool _isUploadingFile = false;
  String? _copiedText;
  bool _hasCopiedText = false;

  ChatFileManager({
    required this.geminiService,
    required this.project,
    required this.onFileUploaded,
  });

  Future<void> pickFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'txt'],
      allowMultiple: false,
    );
    
    if (result != null) {
      _isUploadingFile = true;
      _fileName = result.files.single.name;
      _selectedFile = File(result.files.single.path!);
      
      try {
        String? fileContent;
        if (_fileName!.toLowerCase().endsWith('.txt')) {
          fileContent = await _selectedFile!.readAsString();
        } else {
          fileContent = "فائل اپ لوڈ ہو گئی: $_fileName";
        }
        
        onFileUploaded(_fileName!, fileContent);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ فائل اپ لوڈ ہو گئی: $_fileName'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ فائل اپ لوڈ ناکام: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        _isUploadingFile = false;
      }
    }
  }

  Future<void> pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      _fileName = pickedFile.name;
      _selectedFile = File(pickedFile.path);
      
      onFileUploaded(_fileName!, "اسکرین شاٹ اپ لوڈ ہو گئی: $_fileName");
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ اسکرین شاٹ اپ لوڈ ہو گئی: $_fileName'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void copyText(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    _copiedText = text;
    _hasCopiedText = true;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ متن کاپی ہو گیا!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    
    Future.delayed(Duration(seconds: 3), () {
      _hasCopiedText = false;
    });
  }

  void pasteText(TextEditingController controller, BuildContext context) {
    if (_copiedText != null && _copiedText!.isNotEmpty) {
      controller.text = _copiedText!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ متن پیسٹ ہو گیا!'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ کاپی کرنے کے لیے پہلے کوئی متن کاپی کریں'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget buildFileUploadButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: _isUploadingFile 
                ? CircularProgressIndicator(strokeWidth: 2)
                : Icon(Icons.attach_file, size: 22),
            onPressed: _isUploadingFile ? null : () => pickFile(context),
            tooltip: 'فائل اپ لوڈ کریں',
            color: Colors.blue,
          ),
          
          IconButton(
            icon: Icon(Icons.image, size: 22),
            onPressed: _isUploadingFile ? null : () => pickImage(context),
            tooltip: 'اسکرین شاٹ اپ لوڈ کریں',
            color: Colors.green,
          ),
          
          if (_hasCopiedText)
            IconButton(
              icon: Icon(Icons.check, size: 18),
              onPressed: null,
              tooltip: 'متن کاپی ہو گیا',
              color: Colors.green,
            ),
          
          IconButton(
            icon: Icon(Icons.content_copy, size: 20),
            onPressed: _copiedText == null ? null : () => copyText(_copiedText!, context),
            tooltip: 'کاپی شدہ متن دوبارہ کاپی کریں',
            color: _copiedText == null ? Colors.grey : Colors.blue,
          ),
          
          if (_fileName != null && _fileName!.length < 15)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _fileName!,
                style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
              ),
            ),
        ],
      ),
    );
  }
}
