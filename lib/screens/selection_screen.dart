import 'package:flutter/material.dart';

/// Usage:
/// Navigator.pushNamed(context, '/selection', arguments: projectMap);
/// where projectMap is Map<String, dynamic> like:
/// { "id": "p_abc", "name": "My Project", "platforms": [], "framework": "Flutter" }
///
/// On Save this screen returns Navigator.pop(context, updatedProjectMap);

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  final Map<String, bool> _platforms = {
    'Android': false,
    'iOS': false,
    'Web': false,
  };

  final List<String> _frameworks = ['Flutter', 'React Native'];
  String _selectedFramework = 'Flutter';
  bool _selectAll = false;

  late Map<String, dynamic> project;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      project = Map<String, dynamic>.from(args);
      // initialize UI from project if present
      final p = project['platforms'];
      if (p is List) {
        for (var k in _platforms.keys.toList()) {
          _platforms[k] = p.contains(k);
        }
        _selectAll = _platforms.values.every((v) => v);
      }
      final fw = project['framework'];
      if (fw is String && _frameworks.contains(fw)) {
        _selectedFramework = fw;
      }
    } else {
      // default project if none passed
      project = {
        'id': 'p_tmp',
        'name': 'Untitled',
        'platforms': [],
        'framework': _selectedFramework,
        'assets': {},
      };
    }
  }

  void _toggleSelectAll(bool? v) {
    setState(() {
      _selectAll = v ?? false;
      _platforms.updateAll((key, value) => _selectAll);
    });
  }

  void _onPlatformChanged(String key, bool? val) {
    setState(() {
      _platforms[key] = val ?? false;
      _selectAll = _platforms.values.every((v) => v);
    });
  }

  void _saveAndContinue() {
    final selected = _platforms.entries.where((e) => e.value).map((e) => e.key).toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one platform')),
      );
      return;
    }
    project['platforms'] = selected;
    project['framework'] = _selectedFramework;
    Navigator.pop(context, project);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform & Framework'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CheckboxListTile(
              title: const Text('Select All'),
              value: _selectAll,
              onChanged: _toggleSelectAll,
            ),
            const SizedBox(height: 6),
            ..._platforms.keys.map((k) {
              return CheckboxListTile(
                title: Text(k),
                value: _platforms[k],
                onChanged: (v) => _onPlatformChanged(k, v),
              );
            }).toList(),
            const Divider(height: 28),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text('Select Framework', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Row(
              children: _frameworks.map((fw) {
                final selected = fw == _selectedFramework;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFramework = fw),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? Colors.deepPurple : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: selected ? Colors.deepPurple : Colors.grey.shade400),
                      ),
                      child: Center(
                        child: Text(
                          fw,
                          style: TextStyle(color: selected ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveAndContinue,
                    child: const Text('Save & Continue'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
