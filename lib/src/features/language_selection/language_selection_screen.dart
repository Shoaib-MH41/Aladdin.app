import 'package:flutter/material.dart';
import 'package:aladdin_app/src/models/language_model.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final String appType; // ✅ نئے parameter کو شامل کریں

  const LanguageSelectionScreen({
    Key? key,
    required this.appType, // ✅ required parameter
  }) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  LanguageModel? _selectedLanguage;

  final List<LanguageModel> _languages = const [
    LanguageModel(
      code: 'en', 
      name: 'English', 
      nativeName: 'English', 
      flagEmoji: '🇺🇸'
    ),
    LanguageModel(
      code: 'ur', 
      name: 'Urdu', 
      nativeName: 'اردو', 
      flagEmoji: '🇵🇰'
    ),
    LanguageModel(
      code: 'ar', 
      name: 'Arabic', 
      nativeName: 'العربية', 
      flagEmoji: '🇸🇦'
    ),
  ];

  void _onLanguageSelected(LanguageModel? language) {
    if (language != null) {
      setState(() {
        _selectedLanguage = language;
      });
      // زبان منتخب کرنے کے بعد اگلا screen
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    // یہاں آپ اگلے screen پر navigation شامل کریں گے
    print('منتخب زبان: ${_selectedLanguage?.name}');
    print('ایپ کی قسم: ${widget.appType}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('زبان منتخب کریں - ${widget.appType}'), // ✅ appType دکھائیں
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'اپنی پسند کی زبان منتخب کریں',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<LanguageModel>( // ✅ FormField استعمال کریں
                value: _selectedLanguage,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'زبان',
                ),
                items: _languages.map((LanguageModel language) {
                  return DropdownMenuItem<LanguageModel>(
                    value: language,
                    child: Text('${language.flagEmoji} ${language.nativeName}'),
                  );
                }).toList(),
                onChanged: _onLanguageSelected,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _selectedLanguage == null
                    ? null
                    : _navigateToNextScreen,
                child: const Text('جاری رکھیں'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
