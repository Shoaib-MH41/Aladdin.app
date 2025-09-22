import 'package:flutter/material.dart';
import 'src/features/splash/splash_screen.dart';
import 'src/features/app_type_selection/app_type_selection_screen.dart';
import 'src/features/language_selection/language_selection_screen.dart';
import 'src/features/app_details/app_details_form.dart';
import 'src/features/code_preview/code_preview_screen.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/appType': (context) => const AppTypeSelectionScreen(),
        '/language': (context) => const LanguageSelectionScreen(),
        '/details': (context) => const AppDetailsForm(),
        '/preview': (context) => const CodePreviewScreen(),
      },
    );
  }
}
