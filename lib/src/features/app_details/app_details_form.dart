import 'package:flutter/material.dart';

class AppDetailsForm extends StatefulWidget {
  const AppDetailsForm({super.key});

  @override
  State<AppDetailsForm> createState() => _AppDetailsFormState();
}

class _AppDetailsFormState extends State<AppDetailsForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("App Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "App Name"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/preview');
              },
              child: const Text("Generate Code"),
            ),
          ],
        ),
      ),
    );
  }
}
