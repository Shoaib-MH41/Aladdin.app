import 'package:flutter/material.dart';

// تمام اسکرینز import کریں
import 'screens/home_screen.dart';
import 'screens/project_screen.dart';
import 'screens/selection_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const AladdinApp());
}

class AladdinApp extends StatelessWidget {
  const AladdinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aladdin App',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, // دن/رات auto
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        brightness: Brightness.dark,
      ),
      // پہلا اسکرین
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/projects': (context) => const ProjectScreen(),
        '/select': (context) => const SelectionScreen(),
        '/upload': (context) => const UploadScreen(),
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}
