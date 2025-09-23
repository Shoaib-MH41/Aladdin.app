import 'package:flutter/material.dart';

class AppTypeSelectionScreen extends StatefulWidget {
  const AppTypeSelectionScreen({super.key});

  @override
  State<AppTypeSelectionScreen> createState() => _AppTypeSelectionScreenState();
}

class _AppTypeSelectionScreenState extends State<AppTypeSelectionScreen> {
  final Map<String, bool> platforms = {
    "Android": false,
    "iOS": false,
    "Web": false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Platforms")),
      body: Column(
        children: [
          ...platforms.keys.map((platform) {
            return CheckboxListTile(
              title: Text(platform),
              value: platforms[platform],
              onChanged: (value) {
                setState(() {
                  platforms[platform] = value ?? false;
                });
              },
            );
          }),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/details');
            },
            child: const Text("Save & Continue"),
          ),
        ],
      ),
    );
  }
}
