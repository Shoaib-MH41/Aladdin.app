import 'package:flutter/material.dart';

// Import Screens
import 'screens/project_screen.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const AladdinApp());
}

class AladdinApp extends StatelessWidget {
  const AladdinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aladdin App Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
      // Default Route
      initialRoute: '/projects',

      // Routes
      routes: {
        '/projects': (context) => const ProjectScreen(),
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}
