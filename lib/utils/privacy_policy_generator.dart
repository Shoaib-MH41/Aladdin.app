class PrivacyPolicyGenerator {
  static String generatePolicy(String appName, List<String> permissions) {
    String dataCollectionSection = _getDataCollectionText(permissions);
    String currentDate = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    
    return '''
**پرائیویسی پالیسی - $appName**

آخری اپ ڈیٹ: $currentDate

**1. تعارف**
$appName آپ کی پرائیویسی کا احترام کرتی ہے۔ یہ پرائیویسی پالیسی بتاتی ہے کہ ہم کس طرح ڈیٹا جمع کرتے، استعمال کرتے اور محفوظ کرتے ہیں۔

**2. ڈیٹا کالیکشن**
$appName درج ذیل ڈیٹا جمع کرتی ہے:
$dataCollectionSection

**3. ڈیٹا کا استعمال**
ہم آپ کا ڈیٹا صرف درج ذیل مقاصد کے لیے استعمال کرتے ہیں:
- ایپ کی فعالیت کو بہتر بنانے کے لیے
- صارف کا تجربہ بہتر کرنے کے لیے
- تکنیکی مسائل حل کرنے کے لیے
- سیکیورٹی کو یقینی بنانے کے لیے

**4. ڈیٹا شیئرنگ**
ہم آپ کا ذاتی ڈیٹا کسی تیسرے فریق کے ساتھ شیئر نہیں کرتے، سوائے اس کے کہ قانونی طور پر ضروری ہو۔

**5. ڈیٹا سیکیورٹی**
آپ کا ڈیٹا محفوظ طریقے سے محفوظ کیا جاتا ہے اور غیر مجاز رسائی سے محفوظ رکھا جاتا ہے۔

**6. صارف کے حقوق**
آپ کو درج ذیل حقوق حاصل ہیں:
- اپنا ڈیٹا دیکھنے کا حق
- ڈیٹا ڈیلیٹ کرنے کا حق
- پرائیویسی پالیسی کے بارے میں سوالات پوچھنے کا حق

**7. تبدیلیاں**
ہم پرائیویسی پالیسی میں تبدیلی کر سکتے ہیں۔ تبدیلی کی صورت میں ایپ میں اطلاع دی جائے گی۔

**8. رابطہ**
کسی بھی سوال، مشورے یا شکایت کے لیے ہم سے رابطہ کریں:
- ای میل: support@${appName.toLowerCase().replaceAll(' ', '')}.com
- ویب سائٹ: www.${appName.toLowerCase().replaceAll(' ', '')}.com

**9. منظوری**
ایپ استعمال کر کے آپ اس پرائیویسی پالیسی سے متفق ہیں۔
''';
  }

  static String _getDataCollectionText(List<String> permissions) {
    String text = '';
    
    if (permissions.contains('INTERNET')) {
      text += '- انٹرنیٹ کنیکشن: آن لائن سروسز اور ڈیٹا سینک کے لیے\n';
    }
    if (permissions.contains('ACCESS_FINE_LOCATION')) {
      text += '- لوکیشن ڈیٹا: مقامی خدمات اور نقشہ جات کے لیے\n';
    }
    if (permissions.contains('CAMERA')) {
      text += '- کیمرا: تصاویر کھینچنے اور سکین کرنے کے لیے\n';
    }
    if (permissions.contains('READ_EXTERNAL_STORAGE')) {
      text += '- اسٹوریج: فائلز کو پڑھنے اور محفوظ کرنے کے لیے\n';
    }
    if (permissions.contains('RECORD_AUDIO')) {
      text += '- مائیکروفون: آوڈیو ریکارڈنگ کے لیے\n';
    }
    
    if (text.isEmpty) {
      text = '- کوئی ذاتی ڈیٹا جمع نہیں کیا جاتا\n';
    }
    
    return text;
  }

  static String generateShortPolicy(String appName) {
    return '''
$appName آپ کی پرائیویسی کا احترام کرتی ہے۔ ہم کم سے کم ڈیٹا جمع کرتے ہیں اور اسے صرف ایپ کی فعالیت کے لیے استعمال کرتے ہیں۔
''';
  }
}
