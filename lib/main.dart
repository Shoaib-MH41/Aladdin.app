import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// سروسز کے امپورٹس
import 'services/gemini_service.dart';
import 'services/github_service.dart';
import 'services/api_service.dart';
import 'services/security_service.dart'; // ✅ نیا امپورٹ شامل کریں

// سکرینز کے امپورٹس
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

// ماڈلز کے امپورٹس
import 'models/api_template_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _optimizePerformance();
  runApp(const AladdinApp());
}

void _optimizePerformance() {
  // orientation کو لاک کریں
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // status bar کو transparent بنائیں
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
}

class AladdinApp extends StatelessWidget {
  const AladdinApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ تمام سروسز کو شروع کریں
    final geminiService = GeminiService();
    final githubService = GitHubService();
    final apiService = ApiService();
    final securityService = SecurityService(); // ✅ نیا سروس شامل کریں

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
      
      initialRoute: '/pin',
      
      routes: {
        // 🔒 PIN سکرین - درست parameters کے ساتھ
        '/pin': (context) => PinScreen(
              securityService: securityService, // ✅ securityService شامل کریں
              onUnlocked: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),

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

        // ⚙️ سیٹنگز سکرین - اگر parameters نہیں چاہیے تو
        '/settings': (context) => SettingsScreen(), // ✅ parameters ہٹائیں

        // 🔍 API ڈسکوری سکرین
        '/api-discovery': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return ApiDiscoveryScreen(
            discoveredApis: arguments?['discoveredApis'] ?? [],
            projectName: arguments?['projectName'] ?? 'نیا پروجیکٹ',
          );
        },

        // 🔌 API انٹیگریشن سکرین
        '/api-integration': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return ApiIntegrationScreen(
            apiTemplate: arguments?['apiTemplate'],
            onApiKeySubmitted: arguments?['onApiKeySubmitted'],
          );
        },

        // 🛠️ بلڈ سکرین
        '/build': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return BuildScreen(
            generatedCode: arguments?['code'] ?? '// کوئی کوڈ جنریٹ نہیں ہوا',
            projectName: arguments?['projectName'] ?? 'نیا پروجیکٹ',
            framework: arguments?['framework'] ?? 'Flutter',
          );
        },

        // 🏪 پبلش گائیڈ سکرین
        '/publish-guide': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return PublishGuideScreen(
            appName: arguments?['appName'] ?? 'میرا ایپ',
            generatedCode: arguments?['generatedCode'] ?? '// کوئی کوڈ نہیں',
            framework: arguments?['framework'] ?? 'Flutter',
          );
        },
      },

      // ❌ اگر کوئی روٹ نہیں ملا تو PIN پر جائے
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => PinScreen(
            securityService: securityService, // ✅ securityService شامل کریں
            onUnlocked: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
        );
      },
    );
  }

  // ✅ ایرر سکرین بنانے کا فنکشن
  Widget _buildErrorScreen(String message) {
    return Scaffold(
      appBar: AppBar(
        title: Text('خرابی'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text('ہوم پر واپس جائیں'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
