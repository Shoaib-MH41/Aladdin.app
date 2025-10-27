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
  Future<bool> _requestFilePermission() async {
    try {
      if (Platform.isAndroid) {
        // پہلے چیک کریں کہ permission پہلے سے granted ہے
        if (await Permission.storage.isGranted) {
          print('✅ Storage permission already granted');
          return true;
        }
        
        // Permission request کریں
        print('🔐 Requesting storage permission...');
        final status = await Permission.storage.request();
        
        if (status.isGranted) {
          print('✅ Storage permission granted');
          return true;
        }
        
        // اگر user نے deny کر دیا
        if (status.isDenied) {
          print('❌ Storage permission denied');
          _showPermissionDialog('Storage permission is required to select files from your device.');
        }
        
        // اگر permanently denied ہے تو settings میں لے جائیں
        if (status.isPermanentlyDenied) {
          print('❌ Storage permission permanently denied');
          _showPermissionSettingsDialog();
        }
        
        return false;
      } else if (Platform.isIOS) {
        // iOS کے لیے photos permission
        if (await Permission.photos.isGranted) {
          return true;
        }
        
        final status = await Permission.photos.request();
        return status.isGranted;
      }
      return true;
    } catch (e) {
      print('❌ Permission error: $e');
      return false;
    }
  }

  // ✅ Simple permission dialog
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

  // ✅ Permission settings dialog
  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Storage Access Required'),
        content: const Text(
          'Aladdin App needs access to your storage to select icons, fonts and animations.\n\n'
          'Please allow "Storage" permission in app settings to continue.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings(); // Directly open app settings
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
        return ['json'];
      default:
        return [];
    }
  }

  // ✅ درست فائل pick کرنے کا فنکشن
  Future<void> _pickFiles(String type) async {
    try {
      setState(() {
        _isPicking = true;
        _currentOperation = 'Checking permissions...';
      });

      // Permission چیک کریں
      final hasPermission = await _requestFilePermission();
      
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission denied. Please allow storage access to select files.'),
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      setState(() {
        _currentOperation = 'Opening file picker...';
      });

      // File picker کو call کریں
      FilePickerResult? result;
      try {
        result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: _allowedExtensions(type),
          withData: false,
          dialogTitle: 'Select ${type} files',
        );
      } catch (e) {
        print('FilePicker Error: $e');
        // Fallback - بغیر specific extensions کے
        result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.any,
          withData: false,
          dialogTitle: 'Select ${type} files',
        );
      }

      if (result != null && result.files.isNotEmpty) {
        // Files process کریں
        List<File> selectedFiles = [];
        for (var platformFile in result.files) {
          if (platformFile.path != null && await File(platformFile.path!).exists()) {
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
              content: Text('✅ ${selectedFiles.length} ${type}(s) selected successfully'),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ No valid files selected'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // User نے cancel کیا ہو
        print('User cancelled file selection');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File selection cancelled'),
            duration: Duration(seconds: 1),
          ),
        );
      }

    } catch (e) {
      print('❌ File pick error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          duration: const Duration(seconds: 4),
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
          content: Text('✅ File saved to device'),
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
    if ((project.features['animation'] ?? 'none') != 'none' &&
        _animationFiles.isEmpty) {
      return false;
    }
    
    if ((project.features['font'] ?? 'default') == 'custom' &&
        _fontFiles.isEmpty) {
      return false;
    }
    
    return true;
  }

  // ✅ Continue کرنے پر
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
            textAlign: TextAlign.center,
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
          _buildProjectSummary(project),
          const SizedBox(height: 20),
          
          Expanded(
            child: ListView(
              children: [
                _buildAssetSection('🎬 Animations', _animationFiles, 'animation', project),
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
              Text('Permission Note:'),
              SizedBox(height: 8),
              Text('• Allow "Storage" permission when prompted'),
              Text('• This allows selecting files from your device'),
              Text('• You can manage permissions in app settings'),
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
