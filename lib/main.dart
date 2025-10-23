import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/project_screen.dart';
import 'screens/selection_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/build_screen.dart';
import 'screens/settings_screen.dart';
import 'services/gemini_service.dart';
import 'services/github_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AladdinApp());
}

class AladdinApp extends StatelessWidget {
  const AladdinApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Services initialize کریں
    final geminiService = GeminiService();
    final githubService = GitHubService();

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
              geminiService: geminiService,
              githubService: githubService,
            ),
        '/projects': (context) => ProjectScreen(
              geminiService: geminiService, // ✅ درست parameter
              githubService: githubService, // ✅ درست parameter
            ),
        '/select': (context) => SelectionScreen(
              geminiService: geminiService,
              githubService: githubService,
            ),
        '/upload': (context) => const UploadScreen(),
        '/chat': (context) => ChatScreen(
              geminiService: geminiService,
              githubService: githubService,
            ),
        '/settings': (context) => SettingsScreen(
              geminiService: geminiService,
              githubService: githubService,
            ),
        '/build': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          
          if (arguments == null) {
            return const BuildScreen(
              generatedCode: '// کوئی کوڈ نہیں ملا',
              projectName: 'نا معلوم پروجیکٹ',
            );
          }
          
          return BuildScreen(
            generatedCode: arguments['code'] ?? '// کوئی کوڈ جنریٹ نہیں ہوا',
            projectName: arguments['projectName'] ?? 'نیا پروجیکٹ',
            framework: arguments['framework'] ?? 'Flutter', // ✅ نیا parameter
          );
        },
      },
    );
  }
}
