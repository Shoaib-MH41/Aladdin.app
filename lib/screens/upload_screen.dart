// lib/screens/upload_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/project_model.dart';

class UploadScreen extends StatefulWidget {
  final Project? project;
  
  const UploadScreen({super.key, this.project});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  // ============= 📁 FILE LISTS =============
  List<File> _iconFiles = [];
  List<File> _fontFiles = [];
  List<File> _animationFiles = [];
  List<File> _firebaseJsonFiles = [];  // ✅ NEW: Firebase JSON files
  List<File> _allSelectedFiles = [];

  // ============= ⚡ UI STATE =============
  bool _isPicking = false;
  bool _isUploading = false;
  String _currentOperation = '';

  @override
  void initState() {
    super.initState();
    _requestFilePermission();
  }

  // ============= 🔐 PERMISSIONS =============
  
  Future<bool> _requestFilePermission() async {
    try {
      if (Platform.isAndroid) {
        // Android 13+ (API 33+)
        if (await Permission.photos.isDenied ||
            await Permission.videos.isDenied ||
            await Permission.audio.isDenied) {
          await [
            Permission.photos,
            Permission.videos,
            Permission.audio,
          ].request();
        }

        // Android 10-12
        if (await Permission.storage.isDenied) {
          await Permission.storage.request();
        }

        // Check if any permission granted
        if (await Permission.storage.isGranted ||
            await Permission.photos.isGranted ||
            await Permission.videos.isGranted ||
            await Permission.audio.isGranted) {
          return true;
        }

        // If permanently denied
        if (await Permission.storage.isPermanentlyDenied ||
            await Permission.photos.isPermanentlyDenied) {
          _showPermissionSettingsDialog();
          return false;
        }

        _showPermissionDialog('Storage permission is required to open file manager.');
        return false;
      }

      if (Platform.isIOS) {
        final status = await Permission.photos.request();
        return status.isGranted;
      }

      return true;
    } catch (e) {
      debugPrint('❌ Permission Error: $e');
      return false;
    }
  }

  void _showPermissionDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Storage Access Needed'),
        content: const Text(
          'This app needs access to your files for uploads.\n\n'
          'Please allow storage or media access in App Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // ============= 📁 FILE PICKER =============

  Future<void> _pickFiles(String type) async {
    try {
      setState(() {
        _isPicking = true;
        _currentOperation = 'Opening file manager...';
      });

      // Allowed extensions based on type
      List<String> allowedExtensions = [];
      switch (type) {
        case 'icon':
          allowedExtensions = ['png', 'jpg', 'jpeg', 'svg', 'webp', 'ico'];
          break;
        case 'font':
          allowedExtensions = ['ttf', 'otf', 'woff', 'woff2'];
          break;
        case 'animation':
          allowedExtensions = ['json', 'lottie', 'zip', 'gif'];
          break;
        case 'firebase_json':
          allowedExtensions = ['json', 'plist'];  // ✅ Firebase files
          break;
      }

      FilePickerResult? result;
      try {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: allowedExtensions,
          allowMultiple: true,
          dialogTitle: 'Select ${type.toUpperCase()} Files',
        );
      } catch (e) {
        debugPrint('⚠️ FilePicker error: $e');
        // Fallback
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: true,
        );
      }

      if (result == null || result.files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No files selected')),
        );
        return;
      }

      List<File> selectedFiles = [];
      for (final file in result.files) {
        if (file.path != null) {
          final f = File(file.path!);
          if (await f.exists()) selectedFiles.add(f);
        }
      }

      setState(() {
        switch (type) {
          case 'icon':
            _iconFiles.addAll(selectedFiles);
            break;
          case 'font':
            _fontFiles.addAll(selectedFiles);
            break;
          case 'animation':
            _animationFiles.addAll(selectedFiles);
            break;
          case 'firebase_json':
            _firebaseJsonFiles.addAll(selectedFiles);  // ✅ Add to Firebase list
            break;
        }
        _allSelectedFiles.addAll(selectedFiles);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${selectedFiles.length} ${type}(s) selected'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('❌ File Pick Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isPicking = false;
        _currentOperation = '';
      });
    }
  }

  // ============= ☁️ UPLOAD ALL =============

  Future<void> _uploadAllFilesTogether(Project project) async {
    try {
      setState(() {
        _isUploading = true;
        _currentOperation = 'Uploading files...';
      });

      final allFiles = [
        ..._iconFiles,
        ..._fontFiles,
        ..._animationFiles,
        ..._firebaseJsonFiles,  // ✅ Include Firebase files
      ];

      if (allFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No files selected')),
        );
        return;
      }

      // Simulate upload (in real app, upload to server/GitHub)
      for (final file in allFiles) {
        await Future.delayed(const Duration(milliseconds: 400));
        debugPrint('Uploaded: ${file.path}');
      }

      // Save paths to project assets
      project.assets['icons'] = _iconFiles.map((e) => e.path).toList();
      project.assets['fonts'] = _fontFiles.map((e) => e.path).toList();
      project.assets['animations'] = _animationFiles.map((e) => e.path).toList();
      project.assets['firebase_json'] = _firebaseJsonFiles.map((e) => e.path).toList();  // ✅ Save Firebase paths

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Uploaded ${allFiles.length} files successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to next screen
      Navigator.pushNamed(context, '/chat', arguments: project);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
        _currentOperation = '';
      });
    }
  }

  // ============= 🗑️ DELETE FILE =============

  void _deleteFile(List<File> fileList, File file) {
    setState(() {
      fileList.remove(file);
      _allSelectedFiles.remove(file);
    });
  }

  // ============= 🎨 UI BUILD =============

  @override
  Widget build(BuildContext context) {
    // Get project from either constructor or route arguments
    final Project project;
    if (widget.project != null) {
      project = widget.project!;
    } else {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(child: Text('No project provided')),
        );
      }
      project = args as Project;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('📁 Upload Assets'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isPicking || _isUploading
          ? _buildLoadingState()
          : _buildMainContent(project),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(_currentOperation),
        ],
      ),
    );
  }

  Widget _buildMainContent(Project project) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildAssetSection('🖼️ Icons', _iconFiles, 'icon', Icons.image),
          const SizedBox(height: 8),
          _buildAssetSection('🔤 Fonts', _fontFiles, 'font', Icons.font_download),
          const SizedBox(height: 8),
          _buildAssetSection('🎬 Animations', _animationFiles, 'animation', Icons.animation),
          const SizedBox(height: 8),
          _buildFirebaseSection(),  // ✅ NEW: Firebase JSON section
          const SizedBox(height: 20),
          _buildUploadButton(project),
        ],
      ),
    );
  }

  // ✅ NEW: Firebase JSON Section
  Widget _buildFirebaseSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(FontAwesomeIcons.fire, color: Colors.orange, size: 20),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '🔥 Firebase Configuration',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                _buildAddButton('firebase_json'),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📱 Login System کے لیے JSON files:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.android, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      const Text('Android: ', style: TextStyle(fontWeight: FontWeight.w500)),
                      Expanded(
                        child: Text(
                          'google-services.json',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.apple, color: Colors.black, size: 16),
                      const SizedBox(width: 4),
                      const Text('iOS: ', style: TextStyle(fontWeight: FontWeight.w500)),
                      Expanded(
                        child: Text(
                          'GoogleService-Info.plist',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (_firebaseJsonFiles.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '⚠️ کوئی JSON فائل منتخب نہیں',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              )
            else
              Column(
                children: _firebaseJsonFiles.map((file) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.insert_drive_file, color: Colors.orange),
                    title: Text(
                      file.path.split('/').last,
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _deleteFile(_firebaseJsonFiles, file),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetSection(String title, List<File> files, String type, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                _buildAddButton(type),
              ],
            ),
            const SizedBox(height: 8),
            if (files.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('کوئی فائل منتخب نہیں'),
              )
            else
              Column(
                children: files.map((file) {
                  return ListTile(
                    dense: true,
                    leading: Icon(icon, size: 18),
                    title: Text(
                      file.path.split('/').last,
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _deleteFile(files, file),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(String type) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        icon: const Icon(Icons.add, size: 20),
        style: IconButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(0),
        ),
        onPressed: () => _pickFiles(type),
      ),
    );
  }

  Widget _buildUploadButton(Project project) {
    return ElevatedButton.icon(
      onPressed: () => _uploadAllFilesTogether(project),
      icon: const Icon(Icons.cloud_upload),
      label: const Text(
        'Upload All & Continue',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
