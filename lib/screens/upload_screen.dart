// lib/screens/upload_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../models/project_model.dart';

class UploadScreen extends StatefulWidget {
  final Project? project;
  
  const UploadScreen({super.key, this.project});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  List<File> _iconFiles = [];
  List<File> _fontFiles = [];
  List<File> _animationFiles = [];
  List<File> _allSelectedFiles = [];

  bool _isPicking = false;
  bool _isUploading = false;
  String _currentOperation = '';

  // ============= 🔐 Permission Methods =============
  
  Future<bool> _requestFilePermission() async {
    try {
      if (Platform.isAndroid) {
        if (await Permission.photos.isDenied ||
            await Permission.videos.isDenied ||
            await Permission.audio.isDenied) {
          await [
            Permission.photos,
            Permission.videos,
            Permission.audio,
          ].request();
        }

        if (await Permission.storage.isDenied) {
          await Permission.storage.request();
        }

        if (await Permission.storage.isGranted ||
            await Permission.photos.isGranted ||
            await Permission.videos.isGranted ||
            await Permission.audio.isGranted) {
          return true;
        }

        if (await Permission.storage.isPermanentlyDenied ||
            await Permission.photos.isPermanentlyDenied) {
          _showPermissionSettingsDialog();
          return false;
        }

        _showPermissionDialog(
            'Storage permission is required to open the full File Manager.');
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
          'This app needs access to your files for icon, font, and animation uploads.\n\n'
          'Please allow storage or media access in App Settings.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
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

  // ============= 📁 File Picker Methods =============

  Future<void> _pickFiles(String type) async {
    try {
      setState(() {
        _isPicking = true;
        _currentOperation = 'Opening file manager...';
      });

      FilePickerResult? result;
      try {
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: true,
          dialogTitle: 'Select ${type.toUpperCase()} Files',
        );
      } catch (e) {
        debugPrint('⚠️ FilePicker error: $e');
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: [
            'png', 'jpg', 'jpeg', 'svg', 'webp', 'ttf', 'otf', 'json', 'zip'
          ],
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
        if (type == 'icon') _iconFiles.addAll(selectedFiles);
        if (type == 'font') _fontFiles.addAll(selectedFiles);
        if (type == 'animation') _animationFiles.addAll(selectedFiles);
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

  // ============= ☁️ Upload Methods =============

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
      ];

      if (allFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No files selected')),
        );
        return;
      }

      for (final file in allFiles) {
        await Future.delayed(const Duration(milliseconds: 400));
        debugPrint('Uploaded: ${file.path}');
      }

      project.assets['icons'] = _iconFiles.map((e) => e.path).toList();
      project.assets['fonts'] = _fontFiles.map((e) => e.path).toList();
      project.assets['animations'] = _animationFiles.map((e) => e.path).toList();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Uploaded ${allFiles.length} files successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushNamed(context, '/publish', arguments: project);
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

  Future<void> _downloadToLocal(File file) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final newFile = File('${dir.path}/${file.path.split('/').last}');
      await file.copy(newFile.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to ${newFile.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  // ============= 🎨 UI Build Methods =============

  @override
  Widget build(BuildContext context) {
    // ✅ FIX 1: Project کو صحیح طریقے سے حاصل کریں
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

  Widget _buildLoadingState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(_currentOperation),
          ],
        ),
      );

  Widget _buildMainContent(Project project) => Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildAssetSection('🖼️ Icons', _iconFiles, 'icon', project),
            _buildAssetSection('🔤 Fonts', _fontFiles, 'font', project),
            _buildAssetSection('🎬 Animations', _animationFiles, 'animation', project),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _uploadAllFilesTogether(project),
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Upload All & Continue'),
            ),
          ],
        ),
      );

  Widget _buildAssetSection(
      String title, List<File> files, String type, Project project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _pickFiles(type),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (files.isEmpty)
              const Text('No files selected')
            else
              Column(
                children: files
                    .map((f) => ListTile(
                          title: Text(f.path.split('/').last),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              // ✅ FIX 2: setState کو صحیح طریقے سے استعمال کریں
                              setState(() {
                                files.remove(f);
                                _allSelectedFiles.remove(f);
                              });
                            },
                          ),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
