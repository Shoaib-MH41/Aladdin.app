import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/project_model.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _animationFile;
  File? _iconFile;
  File? _fontFile;

  Future<void> _pickFile(String type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _getAllowedExtensions(type),
      );

      if (result != null && result.files.single.path != null) {
        PlatformFile file = result.files.first;
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
          SnackBar(content: Text("$type file selected: ${file.name}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking file: $e")),
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
    
    if (project.features['animation'] != "none" && _animationFile == null) {
      return false;
    }
    
    if (project.features['font'] != "default" && _fontFile == null) {
      return false;
    }
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final Project project = ModalRoute.of(context)!.settings.arguments as Project;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Assets"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Summary Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Project Settings",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.phone_android, size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Text("Platforms: ${project.platforms.join(', ')}"),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.code, size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Text("Framework: ${project.framework}"),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.animation, size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Text("Animation: ${project.features['animation']}"),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.font_download, size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Text("Font: ${project.features['font']}"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Upload Sections
            if (project.features['animation'] != "none") ...[
              _buildUploadSection(
                title: "Animation File",
                subtitle: "Upload Lottie JSON animation file (.json)",
                icon: Icons.animation,
                file: _animationFile,
                type: "Animation",
                isRequired: true,
              ),
              SizedBox(height: 15),
            ],
            
            if (project.features['font'] != "default") ...[
              _buildUploadSection(
                title: "Custom Font", 
                subtitle: "Upload TTF/OTF font file (.ttf, .otf)",
                icon: Icons.font_download,
                file: _fontFile,
                type: "Font",
                isRequired: true,
              ),
              SizedBox(height: 15),
            ],
            
            _buildUploadSection(
              title: "App Icon",
              subtitle: "Upload custom app icon (.png, .jpg, .svg)",
              icon: Icons.image,
              file: _iconFile,
              type: "Icon",
              isRequired: false,
            ),
            
            Spacer(),
            
            // Continue Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canContinue() ? Colors.deepPurple : Colors.grey,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _canContinue() ? () {
                  // فائلیں project میں سیو کریں
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
                } : null,
                child: Text(
                  "Continue to AI Chat",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepPurple),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (isRequired) ...[
                  SizedBox(width: 5),
                  Text("*", style: TextStyle(color: Colors.red, fontSize: 16)),
                ],
              ],
            ),
            SizedBox(height: 5),
            Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 14)),
            SizedBox(height: 10),
            
            if (file != null) ...[
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.path.split('/').last,
                            style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${(file.lengthSync() / 1024).toStringAsFixed(1)} KB",
                            style: TextStyle(color: Colors.green[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: file != null ? Colors.orange : Colors.deepPurple,
                    ),
                    onPressed: () => _pickFile(type),
                    child: Text(
                      file != null ? "Change File" : "Select File",
                      style: TextStyle(color: Colors.white),
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
