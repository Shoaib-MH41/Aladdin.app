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
  bool _isUploading = false;
  String _currentOperation = '';

  // ✅ تمام فائلیں ایک ساتھ اپلوڈ کرنے کے لیے
  List<File> _allSelectedFiles = [];

  /// ✅ بہتر Permission Handling - تمام Android versions کے لیے
  Future<bool> _requestFilePermission() async {
    try {
      if (Platform.isAndroid) {
        // ✅ Android 13+ (API 33+) کے لیے نئے permissions
        if (await Permission.manageExternalStorage.request().isGranted) {
          return true;
        }
        
        // ✅ تمام ممکنہ storage permissions
        final Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
          Permission.manageExternalStorage,
          Permission.accessMediaLocation,
          if (await Permission.photos.isGranted == false) Permission.photos,
          if (await Permission.mediaLibrary.isGranted == false) Permission.mediaLibrary,
        ].request();

        // ✅ اگر کسی بھی permission کو اجازت مل گئی
        if (statuses.values.any((status) => status.isGranted)) {
          return true;
        }

        // ❌ اگر permanently deny کیا گیا
        if (statuses.values.any((status) => status.isPermanentlyDenied)) {
          _showPermissionSettingsDialog();
          return false;
        }

        // 🔄 اگر deny کر دیا
        if (statuses.values.any((status) => status.isDenied)) {
          _showPermissionDialog(
              'Storage permission is required to select files from your device.');
          return false;
        }
      } else if (Platform.isIOS) {
        // ✅ iOS کے لیے Photos permission
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

  /// ✅ **درست File Picker Function - Complete File Manager کھولنے کے لیے**
  Future<void> _pickFiles(String type) async {
    try {
      setState(() {
        _isPicking = true;
        _currentOperation = 'Opening file manager...';
      });

      // ✅ Permission check
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

      FilePickerResult? result;

      try {
        // ✅ **FileType.any استعمال کریں - تمام فائلیں دکھانے کے لیے**
        result = await FilePicker.platform.pickFiles(
          allowMultiple: true, // ✅ ایک سے زیادہ فائلیں select کرنے کے لیے
          type: FileType.any, // ✅ **تمام فائلیں دکھائے گا - Complete File Manager**
          dialogTitle: 'Select ${type.toUpperCase()} files',
          lockParentWindow: true,
          withData: false,
        );

        debugPrint('✅ File picker opened successfully');
        
      } catch (e) {
        debugPrint('⚠️ FilePicker Error: $e');
        
        // 🔄 Alternative approach اگر پہلا طریقہ کام نہ کرے
        result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: ['png', 'jpg', 'jpeg', 'svg', 'webp', 'ttf', 'otf', 'json', 'txt', 'pdf', 'zip'],
          dialogTitle: 'Select files (All types)',
        );
      }

      if (result != null && result.files.isNotEmpty) {
        // ✅ Files process کریں
        List<File> selectedFiles = [];
        for (var platformFile in result.files) {
          if (platformFile.path != null) {
            File file = File(platformFile.path!);
            if (await file.exists()) {
              selectedFiles.add(file);
              debugPrint('✅ Selected file: ${file.path}');
            }
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
            
            // ✅ تمام selected files کو ایک list میں جمع کریں
            _allSelectedFiles.addAll(selectedFiles);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${selectedFiles.length} ${type}(s) selected successfully'),
              duration: const Duration(seconds: 2),
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
        SnackBar(
          content: Text('❌ Error: Could not open file manager - $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isPicking = false;
        _currentOperation = '';
      });
    }
  }

  /// ✅ **تمام فائلیں ایک ساتھ اپلوڈ کرنے کا function**
  Future<void> _uploadAllFilesTogether(Project project) async {
    try {
      setState(() {
        _isUploading = true;
        _currentOperation = 'Uploading all files...';
      });

      // ✅ تمام selected files کو ایک list میں جمع کریں
      List<File> allFiles = [];
      allFiles.addAll(_iconFiles);
      allFiles.addAll(_fontFiles);
      allFiles.addAll(_animationFiles);

      if (allFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ No files selected for upload')),
        );
        return;
      }

      debugPrint('🚀 Starting upload of ${allFiles.length} files');

      // ✅ Simulate file upload process
      for (int i = 0; i < allFiles.length; i++) {
        File file = allFiles[i];
        setState(() {
          _currentOperation = 'Uploading file ${i + 1}/${allFiles.length}\n${file.path.split('/').last}';
        });

        // 🔄 یہاں آپ کا actual upload logic آئے گا
        await _simulateFileUpload(file);
        
        debugPrint('✅ Uploaded: ${file.path}');
      }

      // ✅ Project میں تمام assets شامل کریں
      if (_iconFiles.isNotEmpty) {
        project.assets['icons'] = _iconFiles.map((e) => e.path).toList();
      }
      if (_fontFiles.isNotEmpty) {
        project.assets['fonts'] = _fontFiles.map((e) => e.path).toList();
      }
      if (_animationFiles.isNotEmpty) {
        project.assets['animations'] = _animationFiles.map((e) => e.path).toList();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Successfully uploaded ${allFiles.length} files!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // ✅ Publish screen پر جائیں
      Navigator.pushNamed(context, '/publish', arguments: project);

    } catch (e) {
      debugPrint('❌ Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Upload failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
        _currentOperation = '';
      });
    }
  }

  /// ✅ File upload simulation (آپ کا actual upload logic یہاں آئے گا)
  Future<void> _simulateFileUpload(File file) async {
    // 🔄 یہ simulate کر رہا ہے - آپ کا actual upload logic یہاں آئے گا
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Example: FTP upload, HTTP upload, etc.
    // await YourUploadService.uploadFile(file);
  }

  Future<void> _downloadToLocal(File file) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = file.path.split('/').last;
      final destination = File('${directory.path}/$fileName');
      await file.copy(destination.path);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ File saved to: ${destination.path}'),
          duration: const Duration(seconds: 2),
        ),
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
      
      // ✅ تمام فائلوں کی list سے بھی remove کریں
      _allSelectedFiles.remove(file);
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
    // ✅ تمام فائلیں ایک ساتھ اپلوڈ کریں
    _uploadAllFilesTogether(project);
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
          // ✅ Selected files count دکھائیں
          if (_allSelectedFiles.isNotEmpty)
            Chip(
              label: Text('${_allSelectedFiles.length}'),
              backgroundColor: Colors.white,
            ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: _isPicking || _isUploading ? _buildLoadingState() : _buildMainContent(project),
    );
  }

  Widget _buildLoadingState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              _currentOperation, 
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget _buildMainContent(Project project) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProjectSummary(project),
            const SizedBox(height: 20),
            // ✅ Total files summary
            if (_allSelectedFiles.isNotEmpty)
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.folder_open, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Total ${_allSelectedFiles.length} files selected',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
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
          Expanded(child: Text(value)),
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
      if (type == 'icon') {
        _allSelectedFiles.removeWhere((file) => _iconFiles.contains(file));
        _iconFiles.clear();
      }
      if (type == 'font') {
        _allSelectedFiles.removeWhere((file) => _fontFiles.contains(file));
        _fontFiles.clear();
      }
      if (type == 'animation') {
        _allSelectedFiles.removeWhere((file) => _animationFiles.contains(file));
        _animationFiles.clear();
      }
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('🗑️ All ${type}s cleared')));
  }

  Widget _buildContinueButton(Project project) {
    final canContinue = _canContinue(project);
    final hasAnyFiles = _allSelectedFiles.isNotEmpty;
    
    return Column(
      children: [
        if (hasAnyFiles)
          Text(
            '📦 ${_allSelectedFiles.length} files ready for upload',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.file_upload),
            label: Text(canContinue 
                ? 'Upload All Files & Continue' 
                : 'Add Required Assets First'),
            onPressed: canContinue ? () => _continueToPublish(project) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canContinue ? Colors.green : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💡 Upload Help'),
        content: const Text(
          '🚀 **New Features:**\n'
          '• Complete File Manager Access\n'
          '• Upload All Files Together\n'
          '• Better Permission Handling\n\n'
          '📁 **Supported Files:**\n'
          '• Icons: PNG, JPG, JPEG, SVG, WEBP\n'
          '• Fonts: TTF, OTF\n'
          '• Animations: Lottie JSON\n'
          '• And many more...\n\n'
          '🔐 **Permissions:**\n'
          'Allow "Storage" permission when prompted for full file access.',
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
