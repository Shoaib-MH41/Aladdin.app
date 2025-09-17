import 'package:flutter/material.dart';
import '../../app_details/app_details_form.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final String appType;

  const LanguageSelectionScreen({required this.appType, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پروگرامنگ لینگویج منتخب کریں')),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.pushNamed(context, '/app_details', arguments: {
          'appType': appType,
          'language': lang,
        });
      },
    );
  }
}
