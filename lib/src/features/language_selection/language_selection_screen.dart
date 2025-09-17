import 'package:flutter/material.dart';
import '../../app_details/app_details_form.dart'; // اگلی اسکرین

class LanguageSelectionScreen extends StatelessWidget {
  final String appType;

  LanguageSelectionScreen({required this.appType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('پروگرامنگ لینگویج منتخب کریں')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildOption(context, 'Flutter'),
          _buildOption(context, 'React Native'),
          _buildOption(context, 'Kotlin'),
          _buildOption(context, 'Swift'),
          _buildOption(context, 'HTML + JS'),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String lang) {
    return ListTile(
      title: Text(lang),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppDetailsForm(appType: appType, language: lang),
          ),
        );
      },
    );
  }
}
