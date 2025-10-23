import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/project_screen.dart';
import 'screens/selection_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/build_screen.dart';
import 'services/gemini_service.dart'; // ✅ نئی
import 'services/github_service.dart'; // ✅ نئی

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AladdinApp());
}

class AladdinApp extends StatelessWidget {
  const AladdinApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ APIs کے keys - بعد میں environment variables میں ڈالیں
    final geminiService = GeminiService('your_gemini_api_key_here');
    final githubService = GitHubService('your_github_token_here');

    return MaterialApp(
      title: 'Aladdin AI App Factory',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomeScreen(
              geminiService: geminiService, // ✅ پاس کریں
              githubService: githubService, // ✅ پاس کریں
            ),
        '/projects': (context) => ProjectScreen(
              geminiService: geminiService, // ✅ پاس کریں
              githubService: githubService, // ✅ پاس کریں
            ),
        '/select': (context) => SelectionScreen(
              geminiService: geminiService, // ✅ پاس کریں
              githubService: githubService, // ✅ پاس کریں
            ),
        '/upload': (context) => const UploadScreen(),
        '/chat': (context) => const ChatScreen(),
        '/build': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          
          if (arguments == null) {
            return const BuildScreen(generatedCode: '// کوئی کوڈ نہیں ملا');
          }
          
          return BuildScreen(
            generatedCode: arguments['code'] ?? '// کوئی کوڈ جنریٹ نہیں ہوا',
            projectName: arguments['projectName'] ?? 'نیا پروجیکٹ',
          );
        },
      },
    );
  }
}
