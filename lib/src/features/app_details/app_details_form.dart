import 'package:flutter/material.dart';

class AppDetailsForm extends StatefulWidget {
  @override
  _AppDetailsFormState createState() => _AppDetailsFormState();
}

class _AppDetailsFormState extends State<AppDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  String _appName = '';
  String _theme = 'لائٹ';
  String _primaryColor = 'نیلا';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
    final appType = args?['appType'] ?? 'mobile';
    final language = args?['language'] ?? 'Flutter';

    return Scaffold(
      appBar: AppBar(title: const Text('ایپ کی تفصیلات')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'ایپ کا نام'),
                onChanged: (value) => _appName = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ایپ کا نام درج کریں';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'تھیم'),
                value: _theme,
                items: ['لائٹ', 'ڈارک'].map((String theme) {
                  return DropdownMenuItem<String>(
                    value: theme,
                    child: Text(theme),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _theme = value!);
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'پرائمری رنگ'),
                value: _primaryColor,
                items: ['نیلا', 'سبز', 'سرخ'].map((String color) {
                  return DropdownMenuItem<String>(
                    value: color,
                    child: Text(color),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _primaryColor = value!);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('ایپ بنائی جا رہی ہے: $_appName ($appType, $language)'),
                      ),
                    );
                  }
                },
                child: const Text('اگلا'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
