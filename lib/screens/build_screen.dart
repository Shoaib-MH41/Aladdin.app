import 'package:flutter/material.dart';

class BuildScreen extends StatelessWidget {
  final String generatedCode;
  
  const BuildScreen({super.key, required this.generatedCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Build APK")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Generated code preview
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Text(generatedCode),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Build buttons
            Column(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.terminal),
                  label: const Text("Termux میں Build کریں"),
                  onPressed: () {
                    // Termux call کا logic
                    _runInTermux(generatedCode);
                  },
                ),
                
                const SizedBox(height: 10),
                
                ElevatedButton.icon(
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text("GitHub پر Build کریں"),
                  onPressed: () {
                    // GitHub Actions کا logic
                    _buildWithGitHub(generatedCode);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _runInTermux(String code) {
    // Termux integration logic
  }
  
  void _buildWithGitHub(String code) {
    // GitHub integration logic
  }
}
