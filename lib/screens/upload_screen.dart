import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:animations/animations.dart';
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

  // ✅ درست Permission Handling
  Future<bool> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        // Android کے لیے storage permission
        final storageStatus = await Permission.storage.status;
        
        if (storageStatus.isGranted) {
          return true;
        }
        
        // Permission request کریں
        final newStatus = await Permission.storage.request();
        
        if (newStatus.isGranted) {
          return true;
        }
        
        // اگر permanently denied ہے تو settings کھولیں
        if (newStatus.isPermanentlyDenied) {
          _showPermissionSettingsDialog();
        }
        
        return false;
        
      } else if (Platform.isIOS) {
        // iOS کے لیے photos permission
        final photosStatus = await Permission.photos.request();
        return photosStatus.isGranted;
      }
      
      return true;
    } catch (e) {
      print('❌ Permission error: $e');
      return false;
    }
  }

  // ✅ Permission settings dialog
  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Storage Permission Required'),
        content: const Text(
          'Aladdin App needs storage permission to select files. '
          'Please allow storage permission in app settings to continue.'
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

  // ✅ فائل extensions کی فہرست
  List<String> _allowedExtensions(String type) {
    switch (type) {
      case 'icon':
        return ['png', 'jpg', 'jpeg', 'svg', 'webp'];
      case 'font':
        return ['ttf', 'otf'];
      case 'animation':
        return ['json', 'lottie'];
      default:
        return [];
    }
  }

  // ✅ درست فائل pick کرنے کا فنکشن
  Future<void> _pickFiles(String type) async {
    try {
      setState(() {
        _isPicking = true;
        _currentOperation = 'Selecting ${type}s...';
      });

      final hasPermission = await _requestPermissions();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to select files. Please allow permission in app settings.'),
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      // File picker کو call کریں - withData: false رکھیں
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: _allowedExtensions(type),
        withData: false, // ✅ یہ false ہونا چاہیے
      );

      if (result != null && result.files.isNotEmpty) {
        final files = result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();

        setState(() {
          if (type == 'icon') _iconFiles.addAll(files);
          if (type == 'font') _fontFiles.addAll(files);
          if (type == 'animation') _animationFiles.addAll(files);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${files.length} ${type}(s) selected successfully'),
            duration: const Duration(seconds: 2),
          ),
        );
      }

    } catch (e) {
      print('❌ File pick error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
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

  // ✅ فائل کو local storage میں save کریں
  Future<void> _downloadToLocal(File file) async {
    try {
      setState(() {
        _currentOperation = 'Saving file...';
      });

      final directory = await getApplicationDocumentsDirectory();
      final fileName = file.path.split('/').last;
      final destination = File('${directory.path}/$fileName');
      
      await file.copy(destination.path);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ File saved to: ${destination.path}'),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Save failed: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _currentOperation = '';
      });
    }
  }

  // ✅ فائل remove کریں
  void _removeFile(File file, String type) {
    setState(() {
      if (type == 'icon') _iconFiles.remove(file);
      if (type == 'font') _fontFiles.remove(file);
      if (type == 'animation') _animationFiles.remove(file);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🗑️ File removed'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ✅ Continue button کے لیے condition
  bool _canContinue(Project project) {
    // اگر animation feature ہے مگر کوئی animation فائل نہیں
    if ((project.features['animation'] ?? 'none') != 'none' &&
        _animationFiles.isEmpty) {
      return false;
    }
    
    // اگر custom font feature ہے مگر کوئی font فائل نہیں
    if ((project.features['font'] ?? 'default') == 'custom' &&
        _fontFiles.isEmpty) {
      return false;
    }
    
    return true;
  }

  // ✅ Continue کرنے پر
  void _continueToPublish(Project project) {
    // Assets کو project میں شامل کریں
    if (_iconFiles.isNotEmpty) {
      project.assets['icons'] = _iconFiles.map((e) => e.path).toList();
    }
    if (_fontFiles.isNotEmpty) {
      project.assets['fonts'] = _fontFiles.map((e) => e.path).toList();
    }
    if (_animationFiles.isNotEmpty) {
      project.assets['animations'] = _animationFiles.map((e) => e.path).toList();
    }

    // Publish screen پر navigate کریں
    Navigator.pushNamed(context, '/publish', arguments: project);
  }

  // ✅ فائل preview tile
  Widget _filePreviewTile(File file, String type) {
    final fileName = file.path.split('/').last;
    final fileSize = (file.lengthSync() / 1024).toStringAsFixed(1);

    return OpenContainer(
      closedElevation: 2,
      closedColor: Colors.white,
      openColor: Colors.white,
      transitionDuration: const Duration(milliseconds: 500),
      closedBuilder: (context, action) => Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: _getFileIcon(file, type),
          title: Text(
            fileName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text('$fileSize KB'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.download, color: Colors.blue),
                onPressed: () => _downloadToLocal(file),
                tooltip: 'Save to device',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFile(file, type),
                tooltip: 'Remove file',
              ),
            ],
          ),
          onTap: action,
        ),
      ),
      openBuilder: (context, action) => _filePreviewScreen(file, type, fileName),
    );
  }

  // ✅ فائل icon
  Widget _getFileIcon(File file, String type) {
    final fileName = file.path.split('/').last;
    
    if (type == 'icon') {
      return Image.file(
        file,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.image, color: Colors.white, size: 20),
          );
        },
      );
    } else if (type == 'animation' && fileName.endsWith('.json')) {
      return const CircleAvatar(
        backgroundColor: Colors.purple,
        child: Icon(Icons.animation, color: Colors.white, size: 20),
      );
    } else {
      return CircleAvatar(
        backgroundColor: _getColorForType(type),
        child: Text(
          fileName[0].toUpperCase(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  // ✅ فائل type کے مطابق color
  Color _getColorForType(String type) {
    switch (type) {
      case 'icon': return Colors.blue;
      case 'font': return Colors.green;
      case 'animation': return Colors.purple;
      default: return Colors.grey;
    }
  }

  // ✅ فائل preview screen
  Widget _filePreviewScreen(File file, String type, String fileName) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadToLocal(file),
            tooltip: 'Save file',
          ),
        ],
      ),
      body: Center(
        child: _buildFilePreview(file, type),
      ),
    );
  }

  // ✅ فائل preview بنائیں
  Widget _buildFilePreview(File file, String type) {
    try {
      if (type == 'animation' && file.path.endsWith('.json')) {
        return Lottie.file(
          file,
          repeat: true,
          animate: true,
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 50, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Animation load failed',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Invalid Lottie JSON file',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          },
        );
      } else if (type == 'icon') {
        return Image.file(
          file,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, size: 50, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Image load failed',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            );
          },
        );
      } else {
        // دیگر فائلوں کے لیے basic preview
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_drive_file,
              size: 60,
              color: _getColorForType(type),
            ),
            const SizedBox(height: 16),
            Text(
              file.path.split('/').last,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${(file.lengthSync() / 1024).toStringAsFixed(1)} KB',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      }
    } catch (e) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Preview failed',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Error: $e',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Project project = ModalRoute.of(context)!.settings.arguments as Project;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📁 Upload Assets'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
            tooltip: 'Help & Tips',
          ),
        ],
      ),
      body: _isPicking ? _buildLoadingState() : _buildMainContent(project),
    );
  }

  // ✅ Loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            _currentOperation,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ✅ Main content
  Widget _buildMainContent(Project project) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Project summary
          _buildProjectSummary(project),
          const SizedBox(height: 20),
          
          // Assets sections
          Expanded(
            child: ListView(
              children: [
                _buildAssetSection('🎬 Animations', _animationFiles, 'animation', project),
                const SizedBox(height: 16),
                _buildAssetSection('🔤 Fonts', _fontFiles, 'font', project),
                const SizedBox(height: 16),
                _buildAssetSection('🖼️ Icons', _iconFiles, 'icon', project),
                const SizedBox(height: 20),
                
                // Continue button
                _buildContinueButton(project),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Project summary card
  Widget _buildProjectSummary(Project project) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSummaryItem('Framework', project.framework),
            _buildSummaryItem('Platforms', project.platforms.join(', ')),
            _buildSummaryItem('Animation', project.features['animation'] ?? 'None'),
            _buildSummaryItem('Font', project.features['font'] ?? 'Default'),
          ],
        ),
      ),
    );
  }

  // ✅ Summary item
  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  // ✅ Asset section
  Widget _buildAssetSection(String title, List<File> files, String type, Project project) {
    final isRequired = _isAssetRequired(type, project);
    
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
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (isRequired) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Required',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            
            if (files.isEmpty)
              Text(
                isRequired ? '❌ Required - Please select files' : 'No files selected',
                style: TextStyle(
                  color: isRequired ? Colors.red : Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Column(
                children: files.map((file) => _filePreviewTile(file, type)).toList(),
              ),
            
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text('Add ${title.toLowerCase()}'),
                    onPressed: () => _pickFiles(type),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                if (files.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _clearFiles(type),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Icon(Icons.clear_all),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Check if asset is required
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

  // ✅ Clear all files of a type
  void _clearFiles(String type) {
    setState(() {
      switch (type) {
        case 'icon': _iconFiles.clear(); break;
        case 'font': _fontFiles.clear(); break;
        case 'animation': _animationFiles.clear(); break;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🗑️ All ${type}s cleared'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ✅ Continue button
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
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ✅ Help dialog
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💡 Upload Help'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Supported Files:'),
              SizedBox(height: 8),
              Text('• Icons: PNG, JPG, JPEG, SVG, WEBP'),
              Text('• Fonts: TTF, OTF'),
              Text('• Animations: Lottie JSON'),
              SizedBox(height: 16),
              Text('Tips:'),
              SizedBox(height: 8),
              Text('• Select multiple files at once'),
              Text('• Tap files to preview'),
              Text('• Required files are marked in orange'),
              Text('• Save files to device for backup'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
