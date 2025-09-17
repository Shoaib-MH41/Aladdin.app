import 'package:flutter/material.dart';
import '../../core/constants/strings.dart';

class CodePreviewScreen extends StatelessWidget {
  final String generatedCode;

  const CodePreviewScreen({required this.generatedCode, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('کوڈ پریویو')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'جنریٹ شدہ کوڈ:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  generatedCode.isEmpty
                      ? 'کوئی کوڈ جنریٹ نہیں ہوا'
                      : generatedCode,
                  style: const TextStyle(fontFamily: 'Courier', fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // بعد میں GitHub پر پش کرنے کا فنکشن
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('کوڈ GitHub پر پش ہوگا')),
                  );
                },
                child: const Text('GitHub پر پش کریں'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
