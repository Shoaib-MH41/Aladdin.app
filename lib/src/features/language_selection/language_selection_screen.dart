import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String selectedLanguage = "English";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Language")),
      body: Column(
        children: [
          RadioListTile(
            title: const Text("English"),
            value: "English",
            groupValue: selectedLanguage,
            onChanged: (value) {
              setState(() => selectedLanguage = value.toString());
            },
          ),
          RadioListTile(
            title: const Text("اردو"),
            value: "Urdu",
            groupValue: selectedLanguage,
            onChanged: (value) {
              setState(() => selectedLanguage = value.toString());
            },
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/details');
            },
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }
}

