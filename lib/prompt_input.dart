

import 'package:flutter/material.dart';
import 'code_preview.dart';  // اگلی screen کا import

class PromptInput extends StatefulWidget {
  @override
  _PromptInputState createState() => _PromptInputState();
}

class _PromptInputState extends State<PromptInput> {
  final _formKey = GlobalKey<FormState>();
  String userPrompt = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اپنی App کی تفصیلات لکھیں'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'مثلاً: مجھے ایک Todo App چاہیے جو آفس ورک منیج کرے',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => userPrompt = value,
                validator: (value) =>
                    value!.isEmpty ? 'براہ کرم پرومٹ لکھیں' : null,
              ),
              SizedBox(height: 20),

              ElevatedButton(
                child: Text('Code Generate کریں', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.deepPurpleAccent,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // آگے Code Preview Screen پر جائیں گے
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CodePreview(prompt: userPrompt),
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

