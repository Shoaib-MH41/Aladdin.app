import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/app_publisher.dart';

class PublishScreen extends StatefulWidget {
  final String appName;
  final String generatedCode;
  final String framework;

  const PublishScreen({
    super.key,
    required this.appName,
    required this.generatedCode,
    required this.framework,
  });

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  final AppPublisher _publisher = AppPublisher();
  bool _isSaving = false;
  String? _savedFilePath;

  Future<void> _saveLocally() async {
    setState(() => _isSaving = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${widget.appName}_release.zip';
      final file = File(filePath);
      await file.writeAsString(widget.generatedCode);
      setState(() => _savedFilePath = filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فائل لوکل اسٹوریج میں محفوظ ہو گئی ✅')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خرابی: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _openGithubPage() async {
    await _publisher.openGithubUpload();
  }

  void _shareFile() async {
    if (_savedFilePath != null) {
      await Share.shareFiles([_savedFilePath!], text: 'میرا Flutter App');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('پہلے فائل کو محفوظ کریں')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📦 Publish App"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.appName,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text("Framework: ${widget.framework}"),
                    const SizedBox(height: 4),
                    const Text(
                        "یہ ایپ لوکل اسٹوریج میں محفوظ ہو کر GitHub پر اپلوڈ کے لیے تیار ہوگی۔"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text(_isSaving ? "Saving..." : "Save Locally"),
              onPressed: _isSaving ? null : _saveLocally,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text("Share / Export File"),
              onPressed: _shareFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload),
              label: const Text("Open GitHub to Publish"),
              onPressed: _openGithubPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            const SizedBox(height: 30),

            // Guide Section
            Card(
              color: Colors.orange[50],
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "⚙️ Manual Publish Guide",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text("1️⃣ اوپر Save Locally دبائیں تاکہ فائل آپ کے موبائل میں محفوظ ہو جائے۔"),
                    Text("2️⃣ پھر 'Open GitHub' دبائیں۔"),
                    Text("3️⃣ GitHub پر نیا Repository بنائیں۔"),
                    Text("4️⃣ محفوظ شدہ ZIP یا APK فائل اپلوڈ کریں۔"),
                    Text("5️⃣ اپلوڈ مکمل ہونے پر GitHub آپ کو شیئر لنک دے گا۔"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

