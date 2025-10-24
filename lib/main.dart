import 'package:flutter/material.dart';

// سکرینز کے امپورٹس
import 'screens/home_screen.dart';
import 'screens/project_screen.dart';
import 'screens/selection_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/build_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/api_integration_screen.dart';
import 'screens/publish_guide_screen.dart'; // ✅ نیا شامل کیا

// سروسز کے امپورٹس
import 'services/gemini_service.dart';
import 'services/github_service.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AladdinApp());
}

class AladdinApp extends StatelessWidget {
  const AladdinApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ سروسز کو شروع کریں
    final geminiService = GeminiService();
    final githubService = GitHubService();
    final apiService = ApiService();

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
        fontFamily: 'Urdu', // ✅ اردو فونٹ کے لیے
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Urdu', // ✅ اردو فونٹ کے لیے
      ),
      initialRoute: '/home',
      routes: {
        // 🏠 ہوم سکرین
        '/home': (context) => HomeScreen(
              geminiService: geminiService,
              githubService: githubService,
            ),

        // 📁 پروجیکٹ سکرین
        '/projects': (context) => ProjectScreen(
              geminiService: geminiService,
              githubService: githubService,
            ),

        // 🎯 سلیکشن سکرین
        '/select': (context) => SelectionScreen(
              geminiService: geminiService,
              githubService: githubService,
            ),

        // 📤 اپلوڈ سکرین
        '/upload': (context) => const UploadScreen(),

        // 💬 چیٹ سکرین
        '/chat': (context) => ChatScreen(
              geminiService: geminiService,
              githubService: githubService,
            ),

        // ⚙️ سیٹنگز سکرین
        '/settings': (context) => SettingsScreen(
              geminiService: geminiService,
              githubService: githubService,
            ),

        // 🔌 API انٹیگریشن سکرین
        '/api-integration': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          
          if (arguments == null) {
            return Scaffold(
              appBar: AppBar(title: Text('خرابی')),
              body: Center(child: Text('API انٹیگریشن کے لیے ڈیٹا نہیں ملا')),
            );
          }
          
          return ApiIntegrationScreen(
            apiTemplate: arguments['apiTemplate'],
            onApiKeySubmitted: arguments['onApiKeySubmitted'],
          );
        },

        // 🛠️ بلڈ سکرین
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
            framework: arguments['framework'] ?? 'Flutter',
          );
        },

        // 🏪 پبلش گائیڈ سکرین (نیا شامل کیا گیا)
        '/publish-guide': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          
          if (arguments == null) {
            return Scaffold(
              appBar: AppBar(title: Text('خرابی')),
              body: Center(child: Text('پبلش گائیڈ کے لیے ڈیٹا نہیں ملا')),
            );
          }
          
          return PublishGuideScreen(
            appName: arguments['appName'] ?? 'میرا ایپ',
            generatedCode: arguments['generatedCode'] ?? '// کوئی کوڈ نہیں',
            framework: arguments['framework'] ?? 'Flutter',
          );
        },
      },

      // 🏠 ڈیفالٹ ہوم اگر کوئی روٹ نہیں ملا
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => HomeScreen(
            geminiService: geminiService,
            githubService: githubService,
          ),
        );
      },
    );
  }
}
