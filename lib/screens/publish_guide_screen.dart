import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import '../services/app_publisher.dart';

class PublishGuideScreen extends StatefulWidget {
  final String appName;
  final String generatedCode;
  final String framework;

  const PublishGuideScreen({
    super.key,
    required this.appName,
    required this.generatedCode,
    required this.framework,
  });

  @override
  State<PublishGuideScreen> createState() => _PublishGuideScreenState();
}

class _PublishGuideScreenState extends State<PublishGuideScreen> {
  final AppPublisher _publisher = AppPublisher();
  bool _isLoading = true;
  Map<String, dynamic>? _publishData;
  String? _zipPath;
  String? _uploadStatus;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _publisher.prepareForPlayStore(
      appName: widget.appName,
      generatedCode: widget.generatedCode,
      framework: widget.framework,
    );
    setState(() {
      _publishData = data;
      _isLoading = false;
    });
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Copied ✅")),
    );
  }

  Future<void> _openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Cannot open URL")));
    }
  }

  Future<void> _exportZip() async {
    setState(() => _isLoading = true);
    final path =
        await _publisher.exportToZip(_publishData!, widget.appName);
    setState(() {
      _zipPath = path;
      _isLoading = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("📦 Exported: $path")));
  }

  Future<void> _uploadToPlayStore() async {
    setState(() {
      _isLoading = true;
      _uploadStatus = null;
    });
    try {
      final result = await _publisher.uploadToPlayStore(
        serviceAccountPath: '/storage/emulated/0/service_account.json',
        packageName: _publishData!['package_name'],
      );
      setState(() {
        _uploadStatus = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _uploadStatus = "❌ Upload failed: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _publishData == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Preparing...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = _publishData!;

    return Scaffold(
      appBar: AppBar(
        title: Text("Publish Guide"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.apps, color: Colors.green),
              title: Text(widget.appName,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Package: ${data['package_name']}"),
            ),
          ),
          SizedBox(height: 20),
          _buildStep("1️⃣ Create Google Play Console Account",
              "https://play.google.com/console"),
          _buildStep("2️⃣ Add your app", ""),
          _buildStep("3️⃣ Add Privacy Policy", data['privacy_policy']),
          _buildStep("4️⃣ Build APK", "", copyText: _publisher.getBuildCommands(
            widget.appName,
            framework: widget.framework,
          )),
          SizedBox(height: 20),
          ElevatedButton.icon(
            icon: Icon(Icons.download),
            label: Text("Export Project (ZIP)"),
            onPressed: _exportZip,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            icon: Icon(Icons.cloud_upload),
            label: Text("Upload to Play Store"),
            onPressed: _uploadToPlayStore,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          if (_uploadStatus != null) ...[
            SizedBox(height: 10),
            Text(_uploadStatus!,
                style: TextStyle(
                    color: _uploadStatus!.contains("✅")
                        ? Colors.green
                        : Colors.red)),
          ]
        ],
      ),
    );
  }

  Widget _buildStep(String title, String url, {String? copyText}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Row(
              children: [
                if (url.isNotEmpty)
                  TextButton.icon(
                    icon: Icon(Icons.open_in_new),
                    label: Text("Open"),
                    onPressed: () => _openUrl(url),
                  ),
                if (copyText != null)
                  TextButton.icon(
                    icon: Icon(Icons.copy),
                    label: Text("Copy"),
                    onPressed: () => _copy(copyText),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
