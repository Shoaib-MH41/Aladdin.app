import 'package:flutter/material.dart';
import 'package:aladdin_app/src/features/language_selection/language_selection_screen.dart'; // ✅ package import

class AppTypeSelectionScreen extends StatelessWidget {
  const AppTypeSelectionScreen({Key? key}) : super(key: key); // ✅ key parameter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ایپ کی قسم منتخب کریں'), // ✅ const
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16), // ✅ const
        children: [
          _buildCard(context, 'ویب ایپ', Icons.web, 'web'),
          _buildCard(context, 'موبائل ایپ', Icons.phone_android, 'mobile'),
          _buildCard(context, 'PWA', Icons.public, 'pwa'),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, String type) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push<Widget>(
            context,
            MaterialPageRoute<Widget>(
              builder: (context) => LanguageSelectionScreen(appType: type),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue),
            const SizedBox(height: 10), // ✅ const
            Text(title, style: const TextStyle(fontSize: 18)), // ✅ const
          ],
        ),
      ),
    );
  }
}
