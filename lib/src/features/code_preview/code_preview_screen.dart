import 'package:flutter/material.dart';
import '../../core/constants/strings.dart';
import '../../models/app_config.dart';

class CodePreviewScreen extends StatelessWidget {
  final AppConfig? config;

  const CodePreviewScreen({this.config, super.key});

  @override
  Widget build(BuildContext context) {
    final generatedCode = config != null
        ? '''
          // جنریٹ شدہ کوڈ کا نمونہ
          // ایپ: ${config!.appName}
          // قسم: ${config!.appType}
          // لینگویج: ${config!.language}
          void main() {
            print('Hello, ${config!.appName} in ${config!.language}!');
          }
          '''
        : 'کوئی کوڈ جنریٹ نہیں ہوا';

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
                  generatedCode,
                  style: const TextStyle(fontFamily: 'Courier', fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
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
