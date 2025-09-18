
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => SplashScreen());

          case '/app_type_selection':
            return MaterialPageRoute(builder: (_) => AppTypeSelectionScreen());

          case '/language_selection':
            final args = settings.arguments as String? ?? 'mobile';
            return MaterialPageRoute(
              builder: (_) => LanguageSelectionScreen(appType: args),
            );

          case '/app_details':
            return MaterialPageRoute(builder: (_) => AppDetailsForm());

          case '/code_preview':
            final args = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => CodePreviewScreen(generatedCode: args),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Text('404 - Screen Not Found'),
                ),
              ),
            );
        }
      },
    );
  }
}
