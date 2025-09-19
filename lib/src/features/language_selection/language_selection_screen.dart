import 'package:flutter/material.dart';
import 'package:aladdin_app/src/models/language_model.dart'; // ✅ package import

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key); // ✅ key parameter

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  LanguageModel? _selectedLanguage;

  final List<LanguageModel> _languages = const [ // ✅ const
    LanguageModel(code: 'en', name: 'English'),
    LanguageModel(code: 'ur', name: 'Urdu'),
    LanguageModel(code: 'ar', name: 'Arabic'),
  ];

  void _onLanguageSelected(LanguageModel? language) {
    if (language != null) {
      setState(() {
        _selectedLanguage = language;
      });
      // زبان منتخب کرنے کے بعد اگلا screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زبان منتخب کریں'), // ✅ const
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text( // ✅ const
              'اپنی پسند کی زبان منتخب کریں',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20), // ✅ const
            DropdownButton<LanguageModel>(
              value: _selectedLanguage,
              items: _languages.map((LanguageModel language) {
                return DropdownMenuItem<LanguageModel>(
                  value: language,
                  child: Text(language.name),
                );
              }).toList(),
              onChanged: _onLanguageSelected,
            ),
            const SizedBox(height: 20), // ✅ const
            ElevatedButton(
              onPressed: _selectedLanguage == null
                  ? null
                  : () {
                      // منتخب زبان کو save کریں
                    },
              child: const Text('جاری رکھیں'), // ✅ const
            ),
          ],
        ),
      ),
    );
  }
}
