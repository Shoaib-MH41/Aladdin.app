
import 'package:flutter/material.dart';
import 'programming_language_selection.dart'; // اگلی screen کا import

class AppTypeSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ایپ کی قسم منتخب کریں'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'آپ کون سی ایپ بنانا چاہتے ہیں؟',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),

            // Web App Option
            ElevatedButton.icon(
              icon: Icon(Icons.web, size: 32),
              label: Text('🌐 ویب ایپ'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
                backgroundColor: Colors.deepPurpleAccent,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProgrammingLanguageSelection()),
                );
              },
            ),
            SizedBox(height: 20),

            // Mobile App Option
            ElevatedButton.icon(
              icon: Icon(Icons.phone_android, size: 32),
              label: Text('📱 موبائل ایپ (Android/iOS)'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
                backgroundColor: Colors.deepPurpleAccent,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProgrammingLanguageSelection()),
                );
              },
            ),
            SizedBox(height: 20),

            // PWA Option
            ElevatedButton.icon(
              icon: Icon(Icons.cloud, size: 32),
              label: Text('⚡ PWA'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
                backgroundColor: Colors.deepPurpleAccent,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProgrammingLanguageSelection()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
