import 'package:flutter/material.dart';
import 'src/features/splash/splash_screen.dart';
import 'src/features/app_type_selection/app_type_selection_screen.dart';
import 'src/features/language_selection/language_selection_screen.dart';
import 'src/features/app_details/app_details_form.dart';
import 'src/features/code_preview/code_preview_screen.dart';

void main() {
  runApp(AladdinApp());
}

class AladdinApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'علادین ایپ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/app_type_selection': (context) => AppTypeSelectionScreen(),
        '/language_selection': (context) => LanguageSelectionScreen(
              appType: ModalRoute.of(context)!.settings.arguments as String? ?? 'mobile',
            ),
        '/app_details': (context) => AppDetailsForm(),
        '/code_preview': (context) => const CodePreviewScreen(generatedCode: ''),
      },
    );
  }
}
