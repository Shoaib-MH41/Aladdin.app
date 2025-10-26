import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/project_model.dart';
import 'package:permission_handler/permission_handler.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _animationFile;
  File? _iconFile;
  File? _fontFile';

  Future<void> _pickFile(String type) async {
    try {
      // ✅ نئے Android 13+ permissions کے لیے
      PermissionStatus status;
      
      if (Platform.isAndroid) {
        // Android 13+ (API level 33) کے لیے
        if (await Permission.mediaLibrary.isGranted) {
          status = Permission.mediaLibrary;
        } else {
          status = await Permission.mediaLibrary.request();
        }
      } else {
        // پرانے Android versions کے لیے
        status = await Permission.storage.request();
      }

      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Storage permission denied")),
        );
        return;
      }

      // ✅ فائل picker کو کھولیں
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _getAllowedExtensions(type),
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        
        // ✅ فائل کے path کو چیک کریں
        if (file.path != null) {
          setState(() {
            if (type == 'Animation') {
              _animationFile = File(file.path!);
            } else if (type == 'Icon') {
              _iconFile = File(file.path!);
            } else if (type == 'Font') {
              _fontFile = File(file.path!);
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$type فائل منتخب ہو گئی: ${file.name}")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("فائل کا راستہ نہیں ملا")),
          );
        }
      }
    } catch (e) {
      print("File picker error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فائل منتخب کرنے میں خرابی: $e")),
      );
    }
  }

  List<String> _getAllowedExtensions(String type) {
    switch (type) {
      case 'Animation':
        return ['json', 'lottie'];
      case 'Font':
        return ['ttf', 'otf'];
      case 'Icon':
        return ['png', 'jpg', 'jpeg', 'svg'];
      default:
        return [];
    }
  }

  bool _canContinue() {
    final Project project = ModalRoute.of(context)!.settings.arguments as Project;

    if ((project.features['animation'] ?? 'none') != "none" && _animationFile == null) {
      return false;
    }

    if ((project.features['font'] ?? 'default') != "default" && _fontFile == null) {
      return false;
    }

    return true;
  }

  // ✅ Permission settings پر جانے کا function
  void _openAppSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final Project project = ModalRoute.of(context)!.settings.arguments as Project;

    return Scaffold(
      appBar: AppBar(
        title: const Text("ایسٹس اپ لوڈ کریں"),
        backgroundColor: Colors.deepPurple,
        actions: [
          // ✅ Settings کا بٹن اگر permission نہ ملے
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _openAppSettings,
            tooltip: "Permission settings",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Permission Warning Card (نیا شامل کریں)
            Card(
              color: Colors.orange[50],
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "اگر فائل مینیجر نہ کھلے تو اوپر والے settings بٹن پر کلک کریں اور storage permission دیں",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),

            // باقی کوڈ ویسا ہی رہے گا...
            // ... آپ کا موجودہ build method کا باقی حصہ
          ],
        ),
      ),
    );
  }

  // باقی تمام functions ویسے ہی رہیں گے...
  // _buildSummaryRow, _buildUploadSection, etc.
}
