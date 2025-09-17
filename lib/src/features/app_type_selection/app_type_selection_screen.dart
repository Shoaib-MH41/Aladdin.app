import 'package:flutter/material.dart';
import '../../language_selection/language_selection_screen.dart'; // اگلی اسکرین

class AppTypeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ایپ کی قسم منتخب کریں')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LanguageSelectionScreen(appType: type)),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 18)),

