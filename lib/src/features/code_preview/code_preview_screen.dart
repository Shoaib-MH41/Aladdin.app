import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // لنک کھولنے کے لیے
import 'package:flutter/services.dart'; // Clipboard کے لیے

class CodePreviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // فرض کریں یہ لنک GitHub Actions سے ملتا ہے (دستی طور پر سیٹ کرو)
    const apkLink = 'https://github.com/تمہارا-username/aladdin_app/actions'; // اصل لنک Actions ٹیب سے لے کر اپ ڈیٹ کرو

    return Scaffold(
      appBar: AppBar(title: Text('Code Preview')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your App is Ready! Download APK from here:'),
            SizedBox(height: 10),
            Text(apkLink, style: TextStyle(fontFamily: 'Poppins')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: apkLink));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Link copied to clipboard!')),
                );
              },
              child: Text('Copy APK Link'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (await canLaunch(apkLink)) {
                  await launch(apkLink); // براؤزر میں لنک کھولے گا
                }
              },
              child: Text('Share APK Link'),
            ),
          ],
        ),
      ),
    );
  }
}
