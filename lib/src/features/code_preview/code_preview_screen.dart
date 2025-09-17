import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // لنک کھولنے/شیئر کرنے کے لیے
import 'package:http/http.dart' as http; // GitHub API کال کے لیے
import 'package:flutter/services.dart'; // Clipboard کے لیے
import 'dart:convert'; // JSON ریسپانس کے لیے

class CodePreviewScreen extends StatelessWidget {
  // GitHub API کے لیے متغیرات (تمہیں اپنا ٹوکن اور repo نام شامل کرنا ہوگا)
  static const String token = 'تمہارا_GitHub_Personal_Access_Token'; // سیٹ اپ کریں
  static const String repoOwner = 'تمہارا-username'; // اپنا username
  static const String repoName = 'aladdin_app'; // اپنا repo نام
  static const String apiUrl = 'https://api.github.com/repos/$repoOwner/$repoName';

  // APK لنک (Actions سے اصل لنک لے کر اپ ڈیٹ کرو)
  static const String apkLink = 'https://github.com/تمہارا-username/aladdin_app/actions'; // Actions لنک، بعد میں اپ ڈیٹ کرو

  // پروجیکٹ ڈیلیٹ کرنے کی فنکشن
  Future<void> deleteProject(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete the project? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // ڈائیلاگ بند کرو
              final response = await http.delete(
                Uri.parse(apiUrl),
                headers: {
                  'Authorization': 'token $token',
                  'Accept': 'application/vnd.github.v3+json',
                },
              );

              if (response.statusCode == 204) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Project deleted successfully!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete project. Check token or permissions.')),
                );
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Code Preview', style: TextStyle(fontFamily: 'Poppins')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your App is Ready!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.w500, // Medium فانٹ
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Download APK from:',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            SizedBox(height: 10),
            Text(
              apkLink,
              style: TextStyle(fontFamily: 'Poppins', color: Colors.blue),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: apkLink));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Link copied to clipboard!')),
                    );
                  },
                  child: Text('Copy Link', style: TextStyle(fontFamily: 'Poppins')),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (await canLaunch(apkLink)) {
                      await launch(apkLink); // براؤزر میں لنک کھولے گا
                    }
                  },
                  child: Text('Share Link', style: TextStyle(fontFamily: 'Poppins')),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => deleteProject(context),
              child: Text('Delete Project', style: TextStyle(fontFamily: 'Poppins')),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
