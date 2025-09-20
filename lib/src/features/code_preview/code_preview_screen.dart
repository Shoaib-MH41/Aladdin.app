import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:aladdin_app/src/core/utils/navigation.dart';
import 'package:aladdin_app/src/models/app_config.dart';
import 'package:aladdin_app/src/core/services/api_service.dart';
import 'package:aladdin_app/src/features/splash/splash_screen.dart';

class CodePreviewScreen extends StatefulWidget {
  final AppConfig? config;
  const CodePreviewScreen({super.key, this.config});

  @override
  CodePreviewScreenState createState() => CodePreviewScreenState();
}

class CodePreviewScreenState extends State<CodePreviewScreen> {
  Map<String, dynamic>? apiData;
  String? errorMessage;
  AppConfig? _appConfig;

  static const String token = 'YOUR_GITHUB_PERSONAL_ACCESS_TOKEN';
  static const String repoOwner = 'your-username';
  static const String repoName = 'aladdin_app';
  static const String apiUrl = 'https://api.github.com/repos/$repoOwner/$repoName';
  static const String apkLink = 'https://github.com/your-username/aladdin_app/actions';

  @override
  void initState() {
    super.initState();
    _appConfig = widget.config;
    _processApiInput();
  }

  Future<void> _processApiInput() async {
    try {
      final configInput = _appConfig?.apiInput;
      debugPrint('Config Input: $configInput');
      if (configInput != null && configInput.isNotEmpty) {
        final apiConfig = await ApiService.generateApiConfig(configInput);
        debugPrint('API Config: $apiConfig');
        setState(() {
          _appConfig = _appConfig;
        });
        final data = await ApiService.fetchData(apiConfig);
        if (!mounted) return;
        setState(() => apiData = data);
      } else {
        if (!mounted) return;
        setState(() => errorMessage = 'No valid API input.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => errorMessage = 'Error: $e');
    }
  }

  Future<void> deleteProject() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete the project? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final response = await http.delete(
                Uri.parse(apiUrl),
                headers: {
                  'Authorization': 'token $token',
                  'Accept': 'application/vnd.github.v3+json'
                },
              );
              if (!mounted) return;
              if (response.statusCode == 204) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Project deleted successfully!')),
                );
                if (!mounted) return;
                Navigation.pushReplacement(context, const SplashScreen());
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Delete failed: ${response.statusCode}')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(const ClipboardData(text: apkLink));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard!')),
    );
  }

  Future<void> _openLink() async {
    final uri = Uri.parse(apkLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Preview', style: TextStyle(fontFamily: 'Poppins')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Your App is Ready!',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: apiData != null
                  ? SingleChildScrollView(
                      child: Text(
                        jsonEncode(apiData),
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                    )
                  : errorMessage != null
                      ? Center(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(fontFamily: 'Poppins', color: Colors.red),
                          ),
                        )
                      : const Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: 20),
            const Text('Download APK from:', style: TextStyle(fontFamily: 'Poppins')),
            const SizedBox(height: 10),
            Text( // یہاں const نہیں لگے گا کیونکہ apkLink variable ہے
              apkLink,
              style: const TextStyle(fontFamily: 'Poppins', color: Colors.blue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _copyLink,
                  child: const Text('Copy Link', style: TextStyle(fontFamily: 'Poppins')),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _openLink,
                  child: const Text('Open Link', style: TextStyle(fontFamily: 'Poppins')),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: deleteProject,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete Project', style: TextStyle(fontFamily: 'Poppins')),
            ),
          ],
        ),
      ),
    );
  }
}
