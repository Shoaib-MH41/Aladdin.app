import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/project_model.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> with TickerProviderStateMixin {
  // allow multiple icons and multiple assets
  List<File> _iconFiles = [];
  List<File> _fontFiles = [];
  List<File> _animationFiles = [];

  bool _isPicking = false;

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    } else {
      // iOS permission is handled by the picker; return true
      return true;
    }
  }

  Future<void> _pickFiles(String type, {bool allowMultiple = true}) async {
    try {
      final ok = await _requestStoragePermission();
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required')),
        );
        return;
      }

      setState(() => _isPicking = true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions(type),
        allowMultiple: allowMultiple,
        withData: false,
      );

      setState(() => _isPicking = false);

      if (result == null) {
        // user cancelled
        return;
      }

      final selected = result.files.where((f) => f.path != null).map((f) => File(f.path!)).toList();

      setState(() {
        if (type == 'icon') {
          _iconFiles.addAll(selected);
        } else if (type == 'font') {
          _fontFiles.addAll(selected);
        } else if (type == 'animation') {
          _animationFiles.addAll(selected);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected ${selected.length} file(s) for $type')),
      );
    } catch (e) {
      setState(() => _isPicking = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File pick error: $e')));
    }
  }

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

  bool _canContinue(Project project) {
    if ((project.features['animation'] ?? 'none') != 'none' && _animationFiles.isEmpty) {
      return false;
    }
    if ((project.features['font'] ?? 'default') == 'custom' && _fontFiles.isEmpty) {
      return false;
    }
    // icons are optional
    return true;
  }

  void _removeFile(File file, String type) {
    setState(() {
      if (type == 'icon') _iconFiles.remove(file);
      if (type == 'font') _fontFiles.remove(file);
      if (type == 'animation') _animationFiles.remove(file);
    });
  }

  void _continue(Project project) {
    // attach paths to project.assets (simple approach)
    if (_iconFiles.isNotEmpty) project.assets['icons'] = _iconFiles.map((f) => f.path).toList();
    if (_fontFiles.isNotEmpty) project.assets['fonts'] = _fontFiles.map((f) => f.path).toList();
    if (_animationFiles.isNotEmpty) project.assets['animations'] = _animationFiles.map((f) => f.path).toList();

    Navigator.pushNamed(context, '/chat', arguments: project);
  }

  Widget _filePreviewTile(File file, String type) {
    final name = file.path.split('/').last;
    final sizeKb = (file.lengthSync() / 1024).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: ListTile(
        leading: type == 'icon'
            ? Image.file(file, width: 40, height: 40, fit: BoxFit.cover)
            : CircleAvatar(child: Text(name.split('.').first.toUpperCase().substring(0, 1))),
        title: Text(name, overflow: TextOverflow.ellipsis),
        subtitle: Text('$sizeKb KB'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _removeFile(file, type),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Project project = ModalRoute.of(context)!.settings.arguments as Project;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Assets'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Upload tips'),
                  content: const Text('You can select multiple icons or font files at once. Use recommended formats: icons (.png/.webp), fonts (.ttf/.otf), animations (Lottie .json).'),
                  actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
                ),
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Project Summary', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Framework: ${project.framework}'),
                      Text('Platforms: ${project.platforms.join(', ')}'),
                      Text('Animation: ${project.features['animation'] ?? 'none'}'),
                      Text('Font: ${project.features['font'] ?? 'default'}'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Animation section (multiple allowed)
              if ((project.features['animation'] ?? 'none') != 'none') ...[
                _sectionHeader('Animations (Lottie)'),
                if (_animationFiles.isEmpty)
                  _emptyPlaceholder('No animation selected yet'),
                ..._animationFiles.map((f) => _filePreviewTile(f, 'animation')),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Select Animations'),
                        onPressed: () => _pickFiles('animation', allowMultiple: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _animationFiles.isEmpty ? null : () => setState(() => _animationFiles.clear()),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: const Icon(Icons.clear),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Font section
              if ((project.features['font'] ?? 'default') == 'custom') ...[
                _sectionHeader('Fonts (TTF/OTF)'),
                if (_fontFiles.isEmpty)
                  _emptyPlaceholder('No font selected yet'),
                ..._fontFiles.map((f) => _filePreviewTile(f, 'font')),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.font_download),
                        label: const Text('Select Fonts'),
                        onPressed: () => _pickFiles('font', allowMultiple: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _fontFiles.isEmpty ? null : () => setState(() => _fontFiles.clear()),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: const Icon(Icons.clear),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Icon section (optional) - allow multiple icons (different densities)
              _sectionHeader('App Icons (optional)'),
              if (_iconFiles.isEmpty)
                _emptyPlaceholder('No icons selected yet'),
              ..._iconFiles.map((f) => _filePreviewTile(f, 'icon')),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text('Select Icons'),
                      onPressed: () => _pickFiles('icon', allowMultiple: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _iconFiles.isEmpty ? null : () => setState(() => _iconFiles.clear()),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    child: const Icon(Icons.clear),
                  ),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canContinue(project) ? () => _continue(project) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canContinue(project) ? Colors.blueAccent : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(_canContinue(project) ? 'Continue to AI Chat' : 'Please add required assets'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _emptyPlaceholder(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }
}
