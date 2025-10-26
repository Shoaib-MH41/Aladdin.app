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
  File? _fontFile; // ✅ درست - single quote ہٹایا

  Future<void> _pickFile(String type) async {
    try {
      // ✅ Permission درست طریقے سے چیک کریں
      PermissionStatus status;
      
      if (Platform.isAndroid) {
        // Android 13+ (API level 33) کے لیے
        status = await Permission.mediaLibrary.request(); // ✅ درست
      } else {
        // پرانے Android versions کے لیے
        status = await Permission.storage.request();
      }

      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
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
            const SnackBar(content: Text("فائل کا راستہ نہیں ملا")),
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
            icon: const Icon(Icons.settings),
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
            // Permission Warning Card
            Card(
              color: Colors.orange[50],
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[800]),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "اگر فائل مینیجر نہ کھلے تو اوپر والے settings بٹن پر کلک کریں اور storage permission دیں",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Project Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "📋 پروجیکٹ کا خلاصہ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildSummaryRow(
                      icon: Icons.devices,
                      label: "پلیٹ فارمز",
                      value: project.platforms.join(', '),
                    ),
                    _buildSummaryRow(
                      icon: Icons.code,
                      label: "فریم ورک",
                      value: project.framework,
                    ),

                    // Only show if Web selected
                    if (project.platforms.contains("Web"))
                      _buildSummaryRow(
                        icon: Icons.web,
                        label: "ویب بلڈ",
                        value: project.features['webBuild'] ?? "ڈیفالٹ",
                      ),

                    _buildSummaryRow(
                      icon: Icons.animation,
                      label: "اینی میشن",
                      value: project.features['animation'] ?? 'کوئی نہیں',
                    ),
                    _buildSummaryRow(
                      icon: Icons.font_download,
                      label: "فونٹ",
                      value: project.features['font'] ?? 'ڈیفالٹ',
                    ),
                    _buildSummaryRow(
                      icon: Icons.cloud,
                      label: "API انٹیگریشن",
                      value: project.features['api'] ?? 'کوئی نہیں',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Upload Sections
            if ((project.features['animation'] ?? 'none') != "none") ...[
              _buildUploadSection(
                title: "اینی میشن فائل",
                subtitle: "Lottie JSON اینی میشن فائل اپ لوڈ کریں (.json)",
                icon: Icons.animation,
                file: _animationFile,
                type: "Animation",
                isRequired: true,
              ),
              const SizedBox(height: 15),
            ],

            if ((project.features['font'] ?? 'default') != "default") ...[
              _buildUploadSection(
                title: "اپنا فونٹ",
                subtitle: "TTF/OTF فونٹ فائل اپ لوڈ کریں (.ttf, .otf)",
                icon: Icons.font_download,
                file: _fontFile,
                type: "Font",
                isRequired: true,
              ),
              const SizedBox(height: 15),
            ],

            _buildUploadSection(
              title: "ایپ آئیکن",
              subtitle: "اپنا ایپ آئیکن اپ لوڈ کریں (.png, .jpg, .svg)",
              icon: Icons.image,
              file: _iconFile,
              type: "Icon",
              isRequired: false,
            ),

            const Spacer(),

            // Continue Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canContinue() ? Colors.deepPurple : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _canContinue()
                    ? () {
                        // Save files into project
                        if (_animationFile != null) {
                          project.assets['animation'] = _animationFile!.path;
                        }
                        if (_iconFile != null) {
                          project.assets['icon'] = _iconFile!.path;
                        }
                        if (_fontFile != null) {
                          project.assets['font'] = _fontFile!.path;
                        }

                        Navigator.pushNamed(context, '/chat', arguments: project);
                      }
                    : null,
                child: const Text(
                  "AI چیٹ پر جائیں",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required File? file,
    required String type,
    required bool isRequired,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepPurple),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (isRequired) ...[
                  const SizedBox(width: 5),
                  const Text("*",
                      style: TextStyle(color: Colors.red, fontSize: 16)),
                ],
              ],
            ),
            const SizedBox(height: 5),
            Text(subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 10),

            if (file != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.path.split('/').last,
                            style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${(file.lengthSync() / 1024).toStringAsFixed(1)} KB",
                            style: TextStyle(
                                color: Colors.green[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: file != null ? Colors.orange : Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _pickFile(type),
                    child: Text(
                      file != null ? "فائل تبدیل کریں" : "فائل منتخب کریں",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
