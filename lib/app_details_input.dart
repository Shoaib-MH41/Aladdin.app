

import 'package:flutter/material.dart';

class AppDetailsInput extends StatefulWidget {
  @override
  _AppDetailsInputState createState() => _AppDetailsInputState();
}

class _AppDetailsInputState extends State<AppDetailsInput> {
  final _formKey = GlobalKey<FormState>();

  String appName = '';
  String appIcon = '';
  String theme = 'Light';
  String primaryColor = '#6200EE';
  String navigationStyle = 'Tab';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ایپ کی تفصیلات درج کریں'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'ایپ کا نام'),
                onChanged: (value) => appName = value,
                validator: (value) =>
                    value!.isEmpty ? 'براہ کرم ایپ کا نام لکھیں' : null,
              ),
              SizedBox(height: 15),

              TextFormField(
                decoration: InputDecoration(labelText: 'ایپ کا آئیکن (Image URL یا Name)'),
                onChanged: (value) => appIcon = value,
                validator: (value) =>
                    value!.isEmpty ? 'براہ کرم آئیکن درج کریں' : null,
              ),
              SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: theme,
                items: ['Light', 'Dark', 'Auto']
                    .map((theme) => DropdownMenuItem(
                          value: theme,
                          child: Text(theme),
                        ))
                    .toList(),
                onChanged: (value) => theme = value!,
                decoration: InputDecoration(labelText: 'Theme منتخب کریں'),
              ),
              SizedBox(height: 15),

              TextFormField(
                decoration: InputDecoration(labelText: 'Primary Color (#hex یا نام)'),
                onChanged: (value) => primaryColor = value,
                validator: (value) =>
                    value!.isEmpty ? 'براہ کرم رنگ درج کریں' : null,
              ),
              SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: navigationStyle,
                items: ['Tab', 'Drawer', 'Bottom Nav']
                    .map((style) => DropdownMenuItem(
                          value: style,
                          child: Text(style),
                        ))
                    .toList(),
                onChanged: (value) => navigationStyle = value!,
                decoration: InputDecoration(labelText: 'Navigation Style منتخب کریں'),
              ),
              SizedBox(height: 25),

              ElevatedButton(
                child: Text('اگلا مرحلہ', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.deepPurpleAccent,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // یہاں ہم آگے بڑھیں گے
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('تفصیلات محفوظ ہو گئیں'),
                        content: Text('App Name: $appName\nTheme: $theme\nColor: $primaryColor'),
                        actions: [
                          TextButton(
                            child: Text('OK'),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

