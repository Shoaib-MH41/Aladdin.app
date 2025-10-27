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

class _UploadScreenState extends State<UploadScreen>
    with TickerProviderStateMixin {
  List<File> _iconFiles = [];
  List<File> _fontFiles = [];
  List<File> _animationFiles = [];

  bool _isPicking = false;
  double _progress = 0;

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    } else {
      return true;
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

  Future<void> _pickFiles(String type) async {
    try {
      final ok = await _requestStoragePermission();
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission required')),
        );
        return;
      }

      setState(() => _isPicking = true);

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: _allowedExtensions(type),
      );

      if (result != null) {
        final files =
            result.paths.whereType<String>().map((p) => File(p)).toList();
        setState(() {
          if (type == 'icon') _iconFiles.addAll(files);
          if (type == 'font') _fontFiles.addAll(files);
          if (type == 'animation') _animationFiles.addAll(files);
        });
      }

      setState(() => _isPicking = false);
    } catch (e) {
      setState(() => _isPicking = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _downloadToLocal(File file) async {
    try {
      final dir = await getExternalStorageDirectory();
      final dest = File('${dir!.path}/${file.path.split('/').last}');
      await file.copy(dest.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to: ${dest.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  void _removeFile(File file, String type) {
    setState(() {
      if (type == 'icon') _iconFiles.remove(file);
      if (type == 'font') _fontFiles.remove(file);
      if (type == 'animation') _animationFiles.remove(file);
    });
  }

  bool _canContinue(Project project) {
    if ((project.features['animation'] ?? 'none') != 'none' &&
        _animationFiles.isEmpty) return false;
    if ((project.features['font'] ?? 'default') == 'custom' &&
        _fontFiles.isEmpty) return false;
    return true;
  }

  void _continue(Project project) {
    if (_iconFiles.isNotEmpty) {
      project.assets['icons'] = _iconFiles.map((e) => e.path).toList();
    }
    if (_fontFiles.isNotEmpty) {
      project.assets['fonts'] = _fontFiles.map((e) => e.path).toList();
    }
    if (_animationFiles.isNotEmpty) {
      project.assets['animations'] =
          _animationFiles.map((e) => e.path).toList();
    }

    Navigator.pushNamed(context, '/publish', arguments: project);
  }

  Widget _filePreviewTile(File file, String type) {
    final name = file.path.split('/').last;
    final sizeKb = (file.lengthSync() / 1024).toStringAsFixed(1);

    return OpenContainer(
      closedElevation: 2,
      closedColor: Colors.white,
      openColor: Colors.white,
      transitionDuration: const Duration(milliseconds: 400),
      closedBuilder: (context, action) => ListTile(
        leading: type == 'icon'
            ? Image.file(file, width: 40, height: 40, fit: BoxFit.cover)
            : CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Text(name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white))),
        title: Text(name, overflow: TextOverflow.ellipsis),
        subtitle: Text('$sizeKb KB'),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadToLocal(file),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _removeFile(file, type),
          ),
        ]),
      ),
      openBuilder: (context, action) {
        if (type == 'animation' && name.endsWith('.json')) {
          return Scaffold(
            appBar: AppBar(title: Text(name)),
            body: Center(
              child: Lottie.file(file, repeat: true, animate: true),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(title: Text(name)),
            body: Center(
              child: Image.file(file, fit: BoxFit.contain),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Project project =
        ModalRoute.of(context)!.settings.arguments as Project;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Assets'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => showDialog(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('Upload Tips'),
                content: const Text(
                    'You can select multiple icons, fonts or animations.\n\nRecommended:\n• Icons: PNG, WEBP\n• Fonts: TTF, OTF\n• Animations: Lottie JSON'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('OK'))
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _isPicking
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(14),
                  child: ListView(
                    children: [
                      _summaryCard(project),
                      const SizedBox(height: 16),
                      _assetSection('Animations', _animationFiles, 'animation'),
                      _assetSection('Fonts', _fontFiles, 'font'),
                      _assetSection('Icons', _iconFiles, 'icon'),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_forward_ios),
                        label: Text(
                            _canContinue(project)
                                ? 'Continue to Publish'
                                : 'Add required assets',
                            style: const TextStyle(fontSize: 16)),
                        onPressed:
                            _canContinue(project) ? () => _continue(project) : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: _canContinue(project)
                              ? Colors.blueAccent
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _summaryCard(Project project) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Project Summary',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Framework: ${project.framework}'),
              Text('Platforms: ${project.platforms.join(", ")}'),
              Text('Animation: ${project.features['animation'] ?? 'none'}'),
              Text('Font: ${project.features['font'] ?? 'default'}'),
            ],
          ),
        ),
      );

  Widget _assetSection(String title, List<File> files, String type) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (files.isEmpty)
            Text('No $title selected',
                style: const TextStyle(color: Colors.grey)),
          ...files.map((f) => _filePreviewTile(f, type)).toList(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: Text('Select $title'),
                  onPressed: () => _pickFiles(type),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed:
                    files.isEmpty ? null : () => setState(() => files.clear()),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent),
                child: const Icon(Icons.clear),
              ),
            ],
          )
        ]),
      ),
    );
  }
}
