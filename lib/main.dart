import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ✅ سروسز کے امپورٹس
import 'services/gemini_service.dart';
import 'services/github_service.dart';
import 'services/api_service.dart';
import 'services/security_service.dart';

// ✅ سکرینز کے امپورٹس
import 'screens/pin_screen.dart';
import 'screens/home_screen.dart';
import 'screens/project_screen.dart';
import 'screens/selection_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/build_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/api_integration_screen.dart';
import 'screens/api_discovery_screen.dart';
import 'screens/publish_guide_screen.dart';

// ✅ ماڈلز کے امپورٹس
import 'models/api_template_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _optimizePerformance();
  runApp(const AladdinApp());
}

void _optimizePerformance() {
  // اسکرین کا orientation صرف portrait پر رکھیں
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar کو شفاف (transparent) بنائیں
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
}

class AladdinApp extends StatelessWidget {
  const AladdinApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ تمام سروسز initialize کریں
    final geminiService = GeminiService();
    final githubService = GitHubService();
    final apiService = ApiService();
    final securityService = SecurityService();

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
        fontFamily: 'Urdu',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Urdu',
      ),

      // 🔒 لاک اسکرین سے شروعات کریں
      initialRoute: '/pin',

      // ✅ تمام روٹس یہاں define کریں
      routes: {
        '/pin': (context) => PinScreen(
              securityService: securityService,
              onUnlocked: () =>
                  Navigator.pushReplacementNamed(context, '/home'),
            ),

        '/home': (context) => HomeScreen(
              geminiService: geminiService,
              githubService: githubService,
            ),

        '/projects': (context) => ProjectScreen(
              geminiService: geminiService,
              githubService: githubService,
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

        '/settings': (context) => SettingsScreen(),

        '/api-discovery': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return ApiDiscoveryScreen(
            discoveredApis: args?['discoveredApis'] ?? [],
            projectName: args?['projectName'] ?? 'نیا پروجیکٹ',
          );
        },

        '/api-integration': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return ApiIntegrationScreen(
            apiTemplate: args?['apiTemplate'],
            onApiKeySubmitted: args?['onApiKeySubmitted'],
          );
        },

        '/build': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return BuildScreen(
            generatedCode: args?['code'] ?? '// کوئی کوڈ جنریٹ نہیں ہوا',
            projectName: args?['projectName'] ?? 'نیا پروجیکٹ',
            framework: args?['framework'] ?? 'Flutter',
          );
        },

        '/publish-guide': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return PublishGuideScreen(
            appName: args?['appName'] ?? 'میرا ایپ',
            generatedCode: args?['generatedCode'] ?? '// کوئی کوڈ نہیں',
            framework: args?['framework'] ?? 'Flutter',
          );
        },
      },

      // ❌ اگر کوئی route نہیں ملا
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => PinScreen(
          securityService: securityService,
          onUnlocked: () =>
              Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
    );
  }

  // ✅ ایرر سکرین (Error Screen)
  Widget _buildErrorScreen(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خرابی'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/home'),
                child: const Text('ہوم پر واپس جائیں'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
