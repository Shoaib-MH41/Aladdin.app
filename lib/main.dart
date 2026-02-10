import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ✅ سروسز کے امپورٹس
import 'services/gemini_service.dart';
import 'services/github_service.dart';
import 'services/api_service.dart';
import 'services/security_service.dart';
import 'services/ad_service.dart'; // ✅ نیا: اشتہار سروس

// ✅ سکرینز کے امپورٹس
import 'screens/pin_screen.dart';
import 'screens/home_screen.dart';
import 'screens/project_screen.dart';
import 'screens/selection_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/chat/chat_main_screen.dart'; // ✅ اپ ڈیٹ: نئی چھٹ اسکرین کا راستہ
import 'screens/build_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/api_integration_screen.dart';
import 'screens/api_discovery_screen.dart';
import 'screens/publish_guide_screen.dart';
import 'screens/ads_screen.dart'; // ✅ نیا: اشتہار اسکرین
import 'screens/ad_campaign_list_screen.dart'; // ✅ نیا: اشتہار مہم فہرست

// ✅ ماڈلز کے امپورٹس
import 'models/api_template_model.dart';
import 'models/project_model.dart';
import 'models/ad_model.dart'; // ✅ نیا: اشتہار ماڈل
import 'models/chat_model.dart'; // ✅ نیا: چیٹ ماڈل

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _optimizePerformance();
  _setupErrorHandling();
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

// ✅ درست: Error Handling Setup
void _setupErrorHandling() {
  // Flutter errors handle کریں
  FlutterError.onError = (FlutterErrorDetails details) {
    print('🚨 Flutter Error: ${details.exception}');
    print('📝 StackTrace: ${details.stack}');
    // آپ یہاں Firebase Crashlytics یا کوئی اور error reporting service شامل کر سکتے ہیں
  };

  // Run-time errors handle کریں
  PlatformDispatcher.instance.onError = (error, stack) {
    print('🚨 Runtime Error: $error');
    print('📝 StackTrace: $stack');
    return true; // Prevent app crash
  };
}

class AladdinApp extends StatelessWidget {
  const AladdinApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ تمام سروسز کی single instance بنائیں
    final geminiService = GeminiService();
    final githubService = GitHubService();
    final apiService = ApiService();
    final securityService = SecurityService();
    final adService = AdService(); // ✅ نیا: اشتہار سروس

    return MaterialApp(
      title: 'Aladdin AI App Factory',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Modern Indigo
          brightness: Brightness.light,
        ),
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6), // Modern Violet
          brightness: Brightness.dark,
        ),
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
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
              adService: adService, // ✅ نیا: اشتہار سروس پاس کریں
            ),

        '/projects': (context) => ProjectScreen(
              geminiService: geminiService,
              githubService: githubService,
              adService: adService, // ✅ نیا: اشتہار سروس پاس کریں
            ),

        '/select': (context) => SelectionScreen(
              geminiService: geminiService,
              githubService: githubService,
            ),

        '/upload': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Project) {
            return UploadScreen(project: args); // ✅ پروجیکٹ پاس کریں
          } else {
            return _buildErrorScreen(
              context, 
              'Upload screen requires project data.\nPlease go back and try again.'
            );
          }
        },

        // ✅ اپ ڈیٹ: نئی chat_main_screen کا راستہ
        '/chat': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Project) {
            return ChatMainScreen( // ✅ نام تبدیل کیا
              geminiService: geminiService,
              githubService: githubService,
              project: args,
            );
          } else {
            return _buildErrorScreen(
              context,
              'Chat screen requires project data.\nPlease select a project first.'
            );
          }
        },

        '/settings': (context) => SettingsScreen(),

        // ✅ نیا: اشتہار مہم اسکرین
        '/ads': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic>) {
            return AdsScreen(
              projectName: args['projectName'] ?? 'نیا پروجیکٹ',
              initialBudget: args['initialBudget'] ?? 100.0,
              initialAdText: args['initialAdText'] ?? 'میرے ایپ کو آزمائیں!',
              adService: adService, // ✅ adService واپس شامل کریں
            );
          } else {
            return _buildErrorScreen(
              context,
              'Ad campaign screen requires project data.'
            );
          }
        },

        // ✅ نیا: اشتہار مہم فہرست اسکرین
        '/ad-campaigns': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic>) {
            return AdCampaignListScreen(
              projectId: args['projectId'] ?? '',
              projectName: args['projectName'] ?? 'نیا پروجیکٹ',
              adService: adService, // ✅ adService واپس شامل کریں
            );
          } else {
            return _buildErrorScreen(
              context,
              'Ad campaigns list requires project data.'
            );
          }
        },

        '/api-discovery': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          if (args != null) {
            return ApiDiscoveryScreen(
              discoveredApis: (args['discoveredApis'] as List?)?.cast<ApiTemplate>() ?? [],
              projectName: args['projectName'] ?? 'نیا پروجیکٹ',
            );
          } else {
            return _buildErrorScreen(
              context,
              'API discovery requires data.'
            );
          }
        },

        '/api-integration': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          if (args != null && args['apiTemplate'] is ApiTemplate) {
            return ApiIntegrationScreen(
              apiTemplate: args['apiTemplate'] as ApiTemplate,
              onApiKeySubmitted: args['onApiKeySubmitted'] as Function(String)?,
            );
          } else {
            return _buildErrorScreen(
              context,
              'API integration requires valid data.'
            );
          }
        },

        '/build': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return BuildScreen(
            generatedCode: args?['code']?.toString() ?? '// کوئی کوڈ جنریٹ نہیں ہوا',
            projectName: args?['projectName']?.toString() ?? 'نیا پروجیکٹ',
            framework: args?['framework']?.toString() ?? 'Flutter',
          );
        },

        '/publish-guide': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return PublishGuideScreen(
            appName: args?['appName']?.toString() ?? 'میرا ایپ',
            generatedCode: args?['generatedCode']?.toString() ?? '// کوئی کوڈ نہیں',
            framework: args?['framework']?.toString() ?? 'Flutter',
          );
        },
      },

      // ❌ اگر کوئی route نہیں ملا
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Route Not Found'),
            backgroundColor: Colors.orange,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber, size: 64, color: Colors.orange),
                const SizedBox(height: 20),
                Text(
                  'Route "${settings.name}" not found',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      ),

      // ✅ Global error handler
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    'An error occurred',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    details.exception.toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    child: const Text('Restart App'),
                  ),
                ],
              ),
            ),
          );
        };

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0, // Prevent text scaling issues
          ),
          child: child!,
        );
      },
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
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                child: const Text('ہوم پر واپس جائیں'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
