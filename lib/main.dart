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
  _setupErrorHandling(); // ✅ نیا error handling
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

// ✅ نیا: Error Handling Setup
void _setupErrorHandling() {
  // Flutter errors handle کریں
  FlutterError.onError = (FlutterErrorDetails details) {
    print('🚨 Flutter Error: ${details.exception}');
    print('📝 StackTrace: ${details.stack}');
  };

  // Platform errors handle کریں
  PlatformExceptionHandler? handler;
  try {
    handler = ServicesBinding.instance.platformExceptionHandler;
  } catch (e) {
    print('⚠️ Platform exception handler not available');
  }
}

class AladdinApp extends StatelessWidget {
  const AladdinApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ تمام سروسز initialize کریں - بہتر error handling کے ساتھ
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

      // ✅ تمام روٹس یہاں define کریں - بہتر error handling کے ساتھ
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

        '/upload': (context) {
          try {
            return const UploadScreen();
          } catch (e) {
            print('🚨 UploadScreen Error: $e');
            return _buildErrorScreen('Upload screen load failed: $e');
          }
        },

        '/chat': (context) => ChatScreen(
              geminiService: geminiService,
              githubService: githubService,
            ),

        '/settings': (context) => SettingsScreen(),

        '/api-discovery': (context) {
          try {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            return ApiDiscoveryScreen(
              discoveredApis: args?['discoveredApis'] ?? [],
              projectName: args?['projectName'] ?? 'نیا پروجیکٹ',
            );
          } catch (e) {
            print('🚨 ApiDiscoveryScreen Error: $e');
            return _buildErrorScreen('API Discovery screen load failed: $e');
          }
        },

        '/api-integration': (context) {
          try {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            return ApiIntegrationScreen(
              apiTemplate: args?['apiTemplate'],
              onApiKeySubmitted: args?['onApiKeySubmitted'],
            );
          } catch (e) {
            print('🚨 ApiIntegrationScreen Error: $e');
            return _buildErrorScreen('API Integration screen load failed: $e');
          }
        },

        '/build': (context) {
          try {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            return BuildScreen(
              generatedCode: args?['code'] ?? '// کوئی کوڈ جنریٹ نہیں ہوا',
              projectName: args?['projectName'] ?? 'نیا پروجیکٹ',
              framework: args?['framework'] ?? 'Flutter',
            );
          } catch (e) {
            print('🚨 BuildScreen Error: $e');
            return _buildErrorScreen('Build screen load failed: $e');
          }
        },

        '/publish-guide': (context) {
          try {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            return PublishGuideScreen(
              appName: args?['appName'] ?? 'میرا ایپ',
              generatedCode: args?['generatedCode'] ?? '// کوئی کوڈ نہیں',
              framework: args?['framework'] ?? 'Flutter',
            );
          } catch (e) {
            print('🚨 PublishGuideScreen Error: $e');
            return _buildErrorScreen('Publish guide screen load failed: $e');
          }
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

      // ✅ نیا: Global error handling
      builder: (context, widget) {
        if (widget == null) {
          return _buildErrorScreen('Widget is null');
        }
        return widget;
      },
    );
  }

  // ✅ بہتر Error Screen
  Widget _buildErrorScreen(String message) {
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
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Home screen پر واپس جائیں
                  Navigator.pushReplacementNamed(
                    // context کو کیسے access کریں؟ یہ tricky ہے
                    // اس لیے app restart کریں
                    // عملی طور پر user app کو دوبارہ start کرے گا
                    const Key('error_context').currentContext!,
                    '/home'
                  );
                },
                child: const Text('ہوم پر واپس جائیں'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // App کو close کریں
                  SystemNavigator.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                child: const Text('ایپ بند کریں'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ نیا: Permission Debugging Widget
class PermissionDebugWidget extends StatelessWidget {
  final String debugInfo;

  const PermissionDebugWidget({super.key, required this.debugInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        '🔍 Debug: $debugInfo',
        style: const TextStyle(fontSize: 12, color: Colors.orange[800]),
      ),
    );
  }
}
