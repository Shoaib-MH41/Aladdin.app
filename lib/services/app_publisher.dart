import 'dart:convert';

class AppPublisher {
  // Automatic Play Store preparation
  Future<Map<String, dynamic>> prepareForPlayStore({
    required String appName,
    required String generatedCode,
    required String framework,
  }) async {
    String packageName = _generatePackageName(appName);
    
    return {
      'package_name': packageName,
      'version_code': '1.0.0',
      'version_name': '1.0.0',
      'permissions': _getRequiredPermissions(generatedCode),
      'store_listing': _generateStoreListing(appName),
      'privacy_policy': _generatePrivacyPolicy(appName, generatedCode),
      'app_icon': _generateAppIconSuggestions(appName),
      'screenshots': _generateScreenshotSuggestions(),
    };
  }

  String _generatePackageName(String appName) {
    String cleanName = appName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .replaceAll(' ', '');
    
    // Unique package name
    return 'com.$cleanName.app${DateTime.now().millisecondsSinceEpoch}';
  }

  List<String> _getRequiredPermissions(String code) {
    List<String> permissions = [];
    if (code.contains('internet') || code.contains('http')) permissions.add('INTERNET');
    if (code.contains('location') || code.contains('Location')) permissions.add('ACCESS_FINE_LOCATION');
    if (code.contains('camera') || code.contains('Camera')) permissions.add('CAMERA');
    if (code.contains('storage') || code.contains('Storage') || code.contains('File')) {
      permissions.addAll(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);
    }
    if (code.contains('microphone') || code.contains('Audio')) permissions.add('RECORD_AUDIO');
    return permissions;
  }

  Map<String, dynamic> _generateStoreListing(String appName) {
    return {
      'title': appName,
      'short_description': 'ایک زبردست $appName ایپ جو AI کی مدد سے بنائی گئی ہے',
      'full_description': '''
$appName ایک جدید اور مفید ایپ ہے جو روزمرہ کی زندگی کو آسان بناتی ہے۔

**خصوصیات:**
- جدید اور صارف دوست انٹرفیس
- تیز رفتار کارکردگی
- مکمل طور پر محفوظ
- مسلسل اپ ڈیٹس

**سپورٹ:**
کسی بھی مسئلے یا تجویز کے لیے ہم سے رابطہ کریں۔
''',
      'keywords': ['flutter', 'ai generated', 'productivity', 'mobile app'],
      'category': 'PRODUCTIVITY',
      'contact_email': 'support@example.com',
    };
  }

  String _generatePrivacyPolicy(String appName, String code) {
    List<String> permissions = _getRequiredPermissions(code);
    
    String dataCollectionSection = '';
    if (permissions.contains('INTERNET')) dataCollectionSection += '- انٹرنیٹ کنیکشن: نیٹ ورک کی سہولت کے لیے\n';
    if (permissions.contains('ACCESS_FINE_LOCATION')) dataCollectionSection += '- لوکیشن ڈیٹا: مقامی خدمات کے لیے\n';
    if (permissions.contains('CAMERA')) dataCollectionSection += '- کیمرا: تصاویر کے لیے\n';
    if (permissions.contains('READ_EXTERNAL_STORAGE')) dataCollectionSection += '- اسٹوریج: فائل مینجمنٹ کے لیے\n';

    return '''
**پرائیویسی پالیسی - $appName**

آخری اپ ڈیٹ: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

**1. ڈیٹا کالیکشن**
$appName درج ذیل ڈیٹا جمع کرتی ہے:
$dataCollectionSection

**2. ڈیٹا کا استعمال**
ہم آپ کا ڈیٹا صرف درج ذیل مقاصد کے لیے استعمال کرتے ہیں:
- ایپ کی فعالیت کو بہتر بنانے کے لیے
- صارف کا تجربہ بہتر کرنے کے لیے
- تکنیکی مسائل حل کرنے کے لیے

**3. ڈیٹا شیئرنگ**
ہم آپ کا ذاتی ڈیٹا کسی تیسرے فریق کے ساتھ شیئر نہیں کرتے۔

**4. ڈیٹا سیکیورٹی**
آپ کا ڈیٹا محفوظ طریقے سے محفوظ کیا جاتا ہے۔

**5. صارف کے حقوق**
آپ کسی بھی وقت اپنا ڈیٹا ڈیلیٹ کر سکتے ہیں۔

**6. رابطہ**
کسی بھی سوال کے لیے ہم سے رابطہ کریں: support@example.com
''';
  }

  List<String> _generateAppIconSuggestions(String appName) {
    return [
      'سادہ اور جدید ڈیزائن',
      'ایپ کے نام کے پہلے حرف کا استعمال',
      'متعلقہ آئیکن کا استعمال',
      'چمکدار رنگوں کا استعمال',
    ];
  }

  List<String> _generateScreenshotSuggestions() {
    return [
      'مین اسکرین کی تصویر',
      'کلیدی فیچرز کی تصاویر',
      'سیٹنگز اسکرین',
      'ڈارک موڈ کی تصاویر',
    ];
  }

  // APK build کے لیے commands
  String getBuildCommands(String projectName) {
    return '''
# Flutter APK بنانے کے commands:
flutter clean
flutter pub get
flutter build apk --release

# APK فائل اس جگہ ملے گی:
# build/app/outputs/flutter-apk/app-release.apk

# یا App Bundle کے لیے:
flutter build appbundle --release
''';
  }
}
