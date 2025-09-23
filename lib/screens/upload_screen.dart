import 'package:flutter/material.dart';

/// Usage:
/// Navigator.pushNamed(context, '/upload', arguments: projectMap);
/// returns Navigator.pop(context, updatedProjectMap);

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  late Map<String, dynamic> project;
  final Map<String, List<String>> assets = {
    'animations': [],
    'fonts': [],
    'icons': [],
    'images': [],
  };

  final TextEditingController _nameController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      project = Map<String, dynamic>.from(args);
      final stored = project['assets'];
      if (stored is Map) {
        // load previously stored assets if any
        for (var k in assets.keys) {
          final v = stored[k];
          if (v is List) assets[k] = List<String>.from(v);
        }
      } else {
        project['assets'] = {};
      }
    } else {
      project = {
        'id': 'p_tmp',
        'name': 'Untitled',
        'assets': {},
      };
    }
  }

  void _addAsset(String type) {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter file name or URL')));
      return;
    }
    setState(() {
      assets[type]?.add(name);
      _nameController.clear();
    });
  }

  void _removeAsset(String type, int index) {
    setState(() {
      assets[type]?.removeAt(index);
    });
  }

  void _saveAssets() {
    project['assets'] = assets.map((k, v) => MapEntry(k, v));
    Navigator.pop(context, project);
  }

  Widget _buildAssetSection(String title, String key) {
    final list = assets[key]!;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(width: 8),
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'name or URL', isDense: true),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () => _addAsset(key), child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 8),
            if (list.isEmpty)
              const Align(alignment: Alignment.centerLeft, child: Text('No assets added yet', style: TextStyle(color: Colors.grey)))
            else
              Column(
                children: list.asMap().entries.map((e) {
                  return ListTile(
                    dense: true,
                    title: Text(e.value),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeAsset(key, e.key),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Assets'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildAssetSection('Animations (Lottie JSON)', 'animations'),
            _buildAssetSection('Fonts (TTF/OTF)', 'fonts'),
            _buildAssetSection('Icons (PNG/SVG)', 'icons'),
            _buildAssetSection('Images', 'images'),
            const Spacer(),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: _saveAssets, child: const Text('Save Assets'))),
              ],
            )
          ],
        ),
      ),
    );
  }
}

