import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';

import '../../core/utils/navigation.dart';
import '../../models/app_config.dart';
import '../../core/services/api_service.dart';
import '../../features/splash/splash_screen.dart'; // پاتھ درست کیا

class CodePreviewScreen extends StatefulWidget {
  @override
  _CodePreviewScreenState createState() => _CodePreviewScreenState();
}

class _CodePreviewScreenState extends State<CodePreviewScreen> {
  Map<String, dynamic>? apiData;
  String? errorMessage;

  static const String token = 'YOUR_GITHUB_PERSONAL_ACCESS_TOKEN'; // اپنا ٹوکن یہاں ڈالو
  static const String repoOwner = 'your-username';
  static const String repoName = 'aladdin_app';
  static const String apiUrl = 'https://api.github.com/repos/$repoOwner/$repoName';
  static const String apkLink = 'https://github.com/your-username/aladdin_app/actions'; // اصل لنک اپ ڈیٹ کرو

  @override
  void initState() {
    super.initState();
    _processApiInput();
  }

  Future<void> _processApiInput() async {
    try {
      final configInput = AppConfig().apiInput;
      print('Config Input: $configInput'); // ڈیبگ
      if (configInput != null && configInput.isNotEmpty) {
        final apiConfig = await ApiService.generateApiConfig(configInput);
        print('API Config: $apiConfig'); // ڈیبگ
        AppConfig().apiConfig = apiConfig;
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
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete the project? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final response = await http.delete(
                Uri.parse(apiUrl),
                headers: {'Authorization': 'token $token', 'Accept': 'application/vnd.github.v3+json'},
              );
              if (response.statusCode == 204) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Project deleted successfully!')));
                Navigation.pushReplacement(context, SplashScreen());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: ${response.statusCode}')));
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: apkLink));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Link copied to clipboard!')));
  }

  Future<void> _openLink() async {
    final uri = Uri.parse(apkLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch link.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Code Preview', style: TextStyle(fontFamily: 'Poppins'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Your App is Ready!', style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w500)),
            SizedBox(height: 20),
            Expanded(
              child: apiData != null
                  ? SingleChildScrollView(child: Text(jsonEncode(apiData), style: TextStyle(fontFamily: 'Poppins')))
                  : errorMessage != null
                      ? Center(child: Text(errorMessage!, style: TextStyle(fontFamily: 'Poppins', color: Colors.red)))
                      : Center(child: CircularProgressIndicator()),
            ),
            SizedBox(height: 20),
            Text('Download APK from:', style: TextStyle(fontFamily: 'Poppins')),
            SizedBox(height: 10),
            Text(apkLink, style: TextStyle(fontFamily: 'Poppins', color: Colors.blue), textAlign: TextAlign.center),
            SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(onPressed: _copyLink, child: Text('Copy Link', style: TextStyle(fontFamily: 'Poppins'))),
              SizedBox(width: 10),
              ElevatedButton(onPressed: _openLink, child: Text('Open Link', style: TextStyle(fontFamily: 'Poppins'))),
            ]),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: deleteProject,
              child: Text('Delete Project', style: TextStyle(fontFamily: 'Poppins')),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
