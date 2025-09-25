import 'package:flutter/material.dart';
import '../services/local_apk_builder.dart';

class BuildScreen extends StatefulWidget {
  final String generatedCode;
  
  const BuildScreen({super.key, required this.generatedCode});

  @override
  State<BuildScreen> createState() => _BuildScreenState();
}

class _BuildScreenState extends State<BuildScreen> {
  bool _isBuilding = false;
  String _buildResult = '';

  void _buildAPK() async {
    setState(() {
      _isBuilding = true;
      _buildResult = '';
    });

    try {
      final apkFile = await LocalAPKBuilder.buildAPK(
        'MyApp_${DateTime.now().millisecondsSinceEpoch}',
        widget.generatedCode
      );
      
      setState(() {
        _isBuilding = false;
        _buildResult = '✅ APK بن گئی ہے!\n📍 مقام: ${apkFile.path}';
      });
    } catch (e) {
      setState(() {
        _isBuilding = false;
        _buildResult = '❌ APK بننے میں ناکامی: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build APK'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Generated Code Preview
            const Text(
              'جنریٹ شدہ کوڈ:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    widget.generatedCode,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Build Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _isBuilding ? null : _buildAPK,
                child: _isBuilding
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(width: 10),
                          Text('APK بن رہی ہے...'),
                        ],
                      )
                    : const Text(
                        'APK بنائیں',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Build Result
            if (_buildResult.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _buildResult.contains('✅') ? Colors.green[50] : Colors.red[50],
                  border: Border.all(
                    color: _buildResult.contains('✅') ? Colors.green : Colors.red,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_buildResult),
              ),
          ],
        ),
      ),
    );
  }
}
