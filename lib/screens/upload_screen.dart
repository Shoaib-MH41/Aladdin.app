import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lottie/lottie.dart';
import '../models/project_model.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  List<File> _iconFiles = [];
  List<File> _fontFiles = [];
  List<File> _animationFiles = [];

  bool _isPicking = false;
  String _currentOperation = '';

  /// ✅ Request all required permissions (Android 10–14 + iOS)
  Future<bool> _requestFilePermission() async {
    try {
      if (Platform.isAndroid) {
        // ✅ اگر پہلے سے اجازت ہے
        if (await Permission.storage.isGranted ||
            await Permission.photos.isGranted ||
            await Permission.mediaLibrary.isGranted ||
            await Permission.manageExternalStorage.isGranted) {
          return true;
        }

        // 🔐 Request new permissions
        final statuses = await [
          Permission.storage,
          Permission.photos,
          Permission.mediaLibrary,
          Permission.manageExternalStorage,
        ].request();

        // ✅ اگر کسی بھی permission کو اجازت مل گئی
        if (statuses.values.any((status) => status.isGranted)) {
          return true;
        }

        // ❌ اگر deny کر دیا
        if (statuses.values.any((status) => status.isDenied)) {
          _showPermissionDialog(
              'Storage permission is required to select files from your device.');
        }

        // 🚫 اگر permanently deny کیا گیا
        if (statuses.values
            .any((status) => status.isPermanentlyDenied)) {
          _showPermissionSettingsDialog();
        }

        return false;
      } else if (Platform.isIOS) {
        // ✅ iOS کے لیے Photos permission
        if (await Permission.photos.isGranted) return true;
        final status = await Permission.photos.request();
        return status.isGranted;
      }

      return true;
    } catch (e) {
      debugPrint('❌ Permission error: $e');
      return false;
    }
  }

  void _showPermissionDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
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
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Storage Access Required'),
        content: const Text(
          'This app needs access to your files to select icons, fonts, and animations.\n\n'
          'Please allow "Storage" or "Media" permission from App Settings to continue.',
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

  List<String> _allowedExtensions(String type) {
    switch (type) {
      case 'icon':
        return ['png', 'jpg', 'jpeg', 'svg', 'webp'];
      case 'font':
        return ['ttf', 'otf'];
      case 'animation':
        return ['json'];
      default:
        return [];
    }
  }

  /// ✅ File picker logic
  Future<void> _pickFiles(String type) async {
    try {
      setState(() {
        _isPicking = true;
        _currentOperation = 'Checking permissions...';
      });

      final hasPermission = await _requestFilePermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Permission denied. Please allow storage access to select files.'),
          ),
        );
        return;
      }

      setState(() {
        _currentOperation = 'Opening file picker...';
      });

      FilePickerResult? result;

      try {
        result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: _allowedExtensions(type),
          withData: false,
          dialogTitle: 'Select ${type.toUpperCase()} files',
        );
      } catch (e) {
        debugPrint('⚠️ FilePicker Error: $e');
        result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.any,
          withData: false,
          dialogTitle: 'Select files',
        );
      }

      if (result != null && result.files.isNotEmpty) {
        List<File> selectedFiles = [];
        for (var platformFile in result.files) {
          if (platformFile.path != null &&
              await File(platformFile.path!).exists()) {
            selectedFiles.add(File(platformFile.path!));
          }
        }

        if (selectedFiles.isNotEmpty) {
          setState(() {
            if (type == 'icon') {
              _iconFiles.addAll(selectedFiles);
            } else if (type == 'font') {
              _fontFiles.addAll(selectedFiles);
            } else if (type == 'animation') {
              _animationFiles.addAll(selectedFiles);
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '✅ ${selectedFiles.length} ${type}(s) selected successfully'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ No valid files selected')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File selection cancelled')),
        );
      }
    } catch (e) {
      debugPrint('❌ File pick error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    } finally {
      setState(() {
        _isPicking = false;
        _currentOperation = '';
      });
    }
  }

  Future<void> _downloadToLocal(File file) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final destination = File('${directory.path}/${file.path.split('/').last}');
      await file.copy(destination.path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ File saved to device')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Save failed: $e')),
      );
    }
  }

  void _removeFile(File file, String type) {
    setState(() {
      if (type == 'icon') _iconFiles.remove(file);
      if (type == 'font') _fontFiles.remove(file);
      if (type == 'animation') _animationFiles.remove(file);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🗑️ File removed')),
    );
  }

  bool _canContinue(Project project) {
    if ((project.features['animation'] ?? 'none') != 'none' &&
        _animationFiles.isEmpty) return false;
    if ((project.features['font'] ?? 'default') == 'custom' &&
        _fontFiles.isEmpty) return false;
    return true;
  }

  void _continueToPublish(Project project) {
    if (_iconFiles.isNotEmpty) {
      project.assets['icons'] = _iconFiles.map((e) => e.path).toList();
    }
    if (_fontFiles.isNotEmpty) {
      project.assets['fonts'] = _fontFiles.map((e) => e.path).toList();
    }
    if (_animationFiles.isNotEmpty) {
      project.assets['animations'] = _animationFiles.map((e) => e.path).toList();
    }

    Navigator.pushNamed(context, '/publish', arguments: project);
  }

  @override
  Widget build(BuildContext context) {
    final Project project =
        ModalRoute.of(context)!.settings.arguments as Project;
    return Scaffold(
      appBar: AppBar(
        title: const Text('📁 Upload Assets'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: _isPicking ? _buildLoadingState() : _buildMainContent(project),
    );
  }

  Widget _buildLoadingState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(_currentOperation, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );

  Widget _buildMainContent(Project project) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProjectSummary(project),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildAssetSection(
                      '🎬 Animations', _animationFiles, 'animation', project),
                  const SizedBox(height: 16),
                  _buildAssetSection('🔤 Fonts', _fontFiles, 'font', project),
                  const SizedBox(height: 16),
                  _buildAssetSection('🖼️ Icons', _iconFiles, 'icon', project),
                  const SizedBox(height: 20),
                  _buildContinueButton(project),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildProjectSummary(Project project) => Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Project Summary',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              _buildSummaryItem('Framework', project.framework),
              _buildSummaryItem('Platforms', project.platforms.join(', ')),
              _buildSummaryItem(
                  'Animation', project.features['animation'] ?? 'None'),
              _buildSummaryItem('Font', project.features['font'] ?? 'Default'),
            ],
          ),
        ),
      );

  Widget _buildSummaryItem(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ]),
      );

  Widget _buildAssetSection(
      String title, List<File> files, String type, Project project) {
    final isRequired = _isAssetRequired(type, project);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (isRequired)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4)),
                child: const Text('Required',
                    style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
          ]),
          const SizedBox(height: 12),
          if (files.isEmpty)
            Text(
              isRequired
                  ? '❌ Required - Please select files'
                  : 'No files selected',
              style: TextStyle(
                color: isRequired ? Colors.red : Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Column(
                children:
                    files.map((file) => _filePreviewTile(file, type)).toList()),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text('Add ${title.toLowerCase()}'),
                onPressed: () => _pickFiles(type),
              ),
            ),
            if (files.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ElevatedButton(
                  onPressed: () => _clearFiles(type),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  child: const Icon(Icons.clear_all, color: Colors.white),
                ),
              ),
          ]),
        ]),
      ),
    );
  }

  bool _isAssetRequired(String type, Project project) {
    switch (type) {
      case 'animation':
        return (project.features['animation'] ?? 'none') != 'none';
      case 'font':
        return (project.features['font'] ?? 'default') == 'custom';
      default:
        return false;
    }
  }

  void _clearFiles(String type) {
    setState(() {
      if (type == 'icon') _iconFiles.clear();
      if (type == 'font') _fontFiles.clear();
      if (type == 'animation') _animationFiles.clear();
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('🗑️ All ${type}s cleared')));
  }

  Widget _buildContinueButton(Project project) {
    final canContinue = _canContinue(project);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.arrow_forward),
        label: Text(canContinue ? 'Continue to Publish' : 'Add Required Assets'),
        onPressed: canContinue ? () => _continueToPublish(project) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canContinue ? Colors.green : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💡 Upload Help'),
        content: const Text(
          'Supported Files:\n'
          '• Icons: PNG, JPG, JPEG, SVG, WEBP\n'
          '• Fonts: TTF, OTF\n'
          '• Animations: Lottie JSON\n\n'
          'Make sure to allow "Storage" permission when prompted.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK')),
        ],
      ),
    );
  }

  Widget _filePreviewTile(File file, String type) {
    final fileName = file.path.split('/').last;
    final fileSize = (file.lengthSync() / 1024).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: type == 'animation'
            ? SizedBox(width: 50, height: 50, child: Lottie.file(file))
            : const Icon(Icons.insert_drive_file, color: Colors.blue),
        title: Text(fileName, overflow: TextOverflow.ellipsis),
        subtitle: Text('$fileSize KB'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download, color: Colors.blue),
              onPressed: () => _downloadToLocal(file),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeFile(file, type),
            ),
          ],
        ),
      ),
    );
  }
}

