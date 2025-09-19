import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:aladdin_app/core/utils/navigation.dart'; // ✅ package import
import 'package:aladdin_app/models/app_config.dart'; // ✅ package import
import 'package:aladdin_app/core/services/api_service.dart'; // ✅ package import
import 'package:aladdin_app/features/splash/splash_screen.dart'; // ✅ package import

class CodePreviewScreen extends StatefulWidget {
  final AppConfig? config; // arguments کے لیے
  const CodePreviewScreen({Key? key, this.config}) : super(key: key); // ✅ key parameter

  @override
  _CodePreviewScreenState createState() => _CodePreviewScreenState();
}

class _CodePreviewScreenState extends State<CodePreviewScreen> {
  Map<String, dynamic>? apiData;
  String? errorMessage;
  AppConfig? _appConfig; // State میں AppConfig رکھیں

  static const String token = 'YOUR_GITHUB_PERSONAL_ACCESS_TOKEN';
  static const String repoOwner = 'your-username';
  static const String repoName = 'aladdin_app';
  static const String apiUrl = 'https://api.github.com/repos/$repoOwner/$repoName';
  static const String apkLink = 'https://github.com/your-username/aladdin_app/actions';

  @override
  void initState() {
    super.initState();
    _appConfig = widget.config; // arguments سے ڈیٹا لیں
    _processApiInput();
  }

  Future<void> _processApiInput() async {
    try {
      final configInput = _appConfig?.apiInput;
      print('Config Input: $configInput');
      if (configInput != null && configInput.isNotEmpty) {
        final apiConfig = await ApiService.generateApiConfig(configInput);
        print('API Config: $apiConfig');
        setState(() => _appConfig = _appConfig?.copyWith(apiConfig: apiConfig)); // copyWith میتھڈ شامل کریں اگر موجود نہ ہو
        final data = await ApiService.fetchData(apiConfig);
        setState(() => apiData = data);
      } else {
        setState(() => errorMessage = 'No valid API input.');
      }
    } catch (e) {
      setState(() => errorMessage = 'Error: $e');
    }
  }

  Future<void> deleteProject() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'), // ✅ const
        content: const Text('Are you sure you want to delete the project? This action cannot be undone.'), // ✅ const
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'), // ✅ const
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final response = await http.delete(
                Uri.parse(apiUrl),
                headers: {
                  'Authorization': 'token $token',
                  'Accept': 'application/vnd.github.v3+json'
                },
              );
              if (!mounted) return;
              if (response.statusCode == 204) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Project deleted successfully!')), // ✅ const
                );
                Navigation.pushReplacement(context, const SplashScreen()); // ✅ const
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Delete failed: ${response.statusCode}')),
                );
              }
            },
            child: const Text('Delete'), // ✅ const
          ),
        ],
      ),
    );
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(const ClipboardData(text: apkLink)); // ✅ const
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard!')), // ✅ const
    );
  }

  Future<void> _openLink() async {
    final uri = Uri.parse(apkLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch link.')), // ✅ const
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Preview', style: TextStyle(fontFamily: 'Poppins')), // ✅ const
      ),
      body: Padding(
        padding: const EdgeInsets.all(16), // ✅ const
        child: Column(
          children: [
            const Text( // ✅ const
              'Your App is Ready!',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w500)
            ),
            const SizedBox(height: 20), // ✅ const
            Expanded(
              child: apiData != null
                  ? SingleChildScrollView(
                      child: Text(
                        jsonEncode(apiData),
                        style: const TextStyle(fontFamily: 'Poppins') // ✅ const
                      ),
                    )
                  : errorMessage != null
                      ? Center(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(fontFamily: 'Poppins', color: Colors.red) // ✅ const
                          ),
                        )
                      : const Center(child: CircularProgressIndicator()), // ✅ const
            ),
            const SizedBox(height: 20), // ✅ const
            const Text('Download APK from:', style: TextStyle(fontFamily: 'Poppins')), // ✅ const
            const SizedBox(height: 10), // ✅ const
            Text(
              apkLink,
              style: const TextStyle(fontFamily: 'Poppins', color: Colors.blue), // ✅ const
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20), // ✅ const
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _copyLink,
                  child: const Text('Copy Link', style: TextStyle(fontFamily: 'Poppins')), // ✅ const
                ),
                const SizedBox(width: 10), // ✅ const
                ElevatedButton(
                  onPressed: _openLink,
                  child: const Text('Open Link', style: TextStyle(fontFamily: 'Poppins')), // ✅ const
                ),
              ],
            ),
            const SizedBox(height: 20), // ✅ const
            ElevatedButton(
              onPressed: deleteProject,
              child: const Text('Delete Project', style: TextStyle(fontFamily: 'Poppins')), // ✅ const
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
