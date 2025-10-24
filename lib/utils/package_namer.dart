class PackageNamer {
  static String generatePackageName(String appName) {
    // اسپیشل کریکٹرز کو ہٹائیں اور lowercase کریں
    String cleanName = appName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .replaceAll('__', '_')
        .replaceAll(' ', '_');
    
    // اگر نام بہت لمبا ہو تو مختصر کریں
    if (cleanName.length > 30) {
      cleanName = cleanName.substring(0, 30);
    }
    
    // یونیک پیکیج نام بنائیں
    return 'com.${cleanName}.app${DateTime.now().millisecondsSinceEpoch}';
  }

  static String generateAppId() {
    return 'app_${DateTime.now().millisecondsSinceEpoch}';
  }

  static String validatePackageName(String packageName) {
    // پیکیج نام کی تصدیق کریں
    if (packageName.length < 6) {
      return 'پیکیج نام بہت چھوٹا ہے';
    }
    if (!packageName.startsWith('com.')) {
      return 'پیکیج نام com. سے شروع ہونا چاہیے';
    }
    if (packageName.contains(' ')) {
      return 'پیکیج نام میں سپیس نہیں ہونی چاہیے';
    }
    return 'صحیح ہے';
  }
}
