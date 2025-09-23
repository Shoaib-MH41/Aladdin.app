import 'package:flutter/material.dart';
import 'screens/project_screen.dart';
import 'screens/selection_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/chat_screen.dart';
import 'models/project_model.dart';

void main() {
  runApp(const AladdinApp());
}

class AladdinApp extends StatelessWidget {
  const AladdinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aladdin App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ProjectScreen(),
        '/select': (context) => const SelectionScreen(),
        '/upload': (context) => const UploadScreen(),
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}
