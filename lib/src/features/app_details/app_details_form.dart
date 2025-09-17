import 'package:flutter/material.dart';
import '../../core/utils/navigation.dart';
import '../../models/app_config.dart';

class AppDetailsForm extends StatefulWidget {
  @override
  _AppDetailsFormState createState() => _AppDetailsFormState();
}

class _AppDetailsFormState extends State<AppDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _appConfig = AppConfig();
  String? _apiInput; // Firebase Studio سے کاپی کردہ API تفصیلات

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('App Details', style: TextStyle(fontFamily: 'Poppins'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'App Name', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Enter app name' : null,
                onSaved: (value) => _appConfig.appName = value!,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Paste API Details/Link (from Firebase Studio)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., API URL, Key, or Firebase Studio Link',
                ),
                onSaved: (value) => _apiInput = value,
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _appConfig.apiInput = _apiInput; // API تفصیلات محفوظ کرو
                    Navigation.push(context, CodePreviewScreen());
                  }
                },
                child: Text('Next', style: TextStyle(fontFamily: 'Poppins')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
