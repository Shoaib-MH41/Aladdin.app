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
import 'screens/chat_screen.dart';
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
  };

  // Platform errors handle کریں
  PlatformExceptionHandler? handler;
  try {
    handler = PlatformExceptionHandler.getInstance();
    // ✅ درستی: ?. کا استعمال کریں
    handler?.setHandler((error, stackTrace) {
      print('🚨 Platform Error: $error');
      print('📝 StackTrace: $stackTrace');
    });
  } catch (e) {
    print('⚠️ Platform exception handler not available: $e');
  }
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
    final adService = AdService(); // ✅ نیا: اشتہار سروس

    return MaterialApp(
      title: 'Aladdin AI App Factory',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
  fontFamily: 'Poppins', // ✅ یہاں Poppins استعمال کریں
  appBarTheme: const AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  ),
),
darkTheme: ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),
  fontFamily: 'Poppins', // ✅ یہاں بھی Poppins
  appBarTheme: const AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
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
            // ✅ درستی: صرف UploadScreen() کال کریں
            return UploadScreen();
          } else {
            // ✅ اگر Project argument نہیں ملا تو error handle کریں
            return _buildErrorScreen(
              context, 
              'Upload screen requires project data.\nPlease go back and try again.'
            );
          }
        },

        '/chat': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Project) {
            return ChatScreen(
              geminiService: geminiService,
              githubService: githubService,
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
              initialCampaign: args['initialCampaign'],
              adService: adService,
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
              adService: adService,
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

// ✅ Platform Exception Handler (اگر available ہو)
class PlatformExceptionHandler {
  static PlatformExceptionHandler? _instance;
  
  factory PlatformExceptionHandler() {
    _instance ??= PlatformExceptionHandler._internal();
    return _instance!;
  }
  
  PlatformExceptionHandler._internal();
  
  static PlatformExceptionHandler? getInstance() {
    return _instance;
  }
  
  void setHandler(Function(Object, StackTrace) handler) {
    // Platform-specific exception handling logic here
  }
}
