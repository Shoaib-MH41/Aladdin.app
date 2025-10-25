import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ میموری مینجمنٹ کے لیے

// سکرینز کے امپورٹس
import 'screens/pin_screen.dart'; // ✅ PIN Screen امپورٹ شامل کریں
import 'screens/home_screen.dart';
import 'screens/project_screen.dart';
import 'screens/selection_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/build_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/api_integration_screen.dart';
import 'screens/publish_guide_screen.dart';

// سروسز کے امپورٹس
import 'services/gemini_service.dart';
import 'services/github_service.dart';
import 'services/api_service.dart';

void main() {
  // ✅ پہلے Flutter انجن کو تیار کریں
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ میموری مینجمنٹ کو بہتر بنائیں
  _optimizePerformance();
  
  // ✅ ایپ کو چلائیں
  runApp(const AladdinApp());
}

// ✅ میموری اور performance کو بہتر بنانے کے لیے فنکشن
void _optimizePerformance() {
  // 1. میموری کلیئرنس کو فعال کریں
  SystemChannels.skia.invokeMethod('webGCTest');
  
  // 2. orientation کو لاک کریں (optional)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // 3. status bar کو transparent بنائیں
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
    // ✅ سروسز کو شروع کریں
    final geminiService = GeminiService();
    final githubService = GitHubService();
    final apiService = ApiService();

    return MaterialApp(
      title: 'Aladdin AI App Factory',
      debugShowCheckedModeBanner: false, // ✅ ڈیبگ بینر ہٹائیں
      
      // ✅ تھیم سیٹنگز
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
      
      // ✅ ابتدائی روٹ - PIN Screen سے شروع
      initialRoute: '/pin',
      
      // ✅ تمام روٹس
      routes: {
        // 🔒 PIN سکرین - نیا entry point
        '/pin': (context) => PinScreen(),

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
            return _buildErrorScreen('API انٹیگریشن کے لیے ڈیٹا نہیں ملا');
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

        // 🏪 پبلش گائیڈ سکرین
        '/publish-guide': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          
          if (arguments == null) {
            return _buildErrorScreen('پبلش گائیڈ کے لیے ڈیٹا نہیں ملا');
          }
          
          return PublishGuideScreen(
            appName: arguments['appName'] ?? 'میرا ایپ',
            generatedCode: arguments['generatedCode'] ?? '// کوئی کوڈ نہیں',
            framework: arguments['framework'] ?? 'Flutter',
          );
        },
      },

      // ❌ اگر کوئی روٹ نہیں ملا تو PIN پر جائے
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => PinScreen(),
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
              SizedBox(height: 20),
              Text(
                message,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: Text('ہوم پر واپس جائیں'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
