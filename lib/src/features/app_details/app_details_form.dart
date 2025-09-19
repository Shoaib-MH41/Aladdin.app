import 'package:flutter/material.dart';
import 'package:aladdin_app/src/core/constants/strings.dart'; // ✅ درست راستہ
import 'package:aladdin_app/src/models/app_config.dart'; // ✅ درست راستہ
import 'package:aladdin_app/src/features/code_preview/code_preview_screen.dart'; // ✅ درست راستہ

class AppDetailsForm extends StatefulWidget {
  const AppDetailsForm({super.key});

  @override
  _AppDetailsFormState createState() => _AppDetailsFormState();
}

class _AppDetailsFormState extends State<AppDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  String _appName = '';
  String? _apiInput;
  String _theme = 'لائٹ';
  String _primaryColor = 'نیلا';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>? ?? {};
    final appType = args['appType'] ?? 'mobile';
    final language = args['language'] ?? 'Flutter';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'App Details', // ✅ براہ راست text استعمال کریں
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ایپ کا نام
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'ایپ کا نام',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _appName = value,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'ایپ کا نام درج کریں' : null,
              ),
              const SizedBox(height: 16),

              // API Input
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'API تفصیلات/لنک (Firebase یا کسی اور سے)',
                  hintText: 'e.g., API URL, Key, or Firebase Studio Link',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _apiInput = value,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Theme
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'تھیم'),
                value: _theme,
                items: ['لائٹ', 'ڈارک'].map((String theme) {
                  return DropdownMenuItem<String>(
                    value: theme,
                    child: Text(theme),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _theme = value!),
              ),
              const SizedBox(height: 16),

              // Primary Color
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'پرائمری رنگ'),
                value: _primaryColor,
                items: ['نیلا', 'سبز', 'سرخ'].map((String color) {
                  return DropdownMenuItem<String>(
                    value: color,
                    child: Text(color),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _primaryColor = value!),
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final config = AppConfig(
                      appName: _appName,
                      appType: appType,
                      language: language,
                      theme: _theme,
                      primaryColor: _primaryColor,
                      apiInput: _apiInput,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CodePreviewScreen(),
                        settings: RouteSettings(arguments: config),
                      ),
                    );
                  }
                },
                child: const Text(
                  'ایپ بنائیں', // ✅ براہ راست text استعمال کریں
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
